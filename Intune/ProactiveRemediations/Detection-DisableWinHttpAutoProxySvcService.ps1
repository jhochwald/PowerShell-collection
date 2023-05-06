# Detection - Disable WinHttpAutoProxySvc service

$RegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Services\WinHttpAutoProxySvc'

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
      Name        = 'Start'
      ErrorAction = 'SilentlyContinue'
   }
   if (-not ((Get-ItemPropertyValue @paramGetItemPropertyValue) -eq 4))
   {
      exit 1
   }
}
catch
{
   exit 1
}

exit 0