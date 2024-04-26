###
###Set default error action and log file name
###If something fails, the script stops immediately
###We also create a log file, in case the script fails for some reason and you have to rebuild the AMI manually
###
$ErrorActionPreference = "Stop" 
$logFile = $PSScriptRoot + "\ChangeTenancyLog-" + $(get-date -f yyyyMMdd-HHmm) + ".txt"

###
###Import dependencies
###https://docs.aws.amazon.com/powershell/latest/userguide/pstools-getting-set-up-windows.html
###
Import-Module AWSPowerShell

###
###Configure credentials and Key to encrypt EBS volumes
###https://docs.aws.amazon.com/powershell/latest/userguide/shared-credentials-in-aws-powershell.html
###
$region = "us-east-1"
$ebsKey = "arn:aws:kms:us-east-1:xxxxxxxxxxxx:key/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
Clear-AWSCredential -Scope Script
Set-AWSCredential -ProfileName SantiagoTesting -Scope Script 
Set-DefaultAWSRegion -Region $region -Scope Script

###
###Only includes running Windows instances with dedicated tenancy
###Of course, you can change this criteria to better suit your needs
###(eg. you may choose only running instances, or all of the instances, not just the Windows, but make sure you choose the ones with 'dedicated' tenancy)
###
$instancesResponse = Get-EC2Instance
$instances = $instancesResponse.Instances | ? {$_.Platform -like "*Windows*" -and $_.Placement.Tenancy.Value -like "*dedicated*"}

