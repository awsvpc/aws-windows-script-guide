$region = Read-Host "Please provide the aws region"

Set-AWSCredentials -AccessKey $env:AWS_ACCESS_KEY_ID -SecretKey $env:AWS_SECRET_ACCESS_KEY -SessionToken $env:AWS_SESSION_TOKEN -StoreAs Build
Initialize-AWSDefaultConfiguration -ProfileName Build -Region $region

$instanceids = (Get-EC2Instance).Instances | Select -ExpandProperty InstanceId

foreach($instanceid in $instanceids)
{
$volumeids = Get-EC2Volume | Where-Object { $_.attachments.InstanceId -eq $instanceid }

foreach($volumeid in $volumeids)
{
if($volumeid.VolumeType -eq 'gp2')
{
if ($volumeid.Iops -gt 3000) {
                $ThisIops = $volumeid.Iops
            }
            else {
                $ThisIops = 3000
            }
Edit-EC2Volume -VolumeId $volumeid.VolumeId -VolumeType gp3 -Iops $ThisIops
}
}
}
