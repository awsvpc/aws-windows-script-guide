#install crowdstrike without cid
# Install CrowdStrike Agent without CID and Stop Service

# Define CrowdStrike installer URL
$installerUrl = "https://example.com/crowdstrike_installer.exe"

# Download CrowdStrike installer
Invoke-WebRequest -Uri $installerUrl -OutFile "C:\Temp\crowdstrike_installer.exe"

# Install CrowdStrike Agent without CID
Start-Process -FilePath "C:\Temp\crowdstrike_installer.exe" -ArgumentList "/silent" -Wait

# Stop CrowdStrike Service
Stop-Service -Name "CSAgent"

######Activate Crowdstrike
# Activate CrowdStrike Agent with CID and GroupTag

# Define CID and GroupTag
$CID = "your_CID_here"
$GroupTag = "your_GroupTag_here"

# Path to CrowdStrike activation utility
$activationUtilityPath = "C:\Program Files\CrowdStrike\CSAgent\CSAgentCmd.exe"

# Activate CrowdStrike Agent with CID and GroupTag
Start-Process -FilePath $activationUtilityPath -ArgumentList "--addcid=$CID --profilename=$GroupTag" -Wait


