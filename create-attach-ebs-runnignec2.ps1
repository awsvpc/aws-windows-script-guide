param(            
        [parameter(mandatory=$true,HelpMessage="Please enter EC2 Instance Name")][string] $InstanceName,            
        [parameter(mandatory=$true)][int] $VolumeSize,            
        [parameter(mandatory=$false)][string] $Device,            
        [parameter(mandatory=$true)][string] $VolumeType            
      )            
         $Filter = New-Object Amazon.EC2.Model.Filter            
         $Filter.Name = 'tag:Name'            
         $Filter.Value = "$InstanceName"            
         $Reservation = Get-EC2Instance -Filter $Filter | Select-Object -ExpandProperty instances            
         $InstanceId = $Reservation.InstanceId            
         $AZ = $Reservation.Placement.AvailabilityZone            
         $Device = Get-Device -InstanceId $InstanceId            
         $Volume = New-EC2Volume -Size $VolumeSize -VolumeType $VolumeType -AvailabilityZone $AZ -Encrypted $false            
         Write-Host ""               
         Write-Host "Creating Volume of Size: $VolumeSize GB, Volume Type: $VolumeType" -ForegroundColor Green            
         while ($Volume.status -ne 'available') {            
            $Volume = Get-EC2Volume -VolumeId $Volume.volumeid            
            Start-Sleep -Seconds 15            
            }            
         #Add additional volume to instance            
         Write-Host ""              
         Write-Host "Attaching Volume to $InstanceName..." -ForegroundColor Green            
         Add-EC2Volume -VolumeId $Volume.volumeid -InstanceId $InstanceId -Device $Device | Out-Null            
         #Tag new volume with instance name            
         $Tag = New-Object Amazon.EC2.Model.Tag            
         $Tag.key = 'Name'            
         $Tag.Value = $InstanceName            
         New-EC2Tag -Resource $Volume.VolumeId -Tag $Tag            
         While ($Volume.status -ne 'in-use') {            
            $Volume = Get-EC2Volume -VolumeId $Volume.volumeid            
            Start-Sleep -Seconds 10            
            }            
        (Get-EC2Volume -VolumeId $Volume.VolumeId).Attachments[0]            
        Initialize-EC2Disk -InstanceId $InstanceId
