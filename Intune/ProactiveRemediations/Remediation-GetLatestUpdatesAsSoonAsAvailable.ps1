<#
   Remediation: Enable or Disable Get Latest Updates as soon as available in Windows 11
#>

$EnableFeature = 1

if ((Test-Path -LiteralPath 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings') -ne $true)
{
   $paramNewItem = @{
      Path        = 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings'
      Force       = $true
      Confirm     = $false
      ErrorAction = 'SilentlyContinue'
   }
   $null = (New-Item @paramNewItem)
}

$paramNewItemProperty = @{
   LiteralPath  = 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings'
   Name         = 'IsContinuousInnovationOptedIn'
   Value        = $EnableFeature
   PropertyType = 'DWord'
   Force        = $true
   Confirm      = $false
   ErrorAction  = 'SilentlyContinue'
}
$null = (New-ItemProperty @paramNewItemProperty)