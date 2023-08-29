#requires -Version 5.0

# Turn Off Use Cellular when Wi-Fi is Poor
# Detection-TurnOffUseCellularWhenWiFiIsPoor

$RegPath = 'HKLM:\SOFTWARE\Microsoft\WcmSvc\CellularFailover'
try
{
   if (!(Test-Path -LiteralPath $RegPath -ErrorAction SilentlyContinue))
   {
      exit 1
   }
   
   
   if (!((Get-ItemPropertyValue -LiteralPath $RegPath -Name 'AllowFailover' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }
}
catch
{
   exit 1
}


exit 0
