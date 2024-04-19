# Path to the playbook.ps1 script
$playbookPath = "C:\Path\To\playbook.ps1"

# Check if playbook.ps1 exists
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
