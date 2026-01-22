#requires -Version 1.0 -RunAsAdministrator

<#
      .SYNOPSIS
      Microsoft Edge settings of "Just the Browser"

      .DESCRIPTION
      Microsoft Edge settings of "Just the Browser"
      Just the Browser helps you remove AI features, telemetry data reporting, sponsored content,
      product integrations, and other annoyances from Microsoft Edge.

      .EXAMPLE
      PS C:\> .\Invoke-ApplyEdgeJustTheBrowserSettings.ps1
      Apply the Microsoft Edge settings of "Just the Browser"

      .LINK
      https://github.com/corbindavenport/just-the-browser

      .NOTES
      Just a PowerShell version of the MIT Licensed "Just the Browser" Settings
#>
[CmdletBinding(ConfirmImpact = 'Medium')]
param ()

process
{
   # The registry path
   $RegPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Edge'

   # Define some defaults for the cmdlets
   $paramDefaults = @{
      LiteralPath = $RegPath
      Force       = $true
      Confirm     = $false
      ErrorAction = 'SilentlyContinue'
   }

   # Ensure the registry path exists
   if ((Test-Path -LiteralPath $RegPath -ErrorAction SilentlyContinue) -ne $true)
   {
      $null = (New-Item -Path $RegPath @paramDefaults)
   }
   
   # Apply the Microsoft Edge settings of "Just the Browser"
   $null = (New-ItemProperty -Name 'HideFirstRunExperience' -Value 1 -PropertyType DWord @paramDefaults)
   $null = (New-ItemProperty -Name 'ShowPDFDefaultRecommendationsEnabled' -Value 0 -PropertyType DWord @paramDefaults)
   $null = (New-ItemProperty -Name 'SpotlightExperiencesAndRecommendationsEnabled' -Value 0 -PropertyType DWord @paramDefaults)
   $null = (New-ItemProperty -Name 'NewTabPageSearchBox' -Value 'redirect' -PropertyType String @paramDefaults)
   $null = (New-ItemProperty -Name 'GenAILocalFoundationalModelSettings' -Value 1 -PropertyType DWord @paramDefaults)
   $null = (New-ItemProperty -Name 'WebToBrowserSignInEnabled' -Value 0 -PropertyType DWord @paramDefaults)
   $null = (New-ItemProperty -Name 'StartupBoostEnabled' -Value 0 -PropertyType DWord @paramDefaults)
   $null = (New-ItemProperty -Name 'NewTabPageBingChatEnabled' -Value 0 -PropertyType DWord @paramDefaults)
   $null = (New-ItemProperty -Name 'NewTabPageContentEnabled' -Value 0 -PropertyType DWord @paramDefaults)
   $null = (New-ItemProperty -Name 'NewTabPageHideDefaultTopSites' -Value 1 -PropertyType DWord @paramDefaults)
   $null = (New-ItemProperty -Name 'AIGenThemesEnabled' -Value 0 -PropertyType DWord @paramDefaults)
   $null = (New-ItemProperty -Name 'AutoImportAtFirstRun' -Value 4 -PropertyType DWord @paramDefaults)
   $null = (New-ItemProperty -Name 'BuiltInAIAPIsEnabled' -Value 0 -PropertyType DWord @paramDefaults)
   $null = (New-ItemProperty -Name 'BuiltInDnsClientEnabled' -Value 0 -PropertyType DWord @paramDefaults)
   $null = (New-ItemProperty -Name 'ComposeInlineEnabled' -Value 0 -PropertyType DWord @paramDefaults)
   $null = (New-ItemProperty -Name 'CopilotPageContext' -Value 0 -PropertyType DWord @paramDefaults)
   $null = (New-ItemProperty -Name 'DefaultBrowserSettingEnabled' -Value 0 -PropertyType DWord @paramDefaults)
   $null = (New-ItemProperty -Name 'DefaultBrowserSettingsCampaignEnabled' -Value 0 -PropertyType DWord @paramDefaults)
   $null = (New-ItemProperty -Name 'DiagnosticData' -Value 0 -PropertyType DWord @paramDefaults)
   $null = (New-ItemProperty -Name 'EdgeShoppingAssistantEnabled' -Value 0 -PropertyType DWord @paramDefaults)
   $null = (New-ItemProperty -Name 'Microsoft365CopilotChatIconEnabled' -Value 0 -PropertyType DWord @paramDefaults)
   $null = (New-ItemProperty -Name 'ShowAcrobatSubscriptionButton' -Value 0 -PropertyType DWord @paramDefaults)
   $null = (New-ItemProperty -Name 'ShowMicrosoftRewards' -Value 0 -PropertyType DWord @paramDefaults)
   $null = (New-ItemProperty -Name 'ShowRecommendationsEnabled' -Value 0 -PropertyType DWord @paramDefaults)
   $null = (New-ItemProperty -Name 'TabServicesEnabled' -Value 0 -PropertyType DWord @paramDefaults)
   $null = (New-ItemProperty -Name 'TextPredictionEnabled' -Value 0 -PropertyType DWord @paramDefaults)
   $null = (New-ItemProperty -Name 'VisualSearchEnabled' -Value 0 -PropertyType DWord @paramDefaults)
   $null = (New-ItemProperty -Name 'EdgeHistoryAISearchEnabled' -Value 0 -PropertyType DWord @paramDefaults)
}
