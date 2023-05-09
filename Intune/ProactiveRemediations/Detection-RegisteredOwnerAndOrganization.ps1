# Detection - Registered Owner and Organization

$RegisteredOwner = 'John Doe'
$RegisteredOrganization = 'Contoso IT'

$RegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'

try
{
   # Funny, it must exist, but we check it anyway
   if (-not (Test-Path -LiteralPath $RegistryPath -ErrorAction SilentlyContinue))
   {
      exit 1
   }

   $paramGetItemPropertyValue = @{
      LiteralPath = $RegistryPath
      Name        = 'RegisteredOwner'
      ErrorAction = 'SilentlyContinue'
   }
   if (-not ((Get-ItemPropertyValue @paramGetItemPropertyValue ) -eq $RegisteredOwner))
   {
      exit 1
   }

   $paramGetItemPropertyValue = @{
      LiteralPath = $RegistryPath
      Name        = 'RegisteredOrganization'
      ErrorAction = 'SilentlyContinue'
   }
   if (-not ((Get-ItemPropertyValue @paramGetItemPropertyValue ) -eq $RegisteredOrganization))
   {
      exit 1
   }
}
catch
{
   exit 1
}

exit 0