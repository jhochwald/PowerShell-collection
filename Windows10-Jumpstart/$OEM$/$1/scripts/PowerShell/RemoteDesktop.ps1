if (-not $ComputerName) {
    $ComputerName = $Env:COMPUTERNAME
}
(Get-WmiObject -class Win32_TSGeneralSetting -Namespace root\cimv2\terminalservices -ComputerName $ComputerName -Filter "TerminalName='RDP-tcp'").SetUserAuthenticationRequired(0)

net localgroup "Remote Desktop Users" /add "AzureAD\joerg@hochwald.net"
