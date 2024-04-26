$server = Read-Host "Please provide the server name"
$InstanceId = (Get-EC2Instance | ?{$_.Instances.tag.value -like $server}).Instances.InstanceId

$deviceids = (Get-EC2InstanceAttribute -InstanceId $InstanceId -Attribute blockDeviceMapping | Select -ExpandProperty BlockDeviceMappings).DeviceName
foreach($deviceid in $deviceids)
{
Edit-EC2InstanceAttribute -InstanceId $InstanceId -BlockDeviceMapping @{DeviceName=$deviceid;Ebs=@{DeleteOnTermination=$true}};
}
