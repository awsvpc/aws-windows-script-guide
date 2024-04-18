function Are-AllVolumesEncrypted {
    param(
        [string]$InstanceId
    )

    # Get all EBS volumes attached to the specified instance
    $volumes = Get-EC2Volume -Filter @{ Name = "attachment.instance-id"; Values = $InstanceId }

    # Check if any volume is not encrypted
    foreach ($volume in $volumes) {
        if (-not $volume.Encrypted) {
            return $false
        }
    }

    return $true
}

# Example usage:
$instanceId = Read-Host -Prompt "Enter instance ID"
$result = Are-AllVolumesEncrypted -InstanceId $instanceId

if ($result) {
    Write-Host "All volumes attached to instance $instanceId are encrypted."
} else {
    Write-Host "Not all volumes attached to instance $instanceId are encrypted."
}
