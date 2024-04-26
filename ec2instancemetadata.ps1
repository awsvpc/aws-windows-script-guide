$Results = @()
$details = Invoke-WebRequest -UseBasicParsing 'http://169.254.169.254/latest/dynamic/instance-identity/document' |ConvertFrom-Json

$INTERFACE = (Invoke-WebRequest -UseBasicParsing -Uri http://169.254.169.254/latest/meta-data/network/interfaces/macs/)
$SubnetId = (Invoke-WebRequest -UseBasicParsing -Uri http://169.254.169.254/latest/meta-data/network/interfaces/macs/$INTERFACE/subnet-id).content
$VPCId = (Invoke-WebRequest -UseBasicParsing -Uri http://169.254.169.254/latest/meta-data/network/interfaces/macs/$INTERFACE/vpc-id).content
$secuirtygroups = (Invoke-WebRequest -UseBasicParsing 'http://169.254.169.254/latest/meta-data/security-groups').content

$Properties = @{
'Account Number' = $details.accountId
InstanceId = $details.instanceId
AMIId = $details.imageId
VPCId = $VPCId
SubnetId = $SubnetId
InstanceType = $details.instanceType
AvailabilityZone = $details.availabilityZone
Region = $details.region
SecurityGroups = $secuirtygroups -join ','
}

$Results += New-Object psobject -Property $Properties
$Results | Export-Csv c:\windows\temp\EC2Details.csv -NoTypeInformation
