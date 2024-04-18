function StartService {
    # Function to start the service
    try {
        # Start the service
        Start-Service -Name "YourServiceName" -ErrorAction Stop
        Write-Output "Service started successfully."
    } catch {
        Write-Error "Failed to start the service: $_"
    }
}

function GetEC2InstanceId {
    # Function to get EC2 instance ID from metadata
    $InstanceId = (Invoke-RestMethod -Uri "http://169.254.169.254/latest/meta-data/instance-id" -ErrorAction SilentlyContinue)
    return $InstanceId
}

function Cleanup {
    # Function to perform cleanup based on execution.log contents
    $logFilePath = "C:\auto\execution.log"

    # Check if the log file exists
    if (Test-Path $logFilePath) {
        # Read the contents of the log file
        $logContent = Get-Content $logFilePath -Raw
        if ($logContent -match "TerminatingError") {
            # Set EC2 instance tag
            $instanceId = GetEC2InstanceId
            if ($instanceId) {
                Write-Output "Setting deployStatus tag to 'Failed' for EC2 instance $instanceId."
                Set-EC2Tag -ResourceId $instanceId -Tag @{Key="deployStatus";Value="Failed"} -ErrorAction Stop
            } else {
                Write-Warning "Failed to retrieve EC2 instance ID from metadata."
            }
        }
    } else {
        Write-Warning "Execution log file not found."
    }
}

# Main script
try {
    # Delete and recreate execution.log file
    $logFilePath = "C:\auto\execution.log"
    if (Test-Path $logFilePath) {
        Remove-Item $logFilePath -Force
        New-Item -Path $logFilePath -ItemType File | Out-Null
        Write-Output "Execution log file deleted and recreated."
    } else {
        New-Item -Path $logFilePath -ItemType File | Out-Null
        Write-Output "Execution log file created."
    }

    # Call StartService function
    StartService

    # Call GetEC2InstanceId function
    $instanceId = GetEC2InstanceId
    if ($instanceId) {
        Write-Output "EC2 instance ID: $instanceId"
    } else {
        Write-Warning "Failed to retrieve EC2 instance ID from metadata."
    }
} catch {
    Write-Error "An error occurred: $_"
} finally {
    # Call Cleanup function
    Cleanup
}
