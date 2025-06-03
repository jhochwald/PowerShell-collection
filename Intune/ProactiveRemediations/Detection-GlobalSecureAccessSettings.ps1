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
   $ChromeRegPath = 'HKLM:\SOFTWARE\Policies\Google\Chrome'
   
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
   $EdgeRegPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Edge'
   
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
   $FirefoxRegPath = 'HKLM:\SOFTWARE\Policies\Mozilla\Firefox\DNSOverHTTPS'

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

   #region Tcpip6DisabledComponents
   $Tcpip6RegPath = 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters'

   if (!(Test-Path -LiteralPath $Tcpip6RegPath -ErrorAction SilentlyContinue))
   {
      exit 1
   }

   if (!((Get-ItemPropertyValue -LiteralPath $Tcpip6RegPath -Name 'DisabledComponents' -ErrorAction SilentlyContinue) -eq 32))
   {
      exit 1
   }
   #region Tcpip6DisabledComponents
}
catch
{
   exit 1
}


exit 0