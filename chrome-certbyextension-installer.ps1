<#
.Synopsis
   Installs Cerby Extensions to Chrome
.DESCRIPTION
   Silent setup for Cerby extensions for Windows deployment. This script is designed to be executed through an endpoint management system for Windows devices for
   a seamless Cerby extension installation, it can also run locally executed manually on Windows endpoints. This script won't install the extensions if browsers 
   are not previously installed.
#>
Add-Type -AssemblyName System.IO.Compression.FileSystem

function installChromeExtension($extensionId) {

    if (!($extensionId)) {
        # Empty Extension
        $result = "No Extension ID"
    }
    else {
        Write-Information "ExtensionID = $extensionID"
        $extensionIdAndUpdateUrl = "$extensionId;https://clients2.google.com/service/update2/crx"
        $regKey = "HKLM:\SOFTWARE\Policies\Google\Chrome\ExtensionInstallForcelist"
        if (!(Test-Path $regKey)) {
            New-Item $regKey -Force
            Write-Information "Created Reg Key $regKey"
        }
        # Add Extension to Chrome
        $extensionsList = New-Object System.Collections.ArrayList
        $number = 0
        $noMore = 0
        do {
            $number++
            Write-Information "Pass : $number"
            try {
                $install = Get-ItemProperty $regKey -name $number -ErrorAction Stop
                $extensionObj = [PSCustomObject]@{
                    Name  = $number
                    Value = $install.$number
                }
                $extensionsList.add($extensionObj) | Out-Null
                Write-Information "Extension List Item : $($extensionObj.name) / $($extensionObj.value)"
            }
            catch {
                $noMore = 1
            }
        }
        until($noMore -eq 1)
        $extensionCheck = $extensionsList | Where-Object { $_.Value -eq $extensionIdAndUpdateUrl }
        if ($extensionCheck) {
            $result = "Extension Already Exists"
            Write-Information "Extension Already Exists"
        }
        else {
            $newExtensionId = $extensionsList[-1].name + 1
            New-ItemProperty HKLM:\SOFTWARE\Policies\Google\Chrome\ExtensionInstallForcelist -PropertyType String -Name $newExtensionId -Value $extensionIdAndUpdateUrl
            $result = "Installed"
        }

        # Set the default workspace
        $policiesKey = "HKLM:\SOFTWARE\Policies\Google\Chrome\3rdparty\extensions\$extensionID\policy"
        if (!(Test-Path $policiesKey)) {
            New-Item $policiesKey -Force
            Write-Information "Created Reg Key $policiesKey"
            New-ItemProperty $policiesKey -PropertyType String -Name "DEFAULT_WORKSPACE" -Value "fox"
            Write-Information "added value fox to $policiesKey"
        } else {
            Set-ItemProperty -Path $policiesKey -Name "DEFAULT_WORKSPACE" -Value "fox"
            Write-Information "added value fox to $policiesKey"
        }

    }
}

$extensionChromeGeneralId = "clccplmaaeihbagbefjinmclielobnkb"

installChromeExtension($extensionChromeGeneralId);

# From here to the bottom can be ignored if the preseeded extension was never installed
function uninstallChromeExtension($extensionId) {

    if (!($extensionId)) {
        # Empty Extension
        $result = "No Extension ID"
        return $result
    }
    else {
        $extensionId = "$extensionId;https://clients2.google.com/service/update2/crx"
        # Construct the policy value without the extension ID
        $regKey = "HKLM:\SOFTWARE\Policies\Google\Chrome\ExtensionInstallForcelist"
        if (!(Test-Path $regKey)) {
            Write-Host "No Chrome\ExtensionForceInstall key"
            return
        }

        $extensionsInstalled = Get-ItemProperty $regKey
        Write-Host "$extensionsInstalled"

        # Add Extension to Chrome
        $extensionsList = New-Object System.Collections.ArrayList
        $number = 0
        $noMore = 0
        do {
            $number++
            Write-Information "Pass : $number"
            try {
                $extensionInstalled = Get-ItemProperty $regKey -name $number -ErrorAction Stop
                $extensionObj = [PSCustomObject]@{
                    Name  = $number
                    Value = $extensionInstalled.$number
                }
                $extension = $($extensionObj.value)
                $isExtensionToRemove =  $extension -eq "$extensionId"
                if(($isExtensionToRemove)) {
                    $extensionsList.add($extensionObj) | Out-Null
                }
            }
            catch {
                $noMore = 1
            }
        }
        until($noMore -eq 1)
        $PolicyPath = "HKLM:\SOFTWARE\Policies\Google\Chrome\ExtensionInstallForcelist"

        forEach($extension in $extensionsList){
            Write-Host "Extension to be removed $extension"
            Remove-ItemProperty -Path $PolicyPath -Name $($extension.name) -ErrorAction SilentlyContinue
        }

        Write-Host "Extension $extensionId removed from ExtensionInstallForcelist policy."
    }
}

uninstallChromeExtension("kdnlfgaekagegbmbcmeddbhjaehmdgjj"); 
