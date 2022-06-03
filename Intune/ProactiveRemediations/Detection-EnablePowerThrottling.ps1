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
$RegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling'

try
{
   if (-not (Test-Path -LiteralPath $RegistryPath))
   {
      exit 1
   }

   if (-not ((Get-ItemPropertyValue -LiteralPath $RegistryPath -Name 'PowerThrottlingOff' -ErrorAction SilentlyContinue) -eq 0))
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
