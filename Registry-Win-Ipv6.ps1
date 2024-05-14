You can use PowerShell to change registry values in Windows. Below, I give a few different examples of how to use the cmdlet in varies scenarios.

From the Microsoft knowledge base article http://support.microsoft.com/kb/154596
How to configure RPC dynamic port allocation to work with firewalls, below is the PowerShell way, using 4 separate PowerShell cmdlets in the same order:
New-Item -Path HKLM:\Software\Microsoft\Rpc\Internet
New-ItemProperty -Path HKLM:\Software\Microsoft\Rpc\Internet -Name Ports -PropertyType MultiString -Value 5984-5994
New-ItemProperty -Path HKLM:\Software\Microsoft\Rpc\Internet -Name PortsInternetAvailable -PropertyType String -Value Y
New-ItemProperty -Path HKLM:\Software\Microsoft\Rpc\Internet -Name UseInternetPorts -PropertyType String -Value Y

To disable IPv6, run the following cmdlet:
New-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\services\TCPIP6\Parameters -Name DisabledComponents -PropertyType DWord -Value 0xffffffff

To add a DNS suffix and DNS search list:
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" Domain -Value domain.local –Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" SearchList -Value domain.local –Force

REG_SZ = String
REG_DWORD = DWord
REG_QWORD = QWord
REG_MULTI_SZ = MultiString
REG_BINARY = Binary
