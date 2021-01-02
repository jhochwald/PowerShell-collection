#requires -Version 5.0 -RunAsAdministrator

<#
      .SYNOPSIS
      Bootstrap Windows 10 System

      .DESCRIPTION
      Bootstrap Windows 10 System with the default configuration.
      Tested with the latest Windows 10 (Enterprise and Professional) releases.

      .NOTES
      Changelog:
      2.0.9:  Windows Hello Video is no longer removed (Requested)
      2.0.8:  Removed the Enable DNS-over-HTTPS part (own script)
      2.0.7:  Add a few more tweaks
      2.0.6:  Add "Make Me Admin" default config
      2.0.5:  Change a few handlers for WindowsFeatures
      2.0.4:  Remove Edge icon on desktop
      2.0.3:  Remove the 20H2 Edge Autostart
      2.0.2:  Remove First Run Experience for Edge

      Version 2.2.0

      Lot of the stuff of this version is adopted from Disassembler <disassembler@dasm.cz>

      .LINK
      http://enatec.io

      .LINK
      https://github.com/Disassembler0/Win10-Initial-Setup-Script
#>
[CmdletBinding(ConfirmImpact = 'Low')]
param ()

begin
{
   Write-Output -InputObject 'Bootstrap Windows 10 System'

   #region GlobalDefaults
   $SCT = 'SilentlyContinue'

   $paramGetCommand = @{
      Name        = 'Set-MpPreference'
      ErrorAction = $SCT
   }
   if (Get-Command @paramGetCommand)
   {
      $paramSetMpPreference = @{
         EnableControlledFolderAccess = 'Disabled'
         Force                        = $true
         ErrorAction                  = $SCT
      }
      $null = (Set-MpPreference @paramSetMpPreference)
   }

   $paramRemoveItemProperty = @{
      Force       = $true
      Confirm     = $false
      ErrorAction = $SCT
   }
   #endregion GlobalDefaults

   #region HelperFunction
   function Confirm-RegistryItemProperty
   {
      <#
            .SYNOPSIS
            Enforce that an item property in the registry

            .DESCRIPTION
            Enforce that an item property in the registry

            .PARAMETER Path
            Registry Path

            .PARAMETER PropertyType
            The Property Type

            .PARAMETER Value
            The Registry Value to set

            .EXAMPLE
            PS C:\> Confirm-RegistryItemProperty -Path 'HKLM:\System\CurrentControlSet\Services\PimIndexMaintenanceSvc\Start' -PropertyType 'DWord' -Value '1'

            .NOTES
            Fixed version of the Helper:
            Recreate the Key if the Type is wrong (Possible cause the old version had a glitsch)
      #>
      [CmdletBinding(ConfirmImpact = 'None', SupportsShouldProcess)]
      param
      (
         [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            HelpMessage = 'Add help message for user')]
         [ValidateNotNullOrEmpty()]
         [Alias('RegistryPath')]
         [string]
         $Path,
         [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            HelpMessage = 'Add help message for user')]
         [ValidateNotNullOrEmpty()]
         [Alias('Property', 'Type')]
         [string]
         $PropertyType,
         [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName)]
         [AllowEmptyCollection()]
         [AllowEmptyString()]
         [AllowNull()]
         [Alias('RegistryValue')]
         $Value
      )

      begin
      {
         #region
         $SCT = 'SilentlyContinue'
         #endregion
      }

      process
      {
         $paramTestPath = @{
            Path          = ($Path | Split-Path)
            WarningAction = $SCT
            ErrorAction   = $SCT
         }
         if (-Not (Test-Path @paramTestPath))
         {
            $paramNewItem = @{
               Path          = ($Path | Split-Path)
               Force         = $true
               WarningAction = $SCT
               ErrorAction   = $SCT
            }
            $null = (New-Item @paramNewItem)
         }

         $paramGetItemProperty = @{
            Path          = ($Path | Split-Path)
            Name          = ($Path | Split-Path -Leaf)
            WarningAction = $SCT
            ErrorAction   = $SCT
         }
         if (-Not (Get-ItemProperty @paramGetItemProperty))
         {
            $paramNewItemProperty = @{
               Path          = ($Path | Split-Path)
               Name          = ($Path | Split-Path -Leaf)
               PropertyType  = $PropertyType
               Value         = $Value
               Force         = $true
               Confirm       = $false
               WarningAction = $SCT
               ErrorAction   = $SCT
            }
            $null = (New-ItemProperty @paramNewItemProperty)
         }
         else
         {
            #region Workaround
            $paramGetItem = @{
               Path          = ($Path | Split-Path)
               ErrorAction   = $SCT
               WarningAction = $SCT
            }
            if (((Get-Item @paramGetItem).GetValueKind(($Path | Split-Path -Leaf))) -ne $PropertyType)
            {
               # The PropertyType is wrong! This might be an issue of our old version! Sorry for the glitsch
               $paramRemoveItemProperty = @{
                  Path          = ($Path | Split-Path)
                  Name          = ($Path | Split-Path -Leaf)
                  Force         = $true
                  Confirm       = $false
                  WarningAction = $SCT
                  ErrorAction   = $SCT
               }
               $null = (Remove-ItemProperty @paramRemoveItemProperty)

               $paramNewItemProperty = @{
                  Path          = ($Path | Split-Path)
                  Name          = ($Path | Split-Path -Leaf)
                  PropertyType  = $PropertyType
                  Value         = $Value
                  Force         = $true
                  Confirm       = $false
                  WarningAction = $SCT
                  ErrorAction   = $SCT
               }
               $null = (New-ItemProperty @paramNewItemProperty)
            }
            else
            {
               # Regular handling: PropertyType was correct
               $paramSetItemProperty = @{
                  Path          = ($Path | Split-Path)
                  Name          = ($Path | Split-Path -Leaf)
                  Value         = $Value
                  Force         = $true
                  Confirm       = $false
                  WarningAction = $SCT
                  ErrorAction   = $SCT
               }
               $null = (Set-ItemProperty @paramSetItemProperty)
            }
            #endregion Workaround
         }
      }
   }
   #endregion HelperFunction
}

