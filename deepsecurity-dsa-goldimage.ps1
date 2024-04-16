## Artcile - 1000480 
https://success.trendmicro.com/dcx/s/solution/1099480-creating-a-deep-security-agent-dsa-gold-image-for-re-provisioning?language=en_US&sfdcIFrameOrigin=null

## Script to stop the service
# Stop the service ds_agent and wait until stopped
Stop-Service -Name "ds_agent" -Force
while ((Get-Service -Name "ds_agent").Status -ne "Stopped") {
    Start-Sleep -Seconds 1
}

# Remove files in the folder *.db, *.crt if they exist in c:\Programdata\Trend Micro\Deep Security Agent\dsa_core
$folderPath = "C:\Programdata\Trend Micro\Deep Security Agent\dsa_core"
$filePatterns = @("*.db", "*.crt")
foreach ($pattern in $filePatterns) {
    $files = Get-ChildItem -Path $folderPath -Filter $pattern -ErrorAction SilentlyContinue
    if ($files) {
        Remove-Item -Path $files.FullName -Force
    }
}

# Set the service startup type to Manual
Set-Service -Name "ds_agent" -StartupType Manual


## Script to start the service
# Check if the service ds_agent exists and its startup type is Manual
if (Get-Service -Name "ds_agent" -ErrorAction SilentlyContinue) {
    $service = Get-Service -Name "ds_agent"
    if ($service.StartType -eq "Manual") {
        # Set service startup type to Automatic
        Set-Service -Name "ds_agent" -StartupType Automatic

        # Start the service and wait for it to start
        Start-Service -Name "ds_agent"
        while ($service.Status -ne "Running") {
            Start-Sleep -Seconds 1
            $service.Refresh()
        }
        Write-Host "Service ds_agent started successfully."
    } else {
        Write-Host "Service ds_agent is not set to Manual startup type."
    }
} else {
    Write-Host "Service ds_agent does not exist."
}

