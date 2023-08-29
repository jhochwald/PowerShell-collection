#requires -Version 1.0

# Enable User Choice to Show Account Email Address on Sign-in Screen for All Users
# Remediation-EnableUserChoiceShowAccountEmailAddressOnSignInScreen

$RegPath2 = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'
$RegPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'

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

if ((Test-Path -LiteralPath $RegPath2 -ErrorAction SilentlyContinue) -ne $true)
{
   $paramNewItem = @{
      Path        = $RegPath2
      Force       = $true
      Confirm     = $false
      ErrorAction = 'SilentlyContinue'
   }
   $null = (New-Item @paramNewItem)
}

$paramRemoveItemProperty = @{
   LiteralPath = $RegPath
   Name        = 'DontDisplayLockedUserId'
   Force       = $true
   Confirm     = $false
   ErrorAction = 'SilentlyContinue'
}
$null = (Remove-ItemProperty @paramRemoveItemProperty)

$paramRemoveItemProperty = @{
   LiteralPath = $RegPath2
   Name        = 'BlockUserFromShowingAccountDetailsOnSignin'
   Force       = $true
   Confirm     = $false
   ErrorAction = 'SilentlyContinue'
}
$null = (Remove-ItemProperty @paramRemoveItemProperty)
