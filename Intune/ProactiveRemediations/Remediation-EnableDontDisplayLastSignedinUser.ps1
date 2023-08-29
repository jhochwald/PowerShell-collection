#requires -Version 1.0

# Enable "Interactive logon: Don't display last signed-in"
# Remediation-EnableDontDisplayLastSignedinUser

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

$paramNewItemProperty = @{
   LiteralPath  = $RegPath
   Name         = 'dontdisplaylastusername'
   Value        = 1
   PropertyType = 'DWord'
   Force        = $true
   Confirm      = $false
   ErrorAction  = 'SilentlyContinue'
}
$null = (New-ItemProperty @paramNewItemProperty)
