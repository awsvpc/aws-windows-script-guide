# URL of the webpage containing the latest version
$url = "https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html"

# Retrieve the HTML content of the webpage
$html = Invoke-WebRequest -Uri $url

# Extract the latest version number
$matches = [regex]::Matches($html.Content, 'putty-64bit-(\d+\.\d+)-installer\.msi')

if ($matches.Count -gt 0) {
    $latestVersion = $matches[0].Groups[1].Value
    Write-Host "Latest version available: $latestVersion"
} else {
    Write-Host "Valid version not found. Skipping."
}
#e.g. putty-64bit-0.80-installer.msi
