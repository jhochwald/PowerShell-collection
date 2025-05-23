# Hide/Remove WSL Linux icon from Desktop
# Detection-RemoveWslDesktopIcon

$RegPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel'

try
{
   if (!(Test-Path -LiteralPath $RegPath -ErrorAction SilentlyContinue))
   {
      exit 1
   }
   
   $paramGetItemPropertyValue = @{
      LiteralPath = $RegPath
      Name        = '{B2B4A4D1-2754-4140-A2EB-9A76D9D7CDC6}'
      ErrorAction = 'SilentlyContinue'
   }
   if (!((Get-ItemPropertyValue @paramGetItemPropertyValue ) -eq 1))
   {
      exit 1
   }
}
catch
{
   exit 1
}

# Ensure a clean exit!
exit 0
