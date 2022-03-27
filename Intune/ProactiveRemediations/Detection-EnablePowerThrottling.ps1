#region Check
$RegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling'

try
{
   if (-not (Test-Path -LiteralPath $RegistryPath))
   {
      return $false
   }

   if (-not ((Get-ItemPropertyValue -LiteralPath $RegistryPath -Name 'PowerThrottlingOff' -ErrorAction SilentlyContinue) -eq 0))
   {
      return $false
   }
}
catch
{
   return $false
}

return $true
#endregion Check