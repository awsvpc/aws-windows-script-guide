# Function to check if required commands are available
function Check-Commands {
    if (-not (Get-Command aws -ErrorAction SilentlyContinue)) {
        Write-Error "AWS CLI could not be found. Please install it to continue."
        exit 1
    }
}

# Function to send SSM command to instances
function Send-SSMCommand {
    param (
        [string[]]$InstanceIds
    )

    $instanceIdsString = $InstanceIds -join ","

    $commandId = (aws ssm send-command `
        --instance-ids $instanceIdsString `
        --document-name "AWS-RunShellScript" `
        --comment "Your command description" `
        --parameters '{"commands":["echo Hello World"]}' `
        --query "Command.CommandId" `
        --output text).Trim()

    Write-Output "Command sent. Command ID: $commandId"
    return $commandId
}

# Function to wait for the command to complete
function Wait-ForCommandCompletion {
    param (
        [string]$CommandId
    )

    while ($true) {
        $status = (aws ssm list-command-invocations `
            --command-id $CommandId `
            --query "CommandInvocations[*].Status" `
            --output text).Trim()

        if ($status -in @("Success", "Failed", "Cancelled")) {
            break
        }

        Write-Output "Waiting for command to complete..."
        Start-Sleep -Seconds 5
    }

    Write-Output "Command $CommandId completed with status: $status"
}

# Function to print command output for each instance
function Print-CommandOutput {
    param (
        [string]$CommandId,
        [string[]]$InstanceIds
    )

    foreach ($instanceId in $InstanceIds) {
        $output = (aws ssm get-command-invocation `
            --command-id $CommandId `
            --instance-id $instanceId `
            --query 'StandardOutputContent' `
            --output text).Trim()

        Write-Output "Instance ID: $instanceId"
        Write-Output "Output: $output"
    }
}

# Main script execution starts here

# Check if AWS CLI is installed
Check-Commands

# Read the list of instance IDs from input
$instanceIds = Read-Host "Enter the instance IDs separated by space" -split ' '

# Send SSM command
$commandId = Send-SSMCommand -InstanceIds $instanceIds

# Wait for the command to complete
Wait-ForCommandCompletion -CommandId $commandId

# Print the command status and output per instance ID
Print-CommandOutput -CommandId $commandId -InstanceIds $instanceIds
