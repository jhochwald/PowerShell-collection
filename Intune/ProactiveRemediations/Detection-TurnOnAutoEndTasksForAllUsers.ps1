#region Check
$RegistryPath = 'Registry::\HKEY_USERS\.DEFAULT\Control Panel\Desktop'

try
{
   if (-not (Test-Path -LiteralPath $RegistryPath -ErrorAction SilentlyContinue))
   {
      return $false
   }

   if (-not ((Get-ItemPropertyValue -LiteralPath $RegistryPath -Name 'AutoEndTasks' -ErrorAction SilentlyContinue) -eq '1'))
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