# Define service name
$serviceName = "splunkforwarder"

# Get the service
$service = Get-Service -Name $serviceName

# Check if service exists
if ($service) {
    # Check if service startup type is not Automatic
    if ($service.StartType -ne 'Automatic') {
        # Set service startup type to Automatic
        Set-Service -Name $serviceName -StartupType Automatic
        Write-Output "Service startup type set to Automatic."
    }
    
    # Check if service is not running
    if ($service.Status -ne 'Running') {
        # Start the service
        Start-Service -Name $serviceName
        Write-Output "Service started."

        # Wait until service starts
        do {
            Start-Sleep -Seconds 5  # Wait for 5 seconds
            $service.Refresh()      # Refresh service status
        } while ($service.Status -ne 'Running')
        
        Write-Output "Service is now running."
    } else {
        # Restart the service
        Restart-Service -Name $serviceName
        Write-Output "Service restarted."
    }
} else {
    Write-Output "Service '$serviceName' not found."
}
