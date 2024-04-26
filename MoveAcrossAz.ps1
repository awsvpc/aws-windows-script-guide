$servername = Read-Host "Please provide the EC2 instance name"
$region= Read-Host "Please provide the region in which server needs to be deployed(eg. us-east-1)"
$AZ = Read-Host "Please provide the AZ in which you want to move the instance(eg. us-east-1a)"

Set-AWSCredentials -AccessKey $env:AWS_ACCESS_KEY_ID -SecretKey $env:AWS_SECRET_ACCESS_KEY -SessionToken $env:AWS_SESSION_TOKEN -StoreAs Build
Initialize-AWSDefaultConfiguration -ProfileName Build -Region $region

$instanceid = (Get-EC2Instance | ?{$_.Instances.tag.value -like $ServerName}).Instances | Select -ExpandProperty InstanceId
$securitygroup = (Get-EC2Instance | ?{$_.Instances.tag.value -like $ServerName}).Instances.SecurityGroups.GroupId
$instancetype = (Get-EC2Instance | ?{$_.Instances.tag.value -like $ServerName}).Instances.InstanceType
$tags1 = Get-EC2Tag -Filter @{Name="resource-type";Values="instance"},@{Name="resource-id";Values= $InstanceId} | Select Key,Value
Stop-EC2Instance -InstanceId $instanceid
Start-Sleep -Seconds 120
$ami = New-EC2Image -InstanceId $instanceid -Name  $InstanceName -Description "Test"
$subnetid = Get-EC2Subnet | ?{$_.AvailabilityZone -eq $AZ } | Select -ExpandProperty SubnetId | Select -First 1

$KeyPair = New-EC2KeyPair -KeyName "Restore-key"
$KeyPair.KeyMaterial | Out-File -Encoding ascii "$env:USERPROFILE\Desktop\Restore-key.pem"

$newid = (New-EC2Instance -ImageId $ami -MinCount 1 -MaxCount 1 -SubnetId $subnetid -SecurityGroupId $securitygroup -DisableApiTermination $true -Monitoring $true -InstanceType $instancetype -KeyName "Restore-key").Instances.InstanceId

foreach($tags in $tags1)
{
New-EC2Tag -Resource $newid -Tag $tags
}
$IP = (Get-EC2Instance | ?{$_.Instances.InstanceId -eq $newid}).Instances | Select -ExpandProperty PrivateIpAddress

$password = Get-EC2PasswordData -InstanceId $newid -PemFile "$env:USERPROFILE\Desktop\Restore-key.pem"
$username  = "Administrator"
$pass = $password | ConvertTo-SecureString -AsPlainText -Force
$cred = New-Object System.Management.Automation.PsCredential($username,$pass)

Add-Computer -ComputerName $IP -DomainName "yourdomain.com" -NewName $servername -LocalCredential $cred -Restart -Force
