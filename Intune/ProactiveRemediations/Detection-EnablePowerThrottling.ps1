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