process
{
   # Stop Search - Gain performance
   $paramGetService = @{
      Name        = 'WSearch'
      ErrorAction = $SCT
   }
   $paramStopService = @{
      Force       = $true
      Confirm     = $false
      ErrorAction = $SCT
   }
   $null = (Get-Service @paramGetService | Where-Object -FilterScript {
         $_.Status -eq 'Running'
      } | Stop-Service @paramStopService)

   #region PrivacyTweaks
   # Turn off the "Previous Versions" tab from properties context menu
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\NoPreviousVersionsPage'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   # Do not use sign-in info to automatically finish setting up device after an update or restart
   $paramGetCimInstance = @{
      ClassName     = 'Win32_UserAccount'
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   $sid = ((Get-CimInstance @paramGetCimInstance | Where-Object -FilterScript {
            $_.Name -eq ($env:USERNAME)
         }).SID)
   $paramConfirmRegistryItemProperty = @{
      Path         = ('HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\UserARSO\' + $sid + 'OptOut')
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   #region DisableTelemetry
   $paramGetWindowsEdition = @{
      Online        = $true
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   $WindowsEditionEdition = ((Get-WindowsEdition @paramGetWindowsEdition) | Select-Object -ExpandProperty Edition)

   if (($WindowsEditionEdition -eq 'Enterprise') -or ($WindowsEditionEdition -eq 'Education'))
   {
      $paramConfirmRegistryItemProperty = @{
         Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection\AllowTelemetry'
         PropertyType = 'DWord'
         Value        = '0'
         ErrorAction  = $SCT
      }
      $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   }
   else
   {
      $paramConfirmRegistryItemProperty = @{
         Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection\AllowTelemetry'
         PropertyType = 'DWord'
         Value        = '1'
         ErrorAction  = $SCT
      }
      $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   }

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection\AllowTelemetry'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection\AllowTelemetry'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds\AllowBuildPreview'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\Software Protection Platform\NoGenTicket'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows\CEIPEnable'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat\AITEnable'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat\DisableInventory'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\AppV\CEIP\CEIPEnable'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\TabletPC\PreventHandwritingDataSharing'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\TextInput\AllowLinguisticDataCollection'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramGetScheduledTask = @{
      TaskName    = 'Microsoft Compatibility Appraiser', 'ProgramDataUpdater', 'Consolidator', 'KernelCeipTask', 'UsbCeip', 'Microsoft-Windows-DiskDiagnosticDataCollector', 'GatherNetworkInfo', 'QueueReporting'
      ErrorAction = $SCT
   }
   $null = (Get-ScheduledTask @paramGetScheduledTask | Disable-ScheduledTask -ErrorAction $SCT)
   #endregion DisableTelemetry

   #region DisableWiFiSense
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting\value'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspot\value'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config\AutoConnectAllowedOEM'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config\WiFISenseAllowed'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableWiFiSense

   #region DisableWebSearch
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search\DisableWebSearch'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableWebSearch

   #region DisableAppSuggestions
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent\DisableWindowsConsumerFeatures'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\WindowsInkWorkspace\AllowSuggestedAppsInWindowsInkWorkspace'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableAppSuggestions

   #region DisableActivityHistory
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System\EnableActivityFeed'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System\PublishUserActivities'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System\UploadUserActivities'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableActivityHistory

   #region HideQuickAccess
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HubMode'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion HideQuickAccess

   #region DisableBackgroundApps
   $ExcludedApps = @('Microsoft.LockApp*', 'Microsoft.Windows.ContentDeliveryManager*', 'Microsoft.Windows.Cortana*', 'Microsoft.Windows.SecHealthUI*', 'Microsoft.Windows.ShellExperienceHost*', 'Microsoft.Windows.StartMenuExperienceHost*')
   $OFS = '|'
   $paramGetChildItem = @{
      Path        = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications'
      ErrorAction = $SCT
   }
   $null = (Get-ChildItem @paramGetChildItem | Where-Object -FilterScript {
         $_.PSChildName -cnotmatch $ExcludedApps
      } | ForEach-Object -Process {
         $paramConfirmRegistryItemProperty = @{
            Path         = ($_.PsPath + 'Disabled')
            PropertyType = 'DWord'
            Value        = '1'
            ErrorAction  = $SCT
         }
         $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
         $paramConfirmRegistryItemProperty = @{
            Path         = ($_.PsPath + 'DisabledByUser')
            PropertyType = 'DWord'
            Value        = '1'
            ErrorAction  = $SCT
         }

         $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
      })
   $OFS = ' '
   #endregion DisableBackgroundApps

   #region EnableSensors
   $null = (Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors' -Name 'DisableSensors' @paramRemoveItemProperty)
   #endregion EnableSensors

   #region DisableLocation
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors\DisableLocation'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors\DisableLocationScripting'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableLocation

   #region DisableMapUpdates
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SYSTEM\Maps\AutoUpdateEnabled'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableMapUpdates

   #region DisableFeedback
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection\DoNotShowFeedbackNotifications'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   $paramDisableScheduledTask = @{
      TaskName    = 'Microsoft\Windows\Feedback\Siuf\DmClient'
      ErrorAction = $SCT
   }
   $null = (Disable-ScheduledTask @paramDisableScheduledTask)
   $paramDisableScheduledTask = @{
      TaskName    = 'Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload'
      ErrorAction = $SCT
   }
   $null = (Disable-ScheduledTask @paramDisableScheduledTask)
   #endregion DisableFeedback

   #region DisableTailoredExperiences
   #endregion DisableTailoredExperiences

   #region DisableAdvertisingID
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo\DisabledByGroupPolicy'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableAdvertisingID

   #region DisableWebLangList
   #endregion DisableWebLangList

   #region DisableCortana
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search\AllowCortana'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization\AllowInputPersonalization'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Experience\AllowCortana\Value'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableCortana

   #region EnableBiometrics
   $null = (Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Biometrics\' -Name 'Enabled' @paramRemoveItemProperty)
   #endregion EnableBiometrics

   #region EnableCamera
   $null = (Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Camera' -Name 'AllowCamera' @paramRemoveItemProperty)
   #endregion EnableCamera

   #region EnableMicrophone
   $null = (Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy' -Name 'LetAppsAccessMicrophone' @paramRemoveItemProperty)
   #endregion EnableMicrophone

   #region DisableErrorReporting
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting\Disabled'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   $null = (Disable-ScheduledTask -TaskName 'Microsoft\Windows\Windows Error Reporting\QueueReporting')
   #endregion DisableErrorReporting

   #region SetP2PUpdateLocal
   # TODO: Convert to switch
   if ([Environment]::OSVersion.Version.Build -eq 10240)
   {
      # Method used in 1507
      $paramConfirmRegistryItemProperty = @{
         Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config\DODownloadMode'
         PropertyType = 'DWord'
         Value        = '1'
         ErrorAction  = $SCT
      }
      $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   }
   elseif ([Environment]::OSVersion.Version.Build -le 14393)
   {
      # Method used in 1511 and 1607
      $paramConfirmRegistryItemProperty = @{
         Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization\DODownloadMode'
         PropertyType = 'DWord'
         Value        = '1'
         ErrorAction  = $SCT
      }
      $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   }
   else
   {
      # Method used since 1703
      $null = (Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization' -Name 'DODownloadMode' @paramRemoveItemProperty)
   }
   #endregion SetP2PUpdateLocal

   #region EnableSyncForegroundPolicy
   # Always wait for the network at computer startup and logon
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\Winlogon\SyncForegroundPolicy'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion EnableSyncForegroundPolicy

   #region EnableUseOLEDTaskbarTransparency
   # Turn on acrylic taskbar transparency
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\UseOLEDTaskbarTransparency'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion EnableUseOLEDTaskbarTransparency

   $paramStopService = @{
      Force         = $true
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $paramSetService = @{
      StartupType = 'Disabled'
      ErrorAction = $SCT
   }

   #region DisableDiagTrack
   $paramGetService = @{
      Name          = 'DiagTrack'
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (Get-Service @paramGetService | Stop-Service @paramStopService)
   $null = (Get-Service @paramGetService | Set-Service @paramSetService)
   #endregion DisableDiagTrack

   #region WMPNetworkSvc
   $paramGetService = @{
      Name          = 'WMPNetworkSvc'
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (Get-Service @paramGetService | Stop-Service @paramStopService)
   $null = (Get-Service @paramGetService | Set-Service @paramSetService)
   #endregion WMPNetworkSvc

   #region DisableContactData
   $paramGetService = @{
      Name          = 'PimIndexMaintenanceSvc_*'
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (Get-Service @paramGetService | Stop-Service @paramStopService)
   $null = (Get-Service @paramGetService | Set-Service @paramSetService)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\System\CurrentControlSet\Services\PimIndexMaintenanceSvc\Start'
      PropertyType = 'DWord'
      Value        = '4'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\System\CurrentControlSet\Services\PimIndexMaintenanceSvc\UserServiceFlags'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableContactData

   #region EnableActiveProbing
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\System\CurrentControlSet\Services\NlaSvc\Parameters\Internet\EnableActiveProbing\EnableActiveProbing'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion EnableActiveProbing

   #region DisableUserDataStorage
   $paramGetService = @{
      Name          = 'UnistoreSvc_*'
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (Get-Service @paramGetService | Stop-Service @paramStopService)
   $null = (Get-Service @paramGetService | Set-Service @paramSetService)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\System\CurrentControlSet\Services\UnistoreSvc\Start'
      PropertyType = 'DWord'
      Value        = '4'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\System\CurrentControlSet\Services\UnistoreSvc\UserServiceFlags'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableUserDataStorage

   #region DisableUserDataAccess
   $paramGetService = @{
      Name          = 'UserDataSvc_*'
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (Get-Service @paramGetService | Stop-Service @paramStopService)
   $null = (Get-Service @paramGetService | Set-Service @paramSetService)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\System\CurrentControlSet\Services\UserDataSvc\Start'
      PropertyType = 'DWord'
      Value        = '4'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\System\CurrentControlSet\Services\UserDataSvc\UserServiceFlags'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableUserDataAccess

   #region StopEventTraceSessions
   $paramGetEtwTraceSession = @{
      Name        = 'DiagLog'
      ErrorAction = $SCT
   }
   $paramStopEtwTraceSession = @{
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (Get-EtwTraceSession @paramGetEtwTraceSession | Stop-EtwTraceSession @paramStopEtwTraceSession)
   #endregion StopEventTraceSessions

   #region UpdateAutologgerConfig
   # Turn off the data collectors at the next computer restart
   $null = (Update-AutologgerConfig -Name DiagLog, AutoLogger-Diagtrack-Listener -Start 0 -ErrorAction $SCT)
   #endregion UpdateAutologgerConfig

   #region EnableWAPPush
   $paramSetService = @{
      Name          = 'dmwappushservice'
      StartupType   = 'Automatic'
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (Set-Service @paramSetService)
   $paramStartService = @{
      Name          = 'dmwappushservice'
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (Start-Service @paramStartService)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SYSTEM\CurrentControlSet\Services\dmwappushservice\DelayedAutoStart'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion EnableWAPPush

   #region EnableClearRecentFiles
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer\ClearRecentDocsOnExit'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion EnableClearRecentFiles

   #region DisableRecentFiles
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer\NoRecentDocsHistory'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableRecentFiles
   #endregion PrivacyTweaks

   #region SecurityTweaks
   #region SetUACHigh
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\ConsentPromptBehaviorAdmin'
      PropertyType = 'DWord'
      Value        = '5'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\PromptOnSecureDesktop'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion SetUACHigh

   #region EnableSharingMappedDrives
   # Turn on access to mapped drives from app running with elevated permissions with Admin Approval Mode enabled
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\EnableLinkedConnections'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion EnableSharingMappedDrives

   #region EnableAdminShares
   $null = (Remove-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters' -Name 'AutoShareWks' @paramRemoveItemProperty)
   #endregion EnableAdminShares

   #region EnableFirewall
   $null = (Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile' -Name 'EnableFirewall' @paramRemoveItemProperty)
   #endregion EnableFirewall

   #region ShowDefenderTrayIcon
   $null = (Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Systray' -Name 'HideSystray' @paramRemoveItemProperty)

   # TODO: Convert to switch
   if ([Environment]::OSVersion.Version.Build -eq 14393)
   {
      $paramConfirmRegistryItemProperty = @{
         Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\WindowsDefender'
         PropertyType = 'ExpandString'
         Value        = "`"%ProgramFiles%\Windows Defender\MSASCuiL.exe`""
         ErrorAction  = $SCT
      }
      $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   }
   elseif ([Environment]::OSVersion.Version.Build -ge 15063 -And [Environment]::OSVersion.Version.Build -le 17134)
   {
      $paramConfirmRegistryItemProperty = @{
         Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\SecurityHealth'
         PropertyType = 'ExpandString'
         Value        = '%ProgramFiles%\Windows Defender\MSASCuiL.exe'
         ErrorAction  = $SCT
      }
      $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   }
   elseif ([Environment]::OSVersion.Version.Build -ge 17763)
   {
      $paramConfirmRegistryItemProperty = @{
         Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\SecurityHealth'
         PropertyType = 'ExpandString'
         Value        = '%windir%\system32\SecurityHealthSystray.exe'
         ErrorAction  = $SCT
      }
      $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   }
   #endregion ShowDefenderTrayIcon

   #region EnableDefender
   $null = (Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender' -Name 'DisableAntiSpyware' @paramRemoveItemProperty)

   # TODO: Convert to switch
   if ([Environment]::OSVersion.Version.Build -eq 14393)
   {
      $paramConfirmRegistryItemProperty = @{
         Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\WindowsDefender'
         PropertyType = 'ExpandString'
         Value        = "`"%ProgramFiles%\Windows Defender\MSASCuiL.exe`""
         ErrorAction  = $SCT
      }
      $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   }
   elseif ([Environment]::OSVersion.Version.Build -ge 15063 -And [Environment]::OSVersion.Version.Build -le 17134)
   {
      $paramConfirmRegistryItemProperty = @{
         Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\SecurityHealth'
         PropertyType = 'ExpandString'
         Value        = '%ProgramFiles%\Windows Defender\MSASCuiL.exe'
         ErrorAction  = $SCT
      }
      $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   }
   elseif ([Environment]::OSVersion.Version.Build -ge 17763)
   {
      $paramConfirmRegistryItemProperty = @{
         Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\SecurityHealth'
         PropertyType = 'ExpandString'
         Value        = '%windir%\system32\SecurityHealthSystray.exe'
         ErrorAction  = $SCT
      }
      $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   }
   #endregion EnableDefender

   #region EnableDefenderCloud
   $null = (Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet' -Name 'SpynetReporting' @paramRemoveItemProperty)
   $null = (Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet' -Name 'SubmitSamplesConsent' @paramRemoveItemProperty)
   #endregion EnableDefenderCloud

   #region EnableControlledFolderAccess
   $null = (Set-MpPreference -EnableControlledFolderAccess Enabled -ErrorAction $SCT)
   #endregion EnableControlledFolderAccess

   #region EnableCoreIsolationMemoryIntegrity
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity\Enabled'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion EnableCoreIsolationMemoryIntegrity

   #region EnableDefenderApplicationGuard
   $paramEnableWindowsOptionalFeature = @{
      Online        = $true
      FeatureName   = 'Windows-Defender-ApplicationGuard'
      NoRestart     = $true
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (Enable-WindowsOptionalFeature @paramEnableWindowsOptionalFeature)
   #endregion EnableDefenderApplicationGuard

   #region EnableDotNetStrongCrypto
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319\SchUseStrongCrypto'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319\SchUseStrongCrypto'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion EnableDotNetStrongCrypto

   #region DisableF8BootMenu
   $null = (& "$env:windir\system32\bcdedit.exe" /set `{current`} BootMenuPolicy Standard)
   #endregion DisableF8BootMenu

   #region DisableBootRecovery
   $null = (& "$env:windir\system32\bcdedit.exe" /set `{current`} BootStatusPolicy IgnoreAllFailures)
   #endregion DisableBootRecovery

   #region SetDEPOptIn
   $null = (& "$env:windir\system32\bcdedit.exe" /set `{current`} nx OptIn)
   #endregion SetDEPOptIn
   #endregion SecurityTweaks

   #region NetworkTweaks
   #region SetUnknownNetworksPublic
   $null = (Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\NetworkList\Signatures\010103000F0000F0010000000F0000F0C967A3643C3AD745950DA7859209176EF5B87C875FA20DF21951640E807D7C24' -Name 'Category' @paramRemoveItemProperty)
   #endregion SetUnknownNetworksPublic

   #region DisableNetDevicesAutoInstallation
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\NcdAutoSetup\Private\AutoSetup'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableNetDevicesAutoInstallation

   #region DisableHomeGroups
   $paramStopService = @{
      Force         = $true
      Confirm       = $false
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $paramSetService = @{
      StartupType   = 'Disabled'
      Confirm       = $false
      WarningAction = $SCT
      ErrorAction   = $SCT
   }

   $paramGetService = @{
      Name          = 'HomeGroupListener'
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (Get-Service @paramGetService | Stop-Service @paramStopService)
   $null = (Get-Service @paramGetService | Set-Service @paramSetService)

   $paramGetService = @{
      Name          = 'HomeGroupProvider'
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (Get-Service @paramGetService | Stop-Service @paramStopService)
   $null = (Get-Service @paramGetService | Set-Service @paramSetService)
   #endregion DisableHomeGroups

   #region DisableSMB1Protocol
   $paramSetSmbServerConfiguration = @{
      EnableSMB1Protocol = $false
      Force              = $true
      WarningAction      = $SCT
      ErrorAction        = $SCT
   }
   $null = (Set-SmbServerConfiguration @paramSetSmbServerConfiguration)
   #endregion DisableSMB1Protocol

   #region DisableSMB1Server
   $paramSetSmbServerConfiguration = @{
      EnableSMB1Protocol = $false
      Force              = $true
      WarningAction      = $SCT
      ErrorAction        = $SCT
   }
   $null = (Set-SmbServerConfiguration @paramSetSmbServerConfiguration)
   #endregion DisableSMB1Server

   #region DisableNetBIOSOverTCP
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SYSTEM\CurrentControlSet\services\NetBT\Parameters\Interfaces\Tcpip*\NetbiosOptions'
      PropertyType = 'DWord'
      Value        = 2
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableNetBIOSOverTCP

   #region DisableLLMNR
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient\EnableMulticast'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableLLMNR

   #region DisableLLDP
   $paramDisableNetAdapterBinding = @{
      Name          = '*'
      ComponentID   = 'ms_lldp'
      WarningAction = $SCT
      ErrorAction   = $SCT
   }

   $null = (Disable-NetAdapterBinding @paramDisableNetAdapterBinding)
   #endregion DisableLLDP

   #region DisableLLTD
   $paramDisableNetAdapterBinding = @{
      Name          = '*'
      ComponentID   = 'ms_lltdio'
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (Disable-NetAdapterBinding @paramDisableNetAdapterBinding)

   $paramDisableNetAdapterBinding = @{
      Name          = '*'
      ComponentID   = 'ms_rspndr'
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (Disable-NetAdapterBinding @paramDisableNetAdapterBinding)
   #endregion DisableLLTD

   #region EnableQoS
   $paramEnableNetAdapterBinding = @{
      Name          = '*'
      ComponentID   = 'ms_pacer'
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (Enable-NetAdapterBinding @paramEnableNetAdapterBinding)
   #endregion EnableQoS

   #region EnableIPv4Stack
   $paramEnableNetAdapterBinding = @{
      Name          = '*'
      ComponentID   = 'ms_tcpip'
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (Enable-NetAdapterBinding @paramEnableNetAdapterBinding)
   #endregion EnableIPv4Stack

   #region EnableIPv6Stack
   $paramEnableNetAdapterBinding = @{
      Name          = '*'
      ComponentID   = 'ms_tcpip6'
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (Enable-NetAdapterBinding @paramEnableNetAdapterBinding)
   #endregion EnableIPv6Stack

   #region DisableNCSIProbe
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\NetworkConnectivityStatusIndicator\NoActiveProbe'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableNCSIProbe

   #region DisableConnectionSharing
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Network Connections\NC_ShowSharedAccessUI'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableConnectionSharing

   #region DisableRemoteAssistance
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance\fAllowToGetHelp'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableRemoteAssistance

   #region EnableRemoteDesktop
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\fDenyTSConnections'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramEnableNetFirewallRule = @{
      Name          = 'RemoteDesktop*'
      Confirm       = $false
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (Enable-NetFirewallRule @paramEnableNetFirewallRule)
   #endregion EnableRemoteDesktop
   #endregion NetworkTweaks

   #region ServiceTweaks
   #region DisableApplicationCompatibilityEngine
   # Disable Application Compatibility Engine and Program Compatibility Assistant
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\Software\Policies\Microsoft\Windows\AppCompat\DisableEngine'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableApplicationCompatibilityEngine

   #region DisableProgramCompatibilityAssistant
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\Software\Policies\Microsoft\Windows\AppCompat\DisablePCA'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableProgramCompatibilityAssistant

   #region EnableUpdateMSRT
   $null = (Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\MRT' -Name 'DontOfferThroughWUAU' @paramRemoveItemProperty)
   #endregion EnableUpdateMSRT

   #region EnableUpdateDriver
   $null = (Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata' -Name 'PreventDeviceMetadataFromNetwork' @paramRemoveItemProperty)
   $null = (Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching' -Name 'DontPromptForWindowsUpdate' @paramRemoveItemProperty)
   $null = (Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching' -Name 'DontSearchWindowsUpdate' @paramRemoveItemProperty)
   $null = (Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching' -Name 'DriverUpdateWizardWuSearchEnabled' @paramRemoveItemProperty)
   $null = (Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -Name 'ExcludeWUDriversInQualityUpdate' @paramRemoveItemProperty)
   #endregion EnableUpdateDriver

   #region EnableUpdateMSProducts
   $paramNewObject = @{
      ComObject = 'Microsoft.Update.ServiceManager'
   }

   $null = (New-Object @paramNewObject).AddService2('7971f918-a847-4430-9279-4a52d1efe18d', 7, '')
   #endregion EnableUpdateMSProducts

   #region DisableUpdateAutoDownload
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU\AUOptions'
      PropertyType = 'DWord'
      Value        = 2
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableUpdateAutoDownload

   #region EnableUpdateRestart
   $null = (Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MusNotification.exe' -Name 'Debugger' @paramRemoveItemProperty)
   #endregion EnableUpdateRestart

   #region DisableMaintenanceWakeUp
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU\AUPowerManagement'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance\WakeUp'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableMaintenanceWakeUp

   #region DisableAutoRestartSignOn
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\DisableAutomaticRestartSignOn'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableAutoRestartSignOn

   #region DisableAutorun
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer\NoDriveTypeAutoRun'
      PropertyType = 'DWord'
      Value        = 255
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableAutorun

   #region EnableRestorePoints
   $paramEnableComputerRestore = @{
      Drive         = ($env:SYSTEMDRIVE)
      Confirm       = $false
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (Enable-ComputerRestore @paramEnableComputerRestore)
   #endregion EnableRestorePoints

   #region DisableDefragmentation
   $paramDisableScheduledTask = @{
      TaskName      = 'Microsoft\Windows\Defrag\ScheduledDefrag'
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (Disable-ScheduledTask @paramDisableScheduledTask)
   #endregion DisableDefragmentation

   #region DisableSuperfetch
   $paramGetService = @{
      Name          = 'SysMain'
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $paramStopService = @{
      Force         = $true
      Confirm       = $false
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $paramSetService = @{
      StartupType   = 'Disabled'
      Confirm       = $false
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (Get-Service @paramGetService | Stop-Service @paramStopService)
   $null = (Get-Service @paramGetService | Set-Service @paramSetService)
   #endregion DisableSuperfetch

   #region EnableIndexing
   $paramSetService = @{
      Name          = 'WSearch'
      StartupType   = 'Automatic'
      Confirm       = $false
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (Set-Service @paramSetService)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SYSTEM\CurrentControlSet\Services\WSearch\DelayedAutoStart'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion EnableIndexing

   #region EnableSwapFile
   $null = (Remove-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -Name 'SwapfileControl' @paramRemoveItemProperty)
   #endregion EnableSwapFile

   #region EnableNTFSLongPaths
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem\LongPathsEnabled'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion EnableNTFSLongPaths

   #region GroupSvchostProcesses
   # Group svchost.exe processes
   $paramGetCimInstance = @{
      ClassName     = 'Win32_PhysicalMemory'
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $ram = ((Get-CimInstance @paramGetCimInstance | Measure-Object -Property 'Capacity' -Sum).Sum / 1kb)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SYSTEM\CurrentControlSet\Control\SvcHostSplitThresholdInKB'
      PropertyType = 'DWord'
      Value        = $ram
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion GroupSvchostProcesses

   #region EnableDisplayParameters
   # Display the Stop error information on the BSoD
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\System\CurrentControlSet\Control\CrashControl\DisplayParameters'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion EnableDisplayParameters

   #region EnableSaveZoneInformation
   # Do not preserve zone information
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Attachments\SaveZoneInformation'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion EnableSaveZoneInformation

   #region DisableNTFSLastAccess
   $null = (& "$env:windir\system32\fsutil.exe" behavior set DisableLastAccess 1)
   #endregion DisableNTFSLastAccess

   #region SetBIOSTimeUTC
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation\RealTimeIsUniversal'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion SetBIOSTimeUTC

   #region DisableFastStartup
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power\HiberbootEnabled'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableFastStartup

   #region EnableAutoRebootOnCrash
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl\AutoReboot'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion EnableAutoRebootOnCrash
   #endregion ServiceTweaks

   #region UITweaks
   #region DisableLockScreen
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization\NoLockScreen'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $service = (New-Object -ComObject Schedule.Service)
   $service.Connect()
   $task = $service.NewTask(0)
   $task.Settings.DisallowStartIfOnBatteries = $false
   $trigger = $task.Triggers.Create(9)
   $trigger = $task.Triggers.Create(11)
   $trigger.StateChange = 8
   $action = $task.Actions.Create(0)
   $action.Path = 'reg.exe'
   $action.Arguments = 'add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\SessionData /t REG_DWORD /v AllowLockScreen /d 0 /f'
   $null = ($service.GetFolder('\').RegisterTaskDefinition('Disable LockScreen', $task, 6, 'NT AUTHORITY\SYSTEM', $null, 4))
   #endregion DisableLockScreen

   #region AwayModeEnabled
   # Lock screen (not sleep) on lid close
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power\AwayModeEnabled'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion AwayModeEnabled

   #region HideNetworkFromLockScreen
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System\DontDisplayNetworkSelectionUI'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion HideNetworkFromLockScreen

   #region ShowShutdownOnLockScreen
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\ShutdownWithoutLogon'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion ShowShutdownOnLockScreen

   #region DisableLockScreenBlur
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System\DisableAcrylicBackgroundOnLogon'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableLockScreenBlur

   #region DisableSearchAppInStore
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer\NoUseStoreOpenWith'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableSearchAppInStore

   #region DisableNewAppPrompt
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer\NoNewAppAlert'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableNewAppPrompt

   #region HideRecentlyAddedApps
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer\HideRecentlyAddedApps'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion HideRecentlyAddedApps

   #region HideMostUsedApps
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer\NoStartMenuMFUprogramsList'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramNewItemProperty = @{
      Path          = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer'
      Name          = 'NoStartMenuMFUprogramsList'
      PropertyType  = 'DWord'
      Value         = 1
      Force         = $true
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (New-ItemProperty @paramNewItemProperty)

   $paramSetItemProperty = @{
      Path          = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer'
      Name          = 'NoStartMenuMFUprogramsList'
      Value         = 1
      Force         = $true
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (Set-ItemProperty @paramSetItemProperty)
   #endregion HideMostUsedApps

   #region ShowShortcutArrow
   $null = (Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons' -Name '29' @paramRemoveItemProperty)
   #endregion ShowShortcutArrow

   #region RemoveENKeyboard
   $paramGetWinUserLanguageList = @{
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   $langs = (Get-WinUserLanguageList @paramGetWinUserLanguageList)

   if ($langs)
   {
      $paramSetWinUserLanguageList = @{
         LanguageList  = ($langs | Where-Object {
               $_.LanguageTag -ne 'en-US'
            })
         Force         = $true
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (Set-WinUserLanguageList @paramSetWinUserLanguageList)
   }
   #endregion RemoveENKeyboard

   #region DisableStartupSound
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\BootAnimation\DisableStartupSound'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableStartupSound

   #region EnableChangingSoundScheme
   $null = (Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization' -Name 'NoChangingSoundScheme' @paramRemoveItemProperty)
   #endregion EnableChangingSoundScheme

   #region DisableVerboseStatus
   $paramGetCimInstance = @{
      ClassName     = 'Win32_OperatingSystem'
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   if ((Get-CimInstance @paramGetCimInstance).ProductType -eq 1)
   {
      $null = (Remove-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'VerboseStatus' @paramRemoveItemProperty)
   }
   else
   {
      $paramConfirmRegistryItemProperty = @{
         Path         = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\VerboseStatus'
         PropertyType = 'DWord'
         Value        = '0'
         ErrorAction  = $SCT
      }
      $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   }
   #endregion DisableVerboseStatus
   #endregion UITweaks

   #region ExplorerUITweaks
   #region HideDesktopFromThisPC
   $null = (Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}' -Recurse @paramRemoveItemProperty)
   #endregion HideDesktopFromThisPC

   #region HideDesktopFromExplorer
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag\ThisPCPolicy'
      PropertyType = 'String'
      Value        = 'Hide'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag\ThisPCPolicy'
      PropertyType = 'String'
      Value        = 'Hide'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion HideDesktopFromExplorer

   #region HideDocumentsFromThisPC
   $null = (Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{d3162b92-9365-467a-956b-92703aca08af}' -Recurse @paramRemoveItemProperty)
   $null = (Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}' -Recurse @paramRemoveItemProperty)
   #endregion HideDocumentsFromThisPC

   #region HideDocumentsFromExplorer
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag\ThisPCPolicy'
      PropertyType = 'String'
      Value        = 'Hide'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag\ThisPCPolicy'
      PropertyType = 'String'
      Value        = 'Hide'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion HideDocumentsFromExplorer

   #region HideDownloadsFromThisPC
   $null = (Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{088e3905-0323-4b02-9826-5d99428e115f}' -Recurse @paramRemoveItemProperty)
   $null = (Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{374DE290-123F-4565-9164-39C4925E467B}' -Recurse @paramRemoveItemProperty)
   #endregion HideDownloadsFromThisPC

   #region HideDownloadsFromExplorer
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag\ThisPCPolicy'
      PropertyType = 'String'
      Value        = 'Hide'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag\ThisPCPolicy'
      PropertyType = 'String'
      Value        = 'Hide'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion HideDownloadsFromExplorer

   #region HideMusicFromThisPC
   $null = (Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}' -Recurse @paramRemoveItemProperty)
   $null = (Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}' -Recurse @paramRemoveItemProperty)
   #endregion HideMusicFromThisPC

   #region HideMusicFromExplorer
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag\ThisPCPolicy'
      PropertyType = 'String'
      Value        = 'Hide'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag\ThisPCPolicy'
      PropertyType = 'String'
      Value        = 'Hide'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion HideMusicFromExplorer

   #region HidePicturesFromThisPC
   $null = (Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}' -Recurse @paramRemoveItemProperty)
   $null = (Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}' -Recurse @paramRemoveItemProperty)
   #endregion HidePicturesFromThisPC

   #region HidePicturesFromExplorer
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag\ThisPCPolicy'
      PropertyType = 'String'
      Value        = 'Hide'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag\ThisPCPolicy'
      PropertyType = 'String'
      Value        = 'Hide'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion HidePicturesFromExplorer

   #region HideVideosFromThisPC
   $null = (Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}' -Recurse @paramRemoveItemProperty)
   $null = (Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A0953C92-50DC-43bf-BE83-3742FED03C9C}' -Recurse @paramRemoveItemProperty)
   #endregion HideVideosFromThisPC

   #region HideVideosFromExplorer
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag\ThisPCPolicy'
      PropertyType = 'String'
      Value        = 'Hide'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag\ThisPCPolicy'
      PropertyType = 'String'
      Value        = 'Hide'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion HideVideosFromExplorer

   #region Hide3DObjectsFromThisPC
   $null = (Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}' -Recurse @paramRemoveItemProperty)
   #endregion Hide3DObjectsFromThisPC

   #region Hide3DObjectsFromExplorer
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag\ThisPCPolicy'
      PropertyType = 'String'
      Value        = 'Hide'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag\ThisPCPolicy'
      PropertyType = 'String'
      Value        = 'Hide'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion Hide3DObjectsFromExplorer

   #region HideIncludeInLibraryMenu
   $paramTestPath = @{
      Path          = 'HKCR:'
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if (-not (Test-Path @paramTestPath))
   {
      $paramNewPSDrive = @{
         Name          = 'HKCR'
         PSProvider    = 'Registry'
         Root          = 'HKEY_CLASSES_ROOT'
         Confirm       = $false
         WarningAction = $SCT
         ErrorAction   = $SCT
      }
      $null = (New-PSDrive @paramNewPSDrive)
   }

   $null = (Remove-Item -Path 'HKCR:\Folder\ShellEx\ContextMenuHandlers\Library Location' @paramRemoveItemProperty)
   #endregion HideIncludeInLibraryMenu

   #region HideGiveAccessToMenu
   $paramTestPath = @{
      Path          = 'HKCR:'
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   if (-not (Test-Path @paramTestPath))
   {
      $paramNewPSDrive = @{
         Name          = 'HKCR'
         PSProvider    = 'Registry'
         Root          = 'HKEY_CLASSES_ROOT'
         Confirm       = $false
         WarningAction = $SCT
         ErrorAction   = $SCT
      }
      $null = (New-PSDrive @paramNewPSDrive)
   }

   $null = (Remove-Item -LiteralPath 'HKCR:\*\shellex\ContextMenuHandlers\Sharing' @paramRemoveItemProperty)
   $null = (Remove-Item -Path 'HKCR:\Directory\Background\shellex\ContextMenuHandlers\Sharing' @paramRemoveItemProperty)
   $null = (Remove-Item -Path 'HKCR:\Directory\shellex\ContextMenuHandlers\Sharing' @paramRemoveItemProperty)
   $null = (Remove-Item -Path 'HKCR:\Drive\shellex\ContextMenuHandlers\Sharing' @paramRemoveItemProperty)
   #endregion HideGiveAccessToMenu

   #region RemoveHPSupportAssistantShortcut
   $null = (Remove-Item -Path ($env:PUBLIC + '\Desktop\HP Support Assistant.lnk') -Force -ErrorAction $SCT)
   #endregion RemoveHPSupportAssistantShortcut
   #endregion ExplorerUITweaks

   #region Application Tweaks
   #region ConfigureMakeMeAdmin
   # Plase see: https://makemeadmin.org/registry-settings.html

   # Create "Make Me Admin" Sub-Tree
   $paramNewItem = @{
      Path          = 'HKLM:\SOFTWARE\Sinclair Community College\Make Me Admin'
      Force         = $true
      Confirm       = $false
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (New-Item @paramNewItem)

   # List of SIDs or names for users or groups that are allowed to obtain administrator rights on the local machine.
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Sinclair Community College\Make Me Admin\Allowed Entities'
      PropertyType = 'MultiString'
      Value        = 'S-1-12-1-2855414155-1143912517-1469153414-3894389289'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   # List of SIDs or names for users or groups that are not allowed to obtain administrator rights on the local machine. Denials take precedence over allowed entities.
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Sinclair Community College\Make Me Admin\Denied Entities'
      PropertyType = 'MultiString'
      Value        = 'S-1-12-1-4187981707-1270255834-494492805-1262097559'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   # List of SIDs or names for users or groups that are automatically added to the Administrators group upon logon.
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Sinclair Community College\Make Me Admin\Automatic Add Allowed'
      PropertyType = 'MultiString'
      Value        = 'S-1-12-1-625767786-1256204928-461728438-4204344446 S-1-12-1-3524765092-1083350200-2707824802-249986053'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   # List of SIDs or names for users or groups that are never allowed to be added automatically to the Administrators group upon logon. Denials take precedence over allowed entities.
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Sinclair Community College\Make Me Admin\Automatic Add Denied'
      PropertyType = 'MultiString'
      Value        = 'S-1-12-1-3644612835-1324734094-3927402880-3336220471 S-1-12-1-755265717-1106991458-2990996133-1768637124'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   # List of SIDs or names for users or groups that are allowed to obtain administrator rights from a remote computer.
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Sinclair Community College\Make Me Admin\Remote Allowed Entities'
      PropertyType = 'MultiString'
      Value        = 'S-1-12-1-625767786-1256204928-461728438-4204344446 S-1-12-1-3524765092-1083350200-2707824802-249986053'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   # List of SIDs or names for users or groups that are not allowed to obtain administrator rights from a remote computer. Denials take precedence over allowed entities.
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Sinclair Community College\Make Me Admin\Remote Denied Entities'
      PropertyType = 'MultiString'
      Value        = 'S-1-12-1-4187981707-1270255834-494492805-1262097559 S-1-12-1-3644612835-1324734094-3927402880-3336220471 S-1-12-1-755265717-1106991458-2990996133-1768637124'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   # Specifies different timeout values for users or groups. For example, you can allow your help desk 60 minutes while allowing everyone else 15 minutes. The highest timeout value that applies to a given user wins.
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Sinclair Community College\Make Me Admin\Timeout Overrides'
      PropertyType = 'String'
      Value        = ''
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   # The default number of minutes that the user will be added to the Administrators group.
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Sinclair Community College\Make Me Admin\Admin Rights Timeout'
      PropertyType = 'DWord'
      Value        = '10'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   # Specifies whether to remove administrator rights if a user logs off of their Windows session.
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Sinclair Community College\Make Me Admin\Remove Admin Rights On Logout'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   # Specifies whether to re-add a user to the Administrators group, if they are removed by another process, e.g., a Group Policy refresh.
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Sinclair Community College\Make Me Admin\Override Removal By Outside Process'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   # Specifies whether to allow requests for administrator rights from remote computers.
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Sinclair Community College\Make Me Admin\Allow Remote Requests'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   # Specifies whether remote sessions are terminated when the user's administrator rights expire.
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Sinclair Community College\Make Me Admin\End Remote Sessions Upon Expiration'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion ConfigureMakeMeAdmin

   #region
   # Edge related
   $paramNewItem = @{
      Path          = 'HKLM:\SOFTWARE\Microsoft\Edge\HideFirstRunExperience'
      Force         = $true
      Confirm       = $false
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (New-Item @paramNewItem)

   $paramNewItem = @{
      Path          = 'HKLM:\\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main'
      Force         = $true
      Confirm       = $false
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (New-Item @paramNewItem)

   # Remove Edge icon on desktop
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\DisableEdgeDesktopShortcutCreation'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   # Show the initial setup ?
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Microsoft\Edge\HideFirstRunExperience'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   # Do NOT allow Microsoft Edge to pre-launch at Windows startup, when the system is idle, and each time Microsoft Edge is closed
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\Software\Policies\Microsoft\MicrosoftEdge\Main\AllowPrelaunch'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   # No preloading of the startpage and Tabs
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\Software\Policies\Microsoft\MicrosoftEdge\Main\TabPreloader'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   # Configure Do Not Track
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\Software\Policies\Microsoft\MicrosoftEdge\Main\DoNotTrack'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   # Show message when opening sites in Internet Explorer
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\Software\Policies\Microsoft\MicrosoftEdge\Main\ShowMessageWhenOpeningSitesInInternetExplorer'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion

   #region EnableOneDrive
   if (-not ($env:COMPUTERNAME -match 'ENSHARED-'))
   {
      $null = (Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive' -Name 'DisableFileSyncNGSC' @paramRemoveItemProperty)
   }
   endregion EnableOneDrive

   #region InstallWindowsStore
   $paramGetAppxPackage = @{
      AllUsers      = $true
      Name          = 'Microsoft.DesktopAppInstaller'
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (Get-AppxPackage @paramGetAppxPackage | ForEach-Object {
         $paramAddAppxPackage = @{
            DisableDevelopmentMode = $true
            Register               = $true
            Path                   = ($_.InstallLocation + '\AppXManifest.xml')
            Confirm                = $false
            WarningAction          = $SCT
            ErrorAction            = $SCT
         }
         $null = (Add-AppxPackage @paramAddAppxPackage)
      })

   $paramGetAppxPackage = @{
      AllUsers      = $true
      Name          = 'Microsoft.Services.Store.Engagement'
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (Get-AppxPackage @paramGetAppxPackage | ForEach-Object {
         $paramAddAppxPackage = @{
            DisableDevelopmentMode = $true
            Register               = $true
            Path                   = ($_.InstallLocation + '\AppXManifest.xml')
            Confirm                = $false
            WarningAction          = $SCT
            ErrorAction            = $SCT
         }
         $null = (Add-AppxPackage @paramAddAppxPackage)
      })

   $paramGetAppxPackage = @{
      AllUsers      = $true
      Name          = 'Microsoft.StorePurchaseApp'
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (Get-AppxPackage @paramGetAppxPackage | ForEach-Object {
         $paramAddAppxPackage = @{
            DisableDevelopmentMode = $true
            Register               = $true
            Path                   = ($_.InstallLocation + '\AppXManifest.xml')
            Confirm                = $false
            WarningAction          = $SCT
            ErrorAction            = $SCT
         }
         $null = (Add-AppxPackage @paramAddAppxPackage)
      })

   $paramGetAppxPackage = @{
      AllUsers      = $true
      Name          = 'Microsoft.WindowsStore'
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (Get-AppxPackage @paramGetAppxPackage | ForEach-Object {
         $paramAddAppxPackage = @{
            DisableDevelopmentMode = $true
            Register               = $true
            Path                   = ($_.InstallLocation + '\AppXManifest.xml')
            Confirm                = $false
            WarningAction          = $SCT
            ErrorAction            = $SCT
         }
         $null = (Add-AppxPackage @paramAddAppxPackage)
      })
   #endregion InstallWindowsStore

   #region DisableAdobeFlash
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\DisableFlashInIE'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Addons\FlashPlayerEnabled'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableAdobeFlash

   #region DisableEdgePreload
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main\AllowPrelaunch'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\TabPreloader\AllowTabPreloading'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableEdgePreload

   #region DisableEdgeShortcutCreation
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\DisableEdgeDesktopShortcutCreation'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableEdgeShortcutCreation


   if (-not ($env:COMPUTERNAME -match 'ENSHARED-'))
   {
      #region ConfiguteOneDrive
      # Try Auto configure
      $paramConfirmRegistryItemProperty = @{
         Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\OneDrive\SilentAccountConfig'
         PropertyType = 'DWord'
         Value        = '1'
         ErrorAction  = $SCT
      }
      $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

      # Enable the FilesOnDemand Freature
      $paramConfirmRegistryItemProperty = @{
         Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\OneDrive\FilesOnDemandEnabled'
         PropertyType = 'DWord'
         Value        = '1'
         ErrorAction  = $SCT
      }
      $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
      #endregion ConfiguteOneDrive
   }

   #region DisableIEFirstRun
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main\DisableFirstRunCustomize'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableIEFirstRun

   #region DisableFirstLogonAnimation
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\EnableFirstLogonAnimation'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableFirstLogonAnimation

   #region RestartNotificationsAllowed2
   # Show more Windows Update restart notifications about restarting
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings\RestartNotificationsAllowed2'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion RestartNotificationsAllowed2

   #region
   # Automatically adjust active hours for me based on daily usage
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings\SmartActiveHoursState'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion

   #region DisableMediaSharing
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\WindowsMediaPlayer\PreventLibrarySharing'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableMediaSharing

   #region UninstallWorkFolders
   $paramGetWindowsOptionalFeature = @{
      Online        = $true
      FeatureName   = 'WorkFolders-Client'
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $paramDisableWindowsOptionalFeature = @{
      Online        = $true
      NoRestart     = $true
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (Get-WindowsOptionalFeature @paramGetWindowsOptionalFeature | Where-Object {
         $_.State -ne 'Disabled'
      } | Disable-WindowsOptionalFeature @paramDisableWindowsOptionalFeature)
   #endregion UninstallWorkFolders

   #region UninstallPowerShellV2
   $paramGetWindowsOptionalFeature = @{
      Online        = $true
      FeatureName   = 'MicrosoftWindowsPowerShellV2Root'
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (Get-WindowsOptionalFeature @paramGetWindowsOptionalFeature | Where-Object {
         $_.State -ne 'Disabled'
      } | Disable-WindowsOptionalFeature @paramDisableWindowsOptionalFeature)
   #endregion UninstallPowerShellV2

   #region InstallSSHClient
   $paramGetWindowsCapability = @{
      Online        = $true
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $paramAddWindowsCapability = @{
      Online        = $true
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (Get-WindowsCapability @paramGetWindowsCapability | Where-Object {
         (($_.Name -like 'OpenSSH.Client*') -and ($_.State -eq 'NotPresent'))
      } | Add-WindowsCapability @paramAddWindowsCapability)
   #endregion InstallSSHClient

   #region UninstallSSHServer
   $paramStopService = @{
      Name          = 'sshd'
      Force         = $true
      NoWait        = $true
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (Stop-Service @paramStopService)

   $paramGetWindowsCapability = @{
      Online        = $true
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $paramRemoveWindowsCapability = @{
      Online        = $true
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (Get-WindowsCapability @paramGetWindowsCapability | Where-Object {
         (($_.Name -like 'OpenSSH.Server*') -and ($_.State -eq 'Installed'))
      } | Remove-WindowsCapability @paramRemoveWindowsCapability)
   #endregion UninstallSSHServer

   #region SetPhotoViewerAssociation
   $paramTestPath = @{
      Path          = 'HKCR:'
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   if (-not (Test-Path @paramTestPath))
   {
      $paramNewPSDrive = @{
         Name          = 'HKCR'
         PSProvider    = 'Registry'
         Root          = 'HKEY_CLASSES_ROOT'
         Confirm       = $false
         WarningAction = $SCT
         ErrorAction   = $SCT
      }
      $null = (New-PSDrive @paramNewPSDrive)
   }

   foreach ($type in @('Paint.Picture', 'giffile', 'jpegfile', 'pngfile'))
   {
      $paramNewItem = @{
         Path          = ('HKCR:\' + $type + '\shell\open')
         Force         = $true
         Confirm       = $false
         WarningAction = $SCT
         ErrorAction   = $SCT
      }
      $null = (New-Item @paramNewItem)

      $paramNewItem = @{
         Path          = ('HKCR:\' + $type + '\shell\open\command')
         Force         = $true
         Confirm       = $false
         WarningAction = $SCT
         ErrorAction   = $SCT
      }
      $null = (New-Item @paramNewItem)

      $paramConfirmRegistryItemProperty = @{
         Path         = ('HKCR:\' + $type + '\shell\open\MuiVerb')
         PropertyType = 'ExpandString'
         Value        = '@%ProgramFiles%\Windows Photo Viewer\photoviewer.dll,-3043'
         ErrorAction  = $SCT
      }
      $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

      $paramConfirmRegistryItemProperty = @{
         Path         = ('HKCR:\' + $type + '\shell\open\command\(Default)')
         PropertyType = 'ExpandString'
         Value        = "%SystemRoot%\System32\rundll32.exe `"%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll`", ImageView_Fullscreen %1"
         ErrorAction  = $SCT
      }
      $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   }
   #endregion SetPhotoViewerAssociation

   #region AddPhotoViewerOpenWith
   $paramTestPath = @{
      Path          = 'HKCR:'
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   if (-not (Test-Path @paramTestPath))
   {
      $paramNewPSDrive = @{
         Name          = 'HKCR'
         PSProvider    = 'Registry'
         Root          = 'HKEY_CLASSES_ROOT'
         Confirm       = $true
         WarningAction = $SCT
         ErrorAction   = $SCT
      }
      $null = (New-PSDrive @paramNewPSDrive)
   }

   $paramNewItem = @{
      Path          = 'HKCR:\Applications\photoviewer.dll\shell\open\command'
      Force         = $true
      Confirm       = $false
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (New-Item @paramNewItem)

   $paramNewItem = @{
      Path          = 'HKCR:\Applications\photoviewer.dll\shell\open\DropTarget'
      Force         = $true
      Confirm       = $false
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (New-Item @paramNewItem)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCR:\Applications\photoviewer.dll\shell\open\MuiVerb'
      PropertyType = 'String'
      Value        = '@photoviewer.dll,-3043'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCR:\Applications\photoviewer.dll\shell\open\command\(Default)'
      PropertyType = 'ExpandString'
      Value        = "%SystemRoot%\System32\rundll32.exe `"%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll`", ImageView_Fullscreen %1"
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCR:\Applications\photoviewer.dll\shell\open\DropTarget\Clsid'
      PropertyType = 'String'
      Value        = '{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion AddPhotoViewerOpenWith

   #region InstallPDFPrinter
   $paramDisableWindowsOptionalFeature = @{
      Online        = $true
      NoRestart     = $true
      WarningAction = $SCT
      ErrorAction   = $SCT
   }


   $paramGetWindowsOptionalFeature = @{
      Online        = $true
      FeatureName   = 'Printing-PrintToPDFServices-Features'
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (Get-WindowsOptionalFeature @paramGetWindowsOptionalFeature | Where-Object {
         $_.State -ne 'Disabled'
      } | Disable-WindowsOptionalFeature @paramDisableWindowsOptionalFeature)
   #endregion InstallPDFPrinter

   #region UninstallXPSPrinter
   $paramGetWindowsOptionalFeature = @{
      Online        = $true
      FeatureName   = 'Printing-XPSServices-Features'
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (Get-WindowsOptionalFeature @paramGetWindowsOptionalFeature | Where-Object {
         $_.State -ne 'Disabled'
      } | Disable-WindowsOptionalFeature @paramDisableWindowsOptionalFeature)
   #endregion UninstallXPSPrinter

   #region RemoveFaxPrinter
   $paramRemovePrinter = @{
      Name          = 'Fax'
      Confirm       = $false
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (Remove-Printer @paramRemovePrinter)
   #endregion RemoveFaxPrinter

   #region UninstallFaxAndScan
   $paramGetWindowsOptionalFeature = @{
      Online        = $true
      FeatureName   = 'FaxServicesClientPackage'
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (Get-WindowsOptionalFeature @paramGetWindowsOptionalFeature | Where-Object {
         $_.State -ne 'Disabled'
      } | Disable-WindowsOptionalFeature @paramDisableWindowsOptionalFeature)
   #endregion UninstallFaxAndScan

   #region InstallNET23
   $paramGetCimInstance = @{
      ClassName     = 'Win32_OperatingSystem'
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if ((Get-CimInstance @paramGetCimInstance).ProductType -eq 1)
   {
      $paramEnableWindowsOptionalFeature = @{
         Online        = $true
         FeatureName   = 'NetFx3'
         NoRestart     = $true
         WarningAction = $SCT
         ErrorAction   = $SCT
      }
      $null = (Enable-WindowsOptionalFeature @paramEnableWindowsOptionalFeature)
   }
   #endregion InstallNET23
   #endregion Application Tweaks

   #region
   #region RemoveShadowCopies
   # Remove Shadow copies (restoration points)
   $paramGetCimInstance = @{
      ClassName     = 'Win32_ShadowCopy'
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $paramRemoveCimInstance = @{
      Confirm       = $false
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (Get-CimInstance @paramGetCimInstance | Remove-CimInstance @paramRemoveCimInstance)
   #endregion RemoveShadowCopies

   #region SystemRestoreCheckpointCreation
   # Revert the System Restore checkpoint creation frequency to 1440 minutes
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore\SystemRestorePointCreationFrequency'
      PropertyType = 'DWord'
      Value        = '1440'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion SystemRestoreCheckpointCreation

   #region
   # Turn on latest installed .NET runtime for all apps
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Microsoft\.NETFramework\OnlyUseLatestCLR'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\OnlyUseLatestCLR'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion

   #region
   # Do not allow the computer (if device is not a laptop) to turn off all the network adapters to save power
   $paramGetCimInstance = @{
      ClassName     = 'Win32_ComputerSystem'
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   if ((Get-CimInstance @paramGetCimInstance).PCSystemType -ne 2)
   {
      $paramGetNetAdapter = @{
         Physical      = $true
         WarningAction = $SCT
         ErrorAction   = $SCT
      }
      $paramGetNetAdapterPowerManagement = @{
         WarningAction = $SCT
         ErrorAction   = $SCT
      }
      $null = (Get-NetAdapter @paramGetNetAdapter | Get-NetAdapterPowerManagement @paramGetNetAdapterPowerManagement | Where-Object -FilterScript {
            $_.AllowComputerToTurnOffDevice -ne 'Unsupported'
         }) | ForEach-Object -Process {
         $_.AllowComputerToTurnOffDevice = 'Disabled'
         $paramSetNetAdapterPowerManagement = @{
            Confirm       = $false
            WarningAction = $SCT
            ErrorAction   = $SCT
         }
         $null = ($_ | Set-NetAdapterPowerManagement @paramSetNetAdapterPowerManagement)
      }
   }
   #endregion

   #region
   $paramGetWindowsEdition = @{
      Online        = $true
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   if (Get-WindowsEdition @paramGetWindowsEdition | Where-Object -FilterScript {
         $_.Edition -eq 'Professional' -or $_.Edition -eq 'Enterprise'
      })
   {
      $paramGetCimInstance = @{
         ClassName     = 'CIM_Processor'
         WarningAction = $SCT
         ErrorAction   = $SCT
      }
      if ((Get-CimInstance @paramGetCimInstance).VirtualizationFirmwareEnabled -eq $true)
      {
         $paramEnableWindowsOptionalFeature = @{
            FeatureName   = 'Containers-DisposableClientVM'
            All           = $true
            Online        = $true
            NoRestart     = $true
            WarningAction = $SCT
            ErrorAction   = $SCT
         }
         $null = (Enable-WindowsOptionalFeature @paramEnableWindowsOptionalFeature)
      }
      else
      {
         $paramGetCimInstance = @{
            ClassName     = 'CIM_ComputerSystem'
            WarningAction = $SCT
            ErrorAction   = $SCT
         }
         if ((Get-CimInstance @paramGetCimInstance).HypervisorPresent -eq $true)
         {
            $paramEnableWindowsOptionalFeature = @{
               FeatureName   = 'Containers-DisposableClientVM'
               All           = $true
               Online        = $true
               NoRestart     = $true
               WarningAction = $SCT
               ErrorAction   = $SCT
            }
            $null = (Enable-WindowsOptionalFeature @paramEnableWindowsOptionalFeature)
         }
      }
   }
   #endregion

   #region
   # Turn off and delete reserved storage after the next update installation
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\ReserveManager\BaseHardReserveSize'
      PropertyType = 'QWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\ReserveManager\BaseSoftReserveSize'
      PropertyType = 'QWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\ReserveManager\HardReserveAdjustment'
      PropertyType = 'QWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\ReserveManager\MinDiskSize'
      PropertyType = 'QWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\ReserveManager\ShippedWithReserves'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramGetCommand = @{
      Name        = 'Set-WindowsReservedStorageState'
      ErrorAction = $SCT
   }
   if (Get-Command @paramGetCommand)
   {
      $paramSetWindowsReservedStorageState = @{
         State       = 'Disabled'
         ErrorAction = $SCT
      }
      $null = (Set-WindowsReservedStorageState @paramSetWindowsReservedStorageState)
   }
   #endregion

   #region
   # Turn on automatic backup the system registry to the $env:SystemRoot\System32\config\RegBack folder
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Configuration Manager\EnablePeriodicBackup'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion

   #region
   # Turn off thumbnail cache removal
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Thumbnail Cache\Autorun'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Thumbnail Cache\Autorun'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion

   #region
   # Use Unicode UTF-8 for worldwide language support
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SYSTEM\CurrentControlSet\Control\Nls\CodePage\ACP'
      PropertyType = 'String'
      Value        = '65001'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SYSTEM\CurrentControlSet\Control\Nls\CodePage\MACCP'
      PropertyType = 'String'
      Value        = '65001'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SYSTEM\CurrentControlSet\Control\Nls\CodePage\OEMCP'
      PropertyType = 'String'
      Value        = '65001'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion

   #region
   # Do not show recently added apps on Start menu
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer\CHideRecentlyAddedApps'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion

   #region
   # Turn on logging for all Windows PowerShell modules
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging\ModuleNames\*'
      PropertyType = 'String'
      Value        = '*'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging\ModuleNames\EnableModuleLogging'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging\EnableScriptBlockLogging'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion

   #region
   # Include command line in progress creation events
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\Audit\ProcessCreationIncludeCmdLine_Enabled'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion

   #region
   # Remove "Edit with Paint 3D" from context menu
   $exts = @('.bmp', '.gif', '.jpe', '.jpeg', '.jpg', '.png', '.tif', '.tiff')

   foreach ($ext in $exts)
   {
      $null = (Remove-Item -Path ('Registry::HKEY_CLASSES_ROOT\SystemFileAssociations\' + $ext + '\Shell\3D Edit\ProgrammaticAccessOnly') @paramRemoveItemProperty)
   }
   #endregion

   #region
   # Remove "Include in Library" from context menu
   $paramConfirmRegistryItemProperty = @{
      Path         = 'Registry::HKEY_CLASSES_ROOT\Folder\shellex\ContextMenuHandlers\Library Location\(default)'
      PropertyType = 'String'
      Value        = '-{3dad6c5d-2167-4cae-9914-f99e41c12cfa}'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   # Remove "Edit with Photos" from context menu
   $null = (Remove-Item -Path 'Registry::HKEY_CLASSES_ROOT\AppX43hnxtbyyps62jhe9sqpdzxn1790zetc\Shell\ShellEdit\ProgrammaticAccessOnly' @paramRemoveItemProperty)

   # Remove "Create a new video" from context menu
   $null = (Remove-Item -Path 'Registry::HKEY_CLASSES_ROOT\AppX43hnxtbyyps62jhe9sqpdzxn1790zetc\Shell\ShellCreateVideo\ProgrammaticAccessOnly' @paramRemoveItemProperty)

   # Remove "Edit" from images context menu
   $null = (Remove-Item -Path 'Registry::HKEY_CLASSES_ROOT\SystemFileAssociations\image\shell\edit\ProgrammaticAccessOnly' @paramRemoveItemProperty)

   # Remove "Print" from batch and .cmd files context menu
   $null = (Remove-Item -Path 'Registry::HKEY_CLASSES_ROOT\batfile\shell\print\ProgrammaticAccessOnly' @paramRemoveItemProperty)
   $null = (Remove-Item -Path 'Registry::HKEY_CLASSES_ROOT\cmdfile\shell\print\ProgrammaticAccessOnly' @paramRemoveItemProperty)
   #endregion

   #region
   # Remove "Rich Text Document" from context menu
   $null = (Remove-Item -Path 'Registry::HKEY_CLASSES_ROOT\.rtf\ShellNew' @paramRemoveItemProperty)

   # Remove "Bitmap image" from context menu
   $null = (Remove-Item -Path 'Registry::HKEY_CLASSES_ROOT\.bmp\ShellNew' @paramRemoveItemProperty)
   #endregion

   #region
   # Turn off Windows features
   $features = @('FaxServicesClientPackage', 'LegacyComponents', 'MicrosoftWindowsPowerShellV2', 'MicrosoftWindowsPowershellV2Root', 'Printing-XPSServices-Features', 'Printing-PrintToPDFServices-Features', 'WorkFolders-Client', 'SMB1Protocol', 'SMB1Protocol-Client', 'SMB1Protocol-Server')

   $paramDisableWindowsOptionalFeature = @{
      Online        = $true
      NoRestart     = $true
      WarningAction = $SCT
      ErrorAction   = $SCT
   }

   foreach ($feature in $features)
   {
      $paramGetWindowsOptionalFeature = @{
         Online        = $true
         FeatureName   = $feature
         WarningAction = $SCT
         ErrorAction   = $SCT
      }
      $null = (Get-WindowsOptionalFeature @paramGetWindowsOptionalFeature | Where-Object {
            $_.State -ne 'Disabled'
         } | Disable-WindowsOptionalFeature @paramDisableWindowsOptionalFeature)
   }

   # Remove Windows capabilities
   $IncludedApps = @('App.Support.QuickAssist*', 'Media.WindowsMediaPlayer*', 'Language.Handwriting*', 'Language.OCR*', 'Language.Speech*', 'Language.TextToSpeech*')
   $OFS = '|'
   $paramRemoveWindowsCapability = @{
      Online        = $true
      WarningAction = $SCT
      ErrorAction   = $SCT
   }

   foreach ($IncludedApp in $IncludedApps)
   {
      try
      {
         $paramGetWindowsCapability = @{
            Online        = $true
            WarningAction = $SCT
            ErrorAction   = $SCT
         }
         $null = (Get-WindowsCapability @paramGetWindowsCapability | Where-Object -FilterScript {
               #$_.Name -cmatch $IncludedApps
               ($_.Name -like $IncludedApp) -and ($_.State -eq 'Installed')
            } | Remove-WindowsCapability @paramRemoveWindowsCapability)
      }
      catch
      {
         Write-Verbose -Message 'Most of the time: Permanent package cannot be uninstalled. And we know that!'
      }
   }
   $OFS = ' '
   #endregion
   #endregion

   #region
   # Disable hibernation if the device is not a laptop
   $paramGetCimInstance = @{
      ClassName     = 'Win32_ComputerSystem'
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if ((Get-CimInstance @paramGetCimInstance).PCSystemType -ne 2)
   {
      $null = (& "$env:windir\system32\powercfg.exe" /HIBERNATE OFF)
   }
   #endregion

   #region
   $paramTestPath = @{
      Path          = 'HKLM:\SOFTWARE\Microsoft\WindowsMitigation'
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   if (-not (Test-Path @paramTestPath))
   {
      $paramNewItem = @{
         Path          = 'HKLM:\SOFTWARE\Microsoft\WindowsMitigation'
         Force         = $true
         WarningAction = $SCT
         ErrorAction   = $SCT
      }

      $null = (New-Item @paramNewItem)
   }

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Microsoft\WindowsMitigation\UserPreference'
      PropertyType = 'DWord'
      Value        = '3'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion

   #region
   # Enable "Network Discovery" and "File and Printers Sharing" for workgroup networks
   $paramGetCimInstance = @{
      ClassName     = 'CIM_ComputerSystem'
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   if ((Get-CimInstance @paramGetCimInstance).PartOfDomain -eq $false)
   {
      $FirewallRules = @(
         # File and printer sharing
         '@FirewallAPI.dll,-32752',
         # Network discovery
         '@FirewallAPI.dll,-28502'
      )
      $paramSetNetFirewallRule = @{
         Group         = $FirewallRules
         Profile       = 'Private'
         Enabled       = 'True'
         WarningAction = $SCT
         ErrorAction   = $SCT
      }
      $null = (Set-NetFirewallRule @paramSetNetFirewallRule)
   }
   #endregion

   #region
   # Turn off Cortana autostarting
   $paramGetAppxPackage = @{
      Name          = 'Microsoft.549981C3F5F10'
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   if (Get-AppxPackage @paramGetAppxPackage)
   {
      $paramConfirmRegistryItemProperty = @{
         Path         = 'Registry::HKEY_CLASSES_ROOT\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData\Microsoft.549981C3F5F10_8wekyb3d8bbwe\CortanaStartupId'
         PropertyType = 'DWord'
         Value        = '3'
         ErrorAction  = $SCT
      }
      $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   }
   #endregion

   #region
   # Turn on hardware-accelerated GPU scheduling. Restart needed
   # Determining whether the PC has a dedicated GPU to use this feature
   $paramGetCimInstance = @{
      ClassName     = 'CIM_VideoController'
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   if ((Get-CimInstance @paramGetCimInstance | Where-Object -FilterScript {
            $_.AdapterDACType -ne 'Internal'
         }))
   {
      # Determining whether an OS is not installed on a virtual machine
      $paramGetCimInstance = @{
         ClassName     = 'CIM_ComputerSystem'
         WarningAction = $SCT
         ErrorAction   = $SCT
      }
      if ((Get-CimInstance @paramGetCimInstance).Model -notmatch 'Virtual')
      {
         # Checking whether a WDDM verion is 2.7 or higher
         $paramGetItemPropertyValue = @{
            Path          = 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\FeatureSetUsage'
            Name          = 'WddmVersion_Min'
            WarningAction = $SCT
            ErrorAction   = $SCT
         }

         if ((Get-ItemPropertyValue @paramGetItemPropertyValue) -ge 2700)
         {
            $paramConfirmRegistryItemProperty = @{
               Path         = 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\HwSchMode'
               PropertyType = 'DWord'
               Value        = '2'
               ErrorAction  = $SCT
            }
            $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
         }
      }
   }
   #endregion

   #region
   # Turn on events auditing generated when a process is created or starts
   $null = (& "$env:windir\system32\auditpol.exe" /set /subcategory:"{0CCE922B-69AE-11D9-BED3-505054503030}" /success:enable /failure:enable)
   #endregion

   #region
   # Log for all Windows PowerShell modules
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging\EnableModuleLogging'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging\ModuleNames\*'
      PropertyType = 'String'
      Value        = '*'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   # Log all PowerShell scripts input to the Windows PowerShell event log
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging\EnableScriptBlockLogging'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion

   #region
   # Turn on Microsoft Defender Exploit Guard network protection
   $paramSetMpPreference = @{
      EnableNetworkProtection = 'Enabled'
      Force                   = $true
      ErrorAction             = $SCT
   }
   $null = (Set-MpPreference @paramSetMpPreference)

   # Turn on detection for potentially unwanted applications and block them
   $paramSetMpPreference = @{
      PUAProtection = 'Enabled'
      Force         = $true
      ErrorAction   = $SCT
   }
   $null = (Set-MpPreference @paramSetMpPreference)

   # Run Microsoft Defender within a sandbox
   $null = (& "$env:windir\system32\setx.exe" /M MP_FORCE_USE_SANDBOX 1)
   #endregion

   #region
   # Make this connection private
   $paramResolveDnsName = @{
      Name          = 'kms.enatec.net'
      Type          = 'A'
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   if (Resolve-DnsName @paramResolveDnsName | Where-Object {
         (($_.Type -eq 'A') -and ($_.IPAddress -ne '0.0.0.0'))
      })
   {
      # Cleanup
      $InterfaceAliasInfo = $null

      <#
            With Windows 10 20H2 some NICs report a limited connection!

            Let us try this as a workaround:
            The first call try to find the NIC with an Internet connection,
            if this fails the second call will try to get the NIC with a working
            connection via Test-NetConnection instead of Get-NetConnectionProfile.

            Not perfect, but the "No Internet Access" state cause some issues!
      #>
      try
      {
         $paramGetNetConnectionProfile = @{
            IPv4Connectivity = 'Internet'
            ErrorAction      = 'Stop'
            WarningAction    = $SCT
         }
         $InterfaceAliasInfo = ((Get-NetConnectionProfile @paramGetNetConnectionProfile).InterfaceAlias)
      }
      catch
      {
         # Cleanup
         $TestNetConnection = $null

         <#
               This is a quick and dirty Workaround:
               Figure out if we have a working Internet connection:
               Try a connection via Test-NetConnection on Port 443/TCP (HTTPS) to
               random Microsoft provided IP/Host.

               - Thanks Microsoft for the crappy NIC handling in Windows 10 20H2 -
         #>
         $paramTestNetConnection = @{
            Port          = 443
            ErrorAction   = $SCT
            WarningAction = $SCT
         }
         $TestNetConnection = (Test-NetConnection @paramTestNetConnection)

         if ((($TestNetConnection).TcpTestSucceeded) -eq $true)
         {
            $InterfaceAliasInfo = (($TestNetConnection). InterfaceAlias)
         }
      }

      # Prevent NULL Pointer Exception - See workaround above!
      if ($InterfaceAliasInfo)
      {
         $paramSetNetConnectionProfile = @{
            InterfaceAlias  = $InterfaceAliasInfo
            NetworkCategory = 'Private'
            ErrorAction     = $SCT
            WarningAction   = $SCT
         }
         $null = (Set-NetConnectionProfile @paramSetNetConnectionProfile)
      }
      else
      {
         Write-Verbose -Message 'Skipped: Could not get the required Network Connection Profile information'
      }
   }
   #endregion

   #region MovedOver
   #region DisableTailoredExperiences
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\Software\Policies\Microsoft\Windows\CloudContent\DisableTailoredExperiencesWithDiagnosticData'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableTailoredExperiences

   #region EnableActionCenter
   $null = (Remove-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Windows\Explorer' -Name 'DisableNotificationCenter' @paramRemoveItemProperty)
   #endregion EnableActionCenter

   #region Office2016Telemetry
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKLM:\software\policies\microsoft\office\16.0\osm\enablelogging'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion Office2016Telemetry
   #endregion MovedOver

   #region FinalTouches
   # Create a task in the Task Scheduler to start Windows cleaning up - The task runs every 90 days
   $keys = @('Delivery Optimization Files', 'Device Driver Packages', 'Previous Installations', 'Setup Log Files', 'Temporary Setup Files', 'Update Cleanup', 'Windows Defender', 'Windows Upgrade Log Files')

   foreach ($key in $keys)
   {
      $paramConfirmRegistryItemProperty = @{
         Path         = ('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\' + $key + 'StateFlags1337')
         PropertyType = 'DWord'
         Value        = '2'
         ErrorAction  = $SCT
      }
      $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   }

   $paramNewScheduledTaskAction = @{
      Execute       = 'cleanmgr.exe'
      Argument      = '/sagerun:1337'
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $action = (New-ScheduledTaskAction @paramNewScheduledTaskAction)

   $paramNewScheduledTaskTrigger = @{
      Daily         = $true
      DaysInterval  = '90'
      At            = '9am'
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $trigger = (New-ScheduledTaskTrigger @paramNewScheduledTaskTrigger)

   $paramNewScheduledTaskSettingsSet = @{
      Compatibility      = 'Win8'
      StartWhenAvailable = $true
      WarningAction      = $SCT
      ErrorAction        = $SCT
   }
   $settings = (New-ScheduledTaskSettingsSet @paramNewScheduledTaskSettingsSet)

   $paramNewScheduledTaskPrincipal = @{
      UserId        = $env:USERNAME
      RunLevel      = 'Highest'
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $principal = (New-ScheduledTaskPrincipal @paramNewScheduledTaskPrincipal)

   $params = @{
      'TaskName'    = 'Update Cleanup'
      'Action'      = $action
      'Trigger'     = $trigger
      'Settings'    = $settings
      'Principal'   = $principal
      'Force'       = $true
      'ErrorAction' = $SCT
   }
   $null = (Register-ScheduledTask @params)

   # Create a task in the Task Scheduler to clear the $env:SystemRoot\SoftwareDistribution\Download folder - The task runs on Thursdays every 4 weeks
   $paramNewScheduledTaskAction = @{
      Execute     = 'powershell.exe'
      ErrorAction = $SCT
      Argument    = @"
   `$getservice = Get-Service -Name wuauserv
   `$getservice.WaitForStatus("Stopped", "01:00:00")
   Get-ChildItem -Path `$env:SystemRoot\SoftwareDistribution\Download -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
"@
   }
   $action = (New-ScheduledTaskAction @paramNewScheduledTaskAction)

   $paramNewJobTrigger = @{
      Weekly        = $true
      WeeksInterval = '4'
      DaysOfWeek    = 'Thursday'
      At            = '9am'
      ErrorAction   = $SCT
   }
   $trigger = (New-JobTrigger @paramNewJobTrigger)

   $paramNewScheduledTaskSettingsSet = @{
      Compatibility      = 'Win8'
      StartWhenAvailable = $true
      ErrorAction        = $SCT
   }
   $settings = (New-ScheduledTaskSettingsSet @paramNewScheduledTaskSettingsSet)

   $paramNewScheduledTaskPrincipal = @{
      UserId      = 'NT AUTHORITY\SYSTEM'
      RunLevel    = 'Highest'
      ErrorAction = $SCT
   }
   $principal = (New-ScheduledTaskPrincipal @paramNewScheduledTaskPrincipal)

   $params = @{
      'TaskName'    = 'SoftwareDistribution'
      'Action'      = $action
      'Trigger'     = $trigger
      'Settings'    = $settings
      'Principal'   = $principal
      'Force'       = $true
      'ErrorAction' = $SCT
   }
   $null = (Register-ScheduledTask @params)

   # Create a task in the Task Scheduler to clear the $env:TEMP folder - The task runs every 62 days
   $paramNewScheduledTaskAction = @{
      Execute     = 'powershell.exe'
      ErrorAction = $SCT
      Argument    = @"
   Get-ChildItem -Path `$env:TEMP -Force -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
"@
   }
   $action = (New-ScheduledTaskAction @paramNewScheduledTaskAction)

   $paramNewScheduledTaskTrigger = @{
      Daily        = $true
      DaysInterval = '62'
      At           = '9am'
      ErrorAction  = $SCT
   }
   $trigger = (New-ScheduledTaskTrigger @paramNewScheduledTaskTrigger)

   $paramNewScheduledTaskSettingsSet = @{
      Compatibility      = 'Win8'
      StartWhenAvailable = $true
      ErrorAction        = $SCT
   }
   $settings = (New-ScheduledTaskSettingsSet @paramNewScheduledTaskSettingsSet)

   $paramNewScheduledTaskPrincipal = @{
      UserId      = 'NT AUTHORITY\SYSTEM'
      RunLevel    = 'Highest'
      ErrorAction = $SCT
   }
   $principal = (New-ScheduledTaskPrincipal @paramNewScheduledTaskPrincipal)

   $params = @{
      'TaskName'    = 'Temp'
      'Action'      = $action
      'Trigger'     = $trigger
      'Settings'    = $settings
      'Principal'   = $principal
      'Force'       = $true
      'ErrorAction' = $SCT
   }
   $null = (Register-ScheduledTask @params)

   # Turn off Windows features
   $features = @('FaxServicesClientPackage', 'LegacyComponents', 'MicrosoftWindowsPowerShellV2', 'MicrosoftWindowsPowershellV2Root', 'Printing-XPSServices-Features', 'Printing-PrintToPDFServices-Features', 'WorkFolders-Client', 'SMB1Protocol', 'SMB1Protocol-Client', 'SMB1Protocol-Server')

   foreach ($feature in $features)
   {
      $paramGetWindowsOptionalFeature = @{
         Online        = $true
         FeatureName   = $feature
         WarningAction = $SCT
         ErrorAction   = $SCT
      }
      $paramDisableWindowsOptionalFeature = @{
         Online        = $true
         NoRestart     = $true
         WarningAction = $SCT
         ErrorAction   = $SCT
      }

      $null = (Get-WindowsOptionalFeature @paramGetWindowsOptionalFeature | Where-Object {
            $_.State -ne 'Disabled'
         } | Disable-WindowsOptionalFeature @paramDisableWindowsOptionalFeature)
   }

   # Remove Windows capabilities
   $IncludedApps = @('App.Support.QuickAssist*', 'Media.WindowsMediaPlayer*', 'Browser.InternetExplorer*', 'Language.Handwriting*', 'Language.OCR*', 'Language.Speech*', 'Language.TextToSpeech*')
   $OFS = '|'
   foreach ($IncludedApp in $IncludedApps)
   {
      try
      {
         $paramGetWindowsCapability = @{
            Online        = $true
            WarningAction = $SCT
            ErrorAction   = $SCT
         }
         $paramRemoveWindowsCapability = @{
            Online        = $true
            WarningAction = $SCT
            ErrorAction   = $SCT
         }
         $null = (Get-WindowsCapability @paramGetWindowsCapability | Where-Object -FilterScript {
               #$_.Name -cmatch $IncludedApps
               ($_.Name -like $IncludedApp) -and ($_.State -eq 'Installed')
            } | Remove-WindowsCapability @paramRemoveWindowsCapability)
      }
      catch
      {
         Write-Verbose -Message 'Most of the time: Permanent package cannot be uninstalled. And we know that!'
      }
   }
   $OFS = ' '
   #endregion FinalTouches
}

end
{
   $paramGetCommand = @{
      Name        = 'Set-MpPreference'
      ErrorAction = $SCT
   }
   if (Get-Command @paramGetCommand)
   {
      $paramSetMpPreference = @{
         EnableControlledFolderAccess = 'Enabled'
         Force                        = $true
         ErrorAction                  = $SCT
      }
      $null = (Set-MpPreference @paramSetMpPreference)
   }
}

#region LICENSE
<#
      BSD 3-Clause License

      Copyright (c) 2021, enabling Technology
      All rights reserved.

      Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
      1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
      2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
      3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

      THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>
#endregion LICENSE

#region DISCLAIMER
<#
      DISCLAIMER:
      - Use at your own risk, etc.
      - This is open-source software, if you find an issue try to fix it yourself. There is no support and/or warranty in any kind
      - This is a third-party Software
      - The developer of this Software is NOT sponsored by or affiliated with Microsoft Corp (MSFT) or any of its subsidiaries in any way
      - The Software is not supported by Microsoft Corp (MSFT)
      - By using the Software, you agree to the License, Terms, and any Conditions declared and described above
      - If you disagree with any of the Terms, and any Conditions declared: Just delete it and build your own solution
#>
#endregion DISCLAIMER
