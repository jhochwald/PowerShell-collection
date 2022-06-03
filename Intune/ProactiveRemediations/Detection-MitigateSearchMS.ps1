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

If (Get-Item -Path ('{0}:\search-ms' -f $RegistryRoot) -ErrorAction $SCT)
{
   exit 1
}

exit 0
#endregion Check
