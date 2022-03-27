#region Check
$RegistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive'

try
{
   if (-not (Test-Path -LiteralPath $RegistryPath -ErrorAction SilentlyContinue))
   {
      return $false
   }

   if (-not ($null -eq (Get-ItemProperty -LiteralPath $RegistryPath -Name 'DisableFileSyncNGSC' -ErrorAction SilentlyContinue)))
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
