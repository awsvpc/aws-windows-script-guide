# Function to extract stable release version and download URL
function Get-WiresharkStableRelease {
    $url = "https://www.wireshark.org/download.html"
    $webRequest = Invoke-WebRequest -Uri $url -UseBasicParsing
    $content = $webRequest.Content

    # Regex pattern to match stable release version
    $versionPattern = "(?<=Stable Release:\s*)\d+\.\d+\.\d+"
    $versionMatch = [regex]::Match($content, $versionPattern)

    if ($versionMatch.Success) {
        $version = $versionMatch.Value
        $downloadUrl = "https://2.na.dl.wireshark.org/win64/Wireshark-$version-x64.exe"
        Write-Output "Stable Release Version: $version"
        Write-Output "Download URL: $downloadUrl"
    }
    else {
        Write-Output "Version could not be determined."
    }
}

# Call the function
Get-WiresharkStableRelease
