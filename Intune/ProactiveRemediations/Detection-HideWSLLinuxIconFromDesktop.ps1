# Check - Hide/Remove WSL Linux icon from Desktop (Check-HideWSLLinuxIconFromDesktop.ps1)

$RegPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel'

try
{
   if (!(Test-Path -LiteralPath $RegPath -ErrorAction SilentlyContinue))
   {
      Exit 1
   }

   # 1 = OFF (Hide) / Replace with 0 to turn it back on
   if (!((Get-ItemPropertyValue -LiteralPath $RegPath -Name '{B2B4A4D1-2754-4140-A2EB-9A76D9D7CDC6}' -ErrorAction SilentlyContinue) -eq 1))
   {
      Exit 1
   }
}
catch
{
   Exit 1
}

Exit 0
