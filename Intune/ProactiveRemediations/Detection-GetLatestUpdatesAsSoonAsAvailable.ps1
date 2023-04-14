<#
   Detection: Enable or Disable Get Latest Updates as soon as available in Windows 11
#>

$EnableFeature = 1

try
{
   if (-not (Test-Path -LiteralPath 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings'))
   {
      exit 1
   }

   $paramGetItemPropertyValue = @{
      LiteralPath = 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings'
      Name        = 'IsContinuousInnovationOptedIn'
      ErrorAction = 'SilentlyContinue'
   }
   if (-not ((Get-ItemPropertyValue @paramGetItemPropertyValue) -eq $EnableFeature))
   {
      exit 1
   }
}
catch
{
   exit 1
}

exit 0