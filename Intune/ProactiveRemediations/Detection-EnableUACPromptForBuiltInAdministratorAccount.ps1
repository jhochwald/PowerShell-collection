#region Check
$RegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'

try
{
   if (-not (Test-Path -LiteralPath $RegistryPath -ErrorAction SilentlyContinue))
   {
      return $false
   }

   if (-not ((Get-ItemPropertyValue -LiteralPath $RegistryPath -Name 'FilterAdministratorToken' -ErrorAction SilentlyContinue) -eq 1))
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