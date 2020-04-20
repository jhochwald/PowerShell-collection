#requires -Version 3.0 -Modules AzureADPreview

<#
      .SYNOPSIS
      Create of modify a Azure AD Naming Policy for Office 365 Groups

      .DESCRIPTION
      Create of modify a Azure AD Naming Policy for Office 365 Groups, these groups (a/k/a Unified Groups) are the base for Microsoft Teams and other Microsoft 365 services.

      .PARAMETER BlockedWordsFile
      CSV with your blacklisted names, 5.000 word is the Office 365 maximum

      .PARAMETER ApplyDefaults
      Apply some basics and defaults

      .EXAMPLE
      PS C:\> .\Set-AzureADNamingPolicyForOffice365Groups.ps1

      Create of modify a Azure AD Naming Policy for Office 365 Groups

      .EXAMPLE
      PS C:\> .\Set-AzureADNamingPolicyForOffice365Groups.ps1 -Verbose

      Create of modify a Azure AD Naming Policy for Office 365 Groups

      .EXAMPLE
      PS C:\> .\Set-AzureADNamingPolicyForOffice365Groups.ps1 -ApplyDefaults

      Create of modify a Azure AD Naming Policy for Office 365 Groups and apply some basics and defaults

      .EXAMPLE
      PS C:\> .\Set-AzureADNamingPolicyForOffice365Groups.ps1 -ApplyDefaults -Verbose

      Create of modify a Azure AD Naming Policy for Office 365 Groups and apply some basics and defaults

      .NOTES
      Nothing fancy, just a modified version of the Microsoft script.

      Please review the setting and check if my values match your requirements.

      If you create the new Group "Development", the Name becomes:
      GRP_Development_Frankfurt

      This is based on my default naming convention: 'GRP_[GroupName]_[Office]' - Change it below to match your own naming convention!

      If you create the new Group "Payroll" it will fail! The Word "Payroll" is blacklisted!

      Please note: You need to have a AzureAD Premium P1 (or Higher) License, or any license option that contains AzureAD Premium P1 or P2

      .LINK
      https://docs.microsoft.com/en-us/microsoft-365/admin/create-groups/groups-naming-policy?view=o365-worldwide#how-to-set-up-the-naming-policy-in-azure-ad-powershell
#>
[CmdletBinding(ConfirmImpact = 'Low')]
param
(
   [Parameter(ValueFromPipeline,
   ValueFromPipelineByPropertyName)]
   [AllowNull()]
   [AllowEmptyString()]
   [Alias('File', 'Path')]
   [string]
   $BlockedWordsFile = '.\BlockedWords.csv',
   [Parameter(ValueFromPipeline,
   ValueFromPipelineByPropertyName)]
   [switch]
   $ApplyDefaults
)

begin
{
   # Remove the regular Module
   $paramRemoveModule = @{
      Name          = 'AzureAD'
      Force         = $true
      ErrorAction   = 'SilentlyContinue'
      WarningAction = 'SilentlyContinue'
   }
   $null = (Remove-Module @paramRemoveModule)

   # Do we have a CSV File?
   if (Test-Path -Path $BlockedWordsFile -ErrorAction SilentlyContinue)
   {
      # Fine, let us import the CSV File
      $paramImportCsv = @{
         Path        = $BlockedWordsFile
         Encoding    = 'UTF8'
         ErrorAction = 'Stop'
      }
      $BlockedWordsImport = (Import-Csv @paramImportCsv)

      # Transfer the values into the list
      [string]$BlockedWords = ($BlockedWordsImport.BlockedWords -join ', ')

      # Cleanup
      $BlockedWordsImport = $null
   }
   else
   {
      # No CSV, let us use some defaults
      [string]$BlockedWords = 'Payroll,CEO,HR,hochwald'
   }

   # Prefix and Suffix for the Unified Groups
   <#
         Valid suffix values are:
         [Company]
         [CountryOrRegion]
         [Department]
         [Office]
         [StateOrProvince]
         [Title]
   #>
   $PrefixSuffix = 'GRP_[GroupName]_[Office]'

   # Connect to your AzureAD tenant, if needed
   try
   {
      $null = (Get-AzureADDomain -ErrorAction Stop)
   }
   catch
   {
      $null = (Connect-AzureAD)
   }
}

process
{
   try
   {
      # Get the existing template
      $template = (Get-AzureADDirectorySettingTemplate -ErrorAction Stop | Where-Object -FilterScript {
            $_.displayname -eq 'group.unified'
      })

      # Modify the settings
      $settingsCopy = $template.CreateDirectorySetting()

      # Create a new setting
      $paramNewAzureADDirectorySetting = @{
         DirectorySetting = $settingsCopy
         ErrorAction      = 'Stop'
      }
      $null = (New-AzureADDirectorySetting @paramNewAzureADDirectorySetting)
   }
   catch
   {
      Write-Verbose -Message 'Looks like we have the Settings...'
   }
   finally
   {
      # Get the settings
      $settingsObjectID = (Get-AzureADDirectorySetting | Where-Object -Property Displayname -Value 'Group.Unified' -EQ | Select-Object -ExpandProperty id)
   }

   # Read the settings
   $settingsCopy = (Get-AzureADDirectorySetting -Id $settingsObjectID)

   # Modify the settings
   $settingsCopy['PrefixSuffixNamingRequirement'] = $PrefixSuffix
   $settingsCopy['CustomBlockedWordsList'] = $BlockedWords

   # Apply some basics and defaults
   if ($ApplyDefaults)
   {
      $settingsCopy['EnableMSStandardBlockedWords'] = $true
      $settingsCopy['AllowGuestsToBeGroupOwner'] = $false
      $settingsCopy['AllowGuestsToAccessGroups'] = $true
   }


   # Apply the settings
   $paramSetAzureADDirectorySetting = @{
      Id               = $settingsObjectID
      DirectorySetting = $settingsCopy
      ErrorAction      = 'Stop'
   }
   $null = (Set-AzureADDirectorySetting @paramSetAzureADDirectorySetting)
}

end
{
   # Get the Info
   $Info = (Get-AzureADDirectorySetting -Id $settingsObjectID | Select-Object -ExpandProperty Values)

   # Dump the Info
   $Info

   # Cleanup
   $Info = $null
}
