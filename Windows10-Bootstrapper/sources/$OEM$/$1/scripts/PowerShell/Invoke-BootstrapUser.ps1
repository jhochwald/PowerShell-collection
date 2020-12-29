#requires -Version 5.0

<#
      .SYNOPSIS
      Bootstrap Windows 10 User Profile

      .DESCRIPTION
      Bootstrap Windows 10 User Profile with the default configuration.
      Tested with the latest Windows 10 (Enterprise and Professional) releases.

      .NOTES
      Lot of the stuff of this version is adopted from Disassembler <disassembler@dasm.cz>

      Version 1.4.8

      .LINK
      http://beyond-datacenter.com

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

	$null = (Set-MpPreference -EnableControlledFolderAccess Disabled -Force -ErrorAction $SCT)

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

		begin
		{
			#region
			$SCT = 'SilentlyContinue'
			#endregion
		}

		process
		{
			if (-Not (Test-Path -Path ($Path | Split-Path) -ErrorAction $SCT))
			{
				$null = (New-Item -Path ($Path | Split-Path) -Force -WarningAction $SCT -ErrorAction $SCT)
			}

			if (-Not (Test-Path -Path $Path -ErrorAction $SCT))
			{
				$null = (New-ItemProperty -Path ($Path | Split-Path) -Name ($Path | Split-Path -Leaf) -PropertyType $PropertyType -Value $Value -Force -Confirm:$false -ErrorAction $SCT)
			}
			else
			{
				$null = (Set-ItemProperty -Path ($Path | Split-Path) -Name ($Path | Split-Path -Leaf) -Value $Value -Force -Confirm:$false -ErrorAction $SCT)
			}
		}
	}
	#endregion HelperFunction
}

