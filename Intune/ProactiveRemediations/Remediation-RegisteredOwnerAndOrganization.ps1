# Remediation - Registered Owner and Organization

$RegisteredOwner = 'John Doe'
$RegisteredOrganization = 'Contoso IT'

$RegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'

try
{
   # Funny, it must exist, but we check it anyway
   if ((Test-Path -LiteralPath $RegistryPath -ErrorAction SilentlyContinue) -ne $true)
   {
      $paramNewItem = @{
         Path        = $RegistryPath
         Force       = $true
         Confirm     = $false
         ErrorAction = 'Stop'
      }

      $null = (New-Item @paramNewItem)
   }

   $paramNewItemProperty = @{
      LiteralPath  = $RegistryPath
      Name         = 'RegisteredOwner'
      Value        = $RegisteredOwner
      PropertyType = 'String'
      Force        = $true
      Confirm      = $false
      ErrorAction  = 'Stop'
   }
   $null = (New-ItemProperty @paramNewItemProperty)

   $paramNewItemProperty = @{
      LiteralPath  = $RegistryPath
      Name         = 'RegisteredOrganization'
      Value        = $RegisteredOrganization
      PropertyType = 'String'
      Force        = $true
      Confirm      = $false
      ErrorAction  = 'Stop'
   }
   $null = (New-ItemProperty @paramNewItemProperty)
}
catch
{
   exit 1
}

exit 0