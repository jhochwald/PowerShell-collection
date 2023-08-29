#requires -Version 1.0

# Turn Off Use Cellular when Wi-Fi is Poor
# Remediation-TurnOffUseCellularWhenWiFiIsPoor

$RegPath = 'HKLM:\SOFTWARE\Microsoft\WcmSvc\CellularFailover'

if ((Test-Path -LiteralPath $RegPath) -ne $true)
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
   Value        = 0
   PropertyType = 'DWord'
   Force        = $true
   Confirm      = $false
   ErrorAction  = 'SilentlyContinue'
}
$null = (New-ItemProperty @paramNewItemProperty)
