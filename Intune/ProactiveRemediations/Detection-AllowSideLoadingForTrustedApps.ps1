# Detection-AllowSideLoadingForTrustedApps

$RegPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Appx'

try
{
   $paramTestPath = @{
      LiteralPath = $RegPath
      ErrorAction = 'SilentlyContinue'
   }

   if (!(Test-Path @paramTestPath))
   {
      exit 1
   }

   $paramGetItemPropertyValue = @{
      LiteralPath = $RegPath
      Name        = 'AllowDeploymentInSpecialProfiles'
      ErrorAction = 'SilentlyContinue'
   }
   if (!((Get-ItemPropertyValue @paramGetItemPropertyValue) -eq 1))
   {
      exit 1
   }

   $paramGetItemPropertyValue = @{
      LiteralPath = $RegPath
      Name        = 'AllowAllTrustedApps'
      ErrorAction = 'SilentlyContinue'
   }
   if (!((Get-ItemPropertyValue @paramGetItemPropertyValue) -eq 1))
   {
      exit 1
   }

   $paramGetItemPropertyValue = @{
      LiteralPath = $RegPath
      Name        = 'AllowDevelopmentWithoutDevLicense'
      ErrorAction = 'SilentlyContinue'
   }
   if (!((Get-ItemPropertyValue @paramGetItemPropertyValue) -eq 1))
   {
      exit 1
   }
}
catch
{
   exit 1
}

exit 0
