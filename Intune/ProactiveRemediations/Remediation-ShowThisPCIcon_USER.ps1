$RegPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel'

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
   Name         = '{20D04FE0-3AEA-1069-A2D8-08002B30309D}'
   Value        = 0
   PropertyType = 'DWord'
   Force        = $true
   Confirm      = $false
   ErrorAction  = 'SilentlyContinue'
}
$null = (New-ItemProperty @paramNewItemProperty)