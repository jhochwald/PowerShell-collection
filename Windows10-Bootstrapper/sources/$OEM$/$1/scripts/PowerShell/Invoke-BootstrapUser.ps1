#requires -Version 5.0

<#
      .SYNOPSIS
      Bootstrap Windows 10 User Profile

      .DESCRIPTION
      Bootstrap Windows 10 User Profile with the default configuration.
      Tested with the latest Windows 10 (Enterprise and Professional) releases.

      .NOTES
      Lot of the stuff of this version is adopted from Disassembler <disassembler@dasm.cz>

      Version 1.7.2

      .LINK
      http://enatec.io

      .LINK
      https://github.com/Disassembler0/Win10-Initial-Setup-Script
#>
[CmdletBinding(ConfirmImpact = 'Low')]
param ()

begin
{
   Write-Output -InputObject 'Bootstrap Windows 10 User Profile'

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
   #region PrivacyTweaks
   #region DisableWindowsErrorDialog
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\Windows Error Reporting\DontShowUI'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableWindowsErrorDialog

   #region DisableAdvertisingInfo
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableAdvertisingInfo

   #region DisableWebSearch
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search\BingSearchEnabled'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search\CortanaConsent'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableWebSearch

   #region
   # Do not suggest ways I can finish setting up my device to get the most out of Windows (current user only)
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\UserProfileEngagement\ScoobeSystemSettingEnabled'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion

   #region DisableAppSuggestions
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\ContentDeliveryAllowed'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\OemPreInstalledAppsEnabled'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\PreInstalledAppsEnabled'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\PreInstalledAppsEverEnabled'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SilentInstalledAppsEnabled'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SubscribedContent-310093Enabled'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SubscribedContent-314559Enabled'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SubscribedContent-338387Enabled'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SubscribedContent-353694Enabled'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SubscribedContent-338388Enabled'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SubscribedContent-338389Enabled'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SubscribedContent-338393Enabled'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SubscribedContent-338388Enabled'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SubscribedContent-353696Enabled'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SubscribedContent-353698Enabled'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SystemPaneSuggestionsEnabled'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   # Empty placeholder tile collection in registry cache and restart Start Menu process to reload the cache
   if ([Environment]::OSVersion.Version.Build -ge 17134)
   {
      $paramGetItemProperty = @{
         Path          = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\*windows.data.placeholdertilecollection\Current'
         WarningAction = $SCT
         ErrorAction   = $SCT
      }
      $key = (Get-ItemProperty @paramGetItemProperty)

      $paramConfirmRegistryItemProperty = @{
         Path          = ($key.PSPath + 'Data')
         PropertyType  = 'Binary'
         Value         = $key.Data[0 .. 15]
         WarningAction = $SCT
         ErrorAction   = $SCT
      }
      $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

      $paramStopProcess = @{
         Name          = 'ShellExperienceHost'
         Force         = $true
         WarningAction = $SCT
         ErrorAction   = $SCT
      }
      $null = (Stop-Process @paramStopProcess)
   }
   #endregion DisableAppSuggestions

   #region DisableActivityHistory
   #endregion DisableActivityHistory

   #region DisableBackgroundApps
   $paramGetChildItem = @{
      Path          = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications'
      Exclude       = 'Microsoft.Windows.Cortana*', 'Microsoft.Windows.ShellExperienceHost*'
      WarningAction = $SCT
      ErrorAction   = $SCT
   }

   $null = (Get-ChildItem @paramGetChildItem | ForEach-Object -Process {
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
   #endregion DisableBackgroundApps

   #region
   # Make the "Open", "Print", "Edit" context menu items available, when more than 15 selected
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\MultipleInvokePromptMinimum'
      PropertyType = 'DWord'
      Value        = '300'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion

   #region DisableFeedback
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Siuf\Rules\NumberOfSIUFInPeriod'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableFeedback

   #region DisableTailoredExperiences
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy\TailoredExperiencesWithDiagnosticDataEnabled'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableTailoredExperiences

   #region DisableAdvertisingID
   #endregion DisableAdvertisingID

   #region DisableWebLangList
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Control Panel\International\User Profile\HttpAcceptLanguageOptOut'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableWebLangList

   #region DisableCortana
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Personalization\Settings\AcceptedPrivacyPolicy'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\InputPersonalization\RestrictImplicitTextCollection'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\InputPersonalization\RestrictImplicitInkCollection'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore\HarvestContacts'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableCortana
   #endregion PrivacyTweaks

   #region SecurityTweaks
   #region
   # Turn off Windows Script Host (current user only)
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\SOFTWARE\Microsoft\Windows Script Host\Settings\Enabled'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion

   #region AppAndBrowser_EdgeSmartScreenOff
   # Dismiss Microsoft Defender offer in the Windows Security about to turn on the SmartScreen filter for Microsoft Edge
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows Security Health\State\AppAndBrowser_EdgeSmartScreenOff'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion AppAndBrowser_EdgeSmartScreenOff

   #region HideDefenderAccountProtectionWarning
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows Security Health\State\AccountProtection_MicrosoftAccount_Disconnected'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion HideDefenderAccountProtectionWarning

   #region DisableDownloadBlocking
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments\SaveZoneInformation'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableDownloadBlocking
   #endregion SecurityTweaks

   #region LegacyDefaultPrinterMode
   # Do not let Windows manage default printer
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Windows\LegacyDefaultPrinterMode'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion LegacyDefaultPrinterMode

   #region ServiceTweaks
   #region DisableSharedExperiences
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\CDP\RomeSdkChannelUserAuthzPolicy'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableSharedExperiences

   #region DisableClipboardHistory
   $null = (Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Clipboard' -Name 'EnableClipboardHistory' @paramRemoveItemProperty)
   #endregion DisableClipboardHistory

   #region DisableAutoplay
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\DisableAutoplay'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableAutoplay

   #region
   # Automatically save my restartable apps when signing out and restart them after signing in (current user only)
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\RestartApps'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion

   #region EnableStorageSense
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy\01'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy\StoragePoliciesNotified'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   # Run Storage Sense every month
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy\2048'
      PropertyType = 'DWord'
      Value        = '30'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   # Delete temporary files that apps aren't using
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy\04'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   # Delete files in recycle bin if they have been there for over 30 days
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy\08'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy\256'
      PropertyType = 'DWord'
      Value        = '30'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   # Never delete files in "Downloads" folder
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy\512'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion EnableStorageSense

   #region EnableRecycleBin
   $null = (Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer' -Name 'NoRecycleFiles' @paramRemoveItemProperty)
   #endregion EnableRecycleBin
   #endregion ServiceTweaks

   #region UITweaks
   #region EnablePerProcessSystemDPI
   # Let Windows try to fix apps so they're not blurry
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Control Panel\Desktop\EnablePerProcessSystemDPI'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion EnablePerProcessSystemDPI

   #region EnableActionCenter
   $null = (Remove-ItemProperty -Path 'HKCU:\Software\Policies\Microsoft\Windows\Explorer' -Name 'DisableNotificationCenter' @paramRemoveItemProperty)
   $null = (Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications' -Name 'ToastEnabled'@paramRemoveItemProperty)
   #endregion EnableActionCenter

   #region EnableAeroShake
   $null = (Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'DisallowShaking' @paramRemoveItemProperty)
   #endregion EnableAeroShake

   #region DisableAccessibilityKeys
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Control Panel\Accessibility\StickyKeys\Flags'
      PropertyType = 'String'
      Value        = '506'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Control Panel\Accessibility\ToggleKeys\Flags'
      PropertyType = 'String'
      Value        = '58'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Control Panel\Accessibility\Keyboard Response\Flags'
      PropertyType = 'String'
      Value        = '122'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableAccessibilityKeys

   #region ShowTaskManagerDetails
   $paramStartProcess = @{
      WindowStyle   = 'Hidden'
      FilePath      = 'taskmgr.exe'
      PassThru      = $true
      WarningAction = $SCT
      ErrorAction   = $SCT
   }

   $taskmgr = (Start-Process @paramStartProcess)
   $timeout = 30000
   $sleep = 100
   $preferences = $null
   do
   {
      $null = (Start-Sleep -Milliseconds $sleep)
      $timeout -= $sleep
      $paramGetItemProperty = @{
         Path          = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager'
         Name          = 'Preferences'
         WarningAction = $SCT
         ErrorAction   = $SCT
      }

      $preferences = (Get-ItemProperty @paramGetItemProperty)
   }
   until ($preferences -or $timeout -le 0)
   $null = ($taskmgr | Stop-Process -WarningAction $SCT -ErrorAction $SCT)

   if ($preferences)
   {
      $preferences.Preferences[28] = 0
      $paramConfirmRegistryItemProperty = @{
         Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager\Preferences'
         PropertyType = 'Binary'
         Value        = $preferences.Preferences
         ErrorAction  = $SCT
      }
      $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   }
   #endregion ShowTaskManagerDetails

   #region ShowFileOperationsDetails
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager\EnthusiastMode'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion ShowFileOperationsDetails

   #region EnableFileDeleteConfirm
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\ConfirmFileDelete'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion EnableFileDeleteConfirm

   #region HideTaskbarSearch
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search\SearchboxTaskbarMode'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion HideTaskbarSearch

   #region HideTaskView
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\ShowTaskViewButton'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion HideTaskView

   #region ShowSmallTaskbarIcons
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarSmallIcons'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion ShowSmallTaskbarIcons

   #region SetTaskbarCombineAlways
   $null = (Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarGlomLevel' @paramRemoveItemProperty)
   $null = (Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'MMTaskbarGlomLevel' @paramRemoveItemProperty)
   #endregion SetTaskbarCombineAlways

   #region HideTaskbarPeopleIcon
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People\PeopleBand'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion HideTaskbarPeopleIcon

   #region HideTrayIcons
   $null = (Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer' -Name 'NoAutoTrayNotify' @paramRemoveItemProperty)
   #endregion HideTrayIcons

   #region HideSecondsFromTaskbar
   $null = (Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'ShowSecondsInSystemClock' @paramRemoveItemProperty)
   #endregion HideSecondsFromTaskbar

   #region SetControlPanelSmallIcons
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel\StartupPage'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel\AllItemsIconView'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion SetControlPanelSmallIcons

   #region DisableShortcutInName
   $paramNewItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\'
      Name         = 'link'
      PropertyType = 'Binary'
      Value        = ([byte[]](00, 00, 00, 00))
      Force        = $true
      ErrorAction  = $SCT
   }
   $null = (New-ItemProperty @paramNewItemProperty)
   #endregion DisableShortcutInName

   #region PrintScreenKeyForSnippingEnabled
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Control Panel\Keyboard\PrintScreenKeyForSnippingEnabled'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion PrintScreenKeyForSnippingEnabled

   #region SetVisualFXPerformance
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Control Panel\Desktop\DragFullWindows'
      PropertyType = 'String'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Control Panel\Desktop\MenuShowDelay'
      PropertyType = 'String'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Control Panel\Desktop\UserPreferencesMask'
      PropertyType = 'Binary'
      Value        = ([byte[]](144, 18, 3, 128, 16, 0, 0, 0))
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Control Panel\Desktop\WindowMetrics\MinAnimate'
      PropertyType = 'String'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Control Panel\Keyboard\KeyboardDelay'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\ListviewAlphaSelect'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\ListviewShadow'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarAnimations'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\VisualFXSetting'
      PropertyType = 'DWord'
      Value        = 3
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\DWM\EnableAeroPeek'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion SetVisualFXPerformance

   #region EnableTitleBarColor
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\DWM\ColorPrevalence'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion EnableTitleBarColor

   #region DisableDynamicScrollbars
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Control Panel\Accessibility\DynamicScrollbars'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableDynamicScrollbars

   #region RemoveENKeyboard
   $langs = (Get-WinUserLanguageList -ErrorAction $SCT)
   $null = (Set-WinUserLanguageList -LanguageList ($langs | Where-Object {
            $_.LanguageTag -ne 'en-US'
         }) -Force -ErrorAction $SCT)
   #endregion RemoveENKeyboard

   #region EnableEnhPointerPrecision
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Control Panel\Mouse\MouseSpeed'
      PropertyType = 'String'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Control Panel\Mouse\MouseThreshold1'
      PropertyType = 'String'
      Value        = '6'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Control Panel\Mouse\MouseThreshold2'
      PropertyType = 'String'
      Value        = '10'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion EnableEnhPointerPrecision

   #region DisableLiveTilesPermanently
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PushNotifications\NoTileApplicationNotification'
      PropertyType = 'String'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableLiveTilesPermanently

   #region ToastNotificationsToTop
   # Move Toast Notifications to Top of Screen
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\DisplayToastAtBottom'
      PropertyType = 'String'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion ToastNotificationsToTop

   #region SetSoundSchemeNone
   $SoundScheme = '.None'
   $paramGetChildItem = @{
      Path        = 'HKCU:\AppEvents\Schemes\Apps\*\*'
      ErrorAction = $SCT
   }
   $null = (Get-ChildItem @paramGetChildItem | ForEach-Object {
         # If scheme keys do not exist in an event, create empty ones (similar behavior to Sound control panel).
         $paramTestPath = @{
            Path        = ($_.PsPath + '\' + $SoundScheme)
            ErrorAction = $SCT
         }
         if (-not (Test-Path @paramTestPath))
         {
            $paramNewItem = @{
               Path        = ($_.PsPath + '\' + $SoundScheme)
               ErrorAction = $SCT
            }
            $null = (New-Item @paramNewItem)
         }

         $paramTestPath = @{
            Path        = ($_.PsPath + '\.Current')
            ErrorAction = $SCT
         }
         if (-not (Test-Path @paramTestPath))
         {
            $paramNewItem = @{
               Path        = ($_.PsPath + '\.Current')
               ErrorAction = $SCT
            }
            $null = (New-Item @paramNewItem)
         }

         # Get a regular string from any possible kind of value, i.e. resolve REG_EXPAND_SZ, copy REG_SZ or empty from non-existing.
         $paramGetItemProperty = @{
            Path        = ($_.PsPath + '\' + $SoundScheme)
            Name        = '(Default)'
            ErrorAction = $SCT
         }
         $Data = ((Get-ItemProperty @paramGetItemProperty).'(Default)')

         if ($Data)
         {
            # Replace any kind of value with a regular string (similar behavior to Sound control panel).
            $paramConfirmRegistryItemProperty = @{
               Path         = ($_.PsPath + '\' + $SoundScheme)
               Name         = '(Default)'
               PropertyType = 'String'
               Value        = $Data
               ErrorAction  = $SCT
            }
            $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

            # Copy data from source scheme to current.
            $paramConfirmRegistryItemProperty = @{
               Path         = ($_.PsPath + '\.Current')
               Name         = '(Default)'
               PropertyType = 'String'
               Value        = $Data
               ErrorAction  = $SCT
            }
            $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
         }
      })

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\AppEvents\Schemes\(Default)'
      PropertyType = 'String'
      Value        = $SoundScheme
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion SetSoundSchemeNone

   #region DisableF1HelpKey
   $paramTestPath = @{
      Path        = 'HKCU:\Software\Classes\TypeLib\{8cec5860-07a1-11d9-b15e-000d56bfe6ee}\1.0\0\win32'
      ErrorAction = $SCT
   }
   if (-not (Test-Path @paramTestPath))
   {
      $paramNewItem = @{
         Path        = 'HKCU:\Software\Classes\TypeLib\{8cec5860-07a1-11d9-b15e-000d56bfe6ee}\1.0\0\win32'
         Force       = $true
         ErrorAction = $SCT
      }
      $null = (New-Item @paramNewItem)
   }

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Classes\TypeLib\{8cec5860-07a1-11d9-b15e-000d56bfe6ee}\1.0\0\win32\(Default)'
      PropertyType = 'String'
      Value        = ''
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramTestPath = @{
      Path        = 'HKCU:\Software\Classes\TypeLib\{8cec5860-07a1-11d9-b15e-000d56bfe6ee}\1.0\0\win64'
      ErrorAction = $SCT
   }
   if (-not (Test-Path @paramTestPath))
   {
      $paramNewItem = @{
         Path        = 'HKCU:\Software\Classes\TypeLib\{8cec5860-07a1-11d9-b15e-000d56bfe6ee}\1.0\0\win64'
         Force       = $true
         ErrorAction = $SCT
      }
      $null = (New-Item @paramNewItem)
   }

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Classes\TypeLib\{8cec5860-07a1-11d9-b15e-000d56bfe6ee}\1.0\0\win64\(Default)'
      PropertyType = 'String'
      Value        = ''
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableF1HelpKey
   #endregion UITweaks

   #region ExplorerUITweaks
   #region DisableXboxGamebar
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR\AppCaptureEnabled'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\System\GameConfigStore\GameDVR_Enabled'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\GameBar\ShowStartupPanel'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableXboxGamebar

   #region HideExplorerTitleFullPath
   $null = (Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState' -Name 'FullPath' @paramRemoveItemProperty)
   #endregion HideExplorerTitleFullPath

   #region ShowKnownExtensions
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\HideFileExt'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion ShowKnownExtensions

   #region ShowHiddenFiles
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Hidden'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion ShowHiddenFiles

   #region HideSuperHiddenFiles
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\ShowSuperHidden'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion HideSuperHiddenFiles

   #region ShowEmptyDrives
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\HideDrivesWithNoMedia'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion ShowEmptyDrives

   #region ShowFolderMergeConflicts
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\HideMergeConflicts'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion ShowFolderMergeConflicts

   #region EnableNavPaneExpand
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\NavPaneExpandToCurrentFolder'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion EnableNavPaneExpand

   #region MMTaskbarMode
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\MMTaskbarMode'
      PropertyType = 'DWord'
      Value        = '2'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion MMTaskbarMode

   #region HideNavPaneAllFolders
   $null = (Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'NavPaneShowAllFolders' @paramRemoveItemProperty)
   #endregion HideNavPaneAllFolders

   #region EnableFolderSeparateProcess
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\SeparateProcess'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion EnableFolderSeparateProcess

   #region DisableRestoreFldrWindows
   $null = (Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'PersistBrowsers' @paramRemoveItemProperty)
   #endregion DisableRestoreFldrWindows

   #region ShowEncCompFilesColor
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\ShowEncryptCompressedColor'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion ShowEncCompFilesColor

   #region DisableSharingWizard
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\SharingWizardOn'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableSharingWizard

   #region ShowSelectCheckboxes
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\AutoCheckSelect'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion ShowSelectCheckboxes

   #region ShowSyncNotifications
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\ShowSyncProviderNotifications'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion ShowSyncNotifications

   #region HideRecentShortcuts
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ShowRecent'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ShowFrequent'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion HideRecentShortcuts

   #region SetExplorerThisPC
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\LaunchTo'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion SetExplorerThisPC

   #region HideQuickAccess
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HubMode'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion HideQuickAccess

   #region ShowRecycleBinOnDesktop
   $null = (Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu' -Name '{645FF040-5081-101B-9F08-00AA002F954E}' @paramRemoveItemProperty)
   $null = (Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel' -Name '{645FF040-5081-101B-9F08-00AA002F954E}' @paramRemoveItemProperty)
   #endregion ShowRecycleBinOnDesktop

   #region ShowThisPCOnDesktop
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu\{20D04FE0-3AEA-1069-A2D8-08002B30309D}'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel\{20D04FE0-3AEA-1069-A2D8-08002B30309D}'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion ShowThisPCOnDesktop

   #region HideUserFolderFromDesktop
   $null = (Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu' -Name '{59031a47-3f72-44a7-89c5-5595fe6b30ee}' @paramRemoveItemProperty)
   $null = (Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel' -Name '{59031a47-3f72-44a7-89c5-5595fe6b30ee}' @paramRemoveItemProperty)
   #endregion HideUserFolderFromDesktop

   #region HideControlPanelFromDesktop
   $null = (Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu' -Name '{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}' @paramRemoveItemProperty)
   $null = (Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel' -Name '{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}' @paramRemoveItemProperty)
   #endregion HideControlPanelFromDesktop

   #region HideNetworkFromDesktop
   $null = (Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu' -Name '{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}' @paramRemoveItemProperty)
   $null = (Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel' -Name '{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}' @paramRemoveItemProperty)
   #endregion HideNetworkFromDesktop

   #region HideBuildNumberFromDesktop
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Control Panel\Desktop\PaintDesktopVersion'
      PropertyType = 'DWord'
      Value        = '0'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion HideBuildNumberFromDesktop

   #region ScreenSaver
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Control Panel\Desktop\ScreenSaveActive'
      PropertyType = 'String'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Control Panel\Desktop\ScreenSaverIsSecure'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Control Panel\Desktop\ScreenSaveTimeOut'
      PropertyType = 'DWord'
      Value        = '600'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Control Panel\Desktop\scrnsave.exe'
      PropertyType = 'String'
      Value        = ($env:windir + '\system32\scrnsave.scr')
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion ScreenSaver

   #region
   # Do not add the "- Shortcut" suffix to the file name of created shortcuts (current user only)
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\NamingTemplates\ShortcutNameTemplate'
      PropertyType = 'String'
      Value        = '%s.lnk'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion

   #region DisableThumbnails
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\IconsOnly'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableThumbnails

   #region DisableThumbnailCache
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\DisableThumbnailCache'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableThumbnailCache

   #region DisableThumbsDBOnNetwork
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\DisableThumbsDBOnNetworkFolders'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableThumbsDBOnNetwork

   #region DisableDesktopWallpaperQualityReduction
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Control Panel\Desktop\JPEGImportQuality'
      PropertyType = 'DWord'
      Value        = '100'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableDesktopWallpaperQualityReduction

   #region RemoveMicrosoftEdgeShortcut
   $paramGetItemPropertyValue = @{
      Path        = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'
      Name        = 'Desktop'
      ErrorAction = $SCT
   }
   $Value = (Get-ItemPropertyValue @paramGetItemPropertyValue)
   $null = (Remove-Item -Path ($Value + '\Microsoft Edge.lnk') @paramRemoveItemProperty)
   #endregion RemoveMicrosoftEdgeShortcut

   #region RemoveHPSupportAssistantShortcut
   $null = (Remove-Item -Path "$env:PUBLIC\Desktop\HP Support Assistant.lnk" @paramRemoveItemProperty)
   #endregion RemoveHPSupportAssistantShortcut
   #endregion ExplorerUITweaks

   #region ApplicationTweaks
   #region DisableFullscreenOptims
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\System\GameConfigStore\GameDVR_DXGIHonorFSEWindowsCompatible'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\System\GameConfigStore\GameDVR_FSEBehavior'
      PropertyType = 'DWord'
      Value        = 2
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\System\GameConfigStore\GameDVR_FSEBehaviorMode'
      PropertyType = 'DWord'
      Value        = 2
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\System\GameConfigStore\GameDVR_HonorUserFSEBehaviorMode'
      PropertyType = 'DWord'
      Value        = '1'
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   #endregion DisableFullscreenOptims

   if (-not ($env:COMPUTERNAME -match 'ENSHARED-'))
   {
      #region OneDriveInsider
      $paramConfirmRegistryItemProperty = @{
         Path         = 'HKCU:\Software\Microsoft\OneDrive\EnableTeamTier_Internal'
         PropertyType = 'DWord'
         Value        = '1'
         ErrorAction  = $SCT
      }
      $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)

      $paramConfirmRegistryItemProperty = @{
         Path         = 'HKCU:\Software\Microsoft\OneDrive\EnableFasterRingUpdate'
         PropertyType = 'DWord'
         Value        = '1'
         ErrorAction  = $SCT
      }
      $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
      #endregion OneDriveInsider

      #region EnableADALOneDrive
      $paramConfirmRegistryItemProperty = @{
         Path         = 'HKCU:\SOFTWARE\Microsoft\OneDrive\EnableADAL'
         PropertyType = 'DWord'
         Value        = '1'
         ErrorAction  = $SCT
      }
      $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
      #endregion EnableADALOneDrive

      #region OneDriveEnableHoldTheFile
      # Users can choose how to handle Office files in conflict
      $paramConfirmRegistryItemProperty = @{
         Path         = 'HKCU:\SOFTWARE\Microsoft\OneDrive\EnableHoldTheFile'
         PropertyType = 'DWord'
         Value        = '1'
         ErrorAction  = $SCT
      }
      $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
      #endregionEnableHoldTheFile

      #region OneDriveEnableAllOcsiClients
      # Coauthoring and in-app sharing for Office files
      $paramConfirmRegistryItemProperty = @{
         Path         = 'HKCU:\SOFTWARE\Microsoft\OneDrive\EnableAllOcsiClients'
         PropertyType = 'DWord'
         Value        = '1'
         ErrorAction  = $SCT
      }
      $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
      #endregion OneDriveEnableAllOcsiClients
   }
   #endregion ApplicationTweaks

   #region Unpinning
   #region UnpinStartMenuTiles
   # TODO: Convert to Switch
   <#
         if ([Environment]::OSVersion.Version.Build -ge 15063 -And [Environment]::OSVersion.Version.Build -le 16299)
         {
         Get-ChildItem -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount' -Include '*.group' -Recurse -WarningAction $SCT -ErrorAction $SCT | ForEach-Object {
         $Data = ((Get-ItemProperty -Path ($_.PsPath + '\Current') -Name 'Data' -WarningAction $SCT -ErrorAction $SCT).Data -Join ',')
         $Data = ($Data.Substring(0, $Data.IndexOf(',0,202,30') + 9) + ',0,202,80,0,0')

         $null = (Confirm-RegistryItemProperty -Path ($_.PsPath + '\Current\Data') -PropertyType Binary -Value $Data.Split(',') -WarningAction $SCT -ErrorAction $SCT)
         }
         }
         elseif ([Environment]::OSVersion.Version.Build -ge 17134)
         {
         $key = (Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\*start.tilegrid`$windows.data.curatedtilecollection.tilecollection\Current" -WarningAction $SCT -ErrorAction $SCT)
         $Data = $key.Data[0 .. 25] + ([byte[]](202, 50, 0, 226, 44, 1, 1, 0, 0))

         $null = (Confirm-RegistryItemProperty -Path ($key.PSPath + '\Data') -PropertyType Binary -Value $Data -ErrorAction $SCT)

         $null = (Stop-Process -Name 'ShellExperienceHost' -Force -WarningAction $SCT -ErrorAction $SCT)
         }
   #>
   #endregion UnpinStartMenuTiles

   #region UnpinTaskbarIcons
   $paramConfirmRegistryItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband\Favorites'
      PropertyType = 'Binary'
      Value        = ([byte[]](255))
      ErrorAction  = $SCT
   }
   $null = (Confirm-RegistryItemProperty @paramConfirmRegistryItemProperty)
   $null = (Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband' -Name 'FavoritesResolve' @paramRemoveItemProperty)
   #endregion UnpinTaskbarIcons
   #endregion Unpinning

   #region FinalTouches
   #region PowerShellProfiles
   # Create all PowerShell related Profiles as dummy (empty)
   $AllSystemProfiles = @(
      (($PROFILE).CurrentUserCurrentHost)
      (($PROFILE).CurrentUserAllHosts)
      (($PROFILE).AllUsersCurrentHost)
      (($PROFILE).AllUsersAllHosts)
      ($PSHOME + '\Microsoft.VSCode_profile.ps1')
   )

   foreach ($SystemProfile in $AllSystemProfiles)
   {
      $paramTestPath = @{
         Path        = $SystemProfile
         ErrorAction = $SCT
      }
      if (-not (Test-Path @paramTestPath))
      {
         $paramNewItem = @{
            ItemType    = 'File'
            Path        = $SystemProfile
            Force       = $true
            ErrorAction = $SCT
         }
         $null = (New-Item @paramNewItem)
      }
   }
   #endregion PowerShellProfiles

   # Restart Start menu
   $paramStopProcess = @{
      Name        = 'StartMenuExperienceHost'
      Force       = $true
      ErrorAction = $SCT
   }
   $null = (Stop-Process @paramStopProcess)

   # Refresh desktop icons, environment variables and taskbar without restarting File Explorer
   $UpdateEnvExplorerAPI = @{
      Namespace        = 'WinAPI'
      Name             = 'UpdateEnvExplorer'
      Language         = 'CSharp'
      MemberDefinition = @'
private static readonly IntPtr HWND_BROADCAST = new IntPtr(0xffff);
private const int WM_SETTINGCHANGE = 0x1a;
private const int SMTO_ABORTIFHUNG = 0x0002;
[DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = false)]
static extern bool SendNotifyMessage(IntPtr hWnd, uint Msg, IntPtr wParam, string lParam);
[DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = false)]
private static extern IntPtr SendMessageTimeout(IntPtr hWnd, int Msg, IntPtr wParam, string lParam, int fuFlags, int uTimeout, IntPtr lpdwResult);
[DllImport("shell32.dll", CharSet = CharSet.Auto, SetLastError = false)]
private static extern int SHChangeNotify(int eventId, int flags, IntPtr item1, IntPtr item2);
public static void Refresh()
{
   // Update desktop icons
   SHChangeNotify(0x8000000, 0x1000, IntPtr.Zero, IntPtr.Zero);
   // Update environment variables
   SendMessageTimeout(HWND_BROADCAST, WM_SETTINGCHANGE, IntPtr.Zero, null, SMTO_ABORTIFHUNG, 100, IntPtr.Zero);
   // Update taskbar
   SendNotifyMessage(HWND_BROADCAST, WM_SETTINGCHANGE, IntPtr.Zero, "TraySettings");
}
'@
   }

   if (-not ('WinAPI.UpdateEnvExplorer' -as [type]))
   {
      $null = (Add-Type @UpdateEnvExplorerAPI)
   }

   $null = ([WinAPI.UpdateEnvExplorer]::Refresh())
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
