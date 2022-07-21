<#
   There following detection script was taken from here
   https://letsconfigmgr.com/mem-automatic-syncing-of-onedrive-shared-libs-via-intune/

   There is a registry key that decreases the delay for end-users to see their administratively assigned libraries
   via the OneDrive sync client, however, this key does get removed upon every reboot, I will show you how you can use
   the power of Proactive Remediations via Microsoft Intune to set detect if this registry key exists and
   if not, create it, on a recurring schedule

#>

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

Try
{
   If ((Get-ItemProperty -Path $RegistryPath -Name $RegistryName -ErrorAction Stop | Select-Object -ExpandProperty $RegistryName) -eq $RegistryValue)
   {
      exit 0
   }

   exit 1
}
Catch
{
   exit 1
}