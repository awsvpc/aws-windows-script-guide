# Define the service name
$serviceName = "lanmanworkstation"
$timeout = 300  # 5 minutes in seconds
$interval = 5   # Check every 5 seconds
$elapsed = 0

# Loop until the service status is Running or timeout
while ($elapsed -lt $timeout) {
    $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
    if ($service.Status -eq 'Running') {
        Write-Output "$serviceName is now running."
        break
    } else {
        Write-Output "Waiting for $serviceName to start..."
        Start-Sleep -Seconds $interval
        $elapsed += $interval
    }
}

# Check if the loop ended due to timeout
if ($elapsed -ge $timeout) {
    Write-Output "Timed out waiting for $serviceName to start."
}

>>>>>>>>>>>>>>>>>>>>>>>>>

# Define the service name
$serviceName = "lanmanworkstation"

# Function to check if the service is running
function Check-ServiceStatus {
    param (
        [string]$name
    )
    $service = Get-Service -Name $name -ErrorAction SilentlyContinue
    if ($service) {
        return $service.Status
    } else {
        throw "Service $name not found"
    }
}

# Loop until the service status is Running
while ($true) {
    try {
        $status = Check-ServiceStatus -name $serviceName
        Write-Output "Current status of $serviceName: $status"
        if ($status -eq 'Running') {
            Write-Output "$serviceName is now running."
            break
        } else {
            Write-Output "Waiting for $serviceName to start..."
            Start-Sleep -Seconds 5  # Wait for 5 seconds before checking again
        }
    } catch {
        Write-Error $_.Exception.Message
        Start-Sleep -Seconds 5  # Wait for 5 seconds before checking again in case of error
    }
}
