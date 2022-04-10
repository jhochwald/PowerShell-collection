#requires -Version 5.0 -Modules Appx, CimCmdlets, ConfigDefender, Dism, NetAdapter, NetSecurity, PackageManagement, ScheduledTasks -RunAsAdministrator

<#
      .SYNOPSIS
      Apply some basic tweaks for Windows 11

      .DESCRIPTION
      Apply some basic tweaks for Windows 11
      This will cause changes to the system and the user.

      Please note: You need to run it elevated to apply the system wide changes.

      .EXAMPLE
      PS C:\> .\Invoke-ApplyBasicTweakWindows11.ps1

      .LINK
      https://github.com/farag2/Sophia-Script-for-Windows/blob/master/Sophia%20Script/Sophia%20Script%20for%20Windows%2011/Module/Sophia.psm1

      .LINK
      https://github.com/farag2/Sophia-Script-for-Windows

      .NOTES
      Most of the stuff is stolen from the Sophia Script for Windows - Thanks to @farag2 <- Also blame him :-)
      Also from the Sophia Script for Windows: Copyright (c) 2019 farag2 - MIT License

      The MIT license also applies to this script (to keep the license of Sophia Script for Windows intact)!
#>
[CmdletBinding(ConfirmImpact = 'Low')]
param ()

#region GlobalVariables
$SCT = 'SilentlyContinue'
#endregion GlobalVariables

# Enable the Restore Point feature
$paramEnableComputerRestore = @{
   Drive       = $env:SystemDrive
   Confirm     = $false
   ErrorAction = $SCT
}
$null = (Enable-ComputerRestore @paramEnableComputerRestore)

# Never skip creating a restore point
$paramNewItemProperty = @{
   Path         = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore'
   Name         = 'SystemRestorePointCreationFrequency'
   PropertyType = 'DWord'
   Value        = 0
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)

# Create the Checkpoint NOW
$paramCheckpointComputer = @{
   Description      = 'Backup Windows 11 before we tweak it'
   RestorePointType = 'MODIFY_SETTINGS'
   ErrorAction      = $SCT
}
$null = (Checkpoint-Computer @paramCheckpointComputer)

# Revert the System Restore checkpoint creation frequency to 1440 minutes
$paramNewItemProperty = @{
   Path         = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore'
   Name         = 'SystemRestorePointCreationFrequency'
   PropertyType = 'DWord'
   Value        = 1440
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)

#region PrivacyAndTelemetry
#region DiagTrack
<#
      Disable the Connected User Experiences and Telemetry (DiagTrack) service, and block connection for the Unified Telemetry Client Outbound Traffic
#>
# Connected User Experiences and Telemetry
$null = (Get-Service -Name 'DiagTrack' -ErrorAction $SCT | Stop-Service -Force -Confirm:$false -ErrorAction $SCT)
$null = (Get-Service -Name 'DiagTrack' -ErrorAction $SCT | Set-Service -StartupType Disabled -Confirm:$false -ErrorAction $SCT)

# Block connection for the Unified Telemetry Client Outbound Traffic
$paramGetNetFirewallRule = @{
   Group       = 'DiagTrack'
   ErrorAction = $SCT
}
$paramSetNetFirewallRule = @{
   Enabled     = 'False'
   Action      = 'Block'
   ErrorAction = $SCT
   Confirm     = $false
}
$null = (Get-NetFirewallRule @paramGetNetFirewallRule | Set-NetFirewallRule @paramSetNetFirewallRule)
#endregion DiagTrack

#region DiagnosticData
<#
      Set the diagnostic data collection to minimum
#>
if (Get-WindowsEdition -Online -ErrorAction $SCT | Where-Object -FilterScript {
      $PSItem.Edition -like 'Enterprise*' -or $PSItem.Edition -eq 'Education'
   })
{
   # Diagnostic data off
   $paramNewItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection'
      Name         = 'AllowTelemetry'
      PropertyType = 'DWord'
      Value        = 0
      Force        = $true
      Confirm      = $false
      ErrorAction  = $SCT
   }
   $null = (New-ItemProperty @paramNewItemProperty)
}
else
{
   # Send required diagnostic data
   $paramNewItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection'
      Name         = 'AllowTelemetry'
      PropertyType = 'DWord'
      Value        = 1
      Force        = $true
      Confirm      = $false
      ErrorAction  = $SCT
   }
   $null = (New-ItemProperty @paramNewItemProperty)
}

