#requires -Version 1.0

# Disable Cellular Data Roaming
# Remediation-DisableCellularDataRoaming

$Regpath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WcmSvc\GroupPolicy'

if ((Test-Path -LiteralPath $Regpath -ErrorAction SilentlyContinue) -ne $true)
{
   $paramNewItem = @{
      Path        = $Regpath
      Force       = $true
      Confirm     = $false
      ErrorAction = 'SilentlyContinue'
   }
   $null = (New-Item @paramNewItem)
}

$paramNewItemProperty = @{
   LiteralPath  = $Regpath
   Name         = 'fBlockRoaming'
   Value        = 1
   PropertyType = 'DWord'
   Force        = $true
   Confirm      = $false
   ErrorAction  = 'SilentlyContinue'
}
$null = (New-ItemProperty @paramNewItemProperty)
