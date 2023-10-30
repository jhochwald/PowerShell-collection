# Remediation-NCStdDomainUserSetLocation

$RegPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Network Connections'

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
      Name        = 'NC_StdDomainUserSetLocation'
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