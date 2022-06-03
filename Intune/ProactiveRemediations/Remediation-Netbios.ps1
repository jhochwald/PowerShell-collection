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

$RegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\services\NetBT\Parameters\Interfaces\tcpip*'
$RegistryName = 'NetbiosOptions'
$RegistryType = 'DWORD'
$RegistryValue = 2

$null = (New-ItemProperty -Path $RegistryPath -Name $RegistryName -Type $RegistryType -Value $RegistryValue -ErrorAction Stop)