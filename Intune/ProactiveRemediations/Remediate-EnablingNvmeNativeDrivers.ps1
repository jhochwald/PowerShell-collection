# Remediate: Enabling NVME native drivers in Win 11
# Remediate-EnablingNvmeNativeDrivers.ps1

$RegPath = 'HKLM:\SYSTEM\CurrentControlSet\Policies\Microsoft\FeatureManagement\Overrides'

if ((Test-Path -LiteralPath $RegPath -ErrorAction SilentlyContinue) -ne $true)
{
   $paramNewItem = @{
      Path        = $RegPath
      Force       = $true
      Confirm     = $false
      ErrorAction = 'SilentlyContinue'
   }
   $null = (New-Item @paramNewItem)
   $paramNewItem = $null
}

$paramNewItemProperty = @{
   LiteralPath  = $RegPath
   Name         = '735209102'
   Value        = 1
   PropertyType = 'DWord'
   Force        = $true
   Confirm      = $false
   ErrorAction  = 'SilentlyContinue'
}
$null = (New-ItemProperty @paramNewItemProperty)
$paramNewItemProperty = $null

$paramNewItemProperty = @{
   LiteralPath  = $RegPath
   Name         = '1853569164'
   Value        = 1
   PropertyType = 'DWord'
   Force        = $true
   Confirm      = $false
   ErrorAction  = 'SilentlyContinue'
}
$null = (New-ItemProperty @paramNewItemProperty)
$paramNewItemProperty = $null

$paramNewItemProperty = @{
   LiteralPath  = $RegPath
   Name         = '156965516'
   Value        = 1
   PropertyType = 'DWord'
   Force        = $true
   Confirm      = $false
   ErrorAction  = 'SilentlyContinue'
}
$null = (New-ItemProperty @paramNewItemProperty)
$paramNewItemProperty = $null

$RegPath = $null
