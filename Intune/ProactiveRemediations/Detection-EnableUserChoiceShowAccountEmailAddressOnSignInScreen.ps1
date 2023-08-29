#requires -Version 1.0

# Enable User Choice to Show Account Email Address on Sign-in Screen for All Users
# Detection-EnableUserChoiceShowAccountEmailAddressOnSignInScreen

$RegPath2 = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'
$RegPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'

try
{
   if (!(Test-Path -LiteralPath $RegPath -ErrorAction SilentlyContinue))
   {
      exit 1
   }
   
   if (!(Test-Path -LiteralPath $RegPath2 -ErrorAction SilentlyContinue))
   {
      exit 1
   }
   
   
   if (!((Get-ItemProperty -LiteralPath $RegPath -Name 'DontDisplayLockedUserId' -ErrorAction SilentlyContinue) -eq $null))
   {
      exit 1
   }
   
   if (!((Get-ItemProperty -LiteralPath $RegPath2 -Name 'BlockUserFromShowingAccountDetailsOnSignin' -ErrorAction SilentlyContinue) -eq $null))
   {
      exit 1
   }
}
catch
{
   exit 1
}


exit 0