$paramNewItemProperty = @{
   Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection'
   Name         = 'MaxTelemetryAllowed'
   PropertyType = 'DWord'
   Value        = 1
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
$paramNewItemProperty = @{
   Path         = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack'
   Name         = 'ShowedToastAtLevel'
   PropertyType = 'DWord'
   Value        = 1
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion DiagnosticData

#region WindowsErrorReporting
<#
      Turn off Windows Error Reporting
#>
if ((Get-WindowsEdition -Online).Edition -notmatch 'Core')
{
   $null = (Get-ScheduledTask -TaskName 'QueueReporting' -ErrorAction $SCT | Disable-ScheduledTask -ErrorAction $SCT)
   $paramNewItemProperty = @{
      Path         = 'HKCU:\SOFTWARE\Microsoft\Windows\Windows Error Reporting'
      Name         = 'Disabled'
      PropertyType = 'DWord'
      Value        = 1
      Force        = $true
      Confirm      = $false
      ErrorAction  = $SCT
   }
   $null = (New-ItemProperty @paramNewItemProperty)
}

$null = (Get-Service -Name 'WerSvc' -ErrorAction $SCT | Stop-Service -Force -Confirm:$false -ErrorAction $SCT)
$null = (Get-Service -Name 'WerSvc' -ErrorAction $SCT | Set-Service -StartupType Disabled -Confirm:$false -ErrorAction $SCT)
#endregion WindowsErrorReporting

#region FeedbackFrequency
<#
      Change the feedback frequency to "Never"
#>
$paramTestPath = @{
   Path        = 'HKCU:\SOFTWARE\Microsoft\Siuf\Rules'
   ErrorAction = $SCT
}
if (-not (Test-Path @paramTestPath))
{
   $paramNewItem = @{
      Path        = 'HKCU:\SOFTWARE\Microsoft\Siuf\Rules'
      Force       = $true
      Confirm     = $false
      ErrorAction = $SCT
   }
   $null = (New-Item @paramNewItem)
}

$paramNewItemProperty = @{
   Path         = 'HKCU:\SOFTWARE\Microsoft\Siuf\Rules'
   Name         = 'NumberOfSIUFInPeriod'
   PropertyType = 'DWord'
   Value        = 0
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion FeedbackFrequency

#region SigninInfo
<#
      The sign-in info to automatically finish setting up device after an update
#>
$SID = (Get-CimInstance -ClassName 'Win32_UserAccount' -ErrorAction $SCT | Where-Object -FilterScript {
      $PSItem.Name -eq $env:USERNAME
   }).SID

$paramTestPath = @{
   Path        = ('HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\UserARSO\{0}' -f $SID)
   ErrorAction = $SCT
}
if (-not (Test-Path @paramTestPath))
{
   $paramNewItem = @{
      Path        = ('HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\UserARSO\{0}' -f $SID)
      Force       = $true
      Confirm     = $false
      ErrorAction = $SCT
   }
   $null = (New-Item @paramNewItem)
}

$paramNewItemProperty = @{
   Path         = ('HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\UserARSO\{0}' -f $SID)
   Name         = 'OptOut'
   PropertyType = 'DWord'
   Value        = 1
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion SigninInfo

#region LanguageListAccess
<#
      The provision to websites a locally relevant content by accessing my language list
#>
$paramNewItemProperty = @{
   Path         = 'HKCU:\Control Panel\International\User Profile'
   Name         = 'HttpAcceptLanguageOptOut'
   PropertyType = 'DWord'
   Value        = 1
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion LanguageListAccess

#region AdvertisingID
<#
      Do not let apps show me personalized ads by using my advertising ID
#>
$paramTestPath = @{
   Path        = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo'
   ErrorAction = $SCT
}
if (-not (Test-Path @paramTestPath))
{
   $paramNewItem = @{
      Path        = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo'
      Force       = $true
      Confirm     = $false
      ErrorAction = $SCT
   }
   $null = (New-Item @paramNewItem)
}

$paramNewItemProperty = @{
   Path         = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo'
   Name         = 'Enabled'
   PropertyType = 'DWord'
   Value        = 0
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion AdvertisingID

#region WindowsWelcomeExperience
<#
      Hide the Windows welcome experiences after updates and occasionally when I sign in to highlight what's new and suggested
#>
$paramNewItemProperty = @{
   Path         = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
   Name         = 'SubscribedContent-310093Enabled'
   PropertyType = 'DWord'
   Value        = 0
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion WindowsWelcomeExperience

#region WindowsTips
<#
      Do not get tip and suggestions when I use Windows
#>
$paramNewItemProperty = @{
   Path         = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
   Name         = 'SubscribedContent-338389Enabled'
   PropertyType = 'DWord'
   Value        = 0
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion WindowsTips

#region SettingsSuggestedContent
<#
      Hide from me suggested content in the Settings app
#>
$paramNewItemProperty = @{
   Path         = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
   Name         = 'SubscribedContent-338393Enabled'
   PropertyType = 'DWord'
   Value        = 0
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
$paramNewItemProperty = @{
   Path         = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
   Name         = 'SubscribedContent-353694Enabled'
   PropertyType = 'DWord'
   Value        = 0
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
$paramNewItemProperty = @{
   Path         = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
   Name         = 'SubscribedContent-353696Enabled'
   PropertyType = 'DWord'
   Value        = 0
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion SettingsSuggestedContent

#region AppsSilentInstalling
<#
      Turn off automatic installing suggested apps
#>
$paramNewItemProperty = @{
   Path         = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
   Name         = 'SilentInstalledAppsEnabled'
   PropertyType = 'DWord'
   Value        = 0
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion AppsSilentInstalling

#region WhatsNewInWindows
<#
      Disable suggestions on how I can set up my device
#>
$paramTestPath = @{
   Path        = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\UserProfileEngagement'
   ErrorAction = $SCT
}
if (-not (Test-Path @paramTestPath))
{
   $paramNewItem = @{
      Path        = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\UserProfileEngagement'
      Force       = $true
      Confirm     = $false
      ErrorAction = $SCT
   }
   $null = (New-Item @paramNewItem)
}

$paramNewItemProperty = @{
   Path         = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\UserProfileEngagement'
   Name         = 'ScoobeSystemSettingEnabled'
   PropertyType = 'DWord'
   Value        = 0
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion WhatsNewInWindows

#region TailoredExperiences
<#
      Do not let Microsoft use your diagnostic data for personalized tips, ads, and recommendations
#>
$paramNewItemProperty = @{
   Path         = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy'
   Name         = 'TailoredExperiencesWithDiagnosticDataEnabled'
   PropertyType = 'DWord'
   Value        = 0
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion TailoredExperiences

#region BingSearch
<#
      Disable Bing search in the Start Menu
#>
$paramTestPath = @{
   Path        = 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer'
   ErrorAction = $SCT
}
if (-not (Test-Path @paramTestPath))
{
   $paramNewItem = @{
      Path        = 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer'
      Force       = $true
      Confirm     = $false
      ErrorAction = $SCT
   }
   $null = (New-Item @paramNewItem)
}

$paramNewItemProperty = @{
   Path         = 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer'
   Name         = 'DisableSearchBoxSuggestions'
   PropertyType = 'DWord'
   Value        = 1
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion BingSearch
#endregion PrivacyAndTelemetry

#region Personalization
#region ThisPC
<#
      Show the "This PC" icon on Desktop
#>
$paramTestPath = @{
   Path        = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel'
   ErrorAction = $SCT
}
if (-not (Test-Path @paramTestPath))
{
   $paramNewItem = @{
      Path        = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel'
      Force       = $true
      Confirm     = $false
      ErrorAction = $SCT
   }
   $null = (New-Item @paramNewItem)
}

$paramNewItemProperty = @{
   Path         = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel'
   Name         = '{20D04FE0-3AEA-1069-A2D8-08002B30309D}'
   PropertyType = 'DWord'
   Value        = 0
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion ThisPC

#region Windows10FileExplorer
<#
      Embrace the change and smell the future
      Disable the Windows 10 File Explorer
#>
$paramRemoveItem = @{
   Path        = 'HKCU:\Software\Classes\CLSID\{d93ed569-3b3e-4bff-8355-3c44f6a52bb5}'
   Recurse     = $true
   Force       = $true
   Confirm     = $false
   ErrorAction = $SCT
}
$null = (Remove-Item @paramRemoveItem)
#endregion Windows10FileExplorer

#region CheckBoxes
<#
      Do not use item check boxes
#>
$paramNewItemProperty = @{
   Path         = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
   Name         = 'AutoCheckSelect'
   PropertyType = 'DWord'
   Value        = 0
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion CheckBoxes

#region HiddenItems
<#
      Show hidden files, folders, and drives
#>
$paramNewItemProperty = @{
   Path         = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
   Name         = 'Hidden'
   PropertyType = 'DWord'
   Value        = 1
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion HiddenItems

#region FileExtensions
<#
      Show the file name extensions
#>
$paramNewItemProperty = @{
   Path         = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
   Name         = 'HideFileExt'
   PropertyType = 'DWord'
   Value        = 0
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion FileExtensions

#region MergeConflicts
<#
      Show folder merge conflicts
#>
$paramNewItemProperty = @{
   Path         = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
   Name         = 'HideMergeConflicts'
   PropertyType = 'DWord'
   Value        = 0
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion MergeConflicts

#region OpenFileExplorerTo
<#
      Open File Explorer to "This PC"
#>
$paramNewItemProperty = @{
   Path         = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
   Name         = 'LaunchTo'
   PropertyType = 'DWord'
   Value        = 1
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion OpenFileExplorerTo

#region OneDriveFileExplorerAd
<#
      Show sync provider notification within File Explorer
#>
$paramNewItemProperty = @{
   Path         = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
   Name         = 'ShowSyncProviderNotifications'
   PropertyType = 'DWord'
   Value        = 1
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion OneDriveFileExplorerAd

#region SnapAssist
<#
      When I snap a window, show what I can snap next to it
#>
$paramNewItemProperty = @{
   Path         = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
   Name         = 'SnapAssist'
   PropertyType = 'DWord'
   Value        = 1
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion SnapAssist

#region SnapAssistFlyout
<#
      Show snap layouts when I hover over a windows's maximize button
#>
$paramNewItemProperty = @{
   Path         = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
   Name         = 'EnableSnapAssistFlyout'
   PropertyType = 'DWord'
   Value        = 1
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion SnapAssistFlyout

#region FileTransferDialog
<#
      Show the file transfer dialog box in the detailed mode
#>
$paramTestPath = @{
   Path        = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager'
   ErrorAction = $SCT
}
if (-not (Test-Path @paramTestPath))
{
   $paramNewItem = @{
      Path        = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager'
      Force       = $true
      Confirm     = $false
      ErrorAction = $SCT
   }
   $null = (New-Item @paramNewItem)
}

$paramNewItemProperty = @{
   Path         = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager'
   Name         = 'EnthusiastMode'
   PropertyType = 'DWord'
   Value        = 1
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion FileTransferDialog

#region RecycleBinDeleteConfirmation
<#
      Display the recycle bin files delete confirmation dialog
#>
$ShellState[4] = 51
$paramNewItemProperty = @{
   Path         = ''
   Filter       = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer'
   Include      = ''
   Name         = 'ShellState'
   PropertyType = 'Binary'
   Value        = $ShellState
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion RecycleBinDeleteConfirmation

#region QuickAccessRecentFiles
<#
      Show recently used files in Quick access
#>
$paramNewItemProperty = @{
   Path         = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer'
   Name         = 'ShowRecent'
   PropertyType = 'DWord'
   Value        = 1
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion QuickAccessRecentFiles

#region QuickAccessFrequentFolders
<#
      Hide frequently used folders in Quick access
#>
$paramNewItemProperty = @{
   Path         = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer'
   Name         = 'ShowFrequent'
   PropertyType = 'DWord'
   Value        = 0
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion QuickAccessFrequentFolders

#region TaskbarAlignment
<#
      Embrace Windows 11, there are changes!
      Set the taskbar alignment to the center
#>
$paramNewItemProperty = @{
   Path         = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
   Name         = 'TaskbarAl'
   PropertyType = 'DWord'
   Value        = 1
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion TaskbarAlignment

#region TaskbarSearch
<#
      Hide the search icon on the taskbar
#>
$paramNewItemProperty = @{
   Path         = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search'
   Name         = 'SearchboxTaskbarMode'
   PropertyType = 'DWord'
   Value        = 0
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion TaskbarSearch

#region TaskViewButton
<#
      Hide the Task view button on the taskbar
#>
$paramNewItemProperty = @{
   Path         = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
   Name         = 'ShowTaskViewButton'
   PropertyType = 'DWord'
   Value        = 0
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion TaskViewButton

#region TaskbarWidgets
<#
      Hide the widgets icon on the taskbar
#>
if (Get-AppxPackage -Name 'MicrosoftWindows.Client.WebExperience' -ErrorAction $SCT)
{
   $paramNewItemProperty = @{
      Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
      Name         = 'TaskbarDa'
      PropertyType = 'DWord'
      Value        = 0
      Force        = $true
      Confirm      = $false
      ErrorAction  = $SCT
   }
   $null = (New-ItemProperty @paramNewItemProperty)
}
#endregion TaskbarWidgets

#region TaskbarChat
<#
      Hide the Chat icon (Microsoft Teams "personal") on the taskbar
#>
$paramNewItemProperty = @{
   Path         = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
   Name         = 'TaskbarMn'
   PropertyType = 'DWord'
   Value        = 0
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion TaskbarChat

#region ControlPanelView
<#
      View the Control Panel icons by Small icons
      This is still around with Windows 11
#>
$paramTestPath = @{
   Path        = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel'
   ErrorAction = $SCT
}
if (-not (Test-Path @paramTestPath))
{
   $paramNewItem = @{
      Path        = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel'
      Force       = $true
      Confirm     = $false
      ErrorAction = $SCT
   }
   $null = (New-Item @paramNewItem)
}

$paramNewItemProperty = @{
   Path         = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel'
   Name         = 'AllItemsIconView'
   PropertyType = 'DWord'
   Value        = 1
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
$paramNewItemProperty = @{
   Path         = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel'
   Name         = 'StartupPage'
   PropertyType = 'DWord'
   Value        = 1
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion ControlPanelView

#region FirstLogonAnimation
<#
      Disable first sign-in animation after the upgrade
#>
$paramNewItemProperty = @{
   Path         = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
   Name         = 'EnableFirstLogonAnimation'
   PropertyType = 'DWord'
   Value        = 0
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion FirstLogonAnimation

#region JPEGWallpapersQuality
<#
      Set the quality factor of the JPEG desktop wallpapers to maximum
      Make them look nice.
#>
$paramNewItemProperty = @{
   Path         = 'HKCU:\Control Panel\Desktop'
   Name         = 'JPEGImportQuality'
   PropertyType = 'DWord'
   Value        = 100
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion JPEGWallpapersQuality

#region TaskManagerWindow
<#
      Start Task Manager in the expanded mode
      The compact mode is tiny and useless, right?
#>
$paramGetProcess = @{
   Name        = 'Taskmgr'
   ErrorAction = $SCT
}
$Taskmgr = (Get-Process @paramGetProcess)

Start-Sleep -Seconds 1

if ($Taskmgr)
{
   $Taskmgr.CloseMainWindow()
}

$paramStartProcess = @{
   FilePath    = 'Taskmgr.exe'
   PassThru    = $true
   ErrorAction = $SCT
}
$null = (Start-Process @paramStartProcess)

Start-Sleep -Seconds 3

do
{
   Start-Sleep -Milliseconds 100
   $paramGetItemPropertyValue = @{
      Path        = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\TaskManager'
      Name        = 'Preferences'
      ErrorAction = $SCT
   }
   $Preferences = (Get-ItemPropertyValue @paramGetItemPropertyValue)
}
until ($Preferences)

$paramStopProcess = @{
   Name        = 'Taskmgr'
   ErrorAction = $SCT
}
$null = (Stop-Process @paramStopProcess)

$Preferences[28] = 0
$paramNewItemProperty = @{
   Path         = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\TaskManager'
   Name         = 'Preferences'
   PropertyType = 'Binary'
   Value        = $Preferences
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion TaskManagerWindow

#region RestartNotification
<#
      Notify me when a restart is required to finish updating
      Let us know when we need to restart the system, after the update.
#>
$paramNewItemProperty = @{
   Path         = 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings'
   Name         = 'RestartNotificationsAllowed2'
   PropertyType = 'DWord'
   Value        = 1
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion RestartNotification

#region ShortcutsSuffix
<#
      Do not add the "- Shortcut" suffix to the file name of created shortcuts
      Now way, this looks crappy as hell, and user do NOT like it
#>
$paramTestPath = @{
   Path        = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\NamingTemplates'
   ErrorAction = $SCT
}
if (-not (Test-Path @paramTestPath))
{
   $paramNewItem = @{
      Path        = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\NamingTemplates'
      Force       = $true
      Confirm     = $false
      ErrorAction = $SCT
   }
   $null = (New-Item @paramNewItem)
}

$paramNewItemProperty = @{
   Path         = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\NamingTemplates'
   Name         = 'ShortcutNameTemplate'
   PropertyType = 'String'
   Value        = '%s.lnk'
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}

$null = (New-ItemProperty @paramNewItemProperty)
#endregion ShortcutsSuffix
#endregion Personalization

#region SystemTweaks
#region StorageSense
<#
      Turn on Storage Sense
#>
$paramTestPath = @{
   Path        = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy'
   ErrorAction = $SCT
}
if (-not (Test-Path @paramTestPath))
{
   $paramNewItem = @{
      Path        = 'H'
      Value       = 'KCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy'
      ItemType    = 'Directory'
      Force       = $true
      Confirm     = $false
      ErrorAction = $SCT
   }
   $null = (New-Item @paramNewItem)
}

$paramNewItemProperty = @{
   Path         = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy'
   Name         = 01
   PropertyType = 'DWord'
   Value        = 1
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion StorageSense

#region StorageSenseTempFiles
<#
      Turn on automatic cleaning up temporary system and app files
#>
$paramGetItemPropertyValue = @{
   Path        = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy'
   Name        = 01
   ErrorAction = $SCT
}
if ((Get-ItemPropertyValue @paramGetItemPropertyValue) -eq '1')
{
   $paramNewItemProperty = @{
      Path         = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy'
      Name         = 04
      PropertyType = 'DWord'
      Value        = 1
      Force        = $true
      Confirm      = $false
      ErrorAction  = $SCT
   }
   $null = (New-ItemProperty @paramNewItemProperty)
}
#endregion StorageSenseTempFiles

#region StorageSenseFrequency
<#
      Run Storage Sense every month, instead of running Storage Sense during low free disk space
      With large disks this can take forever, right?
#>
$paramGetItemPropertyValue = @{
   Path        = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy'
   Name        = 01
   ErrorAction = $SCT
}
if ((Get-ItemPropertyValue @paramGetItemPropertyValue) -eq '1')
{
   $paramNewItemProperty = @{
      Path         = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy'
      Name         = 2048
      PropertyType = 'DWord'
      Value        = 30
      Force        = $true
      Confirm      = $false
      ErrorAction  = $SCT
   }
   $null = (New-ItemProperty @paramNewItemProperty)
}
#endregion StorageSenseFrequency

#region Hibernation
<#
      Disable hibernation
#>
& "$env:windir\system32\powercfg.cpl" /HIBERNATE OFF
#endregion Hibernation

#region TempFolder
<#
      Change the %TEMP% environment variable path to %SystemDrive%\Temp
#>
if ($env:TEMP -ne "$env:SystemDrive\Temp")
{
   # Restart the Printer Spooler service (Spooler)
   $paramRestartService = @{
      Name        = 'Spooler'
      Force       = $true
      ErrorAction = $SCT
   }
   $null = (Restart-Service @paramRestartService)

   # Stop OneDrive processes
   $paramStopProcess = @{
      Name        = 'OneDrive'
      Force       = $true
      ErrorAction = $SCT
   }
   $null = (Stop-Process @paramStopProcess)
   $paramStopProcess = @{
      Name        = 'FileCoAuth'
      Force       = $true
      ErrorAction = $SCT
   }
   $null = (Stop-Process @paramStopProcess)

   $paramTestPath = @{
      Path        = ($env:SystemDrive + '\Temp')
      ErrorAction = $SCT
   }
   if (-not (Test-Path @paramTestPath))
   {
      $paramNewItem = @{
         Path        = ($env:SystemDrive + '\Temp')
         ItemType    = 'Directory'
         Force       = $true
         Confirm     = $false
         ErrorAction = $SCT
      }
      $null = (New-Item @paramNewItem)
   }

   # Cleaning up folders
   $paramRemoveItem = @{
      Path        = ($env:SystemRoot + '\Temp')
      Recurse     = $true
      Force       = $true
      Confirm     = $false
      ErrorAction = $SCT
   }
   $null = (Remove-Item @paramRemoveItem)
   $paramGetItem = @{
      Path        = $env:TEMP
      Force       = $true
      ErrorAction = $SCT
   }
   $null = (Get-Item @paramGetItem | Where-Object -FilterScript {
         $PSItem.LinkType -ne 'SymbolicLink'
      } | Remove-Item -Recurse -Force -Confirm:$false -ErrorAction $SCT)

   $paramTestPath = @{
      Path = ($env:LOCALAPPDATA + '\Temp')
   }
   if (-not (Test-Path @paramTestPath))
   {
      $paramNewItem = @{
         Path        = ($env:LOCALAPPDATA + '\Temp')
         ItemType    = 'Directory'
         Force       = $true
         Confirm     = $false
         ErrorAction = $SCT
      }
      $null = (New-Item @paramNewItem)
   }

   # If there are some files or folders left in %LOCALAPPDATA\Temp%
   $paramGetChildItem = @{
      Path        = $env:TEMP
      Force       = $true
      ErrorAction = $SCT
   }
   if ((Get-ChildItem @paramGetChildItem | Measure-Object).Count -ne 0)
   {
      # https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-movefileexa
      # The system does not move the file until the operating system is restarted
      # The system moves the file immediately after AUTOCHK is executed, but before creating any paging files
      $Signature = @{
         Namespace        = 'WinAPI'
         Name             = 'DeleteFiles'
         Language         = 'CSharp'
         MemberDefinition = @'
public enum MoveFileFlags
{
	MOVEFILE_DELAY_UNTIL_REBOOT = 0x00000004
}

[DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
static extern bool MoveFileEx(string lpExistingFileName, string lpNewFileName, MoveFileFlags dwFlags);

public static bool MarkFileDelete (string sourcefile)
{
	return MoveFileEx(sourcefile, null, MoveFileFlags.MOVEFILE_DELAY_UNTIL_REBOOT);
}
'@
      }

      if (-not ('WinAPI.DeleteFiles' -as [type]))
      {
         $null = (Add-Type @Signature)
      }

      try
      {
         $paramGetChildItem = @{
            Path    = $env:TEMP
            Recurse = $true
            Force   = $true
         }
         $null = (Get-ChildItem @paramGetChildItem | Remove-Item -Recurse -Force -Confirm:$false -ErrorAction $SCT)
      }
      catch
      {
         # If files are in use remove them at the next boot
         Get-ChildItem -Path $env:TEMP -Recurse -Force | ForEach-Object -Process {
            [WinAPI.DeleteFiles]::MarkFileDelete($PSItem.FullName)
         }
      }

      $SymbolicLinkTask = @"
Get-ChildItem -Path `$env:LOCALAPPDATA\Temp -Recurse -Force | Remove-Item -Recurse -Force

Get-Item -Path `$env:LOCALAPPDATA\Temp -Force | Where-Object -FilterScript {`$PSItem.LinkType -ne """SymbolicLink"""} | Remove-Item -Recurse -Force
New-Item -Path `$env:LOCALAPPDATA\Temp -ItemType SymbolicLink -Value `$env:SystemDrive\Temp -Force

Unregister-ScheduledTask -TaskName SymbolicLink -Confirm:`$false
"@

      # Create a temporary scheduled task to create a symbolic link to the %SystemDrive%\Temp folder
      $paramNewScheduledTaskAction = @{
         Execute  = 'powershell.exe'
         Argument = ('-WindowStyle Hidden -Command {0}' -f $SymbolicLinkTask)
      }
      $Action = (New-ScheduledTaskAction @paramNewScheduledTaskAction)
      $paramNewScheduledTaskTrigger = @{
         AtLogOn = $true
         User    = $env:USERNAME
      }
      $Trigger = (New-ScheduledTaskTrigger @paramNewScheduledTaskTrigger)
      $paramNewScheduledTaskSettingsSet = @{
         Compatibility = 'Win8'
      }
      $Settings = (New-ScheduledTaskSettingsSet @paramNewScheduledTaskSettingsSet)
      $paramNewScheduledTaskPrincipal = @{
         UserId   = $env:USERNAME
         RunLevel = 'Highest'
      }
      $Principal = (New-ScheduledTaskPrincipal @paramNewScheduledTaskPrincipal)
      $Parameters = @{
         TaskName  = 'SymbolicLink'
         Principal = $Principal
         Action    = $Action
         Settings  = $Settings
         Trigger   = $Trigger
         Force     = $true
      }
      $null = (Register-ScheduledTask @Parameters)
   }
   else
   {
      # Create a symbolic link to the %SystemDrive%\Temp folder
      $paramNewItem = @{
         Path        = ($env:LOCALAPPDATA + '\Temp')
         ItemType    = 'SymbolicLink'
         Value       = $env:SystemDrive
         Credential  = '\Temp'
         Force       = $true
         Confirm     = $false
         ErrorAction = $SCT
      }
      $null = (New-Item @paramNewItem)
   }

   #region main
   # Change the %TEMP% environment variable path to %LOCALAPPDATA%\Temp
   # The additional registry key creating are needed to fix the property type of the keys: SetEnvironmentVariable creates them with the "String" type instead of "ExpandString" as by default
   [Environment]::SetEnvironmentVariable('TMP', ($env:SystemDrive + '\Temp'), 'User')
   [Environment]::SetEnvironmentVariable('TMP', ($env:SystemDrive + '\Temp'), 'Machine')
   [Environment]::SetEnvironmentVariable('TMP', ($env:SystemDrive + '\Temp'), 'Process')
   $paramNewItemProperty = @{
      Path         = 'HKCU:\Environment'
      Name         = 'TMP'
      PropertyType = 'ExpandString'
      Value        = ($env:SystemDrive + '\Temp')
      Force        = $true
      Confirm      = $false
      ErrorAction  = $SCT
   }
   $null = (New-ItemProperty @paramNewItemProperty)

   [Environment]::SetEnvironmentVariable('TEMP', ($env:SystemDrive + '\Temp'), 'User')
   [Environment]::SetEnvironmentVariable('TEMP', ($env:SystemDrive + '\Temp'), 'Machine')
   [Environment]::SetEnvironmentVariable('TEMP', ($env:SystemDrive + '\Temp'), 'Process')
   $paramNewItemProperty = @{
      Path         = 'HKCU:\Environment'
      Name         = 'TEMP'
      PropertyType = 'ExpandString'
      Value        = ($env:SystemDrive + '\Temp')
      Force        = $true
      Confirm      = $false
      ErrorAction  = $SCT
   }
   $null = (New-ItemProperty @paramNewItemProperty)
   $paramNewItemProperty = @{
      Path         = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
      Name         = 'TMP'
      PropertyType = 'ExpandString'
      Value        = ($env:SystemDrive + '\Temp')
      Force        = $true
      Confirm      = $false
      ErrorAction  = $SCT
   }
   $null = (New-ItemProperty @paramNewItemProperty)
   $paramNewItemProperty = @{
      Path         = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
      Name         = 'TEMP'
      PropertyType = 'ExpandString'
      Value        = ($env:SystemDrive + '\Temp')
      Force        = $true
      Confirm      = $false
      ErrorAction  = $SCT
   }
   $null = (New-ItemProperty @paramNewItemProperty)
   # endregion main
}
#endregion TempFolder

#region Win32LongPathLimit
<#
      Disable the Windows 260 character path limit
#>
$paramNewItemProperty = @{
   Path         = 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem'
   Name         = 'LongPathsEnabled'
   PropertyType = 'DWord'
   Value        = 1
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion Win32LongPathLimit

#region BSoDStopError
<#
      Display Stop error code when BSoD occurs
#>
$paramNewItemProperty = @{
   Path         = 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl'
   Name         = 'DisplayParameters'
   PropertyType = 'DWord'
   Value        = 1
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion BSoDStopError

#region AdminApprovalMode
<#
      Notify me only when apps try to make changes to my computer
      Set this to 0 will disable it - Only a idiot will do that!
#>
$paramNewItemProperty = @{
   Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
   Name         = 'ConsentPromptBehaviorAdmin'
   PropertyType = 'DWord'
   Value        = 5
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion AdminApprovalMode

#region MappedDrivesAppElevatedAccess
<#
      Turn on access to mapped drives from app running with elevated permissions with Admin Approval Mode enabled
      This can be an issue. Please think about it, use with care!
#>
$paramNewItemProperty = @{
   Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
   Name         = 'EnableLinkedConnections'
   PropertyType = 'DWord'
   Value        = 1
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion MappedDrivesAppElevatedAccess

#region DeliveryOptimization
<#
      Turn on Delivery Optimization - Why not?
      If this computer is traveling around in very unsecured networks, we should turn this off
#>
$paramNewItemProperty = @{
   Path         = 'Registry::HKEY_USERS\S-1-5-20\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Settings'
   Name         = 'DownloadMode'
   PropertyType = 'DWord'
   Value        = 1
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion DeliveryOptimization

#region WaitNetworkStartup
<#
      Never wait for the network at computer startup and logon for workgroup networks
      This is a great option, but our computers might not be attached to the corporate network while booting
      Modern workplace approaches might not even need group policy processing any longer, so: WHY WAIT?
#>
$paramGetCimInstance = @{
   ClassName   = 'CIM_ComputerSystem'
   ErrorAction = $SCT
}
if ((Get-CimInstance @paramGetCimInstance).PartOfDomain)
{
   $paramRemoveItemProperty = @{
      Path        = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\Winlogon'
      Name        = 'SyncForegroundPolicy'
      Force       = $true
      Confirm     = $false
      ErrorAction = $SCT
   }
   $null = (Remove-ItemProperty @paramRemoveItemProperty)
}
#endregion WaitNetworkStartup

#region WindowsManageDefaultPrinter
<#
      Do not let Windows manage my default printer
      Why should we?
#>
$paramNewItemProperty = @{
   Path         = 'HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Windows'
   Name         = 'LegacyDefaultPrinterMode'
   PropertyType = 'DWord'
   Value        = 1
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion WindowsManageDefaultPrinter

#region UpdateMicrosoftProducts
<#
      Receive updates for other Microsoft products
#>
$paramNewObject = @{
   ComObject = 'Microsoft.Update.ServiceManager'
}
$null = ((New-Object @paramNewObject).AddService2('7971f918-a847-4430-9279-4a52d1efe18d', 7, ''))
#endregion UpdateMicrosoftProducts

#region LatestInstalledDotNET
<#
      Use the latest installed .NET runtime for all apps
#>
$paramNewItemProperty = @{
   Path         = 'HKLM:\SOFTWARE\Microsoft\.NETFramework'
   Name         = 'OnlyUseLatestCLR'
   PropertyType = 'DWord'
   Value        = 1
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
$paramNewItemProperty = @{
   Path         = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework'
   Name         = 'OnlyUseLatestCLR'
   PropertyType = 'DWord'
   Value        = 1
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion LatestInstalledDotNET

#region IPv6Component
<#
      Dude, we have 2022, why not use IPv6?
      Yeah, I know what you think: It is NOT secure, bla bla bla! Dude, educate yourself!
      Enable the Internet Protocol Version 6 (TCP/IPv6) component for all network connections
#>
# No checking, just do it!
$paramEnableNetAdapterBinding = @{
   Name        = '*'
   ComponentID = 'ms_tcpip6'
   ErrorAction = $SCT
}
$null = (Enable-NetAdapterBinding @paramEnableNetAdapterBinding)
#endregion IPv6Component

#region InputMethod
<#
      Override for default input method: English
#>
$paramSetWinDefaultInputMethodOverride = @{
   InputTip    = '0409:00000409'
   ErrorAction = $SCT
}
#$null = (Set-WinDefaultInputMethodOverride @paramSetWinDefaultInputMethodOverride)

# Alternative: DEFAULT
$paramRemoveItemProperty = @{
   Path        = 'HKCU:\Control Panel\International\User Profile'
   Name        = 'InputMethodOverride'
   Force       = $true
   Confirm     = $false
   ErrorAction = $SCT
}
#$null = (Remove-ItemProperty @paramRemoveItemProperty)
#endregion InputMethod

#region WinPrtScrFolder
<#
      Because Josh loves this: Save screenshots by pressing Win+PrtScr on the Desktop
#>
# Check how the script was invoked: via a preset or Function.ps1
$PresetName = (Get-PSCallStack -ErrorAction $SCT).Position | Where-Object -FilterScript {
   (($PSItem.File -match '.ps1') -and ($PSItem.File -notmatch 'Functions.ps1')) -and (($PSItem.Text -eq 'WinPrtScrFolder -Desktop') -or ($PSItem.Text -match 'Invoke-Expression'))
}

if ($null -ne $PresetName)
{
   # Get the name of a preset (e.g script.ps1) regardless it was named
   $paramSplitPath = @{
      Path = $PresetName.File
      Leaf = $true
   }
   $PresetName = (Split-Path @paramSplitPath)
   # Check whether a preset contains the "OneDrive -Uninstall" string uncommented out
   $paramGetContent = @{
      Path     = ($PSScriptRoot + '\..\' + $PresetName)
      Encoding = 'UTF8'
      Force    = $true
   }
   $OneDriveUninstallFunctionUncommented = (Get-Content @paramGetContent | Select-String -SimpleMatch -Pattern 'OneDrive -Uninstall').Line.StartsWith('#') -eq $false
   $paramGetPackage = @{
      Name         = 'Microsoft OneDrive'
      ProviderName = 'Programs'
      Force        = $true
      ErrorAction  = $SCT
   }
   $OneDriveInstalled = (Get-Package @paramGetPackage)

   if (($OneDriveUninstallFunctionUncommented) -or (-not $OneDriveInstalled))
   {
      $paramGetItemPropertyValue = @{
         Path        = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'
         Name        = 'Desktop'
         ErrorAction = $SCT
      }
      $DesktopFolder = (Get-ItemPropertyValue @paramGetItemPropertyValue)
      $paramNewItemProperty = @{
         Path         = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'
         Name         = '{B7BEDE81-DF94-4682-A7D8-57A52620B86F}'
         PropertyType = 'ExpandString'
         Value        = $DesktopFolder
         Force        = $true
         Confirm      = $false
         ErrorAction  = $SCT
      }
      $null = (New-ItemProperty @paramNewItemProperty)
   }
}
else
{
   # A preset file isn't taking a part so we ignore it and check only whether OneDrive was already uninstalled
   $paramGetPackage = @{
      Name         = 'Microsoft OneDrive'
      ProviderName = 'Programs'
      Force        = $true
      ErrorAction  = $SCT
   }
   if (-not (Get-Package @paramGetPackage))
   {
      $paramGetItemPropertyValue = @{
         Path        = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'
         Name        = 'Desktop'
         ErrorAction = $SCT
      }
      $DesktopFolder = (Get-ItemPropertyValue @paramGetItemPropertyValue)
      $paramNewItemProperty = @{
         Path         = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'
         Name         = '{B7BEDE81-DF94-4682-A7D8-57A52620B86F}'
         PropertyType = 'ExpandString'
         Value        = $DesktopFolder
         Force        = $true
         Confirm      = $false
         ErrorAction  = $SCT
      }
      $null = (New-ItemProperty @paramNewItemProperty)
   }
}
#endregion WinPrtScrFolder

#region RecommendedTroubleshooting
<#
      Ask before running troubleshooter
#>
$paramTestPath = @{
   Path        = 'HKLM:\SOFTWARE\Microsoft\WindowsMitigation'
   ErrorAction = $SCT
}
if (-not (Test-Path @paramTestPath))
{
   $paramNewItem = @{
      Path        = 'HKLM:\SOFTWARE\Microsoft\WindowsMitigation'
      Force       = $true
      Confirm     = $false
      ErrorAction = $SCT
   }
   $null = (New-Item @paramNewItem)
}

$paramNewItemProperty = @{
   Path         = 'HKLM:\SOFTWARE\Microsoft\WindowsMitigation'
   Name         = 'UserPreference'
   PropertyType = 'DWord'
   Value        = 2
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)

# Set the OS level of diagnostic data gathering to "Optional diagnostic data"
$paramNewItemProperty = @{
   Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection'
   Name         = 'AllowTelemetry'
   PropertyType = 'DWord'
   Value        = 3
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
$paramNewItemProperty = @{
   Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection'
   Name         = 'MaxTelemetryAllowed'
   PropertyType = 'DWord'
   Value        = 3
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
$paramNewItemProperty = @{
   Path         = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack'
   Name         = 'ShowedToastAtLevel'
   PropertyType = 'DWord'
   Value        = 3
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)

# Turn on Windows Error Reporting
$paramGetScheduledTask = @{
   TaskName    = 'QueueReporting'
   ErrorAction = $SCT
}
$paramEnableScheduledTask = @{
   ErrorAction = $SCT
}
$null = (Get-ScheduledTask @paramGetScheduledTask | Enable-ScheduledTask @paramEnableScheduledTask)
$paramRemoveItemProperty = @{
   Path        = 'HKCU:\SOFTWARE\Microsoft\Windows\Windows Error Reporting'
   Name        = 'Disabled'
   Force       = $true
   Confirm     = $false
   ErrorAction = $SCT
}
$null = (Remove-ItemProperty @paramRemoveItemProperty)
$paramGetService = @{
   Name        = 'WerSvc'
   ErrorAction = $SCT
}
$paramSetService = @{
   StartupType = 'Manual'
   ErrorAction = $SCT
}
$null = (Get-Service @paramGetService | Set-Service @paramSetService)
$paramGetService = @{
   Name        = 'WerSvc'
   ErrorAction = $SCT
}
$paramStartService = @{
   ErrorAction = $SCT
}
$null = (Get-Service @paramGetService | Start-Service @paramStartService)
#endregion RecommendedTroubleshooting

#region FoldersLaunchSeparateProcess
<#
      Launch folder windows in a separate process
#>
$paramNewItemProperty = @{
   Path         = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
   Name         = 'SeparateProcess'
   PropertyType = 'DWord'
   Value        = 1
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion FoldersLaunchSeparateProcess

#region ReservedStorage
<#
      Enable reserved storage after the next update installation
      Disks are big enough these days, we can keep that space allocated for that
#>
$paramSetWindowsReservedStorageState = @{
   State       = 'Enabled'
   ErrorAction = $SCT
}
$null = (Set-WindowsReservedStorageState @paramSetWindowsReservedStorageState)
#endregion ReservedStorage

#region F1HelpPage
<#
      Disable help lookup via F1
      Nobody seems to use that anymore, therefore we disable it.
#>
$paramTestPath = @{
   Path        = 'HKCU:\SOFTWARE\Classes\Typelib\{8cec5860-07a1-11d9-b15e-000d56bfe6ee}\1.0\0\win64'
   ErrorAction = $SCT
}
if (-not (Test-Path @paramTestPath))
{
   $paramNewItem = @{
      Path        = 'HKCU:\SOFTWARE\Classes\Typelib\{8cec5860-07a1-11d9-b15e-000d56bfe6ee}\1.0\0\win64'
      Force       = $true
      Confirm     = $false
      ErrorAction = $SCT
   }
   $null = (New-Item @paramNewItem)
}

$paramNewItemProperty = @{
   Path         = 'HKCU:\SOFTWARE\Classes\Typelib\{8cec5860-07a1-11d9-b15e-000d56bfe6ee}\1.0\0\win64'
   Name         = '(default)'
   PropertyType = 'String'
   Value        = ''
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion F1HelpPage

#region NumLock
<#
      Disable Num Lock at startup
      In general this is a great idea, but these days many computers are notebooks.
      Therefore we change this (again). This was our default in the past! See? Things change quick!!!
#>
$paramNewItemProperty = @{
   Path         = 'Registry::HKEY_USERS\.DEFAULT\Control Panel\Keyboard'
   Name         = 'InitialKeyboardIndicators'
   PropertyType = 'String'
   Value        = 2147483648
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion NumLock

#region StickyShift
<#
      Turn off pressing the Shift key 5 times to turn Sticky keys
#>
$paramNewItemProperty = @{
   Path         = 'HKCU:\Control Panel\Accessibility\StickyKeys'
   Name         = 'Flags'
   PropertyType = 'String'
   Value        = 506
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion StickyShift

#region Autoplay
<#
      Do NOT use AutoPlay for all media and devices
#>
$paramNewItemProperty = @{
   Path         = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers'
   Name         = 'DisableAutoplay'
   PropertyType = 'DWord'
   Value        = 1
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion Autoplay

#region ThumbnailCacheRemoval
<#
      Disable thumbnail cache removal
      Users want that, I think we just keep it around
#>
$paramNewItemProperty = @{
   Path         = 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Thumbnail Cache'
   Name         = 'Autorun'
   PropertyType = 'DWord'
   Value        = 0
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion ThumbnailCacheRemoval

#region SaveRestartableApps
<#
      Turn off automatically saving my restartable apps and restart them when I sign back in
#>
$paramNewItemProperty = @{
   Path         = 'HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
   Name         = 'RestartApps'
   PropertyType = 'DWord'
   Value        = 0
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion SaveRestartableApps

#region NetworkDiscovery
<#
      Disable "Network Discovery" and "File and Printers Sharing" for workgroup networks
#>
$paramGetCimInstance = @{
   ClassName   = 'CIM_ComputerSystem'
   ErrorAction = $SCT
}
if (-not (Get-CimInstance @paramGetCimInstance).PartOfDomain)
{
   $FirewallRules = @(
      # File and printer sharing
      '@FirewallAPI.dll,-32752',

      # Network discovery
      '@FirewallAPI.dll,-28502'
   )
   $paramSetNetFirewallRule = @{
      Group   = $FirewallRules
      Profile = 'Private'
      Enabled = 'False'
   }
   $null = (Set-NetFirewallRule @paramSetNetFirewallRule)
   $FirewallRules = $null
}
#endregion NetworkDiscovery

#region ActiveHours
<#
      Automatically adjust active hours for me based on daily usage
      This might be reverted! As long as the monitoring stays local (as it looks like) we keep it
#>
$paramNewItemProperty = @{
   Path         = 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings'
   Name         = 'SmartActiveHoursState'
   PropertyType = 'DWord'
   Value        = 1
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion ActiveHours

#region DefaultTerminalApp
<#
      Set Windows Terminal as default terminal app to host the user interface for command-line applications
      The new Windows Terminal is a smash hit!
#>
$paramGetAppxPackage = @{
   Name        = 'Microsoft.WindowsTerminal'
   ErrorAction = $SCT
}

if (Get-AppxPackage @paramGetAppxPackage)
{
   $paramTestPath = @{
      Path        = 'HKCU:\Console\%%Startup'
      ErrorAction = $SCT
   }
   if (-not (Test-Path @paramTestPath))
   {
      $paramNewItem = @{
         Path        = 'HKCU:\Console\%%Startup'
         Force       = $true
         Confirm     = $false
         ErrorAction = $SCT
      }
      $null = (New-Item @paramNewItem)
   }

   # Find the current GUID of Windows Terminal
   $paramGetAppxPackage = @{
      Name        = 'Microsoft.WindowsTerminal'
      ErrorAction = $SCT
   }
   $PackageFullName = (Get-AppxPackage @paramGetAppxPackage).PackageFullName
   Get-ChildItem -Path ('HKLM:\SOFTWARE\Classes\PackagedCom\Package\{0}\Class' -f $PackageFullName) -ErrorAction $SCT | ForEach-Object -Process {
      $paramGetItemPropertyValue = @{
         Path        = $PSItem.PSPath
         Name        = 'ServerId'
         ErrorAction = 'SilentlyContinue'
      }
      if ((Get-ItemPropertyValue @paramGetItemPropertyValue) -eq 0)
      {
         $paramNewItemProperty = @{
            Path         = 'HKCU:\Console\%%Startup'
            Name         = 'DelegationConsole'
            PropertyType = 'String'
            Value        = $PSItem.PSChildName
            Force        = $true
            Confirm      = $false
            ErrorAction  = 'SilentlyContinue'
         }
         $null = (New-ItemProperty @paramNewItemProperty)
      }

      $paramGetItemPropertyValue = @{
         Path        = $PSItem.PSPath
         Name        = 'ServerId'
         ErrorAction = 'SilentlyContinue'
      }
      if ((Get-ItemPropertyValue @paramGetItemPropertyValue) -eq 1)
      {
         $paramNewItemProperty = @{
            Path         = 'HKCU:\Console\%%Startup'
            Name         = 'DelegationTerminal'
            PropertyType = 'String'
            Value        = $PSItem.PSChildName
            Force        = $true
            Confirm      = $false
            ErrorAction  = 'SilentlyContinue'
         }
         $null = (New-ItemProperty @paramNewItemProperty)
      }
   }
}
#endregion DefaultTerminalApp
#endregion SystemTweaks

#region HEIF
<#
      Download and install the "HEVC Video Extensions from Device Manufacturer" extension using the https://store.rg-adguard.net parser
#>
# Check whether the extension is already installed
if ((-not (Get-AppxPackage -Name 'Microsoft.HEVCVideoExtension' -ErrorAction $SCT)) -and (Get-AppxPackage -Name 'Microsoft.Windows.Photos' -ErrorAction $SCT))
{
   try
   {
      try
      {
         # Check whether the https://store.rg-adguard.net site is alive
         $Parameters = @{
            Uri              = 'https://store.rg-adguard.net/api/GetFiles'
            Method           = 'Head'
            DisableKeepAlive = $true
            UseBasicParsing  = $true
            ErrorAction      = $SCT
         }
         if (-not (Invoke-WebRequest @Parameters).StatusDescription)
         {
            return
         }

         $Parameters = @{
            Method          = 'Post'
            Uri             = 'https://store.rg-adguard.net/api/GetFiles'
            ContentType     = 'application/x-www-form-urlencoded'
            Body            = @{
               type = 'url'
               url  = 'https://www.microsoft.com/store/productId/9n4wgh0z6vhq'
               ring = 'Retail'
               lang = 'en-US'
            }
            UseBasicParsing = $true
            ErrorAction     = $SCT
         }
         $Raw = (Invoke-WebRequest @Parameters)

         # Parsing the page
         $Raw | Select-String -Pattern '<tr style.*<a href=\"(?<url>.*)"\s.*>(?<text>.*)<\/a>' -AllMatches | ForEach-Object -Process {
            $PSItem.Matches
         } | ForEach-Object -Process {
            $TempURL = $PSItem.Groups[1].Value
            $Package = $PSItem.Groups[2].Value

            if ($Package -like 'Microsoft.HEVCVideoExtension_*_x64__8wekyb3d8bbwe.appx')
            {
               $paramGetItemPropertyValue = @{
                  Path        = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'
                  Name        = '{374DE290-123F-4565-9164-39C4925E467B}'
                  ErrorAction = 'SilentlyContinue'
               }
               $DownloadsFolder = (Get-ItemPropertyValue @paramGetItemPropertyValue)
               $Parameters = @{
                  Uri             = $TempURL
                  OutFile         = ('{0}\{1}' -f $DownloadsFolder, $Package)
                  UseBasicParsing = $true
                  ErrorAction     = 'SilentlyContinue'
               }
               Invoke-WebRequest @Parameters

               # Installing "HEVC Video Extensions from Device Manufacturer"
               $paramAddAppxPackage = @{
                  Path        = ('{0}\{1}' -f $DownloadsFolder, $Package)
                  ErrorAction = 'SilentlyContinue'
               }
               $null = (Add-AppxPackage @paramAddAppxPackage)
               $paramRemoveItem = @{
                  Path        = ('{0}\{1}' -f $DownloadsFolder, $Package)
                  Force       = $true
                  Confirm     = $false
                  ErrorAction = 'SilentlyContinue'
               }
               $null = (Remove-Item @paramRemoveItem)
            }
         }
      }
      catch
      {
         Write-Verbose -Message 'Whoopsie'
      }
   }
   catch
   {
      Write-Verbose -Message 'Whoopsie'
   }
}
#endregion HEIF

#region CortanaAutostart
<#
      Disable Cortana auto start, we kill it anyway
#>
$paramGetAppxPackage = @{
   Name        = 'Microsoft.549981C3F5F10'
   ErrorAction = $SCT
}
if (Get-AppxPackage @paramGetAppxPackage)
{
   $paramTestPath = @{
      Path        = 'Registry::HKEY_CLASSES_ROOT\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData\Microsoft.549981C3F5F10_8wekyb3d8bbwe\CortanaStartupId'
      ErrorAction = $SCT
   }
   if (-not (Test-Path @paramTestPath))
   {
      $paramNewItem = @{
         Path        = 'Registry::HKEY_CLASSES_ROOT\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData\Microsoft.549981C3F5F10_8wekyb3d8bbwe\CortanaStartupId'
         Force       = $true
         Confirm     = $false
         ErrorAction = $SCT
      }
      $null = (New-Item @paramNewItem)
   }

   $paramNewItemProperty = @{
      Path         = 'Registry::HKEY_CLASSES_ROOT\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData\Microsoft.549981C3F5F10_8wekyb3d8bbwe\CortanaStartupId'
      Name         = 'State'
      PropertyType = 'DWord'
      Value        = 1
      Force        = $true
      Confirm      = $false
      ErrorAction  = $SCT
   }
   $null = (New-ItemProperty @paramNewItemProperty)
}
#endregion CortanaAutostart

#region TeamsAutostart
<#
      Disable (personal) Microsoft Teams auto start
      Let the user decide
#>
$paramGetAppxPackage = @{
   Name        = 'MicrosoftTeams'
   ErrorAction = $SCT
}
if (Get-AppxPackage @paramGetAppxPackage)
{
   $paramTestPath = @{
      Path        = 'HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData\MicrosoftTeams_8wekyb3d8bbwe\TeamsStartupTask'
      ErrorAction = $SCT
   }
   if (-not (Test-Path @paramTestPath))
   {
      $paramNewItem = @{
         Path        = 'HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData\MicrosoftTeams_8wekyb3d8bbwe\TeamsStartupTask'
         Force       = $true
         Confirm     = $false
         ErrorAction = $SCT
      }
      $null = (New-Item @paramNewItem)
   }

   $paramNewItemProperty = @{
      Path         = 'HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData\MicrosoftTeams_8wekyb3d8bbwe\TeamsStartupTask'
      Name         = 'State'
      PropertyType = 'DWord'
      Value        = 1
      Force        = $true
      Confirm      = $false
      ErrorAction  = $SCT
   }
   $null = (New-ItemProperty @paramNewItemProperty)
}
#endregion TeamsAutostart

#region CheckUWPAppsUpdates
<#
      Cheap way to trigger auto update for us
#>
$paramGetCimInstance = @{
   Namespace   = 'Root\cimv2\mdm\dmmap'
   ClassName   = 'MDM_EnterpriseModernAppManagement_AppManagement01'
   ErrorAction = $SCT
}
$paramInvokeCimMethod = @{
   MethodName  = 'UpdateScanMethod'
   ErrorAction = $SCT
}
$null = (Get-CimInstance @paramGetCimInstance | Invoke-CimMethod @paramInvokeCimMethod)
#endregion CheckUWPAppsUpdates

#region XboxGameBar
<#
      Disable Xbox Game Bar
#>
$paramNewItemProperty = @{
   Path         = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR'
   Name         = 'AppCaptureEnabled'
   PropertyType = 'DWord'
   Value        = 0
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
$paramNewItemProperty = @{
   Path         = 'HKCU:\System\GameConfigStore'
   Name         = 'GameDVR_Enabled'
   PropertyType = 'DWord'
   Value        = 0
   Force        = $true
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion XboxGameBar

#region XboxGameTips
$paramGetAppxPackage = @{
   Name        = 'Microsoft.XboxGamingOverlay'
   ErrorAction = $SCT
}
if ((Get-AppxPackage @paramGetAppxPackage) -or (Get-AppxPackage -Name 'Microsoft.GamingApp' -ErrorAction $SCT))
{
   $paramNewItemProperty = @{
      Path         = 'HKCU:\SOFTWARE\Microsoft\GameBar'
      Name         = 'ShowStartupPanel'
      PropertyType = 'DWord'
      Value        = 0
      Force        = $true
      Confirm      = $false
      ErrorAction  = $SCT
   }
   $null = (New-ItemProperty @paramNewItemProperty)
}
#endregion XboxGameTips

#region GPUScheduling
<#
      Enable hardware-accelerated GPU scheduling
      Only with a dedicated GPU and WDDM version is 2.7, or higher.
#>
$paramGetCimInstance = @{
   ClassName   = 'CIM_VideoController'
   ErrorAction = $SCT
}
if (Get-CimInstance @paramGetCimInstance | Where-Object -FilterScript {
      ($PSItem.AdapterDACType -ne 'Internal') -and ($null -ne $PSItem.AdapterDACType)
   })
{
   # Determining whether an OS is not installed on a virtual machine
   $paramGetCimInstance = @{
      ClassName   = 'CIM_ComputerSystem'
      ErrorAction = $SCT
   }
   if ((Get-CimInstance @paramGetCimInstance).Model -notmatch 'Virtual')
   {
      # Checking whether a WDDM version is 2.7 or higher
      $paramGetItemPropertyValue = @{
         Path        = 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\FeatureSetUsage'
         Name        = 'WddmVersion_Min'
         ErrorAction = $SCT
      }
      $WddmVersion_Min = (Get-ItemPropertyValue @paramGetItemPropertyValue)

      if ($WddmVersion_Min -ge 2700)
      {
         $paramNewItemProperty = @{
            Path         = 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers'
            Name         = 'HwSchMode'
            PropertyType = 'DWord'
            Value        = 2
            Force        = $true
            Confirm      = $false
            ErrorAction  = $SCT
         }
         $null = (New-ItemProperty @paramNewItemProperty)
      }
   }
}
#endregion GPUScheduling

#region NetworkProtection
<#
      Enable Microsoft Defender Exploit Guard network protection
      Dude, why even think about that? Security first!!!
#>
if ((Get-MpComputerStatus).AntivirusEnabled)
{
   $paramSetMpPreference = @{
      EnableNetworkProtection = 'Enabled'
      Force                   = $true
      ErrorAction             = $SCT
   }
   $null = (Set-MpPreference @paramSetMpPreference)
}
#endregion NetworkProtection

#region PUAppsDetection
<#
      Enable detection for potentially unwanted applications and block them
      This can sometime block away crappy old apps, but it gives us security!
#>
if ((Get-MpComputerStatus).AntivirusEnabled)
{
   $paramSetMpPreference = @{
      PUAProtection = 'Enabled'
      Force         = $true
      ErrorAction   = $SCT
   }
   $null = (Set-MpPreference @paramSetMpPreference)
}
#endregion PUAppsDetection

#region DefenderSandbox
<#
      Enable sandboxing for Microsoft Defender
      Do NOT make the Defender act as your worst enemy
      Enabling this can cause VMs in KVM with QEMU to freeze up during the loading phase of Windows
#>
if ((Get-MpComputerStatus).AntivirusEnabled)
{
   & "$env:windir\system32\setx.exe" /M MP_FORCE_USE_SANDBOX 1
}
#endregion DefenderSandbox

#region DismissMSAccount
<#
      Dismiss Microsoft Defender offer in the Windows Security about signing in Microsoft account
#>
$paramNewItemProperty = @{
   Path         = 'HKCU:\SOFTWARE\Microsoft\Windows Security Health\State'
   Name         = 'AccountProtection_MicrosoftAccount_Disconnected'
   PropertyType = 'DWord'
   Value        = 1
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion DismissMSAccount

#region AuditProcess
<#
      Enable events auditing generated when a process is created (starts)
#>
& "$env:windir\system32\auditpol.exe" /set /subcategory:"{0CCE922B-69AE-11D9-BED3-505054503030}" /success:enable /failure:enable
#endregion AuditProcess

#region CommandLineProcessAudit
<#
      Include command line in process creation events
      In order this feature to work events auditing must be enabled
#>
# Enable events auditing generated when a process is created (starts)
& "$env:windir\system32\auditpol.exe" /set /subcategory:"{0CCE922B-69AE-11D9-BED3-505054503030}" /success:enable /failure:enable
$paramNewItemProperty = @{
   Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit'
   Name         = 'ProcessCreationIncludeCmdLine_Enabled'
   PropertyType = 'DWord'
   Value        = 1
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion CommandLineProcessAudit

#region EventViewerCustomView
<#
      Create the "Process Creation" custom view in the Event Viewer to log executed processes and their arguments
      In order this feature to work events auditing and command line in process creation events must be enabled
#>
# Enable events auditing generated when a process is created (starts)
& "$env:windir\system32\auditpol.exe" /set /subcategory:"{0CCE922B-69AE-11D9-BED3-505054503030}" /success:enable /failure:enable

# Include command line in process creation events
$paramNewItemProperty = @{
   Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit'
   Name         = 'ProcessCreationIncludeCmdLine_Enabled'
   PropertyType = 'DWord'
   Value        = 1
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)

# Please note: If you do NOT want English names/description, you need to change the values in <Name></Name> and <Description></Description>
$XML = @'
<ViewerConfig>
	<QueryConfig>
		<QueryParams>
			<UserQuery />
		</QueryParams>
		<QueryNode>
			<Name>Process Creation</Name>
			<Description>Process creation and command-line auditing events</Description>
			<QueryList>
				<Query Id="0" Path="Security">
					<Select Path="Security">*[System[(EventID=4688)]]</Select>
				</Query>
			</QueryList>
		</QueryNode>
	</QueryConfig>
</ViewerConfig>
'@

$paramTestPath = @{
   Path        = ($env:ProgramData + '\Microsoft\Event Viewer\Views')
   ErrorAction = $SCT
}
if (-not (Test-Path @paramTestPath))
{
   $paramNewItem = @{
      Path        = ($env:ProgramData + '\Microsoft\Event Viewer\Views')
      ItemType    = 'Directory'
      Force       = $true
      Confirm     = $false
      ErrorAction = $SCT
   }
   $null = (New-Item @paramNewItem)
}

# Save ProcessCreation.xml in the UTF-8 with BOM encoding
$paramSetContent = @{
   Path        = ($env:ProgramData + '\Microsoft\Event Viewer\Views\ProcessCreation.xml')
   Value       = $XML
   Encoding    = 'UTF8'
   Force       = $true
   Confirm     = $false
   ErrorAction = $SCT
}
$null = (Set-Content @paramSetContent)
#endregion EventViewerCustomView

#region PowerShellModulesLogging
<#
      Enable logging for all Windows PowerShell modules
      Only Josh might have an overload here! Who cares?
#>
$paramTestPath = @{
   Path        = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging\ModuleNames'
   ErrorAction = $SCT
}
if (-not (Test-Path @paramTestPath))
{
   $paramNewItem = @{
      Path        = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging\ModuleNames'
      Force       = $true
      Confirm     = $false
      ErrorAction = $SCT
   }
   $null = (New-Item @paramNewItem)
}

$paramNewItemProperty = @{
   Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging'
   Name         = 'EnableModuleLogging'
   PropertyType = 'DWord'
   Value        = 1
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
$paramNewItemProperty = @{
   Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging\ModuleNames'
   Name         = '*'
   PropertyType = 'String'
   Value        = '*'
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion PowerShellModulesLogging

#region PowerShellScriptsLogging
<#
      Enable logging for all PowerShell scripts input to the Windows PowerShell event log
      Repeat after me: Do not use secrets as a command line parameter from now on!!!
#>
$paramTestPath = @{
   Path        = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging'
   ErrorAction = $SCT
}
if (-not (Test-Path @paramTestPath))
{
   $paramNewItem = @{
      Path        = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging'
      Force       = $true
      Confirm     = $false
      ErrorAction = $SCT
   }
   $null = (New-Item @paramNewItem)
}

$paramNewItemProperty = @{
   Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging'
   Name         = 'EnableScriptBlockLogging'
   PropertyType = 'DWord'
   Value        = 1
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion PowerShellScriptsLogging

#region AppsSmartScreen
<#
      Enable apps and files checking within Microsoft Defender SmartScreen
      Any idea why we should even think about disabling this?
#>
$paramNewItemProperty = @{
   Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer'
   Name         = 'SmartScreenEnabled'
   PropertyType = 'String'
   Value        = 'Warn'
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion AppsSmartScreen

#region SaveZoneInformation
<#
      Microsoft Defender SmartScreen marks downloaded files from the Internet as unsafe
      Can cause issues, provide a huge security boost... No brainer!
#>
$paramRemoveItemProperty = @{
   Path        = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Attachments'
   Name        = 'SaveZoneInformation'
   Force       = $true
   Confirm     = $false
   ErrorAction = $SCT
}
$null = (Remove-ItemProperty @paramRemoveItemProperty)
#endregion SaveZoneInformation

#region WindowsScriptHost
<#
      Disable Windows Script Host by default
#>
$paramTestPath = @{
   Path        = 'HKCU:\SOFTWARE\Microsoft\Windows Script Host\Settings'
   ErrorAction = $SCT
}
if (-not (Test-Path @paramTestPath))
{
   $paramNewItem = @{
      Path        = 'HKCU:\SOFTWARE\Microsoft\Windows Script Host\Settings'
      Force       = $true
      Confirm     = $false
      ErrorAction = $SCT
   }
   $null = (New-Item @paramNewItem)
}

$paramNewItemProperty = @{
   Path         = 'HKCU:\SOFTWARE\Microsoft\Windows Script Host\Settings'
   Name         = 'Enabled'
   PropertyType = 'DWord'
   Value        = 0
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion WindowsScriptHost

#region WindowsSandbox
<#
      Enable Windows Sandbox
      Have a system that we can abuse and throw away? Yeah, you bet we want that badly, right?
#>
$paramGetWindowsEdition = @{
   Online      = $true
   ErrorAction = $SCT
}
if (Get-WindowsEdition @paramGetWindowsEdition | Where-Object -FilterScript {
      ($PSItem.Edition -eq 'Professional') -or ($PSItem.Edition -like 'Enterprise*')
   })
{
   # Checking whether x86 virtualization is enabled in the firmware
   $paramGetCimInstance = @{
      ClassName   = 'CIM_Processor'
      ErrorAction = $SCT
   }
   if ((Get-CimInstance @paramGetCimInstance).VirtualizationFirmwareEnabled)
   {
      $paramEnableWindowsOptionalFeature = @{
         FeatureName = 'Containers-DisposableClientVM'
         All         = $true
         Online      = $true
         NoRestart   = $true
         ErrorAction = $SCT
      }
      $null = (Enable-WindowsOptionalFeature @paramEnableWindowsOptionalFeature)
   }
   else
   {
      try
      {
         # Determining whether Hyper-V is enabled
         $paramGetCimInstance = @{
            ClassName   = 'CIM_ComputerSystem'
            ErrorAction = $SCT
         }
         if ((Get-CimInstance @paramGetCimInstance).HypervisorPresent)
         {
            $paramEnableWindowsOptionalFeature = @{
               FeatureName = 'Containers-DisposableClientVM'
               All         = $true
               Online      = $true
               NoRestart   = $true
               ErrorAction = $SCT
            }
            $null = (Enable-WindowsOptionalFeature @paramEnableWindowsOptionalFeature)
         }
      }
      catch
      {
         Write-Verbose -Message 'Jings! No Sandbox for us!!!'
      }
   }
}
#endregion WindowsSandbox

#region MSIExtractContext
<#
      Show the "Extract all" item in the Windows Installer (.msi) context menu
#>
$paramTestPath = @{
   Path        = 'Registry::HKEY_CLASSES_ROOT\Msi.Package\shell\Extract\Command'
   ErrorAction = $SCT
}
if (-not (Test-Path @paramTestPath))
{
   $paramNewItem = @{
      Path        = 'Registry::HKEY_CLASSES_ROOT\Msi.Package\shell\Extract\Command'
      Force       = $true
      Confirm     = $false
      ErrorAction = $SCT
   }
   $null = (New-Item @paramNewItem)
}

$Value = '{0}' -f "msiexec.exe /a `"%1`" /qb TARGETDIR=`"%1 extracted`""
$paramNewItemProperty = @{
   Path         = 'Registry::HKEY_CLASSES_ROOT\Msi.Package\shell\Extract\Command'
   Name         = '(default)'
   PropertyType = 'String'
   Value        = $Value
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
$paramNewItemProperty = @{
   Path         = 'Registry::HKEY_CLASSES_ROOT\Msi.Package\shell\Extract'
   Name         = 'MUIVerb'
   PropertyType = 'String'
   Value        = '@shell32.dll,-37514'
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
$paramNewItemProperty = @{
   Path         = 'Registry::HKEY_CLASSES_ROOT\Msi.Package\shell\Extract'
   Name         = 'Icon'
   PropertyType = 'String'
   Value        = 'shell32.dll,-16817'
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion MSIExtractContext

#region CABInstallContext
<#
      Show the "Install" item in the Cabinet (.cab) filenames extensions context menu
#>
$paramTestPath = @{
   Path        = 'Registry::HKEY_CLASSES_ROOT\CABFolder\Shell\runas\Command'
   ErrorAction = $SCT
}
if (-not (Test-Path @paramTestPath))
{
   $paramNewItem = @{
      Path        = 'Registry::HKEY_CLASSES_ROOT\CABFolder\Shell\runas\Command'
      Force       = $true
      Confirm     = $false
      ErrorAction = $SCT
   }
   $null = (New-Item @paramNewItem)
}

$Value = '{0}' -f "cmd /c DISM.exe /Online /Add-Package /PackagePath:`"%1`" /NoRestart & pause"
$paramNewItemProperty = @{
   Path         = 'Registry::HKEY_CLASSES_ROOT\CABFolder\Shell\runas\Command'
   Name         = '(default)'
   PropertyType = 'String'
   Value        = $Value
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
$paramNewItemProperty = @{
   Path         = 'Registry::HKEY_CLASSES_ROOT\CABFolder\Shell\runas'
   Name         = 'MUIVerb'
   PropertyType = 'String'
   Value        = '@shell32.dll,-10210'
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
$paramNewItemProperty = @{
   Path         = 'Registry::HKEY_CLASSES_ROOT\CABFolder\Shell\runas'
   Name         = 'HasLUAShield'
   PropertyType = 'String'
   Value        = ''
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion CABInstallContext

#region RunAsDifferentUserContext
<#
      Show the "Run as different user" item in the .exe filename extensions context menu
      No Admin, no fun, right? WRONG! Use your admin account instead.
#>
$paramRemoveItemProperty = @{
   Path        = 'Registry::HKEY_CLASSES_ROOT\exefile\shell\runasuser'
   Name        = 'Extended'
   Force       = $true
   Confirm     = $false
   ErrorAction = $SCT
}
$null = (Remove-ItemProperty @paramRemoveItemProperty)
#endregion RunAsDifferentUserContext

#region CastToDeviceContext
<#
      Hide the "Cast to Device" item from the media files and folders context menu
      Nice feature, but we do NOT want that!
#>
$paramTestPath = @{
   Path        = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked'
   ErrorAction = $SCT
}
if (-not (Test-Path @paramTestPath))
{
   $paramNewItem = @{
      Path        = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked'
      Force       = $true
      Confirm     = $false
      ErrorAction = $SCT
   }
   $null = (New-Item @paramNewItem)
}

$paramNewItemProperty = @{
   Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked'
   Name         = '{7AD84985-87B4-4a16-BE58-8B72A5B390F7}'
   PropertyType = 'String'
   Value        = 'Play to menu'
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion CastToDeviceContext

#region ShareContext
<#
      Show the "Share" item in the context menu
      We still have that, but think about removing it soon
#>
$paramTestPath = @{
   Path        = 'Registry::HKEY_CLASSES_ROOT\AllFilesystemObjects\shellex\ContextMenuHandlers\ModernSharing'
   ErrorAction = $SCT
}
if (-not (Test-Path @paramTestPath))
{
   $paramNewItem = @{
      Path        = 'Registry::HKEY_CLASSES_ROOT\AllFilesystemObjects\shellex\ContextMenuHandlers\ModernSharing'
      Force       = $true
      Confirm     = $false
      ErrorAction = $SCT
   }
   $null = (New-Item @paramNewItem)
}

$paramNewItemProperty = @{
   Path         = 'Registry::HKEY_CLASSES_ROOT\AllFilesystemObjects\shellex\ContextMenuHandlers\ModernSharing'
   Name         = '(default)'
   PropertyType = 'String'
   Value        = '{e2bf9676-5f8f-435c-97eb-11607a5bedf7}'
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion ShareContext

#region EditWithPhotosContext
<#
      Hide the "Edit with Photos" item from the media files context menu
      Nah! We don NOT want that from now on
#>
$paramGetAppxPackage = @{
   Name        = 'Microsoft.Windows.Photos'
   ErrorAction = $SCT
}
if (Get-AppxPackage @paramGetAppxPackage)
{
   $paramNewItemProperty = @{
      Path         = 'Registry::HKEY_CLASSES_ROOT\AppX43hnxtbyyps62jhe9sqpdzxn1790zetc\Shell\ShellEdit'
      Name         = 'ProgrammaticAccessOnly'
      PropertyType = 'String'
      Value        = ''
      Force        = $true
      Confirm      = $false
      ErrorAction  = $SCT
   }
   $null = (New-ItemProperty @paramNewItemProperty)
}
#endregion EditWithPhotosContext

#region CreateANewVideoContext
<#
      Hide the "Create a new video" item from the media files context menu
      You will miss that, right? Just kidding, seems to be useless anyway!
#>
$paramGetAppxPackage = @{
   Name        = 'Microsoft.Windows.Photos'
   ErrorAction = $SCT
}
if (Get-AppxPackage @paramGetAppxPackage)
{
   $paramNewItemProperty = @{
      Path         = 'Registry::HKEY_CLASSES_ROOT\AppX43hnxtbyyps62jhe9sqpdzxn1790zetc\Shell\ShellCreateVideo'
      Name         = 'ProgrammaticAccessOnly'
      PropertyType = 'String'
      Value        = ''
      Force        = $true
      Confirm      = $false
      ErrorAction  = $SCT
   }
   $null = (New-ItemProperty @paramNewItemProperty)
}
#endregion CreateANewVideoContext

#region PrintCMDContext
<#
      Hide the "Print" item from the .bat and .cmd context menu
      Yeah! Right, it is awesome to print a batch file! Dude, we have 2022!!!
#>
$paramNewItemProperty = @{
   Path         = 'Registry::HKEY_CLASSES_ROOT\batfile\shell\print'
   Name         = 'ProgrammaticAccessOnly'
   PropertyType = 'String'
   Value        = ''
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
$paramNewItemProperty = @{
   Path         = 'Registry::HKEY_CLASSES_ROOT\cmdfile\shell\print'
   Name         = 'ProgrammaticAccessOnly'
   PropertyType = 'String'
   Value        = ''
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion PrintCMDContext

#region IncludeInLibraryContext
<#
      Hide the "Include in Library" item from the folders and drives context menu
#>
$paramNewItemProperty = @{
   Path         = 'Registry::HKEY_CLASSES_ROOT\Folder\ShellEx\ContextMenuHandlers\Library Location'
   Name         = '(default)'
   PropertyType = 'String'
   Value        = '-{3dad6c5d-2167-4cae-9914-f99e41c12cfa}'
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion IncludeInLibraryContext

#region BitLockerContext
<#
      Show the "Turn on BitLocker" item in the drives context menu
#>
$paramGetWindowsEdition = @{
   Online      = $true
   ErrorAction = $SCT
}
if (Get-WindowsEdition @paramGetWindowsEdition | Where-Object -FilterScript {
      $PSItem.Edition -eq 'Professional' -or $PSItem.Edition -like 'Enterprise*'
   })
{
   $paramRemoveItemProperty = @{
      Path        = 'Registry::HKEY_CLASSES_ROOT\Drive\shell\encrypt-bde-elev'
      Name        = 'ProgrammaticAccessOnly'
      Force       = $true
      Confirm     = $false
      ErrorAction = $SCT
   }
   $null = (Remove-ItemProperty @paramRemoveItemProperty)
}
#endregion BitLockerContext

#region CompressedFolderNewContext
<#
      Show the "Compressed (zipped) Folder" item to the "New" context menu
#>
$paramTestPath = @{
   Path = 'Registry::HKEY_CLASSES_ROOT\.zip\CompressedFolder\ShellNew'
}
if (-not (Test-Path @paramTestPath))
{
   $paramNewItem = @{
      Path        = 'Registry::HKEY_CLASSES_ROOT\.zip\CompressedFolder\ShellNew'
      Force       = $true
      Confirm     = $false
      ErrorAction = $SCT
   }
   $null = (New-Item @paramNewItem)
}

$paramNewItemProperty = @{
   Path         = 'Registry::HKEY_CLASSES_ROOT\.zip\CompressedFolder\ShellNew'
   Name         = 'Data'
   PropertyType = 'Binary'
   Value        = ([byte[]](80, 75, 5, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
$paramNewItemProperty = @{
   Path         = 'Registry::HKEY_CLASSES_ROOT\.zip\CompressedFolder\ShellNew'
   Name         = 'ItemName'
   PropertyType = 'ExpandString'
   Value        = '@%SystemRoot%\system32\zipfldr.dll,-10194'
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion CompressedFolderNewContext

#region MultipleInvokeContext
<#
      Disable the "Open", "Print", and "Edit" items if more than 15 files selected
#>
$paramRemoveItemProperty = @{
   Path        = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer'
   Name        = 'MultipleInvokePromptMinimum'
   Force       = $true
   Confirm     = $false
   ErrorAction = $SCT
}
$null = (Remove-ItemProperty @paramRemoveItemProperty)
#endregion MultipleInvokeContext

#region UseStoreOpenWith
<#
      Hide the "Look for an app in the Microsoft Store" item in the "Open with" dialog
#>
$paramTestPath = @{
   Path        = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer'
   ErrorAction = $SCT
}
if (-not (Test-Path @paramTestPath))
{
   $paramNewItem = @{
      Path        = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer'
      Force       = $true
      Confirm     = $false
      ErrorAction = $SCT
   }
   $null = (New-Item @paramNewItem)
}

$paramNewItemProperty = @{
   Path         = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer'
   Name         = 'NoUseStoreOpenWith'
   PropertyType = 'DWord'
   Value        = 1
   Force        = $true
   Confirm      = $false
   ErrorAction  = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion UseStoreOpenWith

#region OpenWindowsTerminalContext
<#
      Hide the "Open in Windows Terminal" item in the folders context menu
#>
$paramGetAppxPackage = @{
   Name        = 'Microsoft.WindowsTerminal'
   ErrorAction = $SCT
}
if (Get-AppxPackage @paramGetAppxPackage)
{
   $paramTestPath = @{
      Path        = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked'
      ErrorAction = $SCT
   }
   if (-not (Test-Path @paramTestPath))
   {
      $paramNewItem = @{
         Path        = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked'
         Force       = $true
         Confirm     = $false
         ErrorAction = $SCT
      }
      $null = (New-Item @paramNewItem)
   }

   $paramNewItemProperty = @{
      Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked'
      Name         = '{9F156763-7844-4DC4-B2B1-901F640F5155}'
      PropertyType = 'String'
      Value        = 'WindowsTerminal'
      Force        = $true
      Confirm      = $false
      ErrorAction  = $SCT
   }
   $null = (New-ItemProperty @paramNewItemProperty)
}
#endregion OpenWindowsTerminalContext

#region OpenWindowsTerminalAdminContext
<#
      Hide the "Open in Windows Terminal" (Admin) item from the Desktop and folders context menu
#>
$Items = @(
   'Registry::HKEY_CLASSES_ROOT\Directory\Background\shell\runas',
   'Registry::HKEY_CLASSES_ROOT\Directory\shell\runas'
)
$paramRemoveItem = @{
   Path        = $Items
   Recurse     = $true
   Force       = $true
   Confirm     = $false
   ErrorAction = $SCT
}
$null = (Remove-Item @paramRemoveItem)
#endregion OpenWindowsTerminalAdminContext
