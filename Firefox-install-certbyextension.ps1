<#
.Synopsis
   Force installs Fox's pre-seeded Cerby Extension to Firefox 
.DESCRIPTION
   Silent setup for Cerby extensions for Windows deployment. This script is designed to be executed through an endpoint management system for Windows devices for
   a seamless Cerby extension installation, it can also run locally executed manually on Windows endpoints. This script won't install the extensions if browsers 
   are not previously installed.
#>
Add-Type -AssemblyName System.IO.Compression.FileSystem

function installFirefoxAddIn($forcedUrl, $forcedId)
{
    $dest_folder = "C:\Program Files\Mozilla Firefox\distribution"
    $json_content = @"
    {
      "policies": {
        "ExtensionSettings": {
            "$forcedId": {
                "installation_mode": "force_installed",
                "install_url": "$forcedUrl"
            }
        },
        "3rdparty": {
          "Extensions": {
            "$forcedId": {
              "DEFAULT_WORKSPACE": "fox"
            }
          }
        }
      }
    }
"@

    if (!(Test-Path -Path $dest_folder)) {
        New-Item -ItemType Directory -Path $dest_folder | Out-Null
    }

    $json_content | Set-Content -Path "$dest_folder\policies.json"
}


$extensionFirefoxGeneralUrl = "https://addons.mozilla.org/firefox/downloads/latest/cerby-s-browser-extension/latest.xpi"
$extensionFirefoxGeneralId = "{f961ea35-985c-412d-9b06-aafd75752587}"

installFirefoxAddIn $extensionFirefoxGeneralUrl $extensionFirefoxGeneralId
