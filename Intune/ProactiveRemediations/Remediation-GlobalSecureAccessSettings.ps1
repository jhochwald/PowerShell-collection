#requires -Version 1.0

# Remediation-GlobalSecureAccessSettings.ps1

#region Variables
$BIDCE = 'BuiltInDnsClientEnabled'
$DOHMode = 'DnsOverHttpsMode'
$DOHValue = 'off'

$paramNewItem = @{
   Force       = $True
   Confirm     = $false
   ErrorAction = 'SilentlyContinue'
}

$paramNewItemProperty = @{
   Force       = $True
   Confirm     = $false
   ErrorAction = 'SilentlyContinue'
}
#endregion Variables

#region GoogleChrome
$ChromeRegPath = 'HKLM:\SOFTWARE\Policies\Google\Chrome'

if ((Test-Path -LiteralPath $ChromeRegPath -ErrorAction SilentlyContinue) -ne $True)
{
   $null = (New-Item -Path $ChromeRegPath @paramNewItem)
}

$null = (New-ItemProperty -LiteralPath $ChromeRegPath -Name $DOHMode -Value $DOHValue -PropertyType String @paramNewItemProperty)
$null = (New-ItemProperty -LiteralPath $ChromeRegPath -Name $BIDCE -Value 0 -PropertyType DWord @paramNewItemProperty)
#endregion GoogleChrome

#region MicrosoftEdge
$EdgeRegPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Edge'

if ((Test-Path -LiteralPath $EdgeRegPath -ErrorAction SilentlyContinue) -ne $True)
{
   $null = (New-Item -Path $EdgeRegPath @paramNewItem)
}

$null = (New-ItemProperty -LiteralPath $EdgeRegPath -Name $DOHMode -Value $DOHValue -PropertyType String @paramNewItemProperty)
$null = (New-ItemProperty -LiteralPath $EdgeRegPath -Name $BIDCE -Value 0 -PropertyType DWord @paramNewItemProperty)
#endregion MicrosoftEdge

#region MozillaFirefox
$FirefoxRegPath = 'HKLM:\SOFTWARE\Policies\Mozilla\Firefox\DNSOverHTTPS'

if ((Test-Path -LiteralPath $FirefoxRegPath -ErrorAction SilentlyContinue) -ne $True)
{
   $null = (New-Item -Path $FirefoxRegPath @paramNewItem)
}

$null = (New-ItemProperty -LiteralPath $FirefoxRegPath -Name 'Enabled' -Value 0 -PropertyType DWord @paramNewItemProperty)
$null = (New-ItemProperty -LiteralPath $FirefoxRegPath -Name 'Locked' -Value 1 -PropertyType DWord @paramNewItemProperty)
#endregion MozillaFirefox

#region Tcpip6DisabledComponents
$Tcpip6RegPath = 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters'

if ((Test-Path -LiteralPath $Tcpip6RegPath -ErrorAction SilentlyContinue) -ne $True)
{
   $null = (New-Item -Path $Tcpip6RegPath @paramNewItem)
}

$null = (New-ItemProperty -LiteralPath $Tcpip6RegPath -Name 'DisabledComponents' -Value 32 -PropertyType DWord @paramNewItemProperty)
#endregion Tcpip6DisabledComponents
