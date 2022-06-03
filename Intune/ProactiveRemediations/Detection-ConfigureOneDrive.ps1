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

#region Check
# Registry Path
$RegistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\OneDrive'

# AzureAD TenantID
$AzureADTenant = '0e603135-2ea1-4694-89f4-5c1e8703c2d4'

try
{
   #region Splat
   $paramSplat = $null
   $paramSplat = @{
      LiteralPath = $RegistryPath
      ErrorAction = 'SilentlyContinue'
   }
   #endregion Splat

   if (-not (Test-Path @paramSplat))
   {
      exit 1
   }

   if (-not ((Get-ItemPropertyValue @paramSplat -Name 'KFMSilentOptIn') -eq $AzureADTenant))
   {
      exit 1
   }

   if (-not ((Get-ItemPropertyValue @paramSplat -Name 'KFMSilentOptInWithNotification') -eq 1))
   {
      exit 1
   }

   if (-not ((Get-ItemPropertyValue @paramSplat -Name 'KFMSilentOptInDesktop') -eq 1))
   {
      exit 1
   }

   if (-not ((Get-ItemPropertyValue @paramSplat -Name 'KFMSilentOptInDocuments') -eq 1))
   {
      exit 1
   }

   if (-not ((Get-ItemPropertyValue @paramSplat -Name 'KFMSilentOptInPictures') -eq 1))
   {
      exit 1
   }

   if (-not ((Get-ItemPropertyValue @paramSplat -Name 'SilentAccountConfig') -eq 1))
   {
      exit 1
   }

   if (-not ((Get-ItemPropertyValue @paramSplat -Name 'KFMOptInWithWizard') -eq 'The VIER IT team wants you to protect your important folders'))
   {
      exit 1
   }

   if (-not ((Get-ItemPropertyValue @paramSplat -Name 'GPOSetUpdateRing') -eq 4))
   {
      exit 1
   }

   if (-not ((Get-ItemPropertyValue @paramSplat -Name 'FilesOnDemandEnabled') -eq 1))
   {
      exit 1
   }

   if (-not ((Get-ItemPropertyValue @paramSplat -Name 'WarningMinDiskSpaceLimitInMB') -eq 1280))
   {
      exit 1
   }

   if (-not ((Get-ItemPropertyValue @paramSplat -Name 'MinDiskSpaceLimitInMB') -eq 768))
   {
      exit 1
   }

   if (-not ((Get-ItemPropertyValue @paramSplat -Name 'EnableAutomaticUploadBandwidthManagement') -eq 1))
   {
      exit 1
   }
}
catch
{
   exit 1
}

exit 0
#endregion
#endregion Check
