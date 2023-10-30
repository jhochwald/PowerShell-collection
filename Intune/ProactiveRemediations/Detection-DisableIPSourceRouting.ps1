# Detection-DisableIPSourceRouting

$RegPath = 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters'

try
{
   $paramTestPath = @{
      LiteralPath = $RegPath
      ErrorAction = 'SilentlyContinue'
   }
   if (!(Test-Path @paramTestPath))
   {
      exit 1
   }
   $paramGetItemPropertyValue = @{
      LiteralPath = $RegPath
      Name        = 'DisableIPSourceRouting'
      ErrorAction = 'SilentlyContinue'
   }
   if (!((Get-ItemPropertyValue @paramGetItemPropertyValue) -eq 2))
   {
      exit 1
   }
}
catch
{
   exit 1
}


exit 0