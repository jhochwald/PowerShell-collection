#requires -Version 5.0

# Remove Windows Edition and Build Watermark on Desktop for Current User
# Detection-RemoveWindowsWatermarkOnDesktopForCurrentUser

$RegPath = 'HKCU:\Control Panel\Desktop'

try
{
   if (!(Test-Path -LiteralPath $RegPath))
   {
      exit 1
   }
   
   
   if (!((Get-ItemPropertyValue -LiteralPath $RegPath -Name 'PaintDesktopVersion' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }
}
catch
{
   exit 1
}


exit 0
