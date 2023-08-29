#requires -Version 5.0

# Disable User Choice to Show Account Email Address on Sign-in Screen for All Users
# Detection-DisableUserChoiceShowAccountEmailAddressOnSignInScreen

$RegPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'

try
{
   if (!(Test-Path -LiteralPath $RegPath -ErrorAction SilentlyContinue))
   {
      exit 1
   }
   
   
   if (!((Get-ItemPropertyValue -LiteralPath $RegPath -Name 'BlockUserFromShowingAccountDetailsOnSignin' -ErrorAction SilentlyContinue) -eq 1))
   {
      exit 1
   }
}
catch
{
   exit 1
}


exit 0
