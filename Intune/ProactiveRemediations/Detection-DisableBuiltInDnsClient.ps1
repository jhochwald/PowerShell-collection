# Disable Browser built in DNS client for full Global Secure Access (GSA) support
# Detection-DisableBuiltInDnsClient

$AllRegpath = @(
   'HKLM:\SOFTWARE\Policies\BraveSoftware\Brave'
   'HKLM:\SOFTWARE\Policies\Google\Chrome'
   'HKLM:\SOFTWARE\Policies\Microsoft\Edge'
)

try
{
   foreach ($RegPath in $AllRegpath)
   {
      if (!(Test-Path -LiteralPath $RegPath -ErrorAction SilentlyContinue))
      {
exit 1
}
      
      $paramGetItemPropertyValue = @{
         LiteralPath = $RegPath
         Name        = 'BuiltInDnsClientEnabled'
         ErrorAction = 'SilentlyContinue'
      }
      if (!((Get-ItemPropertyValue @paramGetItemPropertyValue) -eq 0))
      {
exit 1
}
   }
}
catch
{
exit 1
}

# Ensure a clean exit!
exit 0
