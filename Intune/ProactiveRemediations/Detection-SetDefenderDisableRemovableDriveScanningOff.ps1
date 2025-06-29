# Detection: Enable the Microsoft Defender Removable Drive Scanning
# Detection-SetDefenderDisableRemovableDriveScanningOff.ps1

# Where to change something?
$RegPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Scan'

try
{
   # Does the target exists?
   if (!(Test-Path -LiteralPath $RegPath -ErrorAction SilentlyContinue))
   {
      exit 1
   }
   
   # Is the value correct?
   $paramGetItemPropertyValue = @{
      LiteralPath = $RegPath
      Name        = 'DisableRemovableDriveScanning'
      ErrorAction = 'SilentlyContinue'
   }
   if (!((Get-ItemPropertyValue @paramGetItemPropertyValue) -eq 0))
   {
      exit 1
   }
   $paramGetItemPropertyValue = $null
}
catch
{
   exit 1
}

exit 0
