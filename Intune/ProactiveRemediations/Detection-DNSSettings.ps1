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

$MyDomainName = 'enatec-intra.net'

$networkConfigStatus = (Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter "IPenabled = 'true'" | Where-Object -FilterScript {
      ($_.Description -like 'Intel*') -or ($_.Description -like 'Ethernet') -or ($_.Description -like 'Wireless-AC')
   })

for ($i = 0; $i -lt $networkConfigStatus.Length; $i++)
{
   if (-not (($networkConfigStatus[$i].dnsdomain -like $MyDomainName) -and ($networkConfigStatus[$i].FullDNSRegistrationEnabled -like 'True') -and ($networkConfigStatus[$i].DomainDNSRegistrationEnabled -like 'True')))
   {
      exit 1
   }
}

# if no network adapters are found, report False
if ($networkConfigStatus.Length -eq 0)
{
   exit 1
}

exit 0