#requires -Version 1.0

# Enable Cellular Data Roaming
# Remediation-EnableCellularDataRoaming

$RegPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WcmSvc\GroupPolicy'

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
   Name        = 'fBlockRoaming'
   Force       = $true
   Confirm     = $false
   ErrorAction = 'SilentlyContinue'
}
$null = (Remove-ItemProperty @paramRemoveItemProperty)
