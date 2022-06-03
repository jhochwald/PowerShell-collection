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

$RegistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU'
$RegistryName = 'NoAutoUpdate'
$RegistryValue = 0

try
{
   if ((Get-ItemProperty -Path $RegistryPath -Name $RegistryName -ErrorAction Stop | Select-Object -ExpandProperty $RegistryName) -eq $RegistryValue)
   {
      exit 0
   }
   else
   {
      exit 1
   }
}
catch
{
   # NoAutoUpdate does not exist (fine)
   exit 0
}