#region Check
$RegistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive'

try
{
   if (-not (Test-Path -LiteralPath $RegistryPath -ErrorAction SilentlyContinue))
   {
      exit 1
   }

   if (-not ($null -eq (Get-ItemProperty -LiteralPath $RegistryPath -Name 'DisableFileSyncNGSC' -ErrorAction SilentlyContinue)))
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


