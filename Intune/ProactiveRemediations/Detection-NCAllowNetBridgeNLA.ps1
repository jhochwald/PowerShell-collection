# Detection-NCAllowNetBridgeNLA

$RegPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Network Connections'

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
      Name        = 'NC_AllowNetBridge_NLA'
      ErrorAction = 'SilentlyContinue'
   }
   if (!((Get-ItemPropertyValue @paramGetItemPropertyValue) -eq 0))
   {
      exit 1
   }
}
catch
{
   exit 1
}


exit 0