# Detection-NCStdDomainUserSetLocation

$RegPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Network Connections'

$paramTestPath = @{
   LiteralPath = $RegPath
   ErrorAction = 'SilentlyContinue'
}
if ((Test-Path @paramTestPath) -ne $true)
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
   Name         = 'NC_StdDomainUserSetLocation'
   Value        = 1
   PropertyType = 'DWord'
   Force        = $true
   Confirm      = $false
   ErrorAction  = 'SilentlyContinue'
}
$null = (New-ItemProperty @paramNewItemProperty)
