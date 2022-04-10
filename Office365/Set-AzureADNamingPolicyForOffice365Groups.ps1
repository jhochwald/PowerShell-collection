#requires -Version 3.0 -Modules AzureADPreview

<#
      .SYNOPSIS
      Create or modify a Azure AD Naming Policy for Office 365 Groups

      .DESCRIPTION
      Create or modify a Azure AD Naming Policy for Office 365 Groups, these groups (a/k/a Unified Groups) are the base for Microsoft Teams and other Microsoft 365 services.

      .PARAMETER BlockedWordsFile
      CSV with your blacklisted names, 5.000 word is the Office 365 maximum

      .PARAMETER ApplyDefaults
      Apply some basics and defaults

      .EXAMPLE
      PS C:\> .\Set-AzureADNamingPolicyForOffice365Groups.ps1

      Create or modify a Azure AD Naming Policy for Office 365 Groups

      .EXAMPLE
      PS C:\> .\Set-AzureADNamingPolicyForOffice365Groups.ps1 -Verbose

      Create or modify a Azure AD Naming Policy for Office 365 Groups

      .EXAMPLE
      PS C:\> .\Set-AzureADNamingPolicyForOffice365Groups.ps1 -ApplyDefaults

      Create or modify a Azure AD Naming Policy for Office 365 Groups and apply some basics and defaults

      .EXAMPLE
      PS C:\> .\Set-AzureADNamingPolicyForOffice365Groups.ps1 -ApplyDefaults -Verbose

      Create or modify a Azure AD Naming Policy for Office 365 Groups and apply some basics and defaults

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
            $PSItem.displayname -eq 'group.unified'
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

#region LICENSE
<#
   BSD 3-Clause License

   Copyright (c) 2022, enabling Technology
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
   - If you disagree with any of the terms, and any conditions declared: Just delete it and build your own solution
#>
#endregion DISCLAIMER
