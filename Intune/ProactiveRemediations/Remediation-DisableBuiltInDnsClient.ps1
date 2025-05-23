# Disable Browser built in DNS client for full Global Secure Access (GSA) support
# Remediation-DisableBuiltInDnsClient

$AllRegpath = @(
   'HKLM:\SOFTWARE\Policies\BraveSoftware\Brave'
   'HKLM:\SOFTWARE\Policies\Google\Chrome'
   'HKLM:\SOFTWARE\Policies\Microsoft\Edge'
)

try
{
   foreach ($RegPath in $AllRegpath)
   {
      if ((Test-Path -LiteralPath $RegPath -ErrorAction SilentlyContinue) -ne $true)
      {
         $paramNewItem = @{
            Path        = $RegPath
            Force       = $true
            Confirm     = $false
            ErrorAction = 'SilentlyContinue'
         }
         $null = (New-Item @paramNewItem)
      }
      
      $paramNewItemProperty = @{
         LiteralPath  = $RegPath
         Name         = 'BuiltInDnsClientEnabled'
         Value        = 0
         PropertyType = 'DWord'
         Force        = $true
         Confirm      = $false
         ErrorAction  = 'SilentlyContinue'
      }
      $null = (New-ItemProperty @paramNewItemProperty)
   }
}
catch
{
   # We should never reach this point!
   exit 1
}

# Ensure a clean exit!
exit 0
