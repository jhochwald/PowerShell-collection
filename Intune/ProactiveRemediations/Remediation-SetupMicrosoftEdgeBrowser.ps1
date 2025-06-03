# Remediation: Setup Microsoft Edge Browser

#region
$EdgeRegPath = 'HKLM:\Software\Policies\Microsoft\Edge'

if ((Test-Path -LiteralPath $EdgeRegPath -ErrorAction SilentlyContinue) -ne $true)
{
   $null = (New-Item -Path $EdgeRegPath -Force -Confirm:$false -ErrorAction SilentlyContinue)
}
$null = (New-ItemProperty -LiteralPath $EdgeRegPath -Name 'EdgeEDropEnabled' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $EdgeRegPath -Name 'EdgeEnhanceImagesEnabled' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $EdgeRegPath -Name 'QuicAllowed' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $EdgeRegPath -Name 'AllowGamesMenu' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $EdgeRegPath -Name 'AudioSandboxEnabled' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $EdgeRegPath -Name 'CryptoWalletEnabled' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $EdgeRegPath -Name 'DirectInvokeEnabled' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $EdgeRegPath -Name 'DNSInterceptionChecksEnabled' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $EdgeRegPath -Name 'EnableMediaRouter' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $EdgeRegPath -Name 'HideRestoreDialogEnabled' -Value 1 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $EdgeRegPath -Name 'MouseGestureEnabled' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $EdgeRegPath -Name 'NewTabPageHideDefaultTopSites' -Value 1 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $EdgeRegPath -Name 'ReadAloudEnabled' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $EdgeRegPath -Name 'RendererAppContainerEnabled' -Value 1 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $EdgeRegPath -Name 'ShowPDFDefaultRecommendationsEnabled' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $EdgeRegPath -Name 'SitePerProcess' -Value 1 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $EdgeRegPath -Name 'SpeechRecognitionEnabled' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $EdgeRegPath -Name 'VideoCaptureAllowed' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $EdgeRegPath -Name 'WalletDonationEnabled' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $EdgeRegPath -Name 'WPADQuickCheckEnabled' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $EdgeRegPath -Name 'MathSolverEnabled' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $EdgeRegPath -Name 'UserFeedbackAllowed' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $EdgeRegPath -Name 'WebWidgetAllowed' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $EdgeRegPath -Name 'WebWidgetIsEnabledOnStartup' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $EdgeRegPath -Name 'MicrosoftEditorProofingEnabled' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $EdgeRegPath -Name 'MicrosoftEditorSynonymsEnabled' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $EdgeRegPath -Name 'NewTabPageAllowedBackgroundTypes' -Value 1 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $EdgeRegPath -Name 'NewTabPageContentEnabled' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $EdgeRegPath -Name 'NewTabPagePrerenderEnabled' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $EdgeRegPath -Name 'NewTabPageHideDefaultTopSites' -Value 1 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $EdgeRegPath -Name 'NewTabPageQuickLinksEnabled' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $EdgeRegPath -Name 'BrowserGuestModeEnabled' -Value 1 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $EdgeRegPath -Name 'FamilySafetySettingsEnabled' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $EdgeRegPath -Name 'AlternateErrorPagesEnabled' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $EdgeRegPath -Name 'DiagnosticData' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $EdgeRegPath -Name 'ResolveNavigationErrorsUseWebService' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $EdgeRegPath -Name 'SearchSuggestEnabled' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $EdgeRegPath -Name 'SiteSafetyServicesEnabled' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $EdgeRegPath -Name 'TabServicesEnabled' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $EdgeRegPath -Name 'TyposquattingCheckerEnabled' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $EdgeRegPath -Name 'VisualSearchEnabled' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $EdgeRegPath -Name 'PersonalizationReportingEnabled' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $EdgeRegPath -Name 'PromotionalTabsEnabled' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $EdgeRegPath -Name 'ShowRecommendationsEnabled' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $EdgeRegPath -Name 'SpotlightExperiencesAndRecommendationsEnabled' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $EdgeRegPath -Name 'PasswordMonitorAllowed' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $EdgeRegPath -Name 'ShowMicrosoftRewards' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $EdgeRegPath -Name 'AADWebSiteSSOUsingThisProfileEnabled' -Value 1 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $EdgeRegPath -Name 'BackgroundModeEnabled' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $EdgeRegPath -Name 'StartupBoostEnabled' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $EdgeRegPath -Name 'NetworkPredictionOptions' -Value 2 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)

$EdgeRegPath = $null
#endregion

#region
$EdgeUpdateRegPath = 'HKLM:\Software\Policies\Microsoft\Edge\EdgeUpdate'

if ((Test-Path -LiteralPath $EdgeUpdateRegPath -ErrorAction SilentlyContinue) -ne $true)
{
	$null = (New-Item -Path $EdgeUpdateRegPath -Force -Confirm:$false -ErrorAction SilentlyContinue)
}

$null = (New-ItemProperty -LiteralPath $EdgeUpdateRegPath -Name 'CreateDesktopShortcutDefault' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $EdgeUpdateRegPath -Name 'CreateDesktopShortcut{56EB18F8-B008-4CBD-B6D2-8C97FE7E9062}' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $EdgeUpdateRegPath -Name 'RemoveDesktopShortcutDefault' -Value 1 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)

$EdgeUpdateRegPath = $null
#endregion

#region
$WebView2Regpath = 'HKLM:\Software\Policies\Microsoft\Edge\WebView2'

if ((Test-Path -LiteralPath $WebView2Regpath -ErrorAction SilentlyContinue) -ne $true)
{
   $null = (New-Item -Path $WebView2Regpath -Force -Confirm:$false -ErrorAction SilentlyContinue)
}

$null = (New-ItemProperty -LiteralPath $WebView2Regpath -Name 'QuicAllowed' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)

$WebView2Regpath = $null
#endregion
