# Remediation-AllowSideLoadingForTrustedApps

$RegPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Appx'

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
   Name         = 'AllowDeploymentInSpecialProfiles'
   Value        = 1
   PropertyType = 'DWord'
   Force        = $true
   Confirm      = $false
   ErrorAction  = 'SilentlyContinue'
}
$null = (New-ItemProperty @paramNewItemProperty)
$paramNewItemProperty = @{
   LiteralPath  = $RegPath
   Name         = 'AllowAllTrustedApps'
   Value        = 1
   PropertyType = 'DWord'
   Force        = $true
   Confirm      = $false
   ErrorAction  = 'SilentlyContinue'
}
$null = (New-ItemProperty @paramNewItemProperty)
$paramNewItemProperty = @{
   LiteralPath  = $RegPath
   Name         = 'AllowDevelopmentWithoutDevLicense'
   Value        = 1
   PropertyType = 'DWord'
   Force        = $true
   Confirm      = $false
   ErrorAction  = 'SilentlyContinue'
}
$null = (New-ItemProperty @paramNewItemProperty)
