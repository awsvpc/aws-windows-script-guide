$logContent = Get-Content $logFilePath -Raw

# Define regex pattern to match multiple error conditions
$errorPattern = "Terminating Error|An unexpected error occured on a send|is not authorized to perform.*because no identity-based policy allows"

# Check if any error matches the pattern
if ($logContent -match $errorPattern) {
    # Set EC2 instance tag
    $instanceId = GetEC2InstanceId
    if ($instanceId) {
        Write-Output "Setting deployStatus tag to 'Failed' for EC2 instance $instanceId."
        Set-EC2Tag -ResourceId $instanceId -Tag @{Key="deployStatus";Value="Failed"} -ErrorAction Stop
    } else {
        Write-Warning "Failed to retrieve EC2 instance ID from metadata."
    }
}
