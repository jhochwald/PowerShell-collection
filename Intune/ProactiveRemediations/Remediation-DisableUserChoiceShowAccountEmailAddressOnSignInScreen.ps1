#requires -Version 1.0

# Disable User Choice to Show Account Email Address on Sign-in Screen for All Users
# Remediation-DisableUserChoiceShowAccountEmailAddressOnSignInScreen

$RegPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'

if ((Test-Path -LiteralPath $RegPath -ErrorAction SilentlyContinue) -ne $true)
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
   Name         = 'BlockUserFromShowingAccountDetailsOnSignin'
   Value        = 1
   PropertyType = 'DWord'
   Force        = $true
   Confirm      = $false
   ErrorAction  = 'SilentlyContinue'
}
$null = (New-ItemProperty @paramNewItemProperty)
