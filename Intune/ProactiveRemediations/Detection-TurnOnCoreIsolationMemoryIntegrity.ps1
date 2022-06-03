#region Check
$RegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity'

try
{
   if (-not (Test-Path -LiteralPath $RegistryPath -ErrorAction SilentlyContinue))
   {
      exit 1
   }

   if (-not ((Get-ItemPropertyValue -LiteralPath $RegistryPath -Name 'Enabled' -ErrorAction SilentlyContinue) -eq 1))
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

