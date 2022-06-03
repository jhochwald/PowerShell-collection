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

$RegistryPath = 'HKCU:\SOFTWARE\Microsoft\OneDrive\Accounts\Business1'
$RegistryName = 'Timerautomount'
$RegistryValue = 1

try
{
   if ((Get-ItemProperty -Path $RegistryPath -Name $RegistryName -ErrorAction Stop | Select-Object -ExpandProperty $RegistryName) -eq $RegistryValue)
   {
      exit 0
   }

   exit 1
}
catch
{
   exit 1
}
