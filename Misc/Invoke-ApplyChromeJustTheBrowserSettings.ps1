#requires -Version 1.0 -RunAsAdministrator

<#
      .SYNOPSIS
      Google Chrome settings of "Just the Browser"

      .DESCRIPTION
      Google Chrome settings of "Just the Browser"
      Just the Browser helps you remove AI features, telemetry data reporting, sponsored content,
      product integrations, and other annoyances from Google Chrome.

      .EXAMPLE
      PS C:\> .\Invoke-ApplyChromeJustTheBrowserSettings.ps1
      Apply the Google Chrome settings of "Just the Browser"

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
   $RegPath = 'HKLM:\SOFTWARE\Policies\Google\Chrome'

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
   
   # Apply the Google Chrome settings of "Just the Browser"
   $null = (New-ItemProperty -Name 'AIModeSettings' -Value 1 -PropertyType DWord @paramDefaults)
   $null = (New-ItemProperty -Name 'CreateThemesSettings' -Value 2 -PropertyType DWord @paramDefaults)
   $null = (New-ItemProperty -Name 'GeminiSettings' -Value 1 -PropertyType DWord @paramDefaults)
   $null = (New-ItemProperty -Name 'GenAILocalFoundationalModelSettings' -Value 1 -PropertyType DWord @paramDefaults)
   $null = (New-ItemProperty -Name 'HelpMeWriteSettings' -Value 2 -PropertyType DWord @paramDefaults)
   $null = (New-ItemProperty -Name 'HistorySearchSettings' -Value 2 -PropertyType DWord @paramDefaults)
   $null = (New-ItemProperty -Name 'TabCompareSettings' -Value 2 -PropertyType DWord @paramDefaults)
   $null = (New-ItemProperty -Name 'BuiltInDnsClientEnabled' -Value 0 -PropertyType DWord @paramDefaults)
   $null = (New-ItemProperty -Name 'DefaultBrowserSettingEnabled' -Value 0 -PropertyType DWord @paramDefaults)
   $null = (New-ItemProperty -Name 'DevToolsGenAiSettings' -Value 2 -PropertyType DWord @paramDefaults)
}
