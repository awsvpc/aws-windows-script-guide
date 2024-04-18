# Check if AWS CLI is installed and working
try {
    $process = Start-Process -FilePath "aws" -ArgumentList "--version" -NoNewWindow -Wait -PassThru
    $exitCode = $process.ExitCode

    if ($exitCode -eq 0) {
        Write-Output "AWS CLI is installed and working: $($process.StandardOutput)"
    } else {
        throw "AWS CLI not found or encountered an error."
    }
} catch {
    Write-Error "Failed to check AWS CLI: $_"
    exit 1  # Exit with error code
}
