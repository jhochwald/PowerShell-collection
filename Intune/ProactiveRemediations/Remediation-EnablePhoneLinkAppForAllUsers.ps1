#requires -Version 1.0

# Enable Phone Link app for All Users
# Remediation-EnablePhoneLinkAppForAllUsers

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

$paramRemoveItemProperty = @{
   LiteralPath = $RegPath
   Name        = 'EnableMmx'
   Force       = $true
   Confirm     = $false
   ErrorAction = 'SilentlyContinue'
}
$null = (Remove-ItemProperty @paramRemoveItemProperty)
