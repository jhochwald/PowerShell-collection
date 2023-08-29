#requires -Version 1.0

# Disable "Interactive logon: Don't display last signed-in"
# Remediation-DisableDontDisplayLastSignedinUser

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

$paramRemoveItemProperty = @{
   LiteralPath = $RegPath
   Name        = 'dontdisplaylastusername'
   Force       = $true
   Confirm     = $false
   ErrorAction = 'SilentlyContinue'
}
$null = (Remove-ItemProperty @paramRemoveItemProperty)
