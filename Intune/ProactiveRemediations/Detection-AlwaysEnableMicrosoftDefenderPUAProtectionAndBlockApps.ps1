#region Check
$RegistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender'

try
{
   if (-not (Test-Path -LiteralPath $RegistryPath -ErrorAction SilentlyContinue))
   {
      return $false
   }

   if (-not ((Get-ItemPropertyValue -LiteralPath $RegistryPath -Name 'PUAProtection' -ErrorAction SilentlyContinue) -eq 1))
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