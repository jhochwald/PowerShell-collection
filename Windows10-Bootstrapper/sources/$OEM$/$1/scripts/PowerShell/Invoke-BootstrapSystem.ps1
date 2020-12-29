#requires -Version 5.0 -RunAsAdministrator

<#
      .SYNOPSIS
      Bootstrap Windows 10 System

      .DESCRIPTION
      Bootstrap Windows 10 System with the default configuration.
      Tested with the latest Windows 10 (Enterprise and Professional) releases.

      .NOTES
      Lot of the stuff of this version is adopted from Disassembler <disassembler@dasm.cz>

		Changelog:
		2.0.5: Change a few handlers for WindowsFeatures
		2.0.4: Remove Edge icon on desktop
		2.0.3: Remove the 20H2 Edge Autostart
		2.0.2: Remove First Run Experience for Edge

		Version 2.0.5

      .LINK
      http://beyond-datacenter.com

      .LINK
      https://github.com/Disassembler0/Win10-Initial-Setup-Script
#>
[CmdletBinding(ConfirmImpact = 'Low')]
param ()

begin {
	Write-Output -InputObject 'Bootstrap Windows 10 System'

	#region GlobalDefaults
	$SCT = 'SilentlyContinue'

	$null = (Set-MpPreference -EnableControlledFolderAccess Disabled -Force -ErrorAction $SCT)

	$paramRemoveItemProperty = @{
		Force       = $true
		Confirm     = $false
		ErrorAction = $SCT
	}
	#endregion GlobalDefaults

	#region HelperFunction
	function Confirm-RegistryItemProperty {
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
            Just an internal Helper function
      #>

		[CmdletBinding(ConfirmImpact = 'None',
			SupportsShouldProcess)]
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

		begin {
			$SCT = 'SilentlyContinue'
		}

		process {
			if (-Not (Test-Path -Path ($Path | Split-Path) -ErrorAction $SCT)) {
				$null = (New-Item -Path ($Path | Split-Path) -Force -WarningAction $SCT -ErrorAction $SCT)
			}

			if (-Not (Test-Path -Path $Path -ErrorAction $SCT)) {
				$null = (New-ItemProperty -Path ($Path | Split-Path) -Name ($Path | Split-Path -Leaf) -PropertyType $PropertyType -Value $Value -Force -Confirm:$false -ErrorAction $SCT)
			}
			else {
				$null = (Set-ItemProperty -Path ($Path | Split-Path) -Name ($Path | Split-Path -Leaf) -Value $Value -Force -Confirm:$false -WarningAction $SCT -ErrorAction $SCT)
			}
		}
	}
	#endregion HelperFunction
}

