#requires -Version 1.0

# Turn On Use Cellular when Wi-Fi is Poor
# Remediation-TurnOnUseCellularWhenWiFiIsPoor

$RegPath = 'HKLM:\SOFTWARE\Microsoft\WcmSvc\CellularFailover'

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
   Name         = 'AllowFailover'
   Value        = 2
   PropertyType = 'DWord'
   Force        = $true
   Confirm      = $false
   ErrorAction  = 'SilentlyContinue'
}
$null = (New-ItemProperty @paramNewItemProperty)
