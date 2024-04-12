<#
.DESCRIPTION
    PowerShell script to force update of Microsoft Edge Stable
.EXAMPLE
    PowerShell.exe -ExecutionPolicy ByPass -File <ScriptName>.ps1
.NOTES
    VERSION     AUTHOR              CHANGE
    1.0         Jonathan Conway     Initial script creation
#>
 
$Exe = Get-ChildItem -Path "${env:ProgramFiles(x86)}\Microsoft\EdgeUpdate\MicrosoftEdgeUpdate.exe"
$Arguments = "/silent /install appguid={56EB18F8-B008-4CBD-B6D2-8C97FE7E9062}&appname=Microsoft%20Edge&needsadmin=True"
return (Start-Process $($Exe.FullName) -ArgumentList $Arguments -NoNewWindow -PassThru -Wait).ExitCode


Alternate 2:
TaskKill /im msedge.exe /f /t

timeout 30

"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" --update

