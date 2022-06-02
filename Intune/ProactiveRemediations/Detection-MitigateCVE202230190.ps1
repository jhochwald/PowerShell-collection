#region Check
#region Defaults
$SCT = 'SilentlyContinue'
#endregion Defaults

# Clean-up
$RegistryRoot = $null

# Figure out if we have an existing PowerShell Registry Provider mapping
$paramGetPSDrive = @{
   ErrorAction   = $SCT
   WarningAction = $SCT
}
$RegistryRoot = ((Get-PSDrive @paramGetPSDrive | Where-Object {
         $PSItem.Root -eq 'HKEY_CLASSES_ROOT'
      }).Name)
$paramGetPSDrive = $null

if (-not ($RegistryRoot))
{
   # PowerShell Registry Provider
   $paramNewPSDrive = @{
      PSProvider  = 'registry'
      Root        = 'HKEY_CLASSES_ROOT'
      Name        = 'HKCR'
      ErrorAction = 'Stop'
   }
   $RegistryRoot = ((New-PSDrive @paramNewPSDrive).Name)
   $paramNewPSDrive = $null
}

If (Get-Item -Path ('{0}:\ms-msdt' -f $RegistryRoot) -ErrorAction $SCT)
{
   return $false
}
else
{
   return $true
}

return $true
#endregion Check