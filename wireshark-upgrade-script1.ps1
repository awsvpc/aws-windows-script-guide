# Specify the minimum required version
$minimumVersion = "3.4.0"

# Function to check Wireshark version
function Get-WiresharkVersion {
    $wiresharkExePath = "C:\Program Files\Wireshark\wireshark.exe"
    if (Test-Path $wiresharkExePath) {
        $fileVersion = (Get-Item $wiresharkExePath).VersionInfo.FileVersion
        return $fileVersion
    } else {
        return $null
    }
}

# Function to download and install Wireshark
function Install-Wireshark {
    $url = "https://www.wireshark.org/download/win64/all-versions/Wireshark-win64-$($latestVersion).exe"
    $outputPath = "$env:TEMP\wireshark_setup.exe"
    Invoke-WebRequest -Uri $url -OutFile $outputPath
    Start-Process -FilePath $outputPath -ArgumentList "/S" -Wait
    Remove-Item $outputPath
}

# Check if Wireshark is installed
$installedVersion = Get-WiresharkVersion

if ($installedVersion -and $installedVersion -lt $minimumVersion) {
    Write-Host "Current Wireshark version ($installedVersion) is below the minimum required version ($minimumVersion). Upgrading..."
    Install-Wireshark
} elseif (-not $installedVersion) {
    Write-Host "Wireshark is not installed."
} else {
    Write-Host "Wireshark is already up-to-date."
}
