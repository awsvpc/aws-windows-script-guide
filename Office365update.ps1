"%CommonProgramFiles%\Microsoft Shared\ClickToRun\OfficeC2RClient.exe" /update user updatepromptuser=false Forceappshutdown=true displaylevel=true

if((Get-WMIObject win32_operatingsystem).name -match 'Microsoft Windows 10'){
    if((Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\O365ProPlusRetail - en-us" -Name DisplayVersion -EA Ignore).LastOSBuild -lt '16.0.12228.20364'){
        (Start-Process -FilePath "${env:CommonProgramFiles}\Microsoft Shared\ClickToRun\OfficeC2RClient.exe" -ArgumentList "/update user updatepromptuser=false Forceappshutdown=true displaylevel=true" -Wait -PassThru).ExitCode
    }
}


