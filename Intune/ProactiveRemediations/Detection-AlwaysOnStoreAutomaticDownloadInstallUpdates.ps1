#region Check
$RegistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore'

try
{
   if (-not (Test-Path -LiteralPath $RegistryPath -ErrorAction SilentlyContinue))
   {
      return $false
   }

   if (-not ((Get-ItemPropertyValue -LiteralPath $RegistryPath -Name 'AutoDownload' -ErrorAction SilentlyContinue) -eq 4))
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
