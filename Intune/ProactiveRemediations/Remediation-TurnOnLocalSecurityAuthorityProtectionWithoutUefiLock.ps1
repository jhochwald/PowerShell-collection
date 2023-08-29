#requires -Version 1.0

# Turn On Local Security Authority (LSA) Protection without UEFI Lock
# Remediation-TurnOnLocalSecurityAuthorityProtectionWithoutUefiLock

$RegPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'

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
   Name         = 'RunAsPPL'
   Value        = 2
   PropertyType = 'DWord'
   Force        = $true
   Confirm      = $false
   ErrorAction  = 'SilentlyContinue'
}
$null = (New-ItemProperty @paramNewItemProperty)

$paramNewItemProperty = @{
   LiteralPath  = $RegPath
   Name         = 'RunAsPPLBoot'
   Value        = 2
   PropertyType = 'DWord'
   Force        = $true
   Confirm      = $false
   ErrorAction  = 'SilentlyContinue'
}
$null = (New-ItemProperty @paramNewItemProperty)
