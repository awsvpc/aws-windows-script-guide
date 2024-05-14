To verify the status of TPM (Trusted Platform Module), UEFI boot mode, and UEFI Secure Boot, you can use various PowerShell commands. Here are commands for each:

TPM Enable Status:
Get-WmiObject -Namespace "Root\CIMv2\Security\MicrosoftTpm" -Class Win32_Tpm | Select-Object IsEnabled
This command retrieves the TPM status. If IsEnabled is True, TPM is enabled; if False, TPM is disabled.

UEFI Status:
(Get-WmiObject -Class Win32_ComputerSystem).FirmwareType
This command retrieves the firmware type. If the output is 2, it indicates UEFI boot mode; if 1, it's Legacy BIOS.

UEFI Secure Boot Status:
Confirm-SecureBootUEFI
This command confirms whether Secure Boot is enabled or not. If it returns True, Secure Boot is enabled; if False, it's not enabled.

These commands can be executed in PowerShell to check the respective statuses.

