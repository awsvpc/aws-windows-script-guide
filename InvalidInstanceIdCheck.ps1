# Check if AWS CLI is installed and working
try {
    # Query EC2 instance metadata
    $instanceId = (Invoke-RestMethod -Uri "http://169.254.169.254/latest/meta-data/instance-id" -ErrorAction Stop)
    Write-Output "EC2 instance ID: $instanceId"

    # Check if AWS CLI is installed and working
    $awsCliOutput = aws --version
    if ($LASTEXITCODE -eq 0) {
        Write-Output "AWS CLI is installed and working: $awsCliOutput"
    } else {
        throw "AWS CLI not found or encountered an error."
    }
} catch {
    Write-Error "Failed to query EC2 metadata or check AWS CLI: $_"
    exit 1  # Exit with error code
}
