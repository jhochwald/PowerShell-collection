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
$RegistryValue = 2
$Counter = 0

Try
{
   foreach ($RegistryEntry in (Get-ItemProperty -Path $RegistryPath -Name $RegistryName -ErrorAction Stop | Select-Object -ExpandProperty $RegistryName))
   {
      if ($RegistryEntry -eq $RegistryValue)
      {
         $Counter += 0
      }
      else
      {
         $Counter += 1
      }
   }

   if ($Counter -eq 0)
   {
      exit 0
   }
   else
   {
      exit 1
   }
}
Catch
{
   exit 1
}