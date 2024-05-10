# Define URLs and file paths
$forwarderDownloadUrl = "http://mylocaldomain.com/binaries/splunkapp.msi"
$forwarderInstallerPath = "C:\Temp\splunkapp.msi"

# Function to check Splunk forwarder version
function Get-SplunkForwarderVersion {
    $version = (Get-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\Splunk\UniversalForwarder\CurrentVersion").Version
    return $version
}

# Function to check Splunk forwarder service status
function Get-SplunkForwarderServiceStatus {
    $serviceStatus = Get-Service -Name "splunkd" -ErrorAction SilentlyContinue
    if ($serviceStatus -eq $null) {
        return "NotInstalled"
    }
    return $serviceStatus.Status
}

# Function to upgrade Splunk forwarder
function Upgrade-SplunkForwarder {
    Write-Host "Downloading Splunk forwarder..."
    Invoke-WebRequest -Uri $forwarderDownloadUrl -OutFile $forwarderInstallerPath

    Write-Host "Upgrading Splunk forwarder..."
    $exitCode = Start-Process msiexec.exe -ArgumentList "/i `"$forwarderInstallerPath`" /qn" -Wait -PassThru | Select-Object -ExpandProperty ExitCode
    return $exitCode
}

# Function to start Splunk forwarder service
function Start-SplunkForwarderService {
    Write-Host "Starting Splunk forwarder service..."
    Start-Service -Name "splunkd"
}

# Main script
$currentVersion = Get-SplunkForwarderVersion
$serviceStatus = Get-SplunkForwarderServiceStatus

if ($currentVersion -ge "9.2.1" -and $serviceStatus -eq "Running") {
    Write-Host "Splunk forwarder already up to date. Exit code 0"
} else {
    $upgradeExitCode = Upgrade-SplunkForwarder

    if ($upgradeExitCode -eq 0) {
        Write-Host "Splunk forwarder updated. Exit code 0"
    } else {
        Write-Host "Failed to install Splunk forwarder. Exit code 1"
    }

    # Start Splunk forwarder service if not running
    if ($serviceStatus -ne "Running") {
        Start-SplunkForwarderService
        Start-Sleep -Seconds 10  # Wait for service to start
        $timeout = 300  # 5 minutes timeout
        $elapsedTime = 0

        # Check service status every 10 seconds until timeout
        while (($serviceStatus = Get-SplunkForwarderServiceStatus) -ne "Running" -and $elapsedTime -lt $timeout) {
            Start-Sleep -Seconds 10
            $elapsedTime += 10
        }

        if ($serviceStatus -eq "Running") {
            Write-Host "Splunk forwarder service started successfully."
        } else {
            Write-Host "Failed to start Splunk forwarder service within timeout. Exiting..."
            exit 1
        }
    }
}
