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
      return $false
   }

   if (-not ((Get-ItemPropertyValue @paramSplat -Name 'KFMSilentOptIn') -eq $AzureADTenant))
   {
      return $false
   }

   if (-not ((Get-ItemPropertyValue @paramSplat -Name 'KFMSilentOptInWithNotification') -eq 1))
   {
      return $false
   }

   if (-not ((Get-ItemPropertyValue @paramSplat -Name 'KFMSilentOptInDesktop') -eq 1))
   {
      return $false
   }

   if (-not ((Get-ItemPropertyValue @paramSplat -Name 'KFMSilentOptInDocuments') -eq 1))
   {
      return $false
   }

   if (-not ((Get-ItemPropertyValue @paramSplat -Name 'KFMSilentOptInPictures') -eq 1))
   {
      return $false
   }

   if (-not ((Get-ItemPropertyValue @paramSplat -Name 'SilentAccountConfig') -eq 1))
   {
      return $false
   }

   if (-not ((Get-ItemPropertyValue @paramSplat -Name 'KFMOptInWithWizard') -eq 'The VIER IT team wants you to protect your important folders'))
   {
      return $false
   }

   if (-not ((Get-ItemPropertyValue @paramSplat -Name 'GPOSetUpdateRing') -eq 4))
   {
      return $false
   }

   if (-not ((Get-ItemPropertyValue @paramSplat -Name 'FilesOnDemandEnabled') -eq 1))
   {
      return $false
   }

   if (-not ((Get-ItemPropertyValue @paramSplat -Name 'WarningMinDiskSpaceLimitInMB') -eq 1280))
   {
      return $false
   }

   if (-not ((Get-ItemPropertyValue @paramSplat -Name 'MinDiskSpaceLimitInMB') -eq 768))
   {
      return $false
   }

   if (-not ((Get-ItemPropertyValue @paramSplat -Name 'EnableAutomaticUploadBandwidthManagement') -eq 1))
   {
      return $false
   }
}
catch
{
   return $false
}

return $true
#endregion
#endregion Check