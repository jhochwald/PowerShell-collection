#region ARM64Handling
# Restart Process using PowerShell 64-bit
if ($ENV:PROCESSOR_ARCHITEW6432 -eq 'AMD64')
{
   try
   {
      &"$ENV:WINDIR\SysNative\WindowsPowershell\v1.0\PowerShell.exe" -File $PSCOMMANDPATH
   }
   catch
   {
      Throw ('Failed to start {0}' -f $PSCOMMANDPATH)
   }

   exit
}
#endregion ARM64Handling

#region Remediation
# Registry Path
$RegistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\OneDrive'

# AzureAD TenantID
$AzureADTenant = '0e603135-2ea1-4694-89f4-5c1e8703c2d4'

#region
if ((Test-Path -LiteralPath $RegistryPath -ErrorAction SilentlyContinue) -ne $true)
{
   $null = (New-Item -Path $RegistryPath -Force -Confirm:$false -ErrorAction SilentlyContinue)
}
#endregion

#region Splat
$paramSplat = $null
$paramSplat = @{
   LiteralPath = $RegistryPath
   Force       = $true
   Confirm     = $false
   ErrorAction = 'SilentlyContinue'
}
#endregion Splat

# Enforce the settings, no further check needed!
$null = (New-ItemProperty @paramSplat -Name 'KFMSilentOptIn' -Value $AzureADTenant -PropertyType String)
$null = (New-ItemProperty @paramSplat -Name 'KFMSilentOptInWithNotification' -Value 1 -PropertyType DWord)
$null = (New-ItemProperty @paramSplat -Name 'KFMSilentOptInDesktop' -Value 1 -PropertyType DWord)
$null = (New-ItemProperty @paramSplat -Name 'KFMSilentOptInDocuments' -Value 1 -PropertyType DWord)
$null = (New-ItemProperty @paramSplat -Name 'KFMSilentOptInPictures' -Value 1 -PropertyType DWord)
$null = (New-ItemProperty @paramSplat -Name 'SilentAccountConfig' -Value 1 -PropertyType DWord)
$null = (New-ItemProperty @paramSplat -Name 'KFMOptInWithWizard' -Value 'The VIER IT team wants you to protect your important folders' -PropertyType String)
$null = (New-ItemProperty @paramSplat -Name 'GPOSetUpdateRing' -Value 4 -PropertyType DWord)
$null = (New-ItemProperty @paramSplat -Name 'FilesOnDemandEnabled' -Value 1 -PropertyType DWord)
$null = (New-ItemProperty @paramSplat -Name 'WarningMinDiskSpaceLimitInMB' -Value 1280 -PropertyType DWord)
$null = (New-ItemProperty @paramSplat -Name 'MinDiskSpaceLimitInMB' -Value 768 -PropertyType DWord)
$null = (New-ItemProperty @paramSplat -Name 'EnableAutomaticUploadBandwidthManagement' -Value 1 -PropertyType DWord)

exit 0
#endregion Remediation