###
###Traverse all of the instances
###Parallelism could be implemented here
###
foreach ($instance in $instances){
    
    ###
    ###Get most of the attributes of the instance to replicate them to the new Instance
    ###You might need to add aditional attributes, if your instances use them
    ###https://docs.aws.amazon.com/powershell/latest/reference/items/Get-EC2Instance.html
    ###https://docs.aws.amazon.com/powershell/latest/reference/items/New-EC2Instance.html
    ###
    $instanceId = $instance.InstanceId
    $instanceTags = $instance.Tags
    $instanceName = ($instanceTags | Where-Object -Property key -EQ 'Name').Value

    ###If the "Name" tag is not populated, we use the instanceId
    if (!$instanceName){
        $instanceName = $instanceId
    }

    $imageName = $instanceName + "_TEMP"
    $imageKeyName = $instanceName + "_TEMP" + "_KEY"
    $instanceSubnet = $instance.SubnetId
    $instanceType = $instance.InstanceType
    $instanceSG = $instance.SecurityGroups
    $instanceKeyPair = $instance.KeyName
    $instanceIP = $instance.PrivateIpAddress
    $instanceEBSOptimized = $instance.EbsOptimized
    $instanceIAMRole = $instance.IamInstanceProfile.Arn
    $instanceUserData = (Get-EC2InstanceAttribute -InstanceId $instanceId -Attribute userData).UserData
    $instanceMonitoring = $true
    if ($instance.Monitoring.State.Value -eq "disabled"){
        $instanceMonitoring = $false
    }

    ###
    ###Dump information to a file just in case something fails
    ###There might be a better way to do this!
    ###
    "-----------------" | Out-File $logFile -Append
    date | Out-File $logFile -Append
    "Instance Id" | Out-File $logFile -Append
    $instanceId | Out-File $logFile -Append
    "Tags" | Out-File $logFile -Append
    $instanceTags | Out-File $logFile -Append
    "Instance Name" | Out-File $logFile -Append
    $instanceName | Out-File $logFile -Append
    "Image Name" | Out-File $logFile -Append
    $imageName | Out-File $logFile -Append
    "Encrypted Image Name" | Out-File $logFile -Append
    $imageKeyName | Out-File $logFile -Append
    "Subnet" | Out-File $logFile -Append
    $instanceSubnet | Out-File $logFile -Append
    "Instance Type" | Out-File $logFile -Append
    $instanceType | Out-File $logFile -Append
    "Security Groups" | Out-File $logFile -Append
    $instanceSG | Out-File $logFile -Append
    "Key Pair" | Out-File $logFile -Append
    $instanceKeyPair | Out-File $logFile -Append
    "IP" | Out-File $logFile -Append
    $instanceIP | Out-File $logFile -Append
    "EBS Optimized" | Out-File $logFile -Append
    $instanceEBSOptimized | Out-File $logFile -Append
    "IAM Role" | Out-File $logFile -Append
    $instanceIAMRole | Out-File $logFile -Append
    "Monitoring" | Out-File $logFile -Append
    $instanceMonitoring | Out-File $logFile -Append
    "UserData" | Out-File $logFile -Append
    $instanceUserData | Out-File $logFile -Append
    "-----------------" | Out-File $logFile -Append
    Write-Host "Processing instance: " $instanceName

    ###
    ###Validate that the AMI doesn't exist
    ###
    if (Get-EC2Image -Filter @{ Name="name"; Values=$imageName }) {
        throw "AMI already exists, please delete it manually first" #Maybe give the option to delete it?
    }

    ###
    ###Validate that the re-encrypted AMI doesn't exist
    ###
    if (Get-EC2Image -Filter @{ Name="name"; Values=$imageKeyName }) {
        throw "Re-encrypted AMI already exists, please delete it manually first" #Maybe give the option to delete it?
    }

    ###
    ###Create AMI
    ###
    $AMIdescription = "Temporal AMI to change tenancy of instance: " + $instanceName
    $imageCreationResponse = New-EC2Image -InstanceId $instanceId -Name $imageName -Description $AMIdescription -Select "*"
    $amiId = $imageCreationResponse.ImageId

    ###
    ###Shutdown instance right after image creation
    ###
    Write-Host "Stopping EC2 instance..."
    Stop-EC2Instance -InstanceId $instanceId
    Write-Host "EC2 instance stopped correctly!"

    ###
    ###Wait for the image to be completed
    ###
    Write-Host "Waiting for the image to be completed..."
    $ami = Get-EC2Image -ImageId $amiId
    while ($ami.State.Value.Equals("pending")) {
        Start-Sleep -Seconds 10
        $ami = Get-EC2Image -ImageId $amiId
    }
    Write-Host "AMI is ready!"

    ###
    ###Copy the AMI to a new AMI with the proper encryption KEY
    ###
    $AMIdescription = "Temporal AMI of instance: " + $instanceName + " to encrypt it with the proper EBS KEY."
    $newImageCreationResponse = Copy-EC2Image -SourceImageId $amiId -SourceRegion $region -Description $AMIdescription -Name $imageKeyName -Encrypted $true -KmsKeyId $ebsKey -Select "*"
    $newAmiId = $newImageCreationResponse.ImageId

    ###
    ###Wait for the re-encrypted image to be completed
    ###
    Write-Host "Waiting for the re-encrypted image to be completed..."
    $newAmi = Get-EC2Image -ImageId $newAmiId
    while ($newAmi.State.Value.Equals("pending")) {
        Start-Sleep -Seconds 10
        $newAmi = Get-EC2Image -ImageId $newAmiId
    }
    Write-Host "Re-Encrypted AMI is ready!"

    ###
    ###Get all tags and create the tag specification
    ###
    $tagSpecification = [Amazon.EC2.Model.TagSpecification]::new()
    $tagSpecification.ResourceType = 'Instance'
    $instanceTags | ? {$_.Key -notlike "aws:*"} | ForEach-Object { #Tags starting with aws:* are reserved and cannot be assigned.
        $tag = [Amazon.EC2.Model.Tag]@{
            Key   = $_.Key
            Value = $_.Value
        }
        $tagSpecification.Tags.Add($tag)
    }

    ###
    ###Terminate old instance, so we can reuse the IP Addresses
    ###
    Write-Host "Terminating original instance..."
    Remove-EC2Instance -InstanceId $instanceId -Force
    $removedInstanceState = (Get-EC2Instance -InstanceId $instanceId).Instances.State.Name
    while (!$removedInstanceState.Equals("terminated")) {
        Start-Sleep -Seconds 10
        $removedInstanceState = (Get-EC2Instance -InstanceId $instanceId).Instances.State.Name
    }
    Write-Host "Original instance terminated!"
    
    ###
    ###Deploy new Instance with all of the copied attributes
    ###
    Write-Host "Deploying new instance..."
    $instanceCreationResponse = New-EC2Instance -ImageId $newAmiId -Placement_Tenancy default -SubnetId $instanceSubnet -InstanceType $instanceType -SecurityGroupIds $instanceSG.GroupId -KeyName $instanceKeyPair `
            -EbsOptimized $instanceEBSOptimized -TagSpecification $tagSpecification -Monitoring $instanceMonitoring -IamInstanceProfile_Arn $instanceIAMRole -PrivateIpAddress $instanceIP -UserData $instanceUserData
    Write-Host "Instance created!"

}
