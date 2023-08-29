#requires -Version 1.0

# Remove Windows Edition and Build Watermark on Desktop for All Users
# RemoveWindowsWatermarkOnDesktopForAllUser

$RegPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Windows'

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
   Name         = 'DisplayVersion'
   Value        = 0
   PropertyType = 'DWord'
   Force        = $true
   Confirm      = $false
   ErrorAction  = 'SilentlyContinue'
}
$null = (New-ItemProperty @paramNewItemProperty)