process {
	# Stop Search - Gain performance
	$null = (Get-Service -Name 'WSearch' -WarningAction $SCT -ErrorAction $SCT | Where-Object { $_.Status -eq "Running" } | Stop-Service -Force -Confirm:$false -WarningAction $SCT -ErrorAction $SCT)

	#region PrivacyTweaks
	# Turn off the "Previous Versions" tab from properties context menu
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\NoPreviousVersionsPage' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)

	# Do not use sign-in info to automatically finish setting up device after an update or restart
	$sid = ((Get-CimInstance -ClassName Win32_UserAccount | Where-Object -FilterScript {
				$_.Name -eq "$env:USERNAME"
   }).SID)
	$null = (Confirm-RegistryItemProperty -Path ('HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\UserARSO\' + $sid + 'OptOut') -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)

	#region DisableTelemetry
	if ((Get-WindowsEdition -Online).Edition -eq 'Enterprise' -or (Get-WindowsEdition -Online).Edition -eq 'Education') {
		$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection\AllowTelemetry' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	}
	else {
		$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection\AllowTelemetry' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	}

	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection\AllowTelemetry' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection\AllowTelemetry' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds\AllowBuildPreview' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\Software Protection Platform\NoGenTicket' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows\CEIPEnable' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat\AITEnable' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat\DisableInventory' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\AppV\CEIP\CEIPEnable' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\TabletPC\PreventHandwritingDataSharing' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\TextInput\AllowLinguisticDataCollection' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)

	$null = (Get-Scheduledtask -TaskName 'Microsoft Compatibility Appraiser', 'ProgramDataUpdater', 'Consolidator', 'KernelCeipTask', 'UsbCeip', 'Microsoft-Windows-DiskDiagnosticDataCollector', 'GatherNetworkInfo', 'QueueReporting' -ErrorAction $SCT | Disable-scheduledtask -ErrorAction $SCT)
	#endregion DisableTelemetry

	#region DisableWiFiSense
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting\value' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspot\value' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config\AutoConnectAllowedOEM' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config\WiFISenseAllowed' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	#endregion DisableWiFiSense

	#region DisableWebSearch
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search\DisableWebSearch' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion DisableWebSearch

	#region DisableAppSuggestions
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent\DisableWindowsConsumerFeatures' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\WindowsInkWorkspace\AllowSuggestedAppsInWindowsInkWorkspace' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	#endregion DisableAppSuggestions

	#region DisableActivityHistory
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System\EnableActivityFeed' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System\PublishUserActivities' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System\UploadUserActivities' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	#endregion DisableActivityHistory

	#region HideQuickAccess
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HubMode' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion HideQuickAccess

	#region DisableBackgroundApps
	$ExcludedApps = @('Microsoft.LockApp*', 'Microsoft.Windows.ContentDeliveryManager*', 'Microsoft.Windows.Cortana*', 'Microsoft.Windows.SecHealthUI*', 'Microsoft.Windows.ShellExperienceHost*', 'Microsoft.Windows.StartMenuExperienceHost*')
	$OFS = '|'
	$null = (Get-ChildItem -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications' -ErrorAction $SCT | Where-Object -FilterScript {
			$_.PSChildName -cnotmatch $ExcludedApps
		} | ForEach-Object -Process {
			$null = (Confirm-RegistryItemProperty -Path ($_.PsPath + 'Disabled') -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
			$null = (Confirm-RegistryItemProperty -Path ($_.PsPath + 'DisabledByUser') -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
		})
	$OFS = ' '
	#endregion DisableBackgroundApps

	#region EnableSensors
	$null = (Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors' -Name 'DisableSensors' @paramRemoveItemProperty)
	#endregion EnableSensors

	#region DisableLocation
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors\DisableLocation' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors\DisableLocationScripting' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion DisableLocation

	#region DisableMapUpdates
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SYSTEM\Maps\AutoUpdateEnabled' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	#endregion DisableMapUpdates

	#region DisableFeedback
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection\DoNotShowFeedbackNotifications' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	$null = (Disable-ScheduledTask -TaskName 'Microsoft\Windows\Feedback\Siuf\DmClient' -ErrorAction $SCT)
	$null = (Disable-ScheduledTask -TaskName 'Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload' -ErrorAction $SCT)
	#endregion DisableFeedback

	#region DisableTailoredExperiences
	#endregion DisableTailoredExperiences

	#region DisableAdvertisingID
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo\DisabledByGroupPolicy' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion DisableAdvertisingID

	#region DisableWebLangList
	#endregion DisableWebLangList

	#region DisableCortana
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search\AllowCortana' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization\AllowInputPersonalization' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Experience\AllowCortana\Value' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
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
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting\Disabled' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	$null = (Disable-ScheduledTask -TaskName 'Microsoft\Windows\Windows Error Reporting\QueueReporting')
	#endregion DisableErrorReporting

	#region SetP2PUpdateLocal
	if ([Environment]::OSVersion.Version.Build -eq 10240) {
		# Method used in 1507
		$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config\DODownloadMode' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	}
	elseif ([Environment]::OSVersion.Version.Build -le 14393) {
		# Method used in 1511 and 1607
		$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization\DODownloadMode' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	}
	else {
		# Method used since 1703
		$null = (Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization' -Name 'DODownloadMode' @paramRemoveItemProperty)
	}
	#endregion SetP2PUpdateLocal

	#region EnableSyncForegroundPolicy
	# Always wait for the network at computer startup and logon
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\Winlogon\SyncForegroundPolicy' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion EnableSyncForegroundPolicy

	#region EnableUseOLEDTaskbarTransparency
	# Turn on acrylic taskbar transparency
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\UseOLEDTaskbarTransparency' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion EnableUseOLEDTaskbarTransparency

	#region DisableDiagTrack
	$null = (Get-Service -Name 'DiagTrack' -WarningAction $SCT -ErrorAction $SCT | Stop-Service -Force -WarningAction $SCT -ErrorAction $SCT)
	$null = (Get-Service -Name 'DiagTrack' -WarningAction $SCT -ErrorAction $SCT | Set-Service -StartupType Disabled -ErrorAction $SCT)
	#endregion DisableDiagTrack

	#region WMPNetworkSvc
	$null = (Get-Service -Name 'WMPNetworkSvc' -WarningAction $SCT -ErrorAction $SCT | Stop-Service -Force -WarningAction $SCT -ErrorAction $SCT)
	$null = (Get-Service -Name 'WMPNetworkSvc' -WarningAction $SCT -ErrorAction $SCT | Set-Service -StartupType Disabled -ErrorAction $SCT)
	#endregion WMPNetworkSvc

	#region DisableContactData
	$null = (Get-Service -Name 'PimIndexMaintenanceSvc_*' -WarningAction $SCT -ErrorAction $SCT | Stop-Service -Force -WarningAction $SCT -ErrorAction $SCT)
	$null = (Get-Service -Name 'PimIndexMaintenanceSvc_*' -WarningAction $SCT -ErrorAction $SCT | Set-Service -StartupType Disabled -ErrorAction $SCT)

	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\System\CurrentControlSet\Services\PimIndexMaintenanceSvc\Start' -PropertyType 'DWord' -Value '4' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\System\CurrentControlSet\Services\PimIndexMaintenanceSvc\UserServiceFlags' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	#endregion DisableContactData

	#region EnableActiveProbing
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\System\CurrentControlSet\Services\NlaSvc\Parameters\Internet\EnableActiveProbing\EnableActiveProbing' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	#endregion EnableActiveProbing

	#region DisableUserDataStorage
	$null = (Get-Service -Name 'UnistoreSvc_*' -WarningAction $SCT -ErrorAction $SCT | Stop-Service -Force -WarningAction $SCT -ErrorAction $SCT)
	$null = (Get-Service -Name 'UnistoreSvc_*' -WarningAction $SCT -ErrorAction $SCT | Set-Service -StartupType Disabled -ErrorAction $SCT)

	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\System\CurrentControlSet\Services\UnistoreSvc\Start' -PropertyType 'DWord' -Value '4' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\System\CurrentControlSet\Services\UnistoreSvc\UserServiceFlags' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	#endregion DisableUserDataStorage

	#region DisableUserDataAccess
	$null = (Get-Service -Name 'UserDataSvc_*' -WarningAction $SCT -ErrorAction $SCT | Stop-Service -Force -WarningAction $SCT -ErrorAction $SCT)
	$null = (Get-Service -Name 'UserDataSvc_*' -WarningAction $SCT -ErrorAction $SCT | Set-Service -StartupType Disabled -ErrorAction $SCT)

	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\System\CurrentControlSet\Services\UserDataSvc\Start' -PropertyType 'DWord' -Value '4' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\System\CurrentControlSet\Services\UserDataSvc\UserServiceFlags' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	#endregion DisableUserDataAccess

	#region StopEventTraceSessions
	$null = (Get-EtwTraceSession -Name 'DiagLog' -ErrorAction $SCT | Stop-EtwTraceSession -WarningAction $SCT -ErrorAction $SCT)
	#endregion StopEventTraceSessions

	#region UpdateAutologgerConfig
	# Turn off the data collectors at the next computer restart
	$null = (Update-AutologgerConfig -Name DiagLog, AutoLogger-Diagtrack-Listener -Start 0 -ErrorAction $SCT)
	#endregion UpdateAutologgerConfig

	#region EnableWAPPush
	$null = (Set-Service -Name 'dmwappushservice' -StartupType Automatic -WarningAction $SCT -ErrorAction $SCT)
	$null = (Start-Service -Name 'dmwappushservice' -WarningAction $SCT -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\dmwappushservice\DelayedAutoStart' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion EnableWAPPush

	#region EnableClearRecentFiles
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer\ClearRecentDocsOnExit' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion EnableClearRecentFiles

	#region DisableRecentFiles
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer\NoRecentDocsHistory' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion DisableRecentFiles
	#endregion PrivacyTweaks

	#region SecurityTweaks
	#region SetUACHigh
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\ConsentPromptBehaviorAdmin' -PropertyType 'DWord' -Value '5' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\PromptOnSecureDesktop' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion SetUACHigh

	#region EnableSharingMappedDrives
	# Turn on access to mapped drives from app running with elevated permissions with Admin Approval Mode enabled
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\EnableLinkedConnections' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion EnableSharingMappedDrives

	#region EnableAdminShares
	$null = (Remove-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters' -Name 'AutoShareWks' @paramRemoveItemProperty)
	#endregion EnableAdminShares

	#region EnableFirewall
	$null = (Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile' -Name 'EnableFirewall' @paramRemoveItemProperty)
	#endregion EnableFirewall

	#region ShowDefenderTrayIcon
	$null = (Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Systray' -Name 'HideSystray' @paramRemoveItemProperty)

	if ([Environment]::OSVersion.Version.Build -eq 14393) {
		$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\WindowsDefender' -PropertyType ExpandString -Value "`"%ProgramFiles%\Windows Defender\MSASCuiL.exe`"" -ErrorAction $SCT)
	}
	elseif ([Environment]::OSVersion.Version.Build -ge 15063 -And [Environment]::OSVersion.Version.Build -le 17134) {
		$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\SecurityHealth' -PropertyType ExpandString -Value '%ProgramFiles%\Windows Defender\MSASCuiL.exe' -ErrorAction $SCT)
	}
	elseif ([Environment]::OSVersion.Version.Build -ge 17763) {
		$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\SecurityHealth' -PropertyType ExpandString -Value '%windir%\system32\SecurityHealthSystray.exe' -ErrorAction $SCT)
	}
	#endregion ShowDefenderTrayIcon

	#region EnableDefender
	$null = (Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender' -Name 'DisableAntiSpyware' @paramRemoveItemProperty)

	if ([Environment]::OSVersion.Version.Build -eq 14393) {
		$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\WindowsDefender' -PropertyType ExpandString -Value "`"%ProgramFiles%\Windows Defender\MSASCuiL.exe`"" -ErrorAction $SCT)
	}
	elseif ([Environment]::OSVersion.Version.Build -ge 15063 -And [Environment]::OSVersion.Version.Build -le 17134) {
		$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\SecurityHealth' -PropertyType ExpandString -Value '%ProgramFiles%\Windows Defender\MSASCuiL.exe' -ErrorAction $SCT)
	}
	elseif ([Environment]::OSVersion.Version.Build -ge 17763) {
		$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\SecurityHealth' -PropertyType ExpandString -Value '%windir%\system32\SecurityHealthSystray.exe' -ErrorAction $SCT)
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
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity\Enabled' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion EnableCoreIsolationMemoryIntegrity

	#region EnableDefenderApplicationGuard
	$null = (Enable-WindowsOptionalFeature -Online -FeatureName 'Windows-Defender-ApplicationGuard' -NoRestart -WarningAction $SCT -ErrorAction $SCT)
	#endregion EnableDefenderApplicationGuard

	#region EnableDotNetStrongCrypto
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319\SchUseStrongCrypto' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319\SchUseStrongCrypto' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
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
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\NcdAutoSetup\Private\AutoSetup' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	#endregion DisableNetDevicesAutoInstallation

	#region DisableHomeGroups
	if (Get-Service -Name 'HomeGroupListener' -WarningAction $SCT -ErrorAction $SCT) {
		$null = (Stop-Service -Name 'HomeGroupListener' -WarningAction $SCT -ErrorAction $SCT)
		$null = (Set-Service -Name 'HomeGroupListener' -StartupType Disabled -WarningAction $SCT -ErrorAction $SCT)
	}

	if (Get-Service -Name 'HomeGroupProvider' -WarningAction $SCT -ErrorAction $SCT) {
		$null = (Stop-Service -Name 'HomeGroupProvider' -WarningAction $SCT -ErrorAction $SCT)
		$null = (Set-Service -Name 'HomeGroupProvider' -StartupType Disabled -WarningAction $SCT -ErrorAction $SCT)
	}
	#endregion DisableHomeGroups

	#region DisableSMB1Protocol
	$null = (Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force -WarningAction $SCT -ErrorAction $SCT)
	#endregion DisableSMB1Protocol

	#region DisableSMB1Server
	$null = (Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force -WarningAction $SCT -ErrorAction $SCT)
	#endregion DisableSMB1Server

	#region DisableNetBIOSOverTCP
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\services\NetBT\Parameters\Interfaces\Tcpip*\NetbiosOptions' -PropertyType 'DWord' -Value 2 -ErrorAction $SCT)
	#endregion DisableNetBIOSOverTCP

	#region DisableLLMNR
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient\EnableMulticast' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	#endregion DisableLLMNR

	#region DisableLLDP
	$null = (Disable-NetAdapterBinding -Name '*' -ComponentID 'ms_lldp' -WarningAction $SCT -ErrorAction $SCT)
	#endregion DisableLLDP

	#region DisableLLTD
	$null = (Disable-NetAdapterBinding -Name '*' -ComponentID 'ms_lltdio' -WarningAction $SCT -ErrorAction $SCT)
	$null = (Disable-NetAdapterBinding -Name '*' -ComponentID 'ms_rspndr' -WarningAction $SCT -ErrorAction $SCT)
	#endregion DisableLLTD

	#region EnableQoS
	$null = (Enable-NetAdapterBinding -Name '*' -ComponentID 'ms_pacer' -WarningAction $SCT -ErrorAction $SCT)
	#endregion EnableQoS

	#region EnableIPv4Stack
	$null = (Enable-NetAdapterBinding -Name '*' -ComponentID 'ms_tcpip' -WarningAction $SCT -ErrorAction $SCT)
	#endregion EnableIPv4Stack

	#region EnableIPv6Stack
	$null = (Enable-NetAdapterBinding -Name '*' -ComponentID 'ms_tcpip6' -WarningAction $SCT -ErrorAction $SCT)
	#endregion EnableIPv6Stack

	#region DisableNCSIProbe
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\NetworkConnectivityStatusIndicator\NoActiveProbe' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion DisableNCSIProbe

	#region DisableConnectionSharing
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Network Connections\NC_ShowSharedAccessUI' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	#endregion DisableConnectionSharing

	#region DisableRemoteAssistance
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance\fAllowToGetHelp' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	#endregion DisableRemoteAssistance

	#region EnableRemoteDesktop
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\fDenyTSConnections' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	$null = (Enable-NetFirewallRule -Name 'RemoteDesktop*' -WarningAction $SCT -ErrorAction $SCT)
	#endregion EnableRemoteDesktop
	#endregion NetworkTweaks

	#region ServiceTweaks
	#region DisableApplicationCompatibilityEngine
	# Disable Application Compatibility Engine and Program Compatibility Assistant
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Windows\AppCompat\DisableEngine' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion DisableApplicationCompatibilityEngine

	#region DisableProgramCompatibilityAssistant
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Windows\AppCompat\DisablePCA' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
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
	$null = (New-Object -ComObject Microsoft.Update.ServiceManager).AddService2('7971f918-a847-4430-9279-4a52d1efe18d', 7, '')
	#endregion EnableUpdateMSProducts

	#region DisableUpdateAutoDownload
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU\AUOptions' -PropertyType 'DWord' -Value 2 -ErrorAction $SCT)
	#endregion DisableUpdateAutoDownload

	#region EnableUpdateRestart
	$null = (Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MusNotification.exe' -Name 'Debugger' @paramRemoveItemProperty)
	#endregion EnableUpdateRestart

	#region DisableMaintenanceWakeUp
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU\AUPowerManagement' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance\WakeUp' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	#endregion DisableMaintenanceWakeUp

	#region DisableAutoRestartSignOn
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\DisableAutomaticRestartSignOn' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion DisableAutoRestartSignOn

	#region DisableAutorun
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer\NoDriveTypeAutoRun' -PropertyType 'DWord' -Value 255 -ErrorAction $SCT)
	#endregion DisableAutorun

	#region EnableRestorePoints
	$null = (Enable-ComputerRestore -Drive "$env:SYSTEMDRIVE" -WarningAction $SCT -ErrorAction $SCT)
	#endregion EnableRestorePoints

	#region DisableDefragmentation
	$null = (Disable-ScheduledTask -TaskName 'Microsoft\Windows\Defrag\ScheduledDefrag' -WarningAction $SCT -ErrorAction $SCT)
	#endregion DisableDefragmentation

	#region DisableSuperfetch
	$null = (Stop-Service -Name 'SysMain' -WarningAction $SCT -ErrorAction $SCT)
	$null = (Set-Service -Name 'SysMain' -StartupType Disabled -WarningAction $SCT -ErrorAction $SCT)
	#endregion DisableSuperfetch

	#region EnableIndexing
	$null = (Set-Service -Name 'WSearch' -StartupType Automatic -WarningAction $SCT -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\WSearch\DelayedAutoStart' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	$null = (Start-Service -Name 'WSearch' -WarningAction $SCT -ErrorAction $SCT)
	#endregion EnableIndexing

	#region EnableSwapFile
	$null = (Remove-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -Name 'SwapfileControl' @paramRemoveItemProperty)
	#endregion EnableSwapFile

	#region EnableNTFSLongPaths
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem\LongPathsEnabled' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion EnableNTFSLongPaths

	#region GroupSvchostProcesses
	# Group svchost.exe processes
	$ram = ((Get-CimInstance -ClassName 'Win32_PhysicalMemory' | Measure-Object -Property 'Capacity' -Sum).Sum / 1kb)
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SvcHostSplitThresholdInKB' -PropertyType 'DWord' -Value $ram -ErrorAction $SCT)
	#endregion GroupSvchostProcesses

	#region EnableDisplayParameters
	# Display the Stop error information on the BSoD
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\CrashControl\DisplayParameters' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion EnableDisplayParameters

	#region EnableSaveZoneInformation
	# Do not preserve zone information
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Attachments\SaveZoneInformation' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion EnableSaveZoneInformation

	#region DisableNTFSLastAccess
	$null = (& "$env:windir\system32\fsutil.exe" behavior set DisableLastAccess 1)
	#endregion DisableNTFSLastAccess

	#region SetBIOSTimeUTC
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation\RealTimeIsUniversal' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion SetBIOSTimeUTC

	#region DisableFastStartup
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power\HiberbootEnabled' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	#endregion DisableFastStartup

	#region EnableAutoRebootOnCrash
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl\AutoReboot' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion EnableAutoRebootOnCrash
	#endregion ServiceTweaks

	#region UITweaks
	#region DisableLockScreen
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization\NoLockScreen' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)

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
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power\AwayModeEnabled' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion AwayModeEnabled

	#region HideNetworkFromLockScreen
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System\DontDisplayNetworkSelectionUI' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion HideNetworkFromLockScreen

	#region ShowShutdownOnLockScreen
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\ShutdownWithoutLogon' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion ShowShutdownOnLockScreen

	#region DisableLockScreenBlur
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System\DisableAcrylicBackgroundOnLogon' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion DisableLockScreenBlur

	#region DisableSearchAppInStore
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer\NoUseStoreOpenWith' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion DisableSearchAppInStore

	#region DisableNewAppPrompt
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer\NoNewAppAlert' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion DisableNewAppPrompt

	#region HideRecentlyAddedApps
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer\HideRecentlyAddedApps' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion HideRecentlyAddedApps

	#region HideMostUsedApps
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer\NoStartMenuMFUprogramsList' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	$null = (New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer' -Name 'NoStartMenuMFUprogramsList' -PropertyType 'DWord' -Value 1 -Force -WarningAction $SCT -ErrorAction $SCT)
	$null = (Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer' -Name 'NoStartMenuMFUprogramsList' -Value 1 -Force -WarningAction $SCT -ErrorAction $SCT)
	#endregion HideMostUsedApps

	#region ShowShortcutArrow
	$null = (Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons' -Name '29' @paramRemoveItemProperty)
	#endregion ShowShortcutArrow

	#region RemoveENKeyboard
	$langs = (Get-WinUserLanguageList -ErrorAction $SCT)
	if ($langs) {
		$null = (Set-WinUserLanguageList -LanguageList ($langs | Where-Object {
					$_.LanguageTag -ne 'en-US'
				}) -Force -ErrorAction $SCT)
	}
	#endregion RemoveENKeyboard

	#region DisableStartupSound
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\BootAnimation\DisableStartupSound' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion DisableStartupSound

	#region EnableChangingSoundScheme
	$null = (Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization' -Name 'NoChangingSoundScheme' @paramRemoveItemProperty)
	#endregion EnableChangingSoundScheme

	#region DisableVerboseStatus
	if ((Get-CimInstance -ClassName 'Win32_OperatingSystem' -ErrorAction $SCT).ProductType -eq 1) {
		$null = (Remove-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'VerboseStatus' @paramRemoveItemProperty)
	}
	else {
		$null = (Confirm-RegistryItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\VerboseStatus' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	}
	#endregion DisableVerboseStatus
	#endregion UITweaks

	#region ExplorerUITweaks
	#region HideDesktopFromThisPC
	$null = (Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}' -Recurse @paramRemoveItemProperty)
	#endregion HideDesktopFromThisPC

	#region HideDesktopFromExplorer
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag\ThisPCPolicy' -PropertyType String -Value 'Hide' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag\ThisPCPolicy' -PropertyType String -Value 'Hide' -ErrorAction $SCT)
	#endregion HideDesktopFromExplorer

	#region HideDocumentsFromThisPC
	$null = (Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{d3162b92-9365-467a-956b-92703aca08af}' -Recurse @paramRemoveItemProperty)
	$null = (Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}' -Recurse @paramRemoveItemProperty)
	#endregion HideDocumentsFromThisPC

	#region HideDocumentsFromExplorer
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag\ThisPCPolicy' -PropertyType String -Value 'Hide' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag\ThisPCPolicy' -PropertyType String -Value 'Hide' -ErrorAction $SCT)
	#endregion HideDocumentsFromExplorer

	#region HideDownloadsFromThisPC
	$null = (Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{088e3905-0323-4b02-9826-5d99428e115f}' -Recurse @paramRemoveItemProperty)
	$null = (Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{374DE290-123F-4565-9164-39C4925E467B}' -Recurse @paramRemoveItemProperty)
	#endregion HideDownloadsFromThisPC

	#region HideDownloadsFromExplorer
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag\ThisPCPolicy' -PropertyType String -Value 'Hide' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag\ThisPCPolicy' -PropertyType String -Value 'Hide' -ErrorAction $SCT)
	#endregion HideDownloadsFromExplorer

	#region HideMusicFromThisPC
	$null = (Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}' -Recurse @paramRemoveItemProperty)
	$null = (Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}' -Recurse @paramRemoveItemProperty)
	#endregion HideMusicFromThisPC

	#region HideMusicFromExplorer
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag\ThisPCPolicy' -PropertyType String -Value 'Hide' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag\ThisPCPolicy' -PropertyType String -Value 'Hide' -ErrorAction $SCT)
	#endregion HideMusicFromExplorer

	#region HidePicturesFromThisPC
	$null = (Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}' -Recurse @paramRemoveItemProperty)
	$null = (Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}' -Recurse @paramRemoveItemProperty)
	#endregion HidePicturesFromThisPC

	#region HidePicturesFromExplorer
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag\ThisPCPolicy' -PropertyType String -Value 'Hide' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag\ThisPCPolicy' -PropertyType String -Value 'Hide' -ErrorAction $SCT)
	#endregion HidePicturesFromExplorer

	#region HideVideosFromThisPC
	$null = (Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}' -Recurse @paramRemoveItemProperty)
	$null = (Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A0953C92-50DC-43bf-BE83-3742FED03C9C}' -Recurse @paramRemoveItemProperty)
	#endregion HideVideosFromThisPC

	#region HideVideosFromExplorer
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag\ThisPCPolicy' -PropertyType String -Value 'Hide' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag\ThisPCPolicy' -PropertyType String -Value 'Hide' -ErrorAction $SCT)
	#endregion HideVideosFromExplorer

	#region Hide3DObjectsFromThisPC
	$null = (Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}' -Recurse @paramRemoveItemProperty)
	#endregion Hide3DObjectsFromThisPC

	#region Hide3DObjectsFromExplorer
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag\ThisPCPolicy' -PropertyType 'String' -Value 'Hide' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag\ThisPCPolicy' -PropertyType String -Value 'Hide' -ErrorAction $SCT)
	#endregion Hide3DObjectsFromExplorer

	#region HideIncludeInLibraryMenu
	if (-not (Test-Path -Path 'HKCR:')) {
		$null = (New-PSDrive -Name 'HKCR' -PSProvider 'Registry' -Root 'HKEY_CLASSES_ROOT' -ErrorAction $SCT)
	}

	$null = (Remove-Item -Path 'HKCR:\Folder\ShellEx\ContextMenuHandlers\Library Location' @paramRemoveItemProperty)
	#endregion HideIncludeInLibraryMenu

	#region HideGiveAccessToMenu
	if (-not (Test-Path -Path 'HKCR:')) {
		$null = (New-PSDrive -Name 'HKCR' -PSProvider 'Registry' -Root 'HKEY_CLASSES_ROOT' -ErrorAction $SCT)
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
	#region

	$null = (New-Item -Path 'HKLM:\SOFTWARE\Microsoft\Edge\HideFirstRunExperience' -Force -Confirm:$false -WarningAction $SCT -ErrorAction $SCT)
	$null = (New-Item -Path 'HKLM:\\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main' -Force -Confirm:$false -WarningAction $SCT -ErrorAction $SCT)

	# Remove Edge icon on desktop
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\DisableEdgeDesktopShortcutCreation' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)

	# Show the initial setup ?
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Edge\HideFirstRunExperience' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)

	# Do NOT allow Microsoft Edge to pre-launch at Windows startup, when the system is idle, and each time Microsoft Edge is closed
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\Software\Policies\Microsoft\MicrosoftEdge\Main\AllowPrelaunch' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)

	# No preloading of the startpage and Tabs
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\Software\Policies\Microsoft\MicrosoftEdge\Main\TabPreloader' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)

	# Configure Do Not Track
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\Software\Policies\Microsoft\MicrosoftEdge\Main\DoNotTrack' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)

	# Show message when opening sites in Internet Explorer
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\Software\Policies\Microsoft\MicrosoftEdge\Main\ShowMessageWhenOpeningSitesInInternetExplorer' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion

	#region EnableOneDrive
	$null = (Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive' -Name 'DisableFileSyncNGSC' @paramRemoveItemProperty)
	#endregion EnableOneDrive

	#region InstallWindowsStore
	$null = (Get-AppxPackage -AllUsers 'Microsoft.DesktopAppInstaller' -ErrorAction $SCT | ForEach-Object {
			$null = (Add-AppxPackage -DisableDevelopmentMode -Register ($_.InstallLocation + '\AppXManifest.xml') -ErrorAction $SCT)
		})
	$null = (Get-AppxPackage -AllUsers 'Microsoft.Services.Store.Engagement' -ErrorAction $SCT | ForEach-Object {
			$null = (Add-AppxPackage -DisableDevelopmentMode -Register ($_.InstallLocation + '\AppXManifest.xml') -ErrorAction $SCT)
		})
	$null = (Get-AppxPackage -AllUsers 'Microsoft.StorePurchaseApp' -ErrorAction $SCT | ForEach-Object {
			$null = (Add-AppxPackage -DisableDevelopmentMode -Register ($_.InstallLocation + '\AppXManifest.xml') -ErrorAction $SCT)
		})
	$null = (Get-AppxPackage -AllUsers 'Microsoft.WindowsStore' -ErrorAction $SCT | ForEach-Object {
			$null = (Add-AppxPackage -DisableDevelopmentMode -Register ($_.InstallLocation + '\AppXManifest.xml') -ErrorAction $SCT)
		})
	#endregion InstallWindowsStore

	#region DisableAdobeFlash
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\DisableFlashInIE' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Addons\FlashPlayerEnabled' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	#endregion DisableAdobeFlash

	#region DisableEdgePreload
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main\AllowPrelaunch' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\TabPreloader\AllowTabPreloading' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	#endregion DisableEdgePreload

	#region DisableEdgeShortcutCreation
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\DisableEdgeDesktopShortcutCreation' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion DisableEdgeShortcutCreation

	#region ConfiguteOneDrive
	# Try Auto configure
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\OneDrive\SilentAccountConfig' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)

	# Enable the FilesOnDemand Freature
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\OneDrive\FilesOnDemandEnabled' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion ConfiguteOneDrive

	#region DisableIEFirstRun
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main\DisableFirstRunCustomize' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion DisableIEFirstRun

	#region DisableFirstLogonAnimation
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\EnableFirstLogonAnimation' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	#endregion DisableFirstLogonAnimation

	#region RestartNotificationsAllowed2
	# Show more Windows Update restart notifications about restarting
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings\RestartNotificationsAllowed2' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion RestartNotificationsAllowed2

	#region
	# Automatically adjust active hours for me based on daily usage
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings\SmartActiveHoursState' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion

	#region DisableMediaSharing
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\WindowsMediaPlayer\PreventLibrarySharing' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion DisableMediaSharing

	#region UninstallWorkFolders
	$null = (Get-WindowsOptionalFeature -Online -FeatureName 'WorkFolders-Client' -WarningAction $SCT -ErrorAction $SCT | Where-Object { $_.State -ne 'Disabled' } | Disable-WindowsOptionalFeature -Online -NoRestart -WarningAction $SCT -ErrorAction $SCT)
	#endregion UninstallWorkFolders

	#region UninstallPowerShellV2
	$null = (Get-WindowsOptionalFeature -Online -FeatureName 'MicrosoftWindowsPowerShellV2Root' -WarningAction $SCT -ErrorAction $SCT | Where-Object { $_.State -ne 'Disabled' } | Disable-WindowsOptionalFeature -Online -NoRestart -WarningAction $SCT -ErrorAction $SCT)
	#endregion UninstallPowerShellV2

	#region InstallSSHClient
	$null = (Get-WindowsCapability -Online -WarningAction $SCT -ErrorAction $SCT | Where-Object {
			(($_.Name -like 'OpenSSH.Client*') -and ($_.State -eq 'NotPresent'))
		} | Add-WindowsCapability -Online -WarningAction $SCT -ErrorAction $SCT)
	#endregion InstallSSHClient

	#region UninstallSSHServer
	$null = (Stop-Service -Name 'sshd' -Force -NoWait -WarningAction $SCT -ErrorAction $SCT)
	$null = (Get-WindowsCapability -Online -WarningAction $SCT -ErrorAction $SCT | Where-Object {
			(($_.Name -like 'OpenSSH.Server*') -and ($_.State -eq 'Installed'))
		} | Remove-WindowsCapability -Online -WarningAction $SCT -ErrorAction $SCT)
	#endregion UninstallSSHServer

	#region SetPhotoViewerAssociation
	if (-not (Test-Path -Path 'HKCR:')) {
		$null = (New-PSDrive -Name 'HKCR' -PSProvider 'Registry' -Root 'HKEY_CLASSES_ROOT' -WarningAction $SCT -ErrorAction $SCT)
	}

	foreach ($type in @('Paint.Picture', 'giffile', 'jpegfile', 'pngfile')) {
		$null = (New-Item -Path $('HKCR:\' + $type + '\shell\open') -Force -Confirm:$false -WarningAction $SCT -ErrorAction $SCT)
		$null = (New-Item -Path $('HKCR:\' + $type + '\shell\open\command') -Force -Confirm:$false -WarningAction $SCT -ErrorAction $SCT)
		$null = (Confirm-RegistryItemProperty -Path $('HKCR:\' + $type + '\shell\open\MuiVerb') -PropertyType ExpandString -Value '@%ProgramFiles%\Windows Photo Viewer\photoviewer.dll,-3043' -ErrorAction $SCT)
		$null = (Confirm-RegistryItemProperty -Path $('HKCR:\' + $type + '\shell\open\command\(Default)') -PropertyType ExpandString -Value "%SystemRoot%\System32\rundll32.exe `"%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll`", ImageView_Fullscreen %1" -ErrorAction $SCT)
	}
	#endregion SetPhotoViewerAssociation

	#region AddPhotoViewerOpenWith
	if (-not (Test-Path -Path 'HKCR:')) {
		$null = (New-PSDrive -Name 'HKCR' -PSProvider 'Registry' -Root 'HKEY_CLASSES_ROOT' -WarningAction $SCT -ErrorAction $SCT)
	}

	$null = (New-Item -Path 'HKCR:\Applications\photoviewer.dll\shell\open\command' -Force -Confirm:$false -WarningAction $SCT -ErrorAction $SCT)
	$null = (New-Item -Path 'HKCR:\Applications\photoviewer.dll\shell\open\DropTarget' -Force -Confirm:$false -WarningAction $SCT -ErrorAction $SCT)

	$null = (Confirm-RegistryItemProperty -Path 'HKCR:\Applications\photoviewer.dll\shell\open\MuiVerb' -PropertyType String -Value '@photoviewer.dll,-3043' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKCR:\Applications\photoviewer.dll\shell\open\command\(Default)' -PropertyType ExpandString -Value "%SystemRoot%\System32\rundll32.exe `"%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll`", ImageView_Fullscreen %1" -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKCR:\Applications\photoviewer.dll\shell\open\DropTarget\Clsid' -PropertyType String -Value '{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}' -ErrorAction $SCT)
	#endregion AddPhotoViewerOpenWith

	#region InstallPDFPrinter
	$null = (Get-WindowsOptionalFeature -Online -FeatureName 'Printing-PrintToPDFServices-Features' -WarningAction $SCT -ErrorAction $SCT | Where-Object { $_.State -ne 'Disabled' } | Disable-WindowsOptionalFeature -Online -NoRestart -WarningAction $SCT -ErrorAction $SCT)
	#endregion InstallPDFPrinter

	#region UninstallXPSPrinter
	$null = (Get-WindowsOptionalFeature -Online -FeatureName 'Printing-XPSServices-Features' -WarningAction $SCT -ErrorAction $SCT | Where-Object { $_.State -ne 'Disabled' } | Disable-WindowsOptionalFeature -Online -NoRestart -WarningAction $SCT -ErrorAction $SCT)
	#endregion UninstallXPSPrinter

	#region RemoveFaxPrinter
	$null = (Remove-Printer -Name 'Fax' -WarningAction $SCT -ErrorAction $SCT)
	#endregion RemoveFaxPrinter

	#region UninstallFaxAndScan
	$null = (Get-WindowsOptionalFeature -Online -FeatureName 'FaxServicesClientPackage' -WarningAction $SCT -ErrorAction $SCT | Where-Object { $_.State -ne 'Disabled' } | Disable-WindowsOptionalFeature -Online -NoRestart -WarningAction $SCT -ErrorAction $SCT)
	#endregion UninstallFaxAndScan

	#region InstallNET23
	if ((Get-CimInstance -ClassName 'Win32_OperatingSystem').ProductType -eq 1) {
		$null = (Enable-WindowsOptionalFeature -Online -FeatureName 'NetFx3' -NoRestart -WarningAction $SCT -ErrorAction $SCT)
	}
	#endregion InstallNET23
	#endregion Application Tweaks

	#region
	#region RemoveShadowCopies
	# Remove Shadow copies (restoration points)
	$null = (Get-CimInstance -ClassName Win32_ShadowCopy -WarningAction $SCT -ErrorAction $SCT | Remove-CimInstance -Confirm:$false -WarningAction $SCT -ErrorAction $SCT)
	#endregion RemoveShadowCopies

	#region
	# Turn on latest installed .NET runtime for all apps
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\.NETFramework\OnlyUseLatestCLR' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\OnlyUseLatestCLR' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion

	#region
	# Do not allow the computer to turn off the Ethernet adapter to save power
	if ((Get-CimInstance -ClassName 'Win32_ComputerSystem' -ErrorAction $SCT).PCSystemType -eq 1) {
		# Desktop
		$adapter = (Get-NetAdapter -Physical -WarningAction $SCT -ErrorAction $SCT | Get-NetAdapterPowerManagement -WarningAction $SCT -ErrorAction $SCT)
		$adapter.AllowComputerToTurnOffDevice = 'Disabled'
		$null = ($adapter | Set-NetAdapterPowerManagement -Confirm:$false -WarningAction $SCT -ErrorAction $SCT)
	}
	#endregion

	#region
	if (Get-WindowsEdition -Online -WarningAction $SCT -ErrorAction $SCT | Where-Object -FilterScript {
			$_.Edition -eq 'Professional' -or $_.Edition -eq 'Enterprise'
		}) {
		if ((Get-CimInstance -ClassName CIM_Processor -WarningAction $SCT -ErrorAction $SCT).VirtualizationFirmwareEnabled -eq $true) {
			$null = (Enable-WindowsOptionalFeature -FeatureName Containers-DisposableClientVM -All -Online -NoRestart -WarningAction $SCT -ErrorAction $SCT)
		}
		else {
			if ((Get-CimInstance -ClassName 'CIM_ComputerSystem' -WarningAction $SCT -ErrorAction $SCT).HypervisorPresent -eq $true) {
				$null = (Enable-WindowsOptionalFeature -FeatureName Containers-DisposableClientVM -All -Online -NoRestart -WarningAction $SCT -ErrorAction $SCT)
			}
		}
	}
	#endregion

	#region
	# Turn off and delete reserved storage after the next update installation
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\ReserveManager\BaseHardReserveSize' -PropertyType 'QWord' -Value '0' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\ReserveManager\BaseSoftReserveSize' -PropertyType 'QWord' -Value '0' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\ReserveManager\HardReserveAdjustment' -PropertyType 'QWord' -Value '0' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\ReserveManager\MinDiskSize' -PropertyType 'QWord' -Value '0' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\ReserveManager\ShippedWithReserves' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	#endregion

	#region
	# Turn on automatic backup the system registry to the $env:SystemRoot\System32\config\RegBack folder
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Configuration Manager\EnablePeriodicBackup' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion

	#region
	# Turn off thumbnail cache removal
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Thumbnail Cache\Autorun' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Thumbnail Cache\Autorun' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	#endregion

	#region
	# Use Unicode UTF-8 for worldwide language support
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Nls\CodePage\ACP' -PropertyType 'String' -Value '65001' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Nls\CodePage\MACCP' -PropertyType 'String' -Value '65001' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Nls\CodePage\OEMCP' -PropertyType 'String' -Value '65001' -ErrorAction $SCT)
	#endregion

	#region
	# Do not show recently added apps on Start menu
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer\CHideRecentlyAddedApps' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion

	#region
	# Turn on logging for all Windows PowerShell modules
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging\ModuleNames\*' -PropertyType String -Value * -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging\ModuleNames\EnableModuleLogging' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging\EnableScriptBlockLogging' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion

	#region
	# Include command line in progress creation events
	$null = (Confirm-RegistryItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\Audit\ProcessCreationIncludeCmdLine_Enabled' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion

	#region
	# Remove "Edit with Paint 3D" from context menu
	$exts = @('.bmp', '.gif', '.jpe', '.jpeg', '.jpg', '.png', '.tif', '.tiff')

	foreach ($ext in $exts) {
		$null = (Remove-Item -Path ('Registry::HKEY_CLASSES_ROOT\SystemFileAssociations\' + $ext + '\Shell\3D Edit\ProgrammaticAccessOnly') @paramRemoveItemProperty)
	}
	#endregion

	#region
	# Remove "Include in Library" from context menu
	$null = (Confirm-RegistryItemProperty -Path 'Registry::HKEY_CLASSES_ROOT\Folder\shellex\ContextMenuHandlers\Library Location\(default)' -PropertyType 'String' -Value '-{3dad6c5d-2167-4cae-9914-f99e41c12cfa}' -ErrorAction $SCT)

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
	foreach ($feature in $features) {
		$null = (Get-WindowsOptionalFeature -Online -FeatureName $feature -WarningAction $SCT -ErrorAction $SCT | Where-Object { $_.State -ne 'Disabled' } | Disable-WindowsOptionalFeature -Online -NoRestart -WarningAction $SCT -ErrorAction $SCT)
	}

	# Remove Windows capabilities
	$IncludedApps = @('App.Support.QuickAssist*', 'Hello.Face*', 'Media.WindowsMediaPlayer*', 'Language.Handwriting*', 'Language.OCR*', 'Language.Speech*', 'Language.TextToSpeech*')
	$OFS = '|'
	foreach ($IncludedApp in $IncludedApps) {
		try {
			$null = (Get-WindowsCapability -Online -WarningAction $SCT -ErrorAction $SCT | Where-Object -FilterScript {
					#$_.Name -cmatch $IncludedApps
					($_.Name -like $IncludedApp) -and ($_.State -eq 'Installed')
				} | Remove-WindowsCapability -Online -WarningAction $SCT -ErrorAction $SCT)
		}
		catch {
			Write-Verbose -Message 'Most of the time: Permanent package cannot be uninstalled. And we know that!'
		}
	}
	$OFS = ' '
	#endregion
	#endregion

	#region FinalTouches
	# Create a task in the Task Scheduler to start Windows cleaning up - The task runs every 90 days
	$keys = @('Delivery Optimization Files', 'Device Driver Packages', 'Previous Installations', 'Setup Log Files', 'Temporary Setup Files', 'Update Cleanup', 'Windows Defender', 'Windows Upgrade Log Files')

	foreach ($key in $keys) {
		$null = (Confirm-RegistryItemProperty -Path ('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\' + $key + 'StateFlags1337') -PropertyType 'DWord' -Value '2' -ErrorAction $SCT)
	}

	$action = (New-ScheduledTaskAction -Execute 'cleanmgr.exe' -Argument '/sagerun:1337' -ErrorAction $SCT)
	$trigger = (New-ScheduledTaskTrigger -Daily -DaysInterval '90' -At '9am' -ErrorAction $SCT)
	$settings = (New-ScheduledTaskSettingsSet -Compatibility 'Win8' -StartWhenAvailable -ErrorAction $SCT)
	$principal = (New-ScheduledTaskPrincipal -UserId $env:USERNAME -RunLevel 'Highest' -ErrorAction $SCT)
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
	$action = (New-ScheduledTaskAction -Execute 'powershell.exe' -ErrorAction $SCT -Argument @"
   `$getservice = Get-Service -Name wuauserv
   `$getservice.WaitForStatus("Stopped", "01:00:00")
   Get-ChildItem -Path `$env:SystemRoot\SoftwareDistribution\Download -Recurse -Force -ErrorAction $SCT | Remove-Item -Recurse -Force -ErrorAction $SCT
"@)
	$trigger = (New-JobTrigger -Weekly -WeeksInterval '4' -DaysOfWeek 'Thursday' -At '9am' -ErrorAction $SCT)
	$settings = (New-ScheduledTaskSettingsSet -Compatibility 'Win8' -StartWhenAvailable -ErrorAction $SCT)
	$principal = (New-ScheduledTaskPrincipal -UserId 'NT AUTHORITY\SYSTEM' -RunLevel 'Highest' -ErrorAction $SCT)
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
	$action = (New-ScheduledTaskAction -Execute 'powershell.exe' -ErrorAction $SCT -Argument @"
   Get-ChildItem -Path `$env:TEMP -Force -Recurse -ErrorAction $SCT | Remove-Item -Force -Recurse -ErrorAction $SCT
"@)
	$trigger = (New-ScheduledTaskTrigger -Daily -DaysInterval '62' -At '9am' -ErrorAction $SCT)
	$settings = (New-ScheduledTaskSettingsSet -Compatibility 'Win8' -StartWhenAvailable -ErrorAction $SCT)
	$principal = (New-ScheduledTaskPrincipal -UserId 'NT AUTHORITY\SYSTEM' -RunLevel 'Highest' -ErrorAction $SCT)
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
	foreach ($feature in $features) {
		$null = (Get-WindowsOptionalFeature -Online -FeatureName $feature -WarningAction $SCT -ErrorAction $SCT | Where-Object { $_.State -ne 'Disabled' } | Disable-WindowsOptionalFeature -Online -NoRestart -WarningAction $SCT -ErrorAction $SCT)
	}

	# Remove Windows capabilities
	$IncludedApps = @('App.Support.QuickAssist*', 'Hello.Face*', 'Media.WindowsMediaPlayer*', 'Browser.InternetExplorer*', 'Language.Handwriting*', 'Language.OCR*', 'Language.Speech*', 'Language.TextToSpeech*')
	$OFS = '|'
	foreach ($IncludedApp in $IncludedApps) {
		try {
			$null = (Get-WindowsCapability -Online -WarningAction $SCT -ErrorAction $SCT | Where-Object -FilterScript {
					#$_.Name -cmatch $IncludedApps
					($_.Name -like $IncludedApp) -and ($_.State -eq 'Installed')
				} | Remove-WindowsCapability -Online -WarningAction $SCT -ErrorAction $SCT)
		}
		catch {
			Write-Verbose -Message 'Most of the time: Permanent package cannot be uninstalled. And we know that!'
		}
	}
	$OFS = ' '
	#endregion FinalTouches
}

end {
	$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction $SCT)
}

#region LICENSE
<#
      BSD 3-Clause License

      Copyright (c) 2020, Beyond Datacenter
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
