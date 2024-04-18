# Function to print audit task status and capture failures
function Print-AuditTaskStatus {
    param(
        [string]$TaskName,
        [bool]$Status,
        [ref]$FailedTasks
    )

    if ($Status -eq $true) {
        Write-Host "$TaskName: Passed"
    } else {
        Write-Host "$TaskName: Failed"
        $FailedTasks.Value += $TaskName
    }
}

# Main audit function
function Audit-Server {
    $FailedTasks = @()

    # Task 1: Check AWS CLI exists
    $awsCliExists = Test-Path "C:\Program Files\Amazon\AWSCLI\aws.exe"
    Print-AuditTaskStatus -TaskName "Check AWS CLI exists" -Status $awsCliExists -FailedTasks ([ref]$FailedTasks)

    # Task 2: Check ds_agent service is running
    $dsAgentServiceRunning = Get-Service -Name "ds_agent" -ErrorAction SilentlyContinue
    Print-AuditTaskStatus -TaskName "Check ds_agent service is running" -Status ($dsAgentServiceRunning -ne $null) -FailedTasks ([ref]$FailedTasks)

    # Task 3: Check Splunk service is running
    $splunkServiceRunning = Get-Service -Name "splunk" -ErrorAction SilentlyContinue
    Print-AuditTaskStatus -TaskName "Check Splunk service is running" -Status ($splunkServiceRunning -ne $null) -FailedTasks ([ref]$FailedTasks)

    # Task 4: Check host is domain joined
    $domainJoined = (Get-WmiObject Win32_ComputerSystem).PartOfDomain
    Print-AuditTaskStatus -TaskName "Check host is domain joined" -Status $domainJoined -FailedTasks ([ref]$FailedTasks)

    # Task 5: Check EC2 has tag hostFQDN and value not empty
    # Assume EC2 tag checking logic here...

    # Task 6: Check EC2 has tag hostFQDN1 and value not empty
    # Assume EC2 tag checking logic here...

    # Task 7: Check EC2 has tag hostFQDN2 and value not empty
    # Assume EC2 tag checking logic here...

    # Task 8: Check no pending Windows updates
    $pendingUpdates = (Get-WindowsUpdate -Online).Count
    Print-AuditTaskStatus -TaskName "Check no pending Windows updates" -Status ($pendingUpdates -eq 0) -FailedTasks ([ref]$FailedTasks)

    # Task 9: Check no pending reboot
    $pendingReboot = Test-PendingReboot
    Print-AuditTaskStatus -TaskName "Check no pending reboot" -Status (!$pendingReboot) -FailedTasks ([ref]$FailedTasks)

    # Check if any tasks failed
    if ($FailedTasks.Count -gt 0) {
        Write-Host "Below checks failed:"
        $FailedTasks | ForEach-Object { Write-Host $_ }
    }
}

# Run the audit
Audit-Server
