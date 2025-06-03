# Detection: Setup Microsoft Edge Browser

try {
   #region
   $EdgeRegPath = 'HKLM:\Software\Policies\Microsoft\Edge'

   if (!(Test-Path -LiteralPath $EdgeRegPath -ErrorAction SilentlyContinue))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $EdgeRegPath -Name 'EdgeEDropEnabled' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $EdgeRegPath -Name 'EdgeEnhanceImagesEnabled' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $EdgeRegPath -Name 'QuicAllowed' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $EdgeRegPath -Name 'AllowGamesMenu' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $EdgeRegPath -Name 'AudioSandboxEnabled' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $EdgeRegPath -Name 'CryptoWalletEnabled' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $EdgeRegPath -Name 'DirectInvokeEnabled' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $EdgeRegPath -Name 'DNSInterceptionChecksEnabled' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $EdgeRegPath -Name 'EnableMediaRouter' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $EdgeRegPath -Name 'HideRestoreDialogEnabled' -ErrorAction SilentlyContinue) -eq 1))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $EdgeRegPath -Name 'MouseGestureEnabled' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $EdgeRegPath -Name 'NewTabPageHideDefaultTopSites' -ErrorAction SilentlyContinue) -eq 1))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $EdgeRegPath -Name 'ReadAloudEnabled' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $EdgeRegPath -Name 'RendererAppContainerEnabled' -ErrorAction SilentlyContinue) -eq 1))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $EdgeRegPath -Name 'ShowPDFDefaultRecommendationsEnabled' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $EdgeRegPath -Name 'SitePerProcess' -ErrorAction SilentlyContinue) -eq 1))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $EdgeRegPath -Name 'SpeechRecognitionEnabled' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $EdgeRegPath -Name 'VideoCaptureAllowed' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $EdgeRegPath -Name 'WalletDonationEnabled' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $EdgeRegPath -Name 'WPADQuickCheckEnabled' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $EdgeRegPath -Name 'MathSolverEnabled' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $EdgeRegPath -Name 'UserFeedbackAllowed' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $EdgeRegPath -Name 'WebWidgetAllowed' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $EdgeRegPath -Name 'WebWidgetIsEnabledOnStartup' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $EdgeRegPath -Name 'MicrosoftEditorProofingEnabled' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $EdgeRegPath -Name 'MicrosoftEditorSynonymsEnabled' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $EdgeRegPath -Name 'NewTabPageAllowedBackgroundTypes' -ErrorAction SilentlyContinue) -eq 1))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $EdgeRegPath -Name 'NewTabPageContentEnabled' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $EdgeRegPath -Name 'NewTabPagePrerenderEnabled' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $EdgeRegPath -Name 'NewTabPageHideDefaultTopSites' -ErrorAction SilentlyContinue) -eq 1))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $EdgeRegPath -Name 'NewTabPageQuickLinksEnabled' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $EdgeRegPath -Name 'BrowserGuestModeEnabled' -ErrorAction SilentlyContinue) -eq 1))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $EdgeRegPath -Name 'FamilySafetySettingsEnabled' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $EdgeRegPath -Name 'AlternateErrorPagesEnabled' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $EdgeRegPath -Name 'DiagnosticData' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $EdgeRegPath -Name 'ResolveNavigationErrorsUseWebService' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $EdgeRegPath -Name 'SearchSuggestEnabled' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $EdgeRegPath -Name 'SiteSafetyServicesEnabled' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $EdgeRegPath -Name 'TabServicesEnabled' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $EdgeRegPath -Name 'TyposquattingCheckerEnabled' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $EdgeRegPath -Name 'VisualSearchEnabled' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $EdgeRegPath -Name 'PersonalizationReportingEnabled' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $EdgeRegPath -Name 'PromotionalTabsEnabled' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $EdgeRegPath -Name 'ShowRecommendationsEnabled' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $EdgeRegPath -Name 'SpotlightExperiencesAndRecommendationsEnabled' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $EdgeRegPath -Name 'PasswordMonitorAllowed' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $EdgeRegPath -Name 'ShowMicrosoftRewards' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $EdgeRegPath -Name 'AADWebSiteSSOUsingThisProfileEnabled' -ErrorAction SilentlyContinue) -eq 1))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $EdgeRegPath -Name 'BackgroundModeEnabled' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $EdgeRegPath -Name 'StartupBoostEnabled' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $EdgeRegPath -Name 'NetworkPredictionOptions' -ErrorAction SilentlyContinue) -eq 2))
   {
      exit 1
   }

   $EdgeRegPath = $null
   #endregion

   #region
   $EdgeUpdateRegPath = 'HKLM:\Software\Policies\Microsoft\Edge\EdgeUpdate'

   if (!(Test-Path -LiteralPath $EdgeUpdateRegPath -ErrorAction SilentlyContinue))
   {
      exit 1
   }
   	
   if (!((Get-ItemPropertyValue -LiteralPath $EdgeUpdateRegPath -Name 'CreateDesktopShortcutDefault' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $EdgeUpdateRegPath -Name 'CreateDesktopShortcut{56EB18F8-B008-4CBD-B6D2-8C97FE7E9062}' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $EdgeUpdateRegPath -Name 'RemoveDesktopShortcutDefault' -ErrorAction SilentlyContinue) -eq 1))
   {
      exit 1
   }

   $EdgeUpdateRegPath = $null
	#endregion

   #region
   $WebView2RegPath = 'HKLM:\Software\Policies\Microsoft\Edge\WebView2'

   if (!(Test-Path -LiteralPath $WebView2RegPath -ErrorAction SilentlyContinue))
   {
      exit 1
   }

   if (!((Get-ItemPropertyValue -LiteralPath $WebView2RegPath -Name 'QuicAllowed' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }

   $WebView2RegPath = $null
   #endregion
}
catch
{
   exit 1
}

exit 0
