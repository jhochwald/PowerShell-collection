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

#region Check
$RegistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive'

try
{
   if (-not (Test-Path -LiteralPath $RegistryPath -ErrorAction SilentlyContinue))
   {
      exit 1
   }

   if (-not ($null -eq (Get-ItemProperty -LiteralPath $RegistryPath -Name 'DisableFileSyncNGSC' -ErrorAction SilentlyContinue)))
   {
      exit 1
   }
}
catch
{
   exit 1
}

exit 0
#endregion Check
