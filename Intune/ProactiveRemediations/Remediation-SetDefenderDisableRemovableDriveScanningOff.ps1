# Remediation: Enable the Microsoft Defender Removable Drive Scanning
# Remediation-SetDefenderDisableRemovableDriveScanningOff.ps1

# Where to change something?
$RegPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Scan'

# Does the target exists?
if ((Test-Path -LiteralPath $RegPath -ErrorAction SilentlyContinue) -ne $true)
{
   # Create the target path
   @{
      Path        = $RegPath
      Force       = $true
      Confirm     = $false
      ErrorAction = 'SilentlyContinue'
   }
   $null = (New-Item @paramNewItem)
   $paramNewItem = $null
}

# Enforce the setting we want!
$paramNewItemProperty = @{
   LiteralPath  = $RegPath
   Name         = 'DisableRemovableDriveScanning'
   Value        = 0
   PropertyType = 'DWord'
   Force        = $true
   Confirm      = $false
   ErrorAction  = 'SilentlyContinue'
}
$null = (New-ItemProperty @paramNewItemProperty)
$paramNewItemProperty = $null
