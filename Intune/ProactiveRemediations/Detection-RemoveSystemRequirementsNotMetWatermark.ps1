#requires -Version 5.0

# Remove "System requirements not met" Watermark on Windows 11 Desktop
# Detection-RemoveSystemRequirementsNotMetWatermark

$RegPath = 'HKCU:\Control Panel\UnsupportedHardwareNotificationCache'

try
{
   if (!(Test-Path -LiteralPath $RegPath))
   {
      exit 1
   }
   
   
   if (!((Get-ItemPropertyValue -LiteralPath $RegPath -Name 'SV1' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }
   
   if (!((Get-ItemPropertyValue -LiteralPath $RegPath -Name 'SV2' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }
}
catch
{
   exit 1
}


exit 0
