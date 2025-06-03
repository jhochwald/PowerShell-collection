# Remediation - Enable WinHttpAutoProxySvc service

$RegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Services\WinHttpAutoProxySvc'

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
   Name         = 'Start'
   Value        = 3
   PropertyType = 'DWord'
   Force        = $true
   Confirm      = $false
   ErrorAction  = 'SilentlyContinue'
}
$null = (New-ItemProperty @paramNewItemProperty)