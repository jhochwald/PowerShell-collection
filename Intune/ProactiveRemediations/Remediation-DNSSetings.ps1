#region ARM64Handling
# Restart Process using PowerShell 64-bit
if ($ENV:PROCESSOR_ARCHITEW6432 -eq 'AMD64')
{
   try
   {
      &"$ENV:WINDIR\SysNative\WindowsPowershell\v1.0\PowerShell.exe" -File $PSCOMMANDPATH
   }
   catch
   {
      Throw ('Failed to start {0}' -f $PSCOMMANDPATH)
   }

   exit
}
#endregion ARM64Handling

$MyDomainName = 'enatec.net'

$networkConfig = (Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter "DHCPenabled = 'true'" | Where-Object -FilterScript {
      ($_.Description -like 'Intel*') -or ($_.Description -like 'Ethernet') -or ($_.Description -like 'Wireless-AC')
   })
Set-DnsClientGlobalSetting -SuffixSearchList @()
$networkConfig.SetDnsDomain($MyDomainName)
$networkConfig.SetDynamicDNSRegistration($true, $true)
$null = (& "$env:windir\system32\ipconfig.exe" /registerdns)