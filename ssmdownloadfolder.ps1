# Get the path to the current script's folder
$currentFolder = "c:\myfolder\somefoldername"

# Get the parent folder of the current folder
$parentFolder = Split-Path -Path $currentFolder -Parent

# Construct the path to the downloads folder
$downloadsFolder = Join-Path -Path $parentFolder -ChildPath "downloads"

# Change directory to the downloads folder
Set-Location -Path $downloadsFolder

# Path to the playbook.ps1 script in the downloads folder
$playbookPath = Join-Path -Path $downloadsFolder -ChildPath "playbook.ps1"

# Check if playbook.ps1 exists in the downloads folder
if (-not (Test-Path $playbookPath)) {
    Write-Error "playbook.ps1 not found at $playbookPath"
    exit 1
}

try {
    # Run playbook.ps1 with execution policy bypassed
    Invoke-Expression -Command "powershell -ExecutionPolicy Bypass -File $playbookPath"
    # Check if the last command was successful
    if ($LastExitCode -ne 0) {
        # If playbook.ps1 returned an error, exit with code 1
        exit 1
    }
} catch {
    # If an exception occurred, exit with code 1
    exit 1
}