process
{
	# Stop Search - Gain performance
	$null = (Get-Service -Name 'WSearch' -ErrorAction $SCT | Where-Object { $_.Status -eq "Running" } | Stop-Service -Force -Confirm:$false -ErrorAction $SCT)

	#region PrivacyTweaks
	#region DisableWindowsErrorDialog
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\Windows Error Reporting\DontShowUI' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion DisableWindowsErrorDialog

	#region DisableAdvertisingInfo
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	#endregion DisableAdvertisingInfo

	#region DisableWebSearch
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search\BingSearchEnabled' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search\CortanaConsent' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	#endregion DisableWebSearch

	#region DisableAppSuggestions
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\ContentDeliveryAllowed' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\OemPreInstalledAppsEnabled' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\PreInstalledAppsEnabled' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\PreInstalledAppsEverEnabled' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SilentInstalledAppsEnabled' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SubscribedContent-310093Enabled' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SubscribedContent-314559Enabled' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SubscribedContent-338387Enabled' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SubscribedContent-353694Enabled' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SubscribedContent-338388Enabled' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SubscribedContent-338389Enabled' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SubscribedContent-338393Enabled' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SubscribedContent-338388Enabled' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SubscribedContent-353696Enabled' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SubscribedContent-353698Enabled' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SystemPaneSuggestionsEnabled' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)

	# Empty placeholder tile collection in registry cache and restart Start Menu process to reload the cache
	if ([Environment]::OSVersion.Version.Build -ge 17134)
	{
		$key = (Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\*windows.data.placeholdertilecollection\Current' -WarningAction $SCT -ErrorAction $SCT)
		$null = (Confirm-RegistryItemProperty -Path ($key.PSPath + 'Data') -PropertyType Binary -Value $key.Data[0..15] -WarningAction $SCT -ErrorAction $SCT)
		$null = (Stop-Process -Name 'ShellExperienceHost' -Force -WarningAction $SCT -ErrorAction $SCT)
	}
	#endregion DisableAppSuggestions

	#region DisableActivityHistory
	#endregion DisableActivityHistory

	#region DisableBackgroundApps
	Get-ChildItem -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications' -Exclude 'Microsoft.Windows.Cortana*', 'Microsoft.Windows.ShellExperienceHost*' -WarningAction $SCT -ErrorAction $SCT | ForEach-Object -Process {
		$null = (Confirm-RegistryItemProperty -Path ($_.PsPath + 'Disabled') -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
		$null = (Confirm-RegistryItemProperty -Path ($_.PsPath + 'DisabledByUser') -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	}
	#endregion DisableBackgroundApps

	#region
	# Make the "Open", "Print", "Edit" context menu items available, when more than 15 selected
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\MultipleInvokePromptMinimum' -PropertyType 'DWord' -Value '300' -ErrorAction $SCT)
	#endregion

	#region DisableFeedback
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Siuf\Rules\NumberOfSIUFInPeriod' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	#endregion DisableFeedback

	#region DisableTailoredExperiences
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Policies\Microsoft\Windows\CloudContent\DisableTailoredExperiencesWithDiagnosticData' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy\TailoredExperiencesWithDiagnosticDataEnabled' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	#endregion DisableTailoredExperiences

	#region DisableAdvertisingID
	#endregion DisableAdvertisingID

	#region DisableWebLangList
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Control Panel\International\User Profile\HttpAcceptLanguageOptOut' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion DisableWebLangList

	#region DisableCortana
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Personalization\Settings\AcceptedPrivacyPolicy' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\InputPersonalization\RestrictImplicitTextCollection' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\InputPersonalization\RestrictImplicitInkCollection' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore\HarvestContacts' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	#endregion DisableCortana
	#endregion PrivacyTweaks

	#region SecurityTweaks
	#region AppAndBrowser_EdgeSmartScreenOff
	# Dismiss Microsoft Defender offer in the Windows Security about to turn on the SmartScreen filter for Microsoft Edge
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows Security Health\State\AppAndBrowser_EdgeSmartScreenOff' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	#endregion AppAndBrowser_EdgeSmartScreenOff

	#region HideDefenderAccountProtectionWarning
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows Security Health\State\AccountProtection_MicrosoftAccount_Disconnected' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion HideDefenderAccountProtectionWarning

	#region DisableDownloadBlocking
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments\SaveZoneInformation' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion DisableDownloadBlocking
	#endregion SecurityTweaks

	#region LegacyDefaultPrinterMode
	# Do not let Windows manage default printer
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Windows\LegacyDefaultPrinterMode' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion LegacyDefaultPrinterMode

	#region ServiceTweaks
	#region DisableSharedExperiences
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\CDP\RomeSdkChannelUserAuthzPolicy' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	#endregion DisableSharedExperiences

	#region DisableClipboardHistory
	$null = (Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Clipboard' -Name 'EnableClipboardHistory' @paramRemoveItemProperty)
	#endregion DisableClipboardHistory

	#region DisableAutoplay
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\DisableAutoplay' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion DisableAutoplay

	#region EnableStorageSense
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy\01' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy\StoragePoliciesNotified' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)

	# Run Storage Sense every month
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy\2048' -PropertyType 'DWord' -Value '30' -ErrorAction $SCT)

	# Delete temporary files that apps aren't using
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy\04' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)

	# Delete files in recycle bin if they have been there for over 30 days
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy\256' -PropertyType 'DWord' -Value '30' -ErrorAction $SCT)

	# Never delete files in "Downloads" folder
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy\512' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	#endregion EnableStorageSense

	#region EnableRecycleBin
	$null = (Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer' -Name 'NoRecycleFiles' @paramRemoveItemProperty)
	#endregion EnableRecycleBin
	#endregion ServiceTweaks

	#region UITweaks
	#region EnablePerProcessSystemDPI
	# Let Windows try to fix apps so they're not blurry
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Control Panel\Desktop\EnablePerProcessSystemDPI' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion EnablePerProcessSystemDPI

	#region EnableActionCenter
	$null = (Remove-ItemProperty -Path 'HKCU:\Software\Policies\Microsoft\Windows\Explorer' -Name 'DisableNotificationCenter' @paramRemoveItemProperty)
	$null = (Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications' -Name 'ToastEnabled'@paramRemoveItemProperty)
	#endregion EnableActionCenter

	#region EnableAeroShake
	$null = (Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'DisallowShaking' @paramRemoveItemProperty)
	#endregion EnableAeroShake

	#region DisableAccessibilityKeys
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Control Panel\Accessibility\StickyKeys\Flags' -PropertyType 'String' -Value '506' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Control Panel\Accessibility\ToggleKeys\Flags' -PropertyType String -Value '58' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Control Panel\Accessibility\Keyboard Response\Flags' -PropertyType String -Value '122' -ErrorAction $SCT)
	#endregion DisableAccessibilityKeys

	#region ShowTaskManagerDetails
	$taskmgr = (Start-Process -WindowStyle Hidden -FilePath taskmgr.exe -PassThru -WarningAction $SCT -ErrorAction $SCT)
	$timeout = 30000
	$sleep = 100
	do
	{
		$null = (Start-Sleep -Milliseconds $sleep)
		$timeout -= $sleep
		$preferences = (Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager' -Name 'Preferences' -WarningAction $SCT -ErrorAction $SCT)
	}
	until ($preferences -or $timeout -le 0)
	$null = ($taskmgr | Stop-Process -WarningAction $SCT -ErrorAction $SCT)

	if ($preferences)
	{
		$preferences.Preferences[28] = 0
		$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager\Preferences' -PropertyType Binary -Value $preferences.Preferences -ErrorAction $SCT)
	}
	#endregion ShowTaskManagerDetails

	#region ShowFileOperationsDetails
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager\EnthusiastMode' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion ShowFileOperationsDetails

	#region EnableFileDeleteConfirm
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\ConfirmFileDelete' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion EnableFileDeleteConfirm

	#region HideTaskbarSearch
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search\SearchboxTaskbarMode' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	#endregion HideTaskbarSearch

	#region HideTaskView
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\ShowTaskViewButton' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	#endregion HideTaskView

	#region ShowSmallTaskbarIcons
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarSmallIcons' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion ShowSmallTaskbarIcons

	#region SetTaskbarCombineAlways
	$null = (Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarGlomLevel' @paramRemoveItemProperty)
	$null = (Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'MMTaskbarGlomLevel' @paramRemoveItemProperty)
	#endregion SetTaskbarCombineAlways

	#region HideTaskbarPeopleIcon
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People\PeopleBand' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	#endregion HideTaskbarPeopleIcon

	#region HideTrayIcons
	$null = (Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer' -Name 'NoAutoTrayNotify' @paramRemoveItemProperty)
	#endregion HideTrayIcons

	#region HideSecondsFromTaskbar
	$null = (Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'ShowSecondsInSystemClock' @paramRemoveItemProperty)
	#endregion HideSecondsFromTaskbar

	#region SetControlPanelSmallIcons
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel\StartupPage' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel\AllItemsIconView' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion SetControlPanelSmallIcons

	#region DisableShortcutInName
	$null = (New-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\' -Name 'link' -PropertyType 'Binary' -Value ([byte[]](00, 00, 00, 00)) -Force -ErrorAction $SCT)
	#endregion DisableShortcutInName

	#region PrintScreenKeyForSnippingEnabled
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Control Panel\Keyboard\PrintScreenKeyForSnippingEnabled' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion PrintScreenKeyForSnippingEnabled

	#region SetVisualFXPerformance
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Control Panel\Desktop\DragFullWindows' -PropertyType String -Value '0' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Control Panel\Desktop\MenuShowDelay' -PropertyType String -Value '0' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Control Panel\Desktop\UserPreferencesMask' -PropertyType Binary -Value ([byte[]](144, 18, 3, 128, 16, 0, 0, 0)) -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Control Panel\Desktop\WindowMetrics\MinAnimate' -PropertyType String -Value '0' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Control Panel\Keyboard\KeyboardDelay' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\ListviewAlphaSelect' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\ListviewShadow' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarAnimations' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\VisualFXSetting' -PropertyType 'DWord' -Value 3 -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\DWM\EnableAeroPeek' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	#endregion SetVisualFXPerformance

	#region EnableTitleBarColor
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\DWM\ColorPrevalence' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion EnableTitleBarColor

	#region DisableDynamicScrollbars
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Control Panel\Accessibility\DynamicScrollbars' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	#endregion DisableDynamicScrollbars

	#region RemoveENKeyboard
	$langs = (Get-WinUserLanguageList -ErrorAction $SCT)
	$null = (Set-WinUserLanguageList -LanguageList ($langs | Where-Object {
				$_.LanguageTag -ne 'en-US'
   }) -Force -ErrorAction $SCT)
	#endregion RemoveENKeyboard

	#region EnableEnhPointerPrecision
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Control Panel\Mouse\MouseSpeed' -PropertyType String -Value '1' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Control Panel\Mouse\MouseThreshold1' -PropertyType String -Value '6' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Control Panel\Mouse\MouseThreshold2' -PropertyType String -Value '10' -ErrorAction $SCT)
	#endregion EnableEnhPointerPrecision

	#region SetSoundSchemeNone
	$SoundScheme = '.None'
	Get-ChildItem -Path 'HKCU:\AppEvents\Schemes\Apps\*\*' -ErrorAction $SCT | ForEach-Object {
		# If scheme keys do not exist in an event, create empty ones (similar behavior to Sound control panel).
		if (-not (Test-Path -Path ($_.PsPath + '\' + $SoundScheme) -ErrorAction $SCT))
		{
			$null = (New-Item -Path ($_.PsPath + '\' + $SoundScheme) -ErrorAction $SCT)
		}

		if (-not (Test-Path -Path ($_.PsPath + '\.Current') -ErrorAction $SCT))
		{
			$null = (New-Item -Path ($_.PsPath + '\.Current') -ErrorAction $SCT)
		}

		# Get a regular string from any possible kind of value, i.e. resolve REG_EXPAND_SZ, copy REG_SZ or empty from non-existing.
		$Data = (Get-ItemProperty -Path ($_.PsPath + '\' + $SoundScheme) -Name '(Default)' -ErrorAction $SCT).'(Default)'

		if ($Data)
		{
			# Replace any kind of value with a regular string (similar behavior to Sound control panel).
			$null = (Confirm-RegistryItemProperty -Path ($_.PsPath + '\' + $SoundScheme) -Name '(Default)' -PropertyType String -Value $Data -ErrorAction $SCT)

			# Copy data from source scheme to current.
			$null = (Confirm-RegistryItemProperty -Path ($_.PsPath + '\.Current') -Name '(Default)' -PropertyType String -Value $Data -ErrorAction $SCT)
		}
	}

	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\AppEvents\Schemes\(Default)' -PropertyType String -Value $SoundScheme -ErrorAction $SCT)
	#endregion SetSoundSchemeNone

	#region DisableF1HelpKey
	if (-not (Test-Path -Path 'HKCU:\Software\Classes\TypeLib\{8cec5860-07a1-11d9-b15e-000d56bfe6ee}\1.0\0\win32' -ErrorAction $SCT))
	{
		$null = (New-Item -Path 'HKCU:\Software\Classes\TypeLib\{8cec5860-07a1-11d9-b15e-000d56bfe6ee}\1.0\0\win32' -Force -ErrorAction $SCT)
	}

	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Classes\TypeLib\{8cec5860-07a1-11d9-b15e-000d56bfe6ee}\1.0\0\win32\(Default)' -PropertyType 'String' -Value '' -ErrorAction $SCT)

	if (-not (Test-Path -Path 'HKCU:\Software\Classes\TypeLib\{8cec5860-07a1-11d9-b15e-000d56bfe6ee}\1.0\0\win64' -ErrorAction $SCT))
	{
		$null = (New-Item -Path 'HKCU:\Software\Classes\TypeLib\{8cec5860-07a1-11d9-b15e-000d56bfe6ee}\1.0\0\win64' -Force -ErrorAction $SCT)
	}

	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Classes\TypeLib\{8cec5860-07a1-11d9-b15e-000d56bfe6ee}\1.0\0\win64\(Default)' -PropertyType 'String' -Value '' -ErrorAction $SCT)
	#endregion DisableF1HelpKey
	#endregion UITweaks

	#region ExplorerUITweaks
	#region DisableXboxGamebar
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR\AppCaptureEnabled' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\System\GameConfigStore\GameDVR_Enabled' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\GameBar\ShowStartupPanel' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	#endregion DisableXboxGamebar

	#region HideExplorerTitleFullPath
	$null = (Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState' -Name 'FullPath' @paramRemoveItemProperty)
	#endregion HideExplorerTitleFullPath

	#region ShowKnownExtensions
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\HideFileExt' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	#endregion ShowKnownExtensions

	#region ShowHiddenFiles
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Hidden' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion ShowHiddenFiles

	#region HideSuperHiddenFiles
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\ShowSuperHidden' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	#endregion HideSuperHiddenFiles

	#region ShowEmptyDrives
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\HideDrivesWithNoMedia' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	#endregion ShowEmptyDrives

	#region ShowFolderMergeConflicts
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\HideMergeConflicts' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	#endregion ShowFolderMergeConflicts

	#region EnableNavPaneExpand
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\NavPaneExpandToCurrentFolder' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion EnableNavPaneExpand

	#region MMTaskbarMode
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\MMTaskbarMode' -PropertyType 'DWord' -Value '2' -ErrorAction $SCT)
	#endregion MMTaskbarMode

	#region HideNavPaneAllFolders
	$null = (Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'NavPaneShowAllFolders' @paramRemoveItemProperty)
	#endregion HideNavPaneAllFolders

	#region EnableFolderSeparateProcess
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\SeparateProcess' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion EnableFolderSeparateProcess

	#region DisableRestoreFldrWindows
	$null = (Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'PersistBrowsers' @paramRemoveItemProperty)
	#endregion DisableRestoreFldrWindows

	#region ShowEncCompFilesColor
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\ShowEncryptCompressedColor' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion ShowEncCompFilesColor

	#region DisableSharingWizard
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\SharingWizardOn' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	#endregion DisableSharingWizard

	#region ShowSelectCheckboxes
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\AutoCheckSelect' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion ShowSelectCheckboxes

	#region ShowSyncNotifications
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\ShowSyncProviderNotifications' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion ShowSyncNotifications

	#region HideRecentShortcuts
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ShowRecent' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ShowFrequent' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	#endregion HideRecentShortcuts

	#region SetExplorerThisPC
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\LaunchTo' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion SetExplorerThisPC

	#region HideQuickAccess
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HubMode' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion HideQuickAccess

	#region ShowRecycleBinOnDesktop
	$null = (Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu' -Name '{645FF040-5081-101B-9F08-00AA002F954E}' @paramRemoveItemProperty)
	$null = (Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel' -Name '{645FF040-5081-101B-9F08-00AA002F954E}' @paramRemoveItemProperty)
	#endregion ShowRecycleBinOnDesktop

	#region ShowThisPCOnDesktop
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu\{20D04FE0-3AEA-1069-A2D8-08002B30309D}' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel\{20D04FE0-3AEA-1069-A2D8-08002B30309D}' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
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
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Control Panel\Desktop\PaintDesktopVersion' -PropertyType 'DWord' -Value '0' -ErrorAction $SCT)
	#endregion HideBuildNumberFromDesktop

	#region ScreenSaver
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Control Panel\Desktop\ScreenSaveActive' -PropertyType 'String' -Value '1' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Control Panel\Desktop\ScreenSaverIsSecure' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Control Panel\Desktop\ScreenSaveTimeOut' -PropertyType 'DWord' -Value '600' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Control Panel\Desktop\scrnsave.exe' -PropertyType 'String' -Value 'c:\windows\system32\scrnsave.scr' -ErrorAction $SCT)

	#endregion ScreenSaver

	#region DisableThumbnails
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\IconsOnly' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion DisableThumbnails

	#region DisableThumbnailCache
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\DisableThumbnailCache' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion DisableThumbnailCache

	#region DisableThumbsDBOnNetwork
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\DisableThumbsDBOnNetworkFolders' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion DisableThumbsDBOnNetwork

	#region DisableDesktopWallpaperQualityReduction
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Control Panel\Desktop\JPEGImportQuality' -PropertyType 'DWord' -Value '100' -ErrorAction $SCT)
	#endregion DisableDesktopWallpaperQualityReduction

	#region RemoveMicrosoftEdgeShortcut
	$Value = (Get-ItemPropertyValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -Name Desktop -ErrorAction $SCT)
	$null = (Remove-Item -Path ($Value + '\Microsoft Edge.lnk') @paramRemoveItemProperty)
	#endregion RemoveMicrosoftEdgeShortcut

	#region RemoveHPSupportAssistantShortcut
	$null = (Remove-Item -Path "$env:PUBLIC\Desktop\HP Support Assistant.lnk" @paramRemoveItemProperty)
	#endregion RemoveHPSupportAssistantShortcut
	#endregion ExplorerUITweaks

	#region ApplicationTweaks
	#region DisableFullscreenOptims
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\System\GameConfigStore\GameDVR_DXGIHonorFSEWindowsCompatible' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\System\GameConfigStore\GameDVR_FSEBehavior' -PropertyType 'DWord' -Value 2 -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\System\GameConfigStore\GameDVR_FSEBehaviorMode' -PropertyType 'DWord' -Value 2 -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\System\GameConfigStore\GameDVR_HonorUserFSEBehaviorMode' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion DisableFullscreenOptims

	#region OneDriveInsider
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\OneDrive\EnableTeamTier_Internal' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\OneDrive\EnableFasterRingUpdate' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion OneDriveInsider

	#region EnableADALOneDrive
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\OneDrive\EnableADAL' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion EnableADALOneDrive

	#region OneDriveEnableHoldTheFile
	# Users can choose how to handle Office files in conflict
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\OneDrive\EnableHoldTheFile' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregionEnableHoldTheFile

	#region OneDriveEnableAllOcsiClients
	# Coauthoring and in-app sharing for Office files
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\OneDrive\EnableAllOcsiClients' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion OneDriveEnableAllOcsiClients

	#region Office2016Telemetry
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\software\policies\microsoft\office\16.0\osm\enablelogging' -PropertyType 'DWord' -Value '1' -ErrorAction $SCT)
	#endregion Office2016Telemetry
	#endregion ApplicationTweaks

	#region Unpinning
	#region UnpinStartMenuTiles
	if ([Environment]::OSVersion.Version.Build -ge 15063 -And [Environment]::OSVersion.Version.Build -le 16299)
	{
		Get-ChildItem -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount' -Include '*.group' -Recurse -WarningAction $SCT -ErrorAction $SCT | ForEach-Object {
			$data = ((Get-ItemProperty -Path ($_.PsPath + '\Current') -Name 'Data' -WarningAction $SCT -ErrorAction $SCT).Data -Join ',')
			$data = ($data.Substring(0, $data.IndexOf(',0,202,30') + 9) + ',0,202,80,0,0')

			$null = (Confirm-RegistryItemProperty -Path ($_.PsPath + '\Current\Data') -PropertyType Binary -Value $data.Split(',') -WarningAction $SCT -ErrorAction $SCT)
		}
	}
	elseif ([Environment]::OSVersion.Version.Build -ge 17134)
	{
		$key = (Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\*start.tilegrid`$windows.data.curatedtilecollection.tilecollection\Current" -WarningAction $SCT -ErrorAction $SCT)
		$data = $key.Data[0 .. 25] + ([byte[]](202, 50, 0, 226, 44, 1, 1, 0, 0))

		$null = (Confirm-RegistryItemProperty -Path ($key.PSPath + '\Data') -PropertyType Binary -Value $data -ErrorAction $SCT)

		$null = (Stop-Process -Name 'ShellExperienceHost' -Force -WarningAction $SCT -ErrorAction $SCT)
	}
	#endregion UnpinStartMenuTiles

	#region UnpinTaskbarIcons
	$null = (Confirm-RegistryItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband\Favorites' -PropertyType Binary -Value ([byte[]](255)) -ErrorAction $SCT)
	$null = (Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband' -Name 'FavoritesResolve' @paramRemoveItemProperty)
	#endregion UnpinTaskbarIcons
	#endregion Unpinning

	#region FinalTouches
	#region PowerShellProfiles
	# Create all PowerShell related Profiles as dummy (empty)
	$AllSystemProfiles = @(
		"$PROFILE.CurrentUserCurrentHost"
		"$PROFILE.CurrentUserAllHosts"
		"$PROFILE.AllUsersCurrentHost"
		"$PROFILE.AllUsersAllHosts"
		"$PSHOME\Microsoft.VSCode_profile.ps1"
		"$env:DOCUMENTS\PowerShell\Microsoft.VSCode_profile.ps1'"
	)

	foreach ($SystemProfile in $AllSystemProfiles)
	{
		if (-not (Test-Path -Path $SystemProfile -ErrorAction $SCT))
		{
			$null = (New-Item -ItemType File -Path $SystemProfile -Force -ErrorAction $SCT)
		}
	}
	#endregion PowerShellProfiles

	# Restart Start menu
	$null = (Stop-Process -Name StartMenuExperienceHost -Force -ErrorAction $SCT)

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
