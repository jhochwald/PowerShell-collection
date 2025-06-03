#requires -Version 5.0

# Detection-GlobalSecureAccessSettings.ps1

#region Variables
$BIDCE = 'BuiltInDnsClientEnabled'
$DOHMode = 'DnsOverHttpsMode'
$DOHValue = 'off'
#endregion Variables

try
{
   #region GoogleChrome
   $ChromeRegPath = 'HKCU:\SOFTWARE\Policies\Google\Chrome'

   if (!(Test-Path -LiteralPath $ChromeRegPath -ErrorAction SilentlyContinue))
   {
      exit 1
   }

   if (!((Get-ItemPropertyValue -LiteralPath $ChromeRegPath -Name $DOHMode -ErrorAction SilentlyContinue) -eq $DOHValue))
   {
      exit 1
   }

   if (!((Get-ItemPropertyValue -LiteralPath $ChromeRegPath -Name $BIDCE -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }
   #endregion GoogleChrome

   #region MicrosoftEdge
   $EdgeRegPath = 'HKCU:\SOFTWARE\Policies\Microsoft\Edge'

   if (!(Test-Path -LiteralPath $EdgeRegPath -ErrorAction SilentlyContinue))
   {
      exit 1
   }

   if (!((Get-ItemPropertyValue -LiteralPath $EdgeRegPath -Name $DOHMode -ErrorAction SilentlyContinue) -eq $DOHValue))
   {
      exit 1
   }

   if (!((Get-ItemPropertyValue -LiteralPath $EdgeRegPath -Name $BIDCE -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }
   #endregion MicrosoftEdge

   #region MozillaFirefox
   $FirefoxRegPath = 'HKCU:\SOFTWARE\Policies\Mozilla\Firefox\DNSOverHTTPS'

   if (!(Test-Path -LiteralPath $FirefoxRegPath -ErrorAction SilentlyContinue))
   {
      exit 1
   }

   if (!((Get-ItemPropertyValue -LiteralPath $FirefoxRegPath -Name 'Enabled' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }

   if (!((Get-ItemPropertyValue -LiteralPath $FirefoxRegPath -Name 'Locked' -ErrorAction SilentlyContinue) -eq 1))
   {
      exit 1
   }
   #endregion MozillaFirefox
}
catch
{
   exit 1
}


exit 0