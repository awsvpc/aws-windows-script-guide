# Define the ProfileImagePath
$ProfileImagePath = "%SystemRoot%\ServiceProfiles\SplunkFowarders"

# Get the SID for the given ProfileImagePath
$SID = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\*" | Where-Object { $_.ProfileImagePath -eq $ProfileImagePath }).SID

if ($SID) {
    # Create the registry key
    New-Item -Path "HKU\$SID\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Force | Out-Null

    # Set the registry value to 1
    Set-ItemProperty -Path "HKU\$SID\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "TestValue" -Value 1
}
else {
    Write-Host "SID not found for ProfileImagePath: $ProfileImagePath" -ForegroundColor Red
}


>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Function to get SID from ProfileImagePath
function Get-SIDFromProfileImagePath {
    param(
        [string]$ProfileImagePath
    )

    # Get SID from ProfileList registry key
    $ProfileList = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\*" | Where-Object { $_.ProfileImagePath -eq $ProfileImagePath }

    if ($ProfileList) {
        $ProfileList.SID
    }
    else {
        Write-Host "SID not found for ProfileImagePath: $ProfileImagePath" -ForegroundColor Red
    }
}

# Function to create registry key
function Create-ExplorerPolicyRegistryKey {
    param(
        [string]$SID
    )

    $ExplorerPolicyPath = "HKU\$SID\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
    
    # Create registry key
    New-Item -Path $ExplorerPolicyPath -Force | Out-Null
    
    # Set registry value to 1
    Set-ItemProperty -Path $ExplorerPolicyPath -Name "TestValue" -Value 1
}

# ProfileImagePath
$ProfileImagePath = "%SystemRoot%\ServiceProfiles\SplunkFowarders"

# Get SID from ProfileImagePath
$SID = Get-SIDFromProfileImagePath $ProfileImagePath

if ($SID) {
    # Create registry key for Explorer policy
    Create-ExplorerPolicyRegistryKey $SID
}
