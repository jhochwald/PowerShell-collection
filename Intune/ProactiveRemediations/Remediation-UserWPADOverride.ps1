# Remediation - User WPAD Override

$RegistryPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Wpad'

$paramTestPath = @{
   LiteralPath = $RegistryPath
   ErrorAction = 'SilentlyContinue'
}
if ((Test-Path @paramTestPath) -ne $true)
{
   $paramNewItem = @{
      Path        = $RegistryPath
      Force       = $true
      Confirm     = $false
      ErrorAction = 'SilentlyContinue'
   }
   $null = (New-Item @paramNewItem)
}

$paramNewItemProperty = @{
   LiteralPath  = $RegistryPath
   Name         = 'WpadOverride'
   Value        = 1
   PropertyType = 'DWord'
   Force        = $true
   Confirm      = $false
   ErrorAction  = 'SilentlyContinue'
}
$null = (New-ItemProperty @paramNewItemProperty)