$serviceName = "YourServiceName"
$retryCount = 2

for ($retry = 0; $retry -le $retryCount; $retry++) {
    try {
        # Attempt to start the service
        Start-Service -Name $serviceName -ErrorAction Stop
        Write-Output "Service '$serviceName' started successfully."
        break  # Break the loop if service starts successfully
    }
    catch {
        if ($retry -lt $retryCount) {
            Write-Output "Failed to start service. Retrying..."
            Start-Sleep -Seconds 5  # Wait before retrying
        }
        else {
            Write-Output "Failed to start service after $retryCount retries."
            Write-Output "Error: $_"
            # Handle any further actions or logging here
        }
    }
}
