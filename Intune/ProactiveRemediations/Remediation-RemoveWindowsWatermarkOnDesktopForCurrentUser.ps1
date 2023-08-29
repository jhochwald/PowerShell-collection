#requires -Version 1.0

# Remove Windows Edition and Build Watermark on Desktop for Current User
# Remediation-RemoveWindowsWatermarkOnDesktopForCurrentUser

$RegPath = 'HKCU:\Control Panel\Desktop'

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
   Name         = 'PaintDesktopVersion'
   Value        = 0
   PropertyType = 'DWord'
   Force        = $true
   Confirm      = $false
   ErrorAction  = 'SilentlyContinue'
}
$null = (New-ItemProperty @paramNewItemProperty)
