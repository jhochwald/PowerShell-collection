#requires -Version 5.0

# Remove Windows Edition and Build Watermark on Desktop for All Users
# Detection-RemoveWindowsWatermarkOnDesktopForAllUser

$RegPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Windows'

try
{
   if (!(Test-Path -LiteralPath $RegPath))
   {
      exit 1
   }
   
   
   if (!((Get-ItemPropertyValue -LiteralPath $RegPath -Name 'DisplayVersion' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }
}
catch
{
   exit 1
}


exit 0
