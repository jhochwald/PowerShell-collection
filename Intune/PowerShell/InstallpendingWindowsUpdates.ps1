<#
      .SYNOPSIS
      Automates the PSWindowsUpdate module to install OS updates

      .DESCRIPTION
      Automates the PSWindowsUpdate module to install all pending OS and driver updates

      .PARAMETER PSWindowsUpdateVersion
      Module Version to use

      .EXAMPLE
      PS C:\> .\InstallpendingWindowsUpdates.ps1

      .LINK
      https://www.powershellgallery.com/packages/PSWindowsUpdate/

      .LINK
      https://github.com/mgajda83/PSWindowsUpdate

      .NOTES
      Based on PSWindowsUpdate by Michal Gajda
      Created for Endpoint Manager usage
#>
[CmdletBinding(ConfirmImpact = 'Low')]
param
(
   [Parameter(ValueFromPipeline,
              ValueFromPipelineByPropertyName)]
   [ValidateNotNullOrEmpty()]
   [string]
   $PSWindowsUpdateVersion = '2.2.0.3'
)

begin
{
   #region Global
   $SCT = 'SilentlyContinue'
   #endregion Global
   
   #region ARM64
   # If we are running as a 32-bit process on an x64 system, re-launch as a 64-bit process
   if ("$env:PROCESSOR_ARCHITEW6432" -ne 'ARM64')
   {
       if (Test-Path -Path ('{0}\SysNative\WindowsPowerShell\v1.0\powershell.exe' -f $env:WINDIR) -ErrorAction $SCT -WarningAction $SCT)
       {
           & "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe" -ExecutionPolicy bypass -NoProfile -File $PSCommandPath
           Exit $lastexitcode
       }
   }
   #endregion ARM64
   
   #region NuGetPackageProvider
   $paramGetPackageProvider = @{
      Name          = 'NuGet'
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if (-not (Get-PackageProvider @paramGetPackageProvider))
   {
      $paramInstallPackageProvider = @{
         Name            = 'NuGet'
         RequiredVersion = '2.8.5.201'
         scope           = 'AllUsers'
         Force           = $true
         ErrorAction     = $SCT
         WarningAction   = $SCT
      }
      $null = (Install-PackageProvider @paramInstallPackageProvider)
   }
   #endregion NuGetPackageProvider
   
   #region MakePSGalleryTrusted
   $paramGetPSRepository = @{
      Name          = 'PSGallery'
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if (Get-PSRepository @paramGetPSRepository | Where-Object -FilterScript {
         $PSItem.InstallationPolicy -ne 'Trusted'
      })
   {
      $paramSetPSRepository = @{
         Name               = 'PSGallery'
         InstallationPolicy = 'Trusted'
         ErrorAction        = $SCT
         WarningAction      = $SCT
      }
      $null = (Set-PSRepository @paramSetPSRepository)
   }
   #endregion MakePSGalleryTrusted
   
   #region CheckPSWindowsUpdate
   # Check if we have the latest version installed
   $paramGetModule = @{
      Name          = 'PSWindowsUpdate'
      ListAvailable = $true
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if (-not (Get-Module @paramGetModule | Sort-Object -Descending -Property Version | Select-Object -First 1 | Where-Object -FilterScript {
            $PSItem.Version -cge $PSWindowsUpdateVersion
         }))
   {
      # Get the latest
      $paramInstallModule = @{
         Name           = 'PSWindowsUpdate'
         Force          = $true
         MinimumVersion = $PSWindowsUpdateVersion
         Repository     = 'PSGallery'
         AllowClobber   = $true
         ErrorAction    = $SCT
         WarningAction  = $SCT
      }
      $null = (Install-Module @paramInstallModule)
   }
   #endregion CheckPSWindowsUpdate
   
   #region ImportPSWindowsUpdate
   $paramImportModule = @{
      Name                = 'PSWindowsUpdate'
      Force               = $true
      DisableNameChecking = $true
      NoClobber           = $true
      MinimumVersion      = $PSWindowsUpdateVersion
      ErrorAction         = $SCT
      WarningAction       = $SCT
   }
   $null = (Import-Module @paramImportModule)
   #endregion ImportPSWindowsUpdate
}

process
{
   #region InstallPendingDrivers
   try
   {
      Write-Output -InputObject 'Install all available drivers'
      
      $paramGetWindowsUpdate = @{
         Install         = $true
         MicrosoftUpdate = $true
         UpdateType      = 'Driver'
         IgnoreUserInput = $true
         AcceptAll       = $true
         IgnoreReboot    = $true
         ForceInstall    = $true
         ComputerName    = $env:ComputerName
         Confirm         = $false
         ErrorAction     = $SCT
         WarningAction   = $SCT
      }
      $null = (Get-WindowsUpdate @paramGetWindowsUpdate)
   }
   catch
   {
      Write-Verbose -Message 'Install all available drivers issue'
   }
   #endregion InstallPendingDrivers
   
   #region InstallPendingUpdates
   try
   {
      Write-Output -InputObject 'Install all available updates, except SilverLight'
      
      $paramGetWindowsUpdate = @{
         Install         = $true
         MicrosoftUpdate = $true
         NotKBArticleID  = 'KB4481252'
         IgnoreUserInput = $true
         AcceptAll       = $true
         IgnoreReboot    = $true
         ForceDownload   = $true
         ComputerName    = $env:ComputerName
         Confirm         = $false
         ErrorAction     = $SCT
         WarningAction   = $SCT
      }
      $null = (Get-WindowsUpdate @paramGetWindowsUpdate)
   }
   catch
   {
      Write-Verbose -Message 'Install all available updates issue'
   }
   #endregion InstallPendingUpdates
}

end
{
   $paramGetWURebootStatus = @{
      ComputerName  = $env:ComputerName
      Silent        = $true
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   $needReboot = ((Get-WURebootStatus @paramGetWURebootStatus).RebootRequired)
   
   if ($needReboot)
   {
      Write-Output -InputObject 'Reboot required'
      
      # Set return code 3010. As long as this happens during device ESP, the computer will automatically reboot at the end of device ESP.
      exit 3010
   }
   else
   {
      Write-Output -InputObject 'No reboot required'
      
      exit 0
   }
}
