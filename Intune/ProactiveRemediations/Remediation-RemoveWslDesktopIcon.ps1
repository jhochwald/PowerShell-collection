# Hide/Remove WSL Linux icon from Desktop
# Remediation-RemoveWslDesktopIcon

$RegPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel'

try
{
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
      Name         = '{B2B4A4D1-2754-4140-A2EB-9A76D9D7CDC6}'
      Value        = 1
      PropertyType = 'DWord'
      Force        = $true
      Confirm      = $false
      ErrorAction  = 'SilentlyContinue'
   }
   $null = (New-ItemProperty @paramNewItemProperty)
}
catch
{
   # We should never reach this point!
   exit 1
}

# Ensure a clean exit!
exit 0
