#requires -Version 1.0

if (-not ($ComputerName))
{
   $ComputerName = $Env:COMPUTERNAME
}
$paramGetWmiObject = @{
   Class        = 'Win32_TSGeneralSetting'
   Namespace    = 'root\cimv2\terminalservices'
   ComputerName = $ComputerName
   Filter       = "TerminalName='RDP-tcp'"
}
$null = ((Get-WmiObject @paramGetWmiObject).SetUserAuthenticationRequired(0))

& "$env:windir\system32\net.exe" localgroup 'Remote Desktop Users' /add 'AzureAD\joerg@hochwald.net'
