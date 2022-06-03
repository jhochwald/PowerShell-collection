#region Check
$RegistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore'

try
{
   if (-not (Test-Path -LiteralPath $RegistryPath -ErrorAction SilentlyContinue))
   {
      exit 1
   }

   if (-not ((Get-ItemPropertyValue -LiteralPath $RegistryPath -Name 'AutoDownload' -ErrorAction SilentlyContinue) -eq 4))
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


