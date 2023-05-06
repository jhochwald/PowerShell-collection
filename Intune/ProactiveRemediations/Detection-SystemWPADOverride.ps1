# Detection - System WPAD Override

$RegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Wpad'

try
{
   $paramTestPath = @{
      LiteralPath = $RegistryPath
      ErrorAction = 'Stop'
   }
   if (-not (Test-Path @paramTestPath))
   {
      exit 1
   }
   $paramGetItemPropertyValue = @{
      LiteralPath = $RegistryPath
      Name        = 'WpadOverride'
      ErrorAction = 'SilentlyContinue'
   }
   if (-not ((Get-ItemPropertyValue @paramGetItemPropertyValue) -eq 1))
   {
      exit 1
   }
}
catch
{
   exit 1
}

exit 0