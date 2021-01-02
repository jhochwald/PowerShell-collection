<#
      .SYNOPSIS
      Create a Project team in Teams with folder structure in files tab

      .TeamsDescription
      Create a Project team in Teams with folder structure in files tab
      Based on Alexander Holmeset's version.

      .DESCRIPTION
      A detailed description of the  file.

      .PARAMETER TeamName
      Name of the Microsoft Teams team

      .PARAMETER TeamsOwner
      TeamsOwner of the new Microsoft Teams team

      .PARAMETER privatepublic
      Os it a private or Public team?

      .PARAMETER TeamsDescription
      The TeamsDescription for the new team

      .PARAMETER ClientId
      Azure AD Application (client) ID

      .PARAMETER TenantId
      Azure AD Tenant ID

      .PARAMETER ClientSecret
      Azure AD secret

      .PARAMETER TenantName
      Office 365 Tenant Name (e.g. contoso for https://contoso.sharepoint.com)

      .PARAMETER DocumentLibrary
      Document Library Folder, default is /shared documents

      .EXAMPLE
      PS C:\> .\ProjectTeamStructure.ps1 -TeamName 'Value1' -TeamsOwner 'Value2'

      .NOTES
      Original found in Alexander Holmeset's Blog
      My version starts to make it a bit more flexible (e.g. more parameters)
      I might update this to be more configurable in the future

      .LINK
      https://alexholmeset.blog/2019/05/01/project-team-in-teams-with-folder-structure-in-files-tab/

      .LINK
      https://gist.githubusercontent.com/AlexanderHolmeset/d447cd7c24dd91c3275ad17a5091f0ed/raw/79478f1e789ab36a9236f21a3161685091b12e62/ProjectTeamStructure.ps1
#>
[CmdletBinding(ConfirmImpact = 'Low')]
param
(
   [Parameter(Mandatory,
      ValueFromPipeline,
      ValueFromPipelineByPropertyName,
      Position = 0,
      HelpMessage = 'Name of the Microsoft Teams team')]
   [Parameter (Mandatory)]
   [ValidateNotNullOrEmpty()]
   [Alias('Name')]
   [String]
   $TeamName,
   [Parameter(Mandatory,
      ValueFromPipeline,
      ValueFromPipelineByPropertyName,
      Position = 1,
      HelpMessage = 'Owner of the new Microsoft Teams team')]
   [Parameter (Mandatory)]
   [ValidateNotNullOrEmpty()]
   [Alias('Owner')]
   [String]
   $TeamsOwner,
   [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName,
      Position = 2)]
   [Parameter (Mandatory)]
   [ValidateNotNullOrEmpty()]
   [String]
   $privatepublic = 'Public',
   [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName,
      Position = 3)]
   [Parameter (Mandatory)]
   [Alias('description')]
   [String]
   $TeamsDescription,
   [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName,
      Position = 4)]
   [Alias('OAuthClientId')]
   [string]
   $ClientId,
   [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName,
      Position = 5)]
   [Alias('OAuthTenantId')]
   [string]
   $TenantId,
   [Parameter(Position = 6)]
   [Alias('OAuthClientSecret')]
   [string]
   $ClientSecret,
   [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName,
      Position = 7)]
   [string]
   $TenantName = 'contoso',
   [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName,
      Position = 8)]
   [string]
   $DocumentLibrary = '/shared documents'
)

begin
{
   <#
      # Azure AD OAuth Application Token for Graph API
      # Get OAuth token for a AAD Application (returned as $token)
      # Application (client) ID, tenant ID and secret
      $ClientId = 'xxxxxxxxxxxxxxxxxxxxxxxx'
      $TenantId = 'xxxxxxxxxxxxxxxxxxxxxxxx'
      $ClientSecret = 'xxxxxxxxxxxxxxxxxxxxxxxx'
   #>
}

process
{
   # Get the credentials to use
   $Cred = (Get-Credential)

   # Connect to Exchange Online
   $paramNewPSSession = @{
      ConfigurationName = 'Microsoft.Exchange'
      ConnectionUri     = 'https://outlook.office365.com/powershell-liveid'
      Credential        = $Cred
      Authentication    = 'Basic'
      AllowRedirection  = $true
   }

   $Session = (New-PSSession @paramNewPSSession)
   $paramImportPSSession = @{
      Session             = $Session
      DisableNameChecking = $true
      AllowClobber        = $true
   }

   $null = (Import-PSSession @paramImportPSSession)

   # Connect to Microsoft Teams
   $null = (Connect-MicrosoftTeams -Credential $Cred)

   # Contruct URI
   $uri = 'https://login.microsoftonline.com/' + $TenantId + '/oauth2/v2.0/token'

   # Construct the JSON Body
   $body1 = @{
      client_id     = $ClientId
      scope         = 'https://graph.microsoft.com/.default'
      client_secret = $ClientSecret
      grant_type    = 'client_credentials'
   }

   try
   {
      # Get OAuth 2.0 Token
      $paramInvokeWebRequest = @{
         Method          = 'Post'
         Uri             = $uri
         ContentType     = 'application/x-www-form-urlencoded'
         Body            = $body1
         ErrorAction     = 'Stop'
         UseBasicParsing = $true
      }
      $tokenRequest = (Invoke-WebRequest @paramInvokeWebRequest)
   }
   catch
   {
      # get error record
      [Management.Automation.ErrorRecord]$e = $_

      # retrieve information about runtime error
      $info = [PSCustomObject]@{
         Exception = $e.Exception.Message
         Reason    = $e.CategoryInfo.Reason
         Target    = $e.CategoryInfo.TargetName
         Script    = $e.InvocationInfo.ScriptName
         Line      = $e.InvocationInfo.ScriptLineNumber
         Column    = $e.InvocationInfo.OffsetInLine
      }

      # output information. Post-process collected info, and log info (optional)
      $info | Out-String | Write-Verbose

      $paramWriteError = @{
         Message      = $e.Exception.Message
         ErrorAction  = 'Stop'
         Exception    = $e.Exception
         TargetObject = $e.CategoryInfo.TargetName
      }
      Write-Error @paramWriteError
   }

   # Extract the Token
   $token = (($tokenRequest.Content | ConvertFrom-Json).access_token)

   # Get ID of team requester and set as owner.
   $uri = 'https://graph.microsoft.com/beta/users/' + $TeamsOwner + '?$select=id'
   $method = 'GET'

   try
   {
      $paramInvokeWebRequest = @{
         Method          = $method
         Uri             = $uri
         ContentType     = 'application/json'
         Headers         = @{
            Authorization = 'Bearer ' + $token
         }
         ErrorAction     = 'Stop'
         UseBasicParsing = $true
      }
      $query = (Invoke-WebRequest @paramInvokeWebRequest)
   }
   catch
   {
      # get error record
      [Management.Automation.ErrorRecord]$e = $_

      # retrieve information about runtime error
      $info = [PSCustomObject]@{
         Exception = $e.Exception.Message
         Reason    = $e.CategoryInfo.Reason
         Target    = $e.CategoryInfo.TargetName
         Script    = $e.InvocationInfo.ScriptName
         Line      = $e.InvocationInfo.ScriptLineNumber
         Column    = $e.InvocationInfo.OffsetInLine
      }

      # output information. Post-process collected info, and log info (optional)
      $info | Out-String | Write-Verbose

      $paramWriteError = @{
         Message      = $e.Exception.Message
         ErrorAction  = 'Stop'
         Exception    = $e.Exception
         TargetObject = $e.CategoryInfo.TargetName
      }
      Write-Error @paramWriteError
   }

   # Extract the ID
   $ownerID = (($query.content | ConvertFrom-Json).id)

   # Specify the URI to call and method
   $uri = 'https://graph.microsoft.com/beta/teams'
   $method = 'Post'

   # Construct the JSON Body
   <#
         Please review this defaults,
         these settings are applied to the new Microsoft Teams team!
   #>
   $body = @"
{
"template@odata.bind": "https://graph.microsoft.com/beta/teamsTemplates/standard",
"displayName": "$TeamName",
"description": "$TeamsDescription",
"channels": [
{
"displayName": "01-Management",
"isFavoriteByDefault": true,
"description": "Description"
},
{
"displayName": "02-Developement",
"isFavoriteByDefault": true,
"description": "DEscription"
},
{
"displayName": "03-Marketing",
"isFavoriteByDefault": true,
"description": "Description"
},
{
"displayName": "04-Finance",
"isFavoriteByDefault": true,
"description": "Description"
}
],
"memberSettings": {
"allowCreateUpdateChannels": true,
"allowDeleteChannels": false,
"allowAddRemoveApps": true,
"allowCreateUpdateRemoveTabs": true,
"allowCreateUpdateRemoveConnectors": true
},
"guestSettings": {
"allowCreateUpdateChannels": false,
"allowDeleteChannels": false
},
"funSettings": {
"allowGiphy": true,
"giphyContentRating": "Moderate",
"allowStickersAndMemes": true,
"allowCustomMemes": true
},
"messagingSettings": {
"allowUserEditMessages": true,
"allowUserDeleteMessages": true,
"allowOwnerDeleteMessages": true,
"allowTeamMentions": true,
"allowChannelMentions": true
},
"visibility": "$Private",
"owners@odata.bind": [
"https://graph.microsoft.com/beta/users('$ownerID')"
]
}
"@

   try
   {
      $paramInvokeWebRequest = @{
         Method          = $method
         Uri             = $uri
         ContentType     = 'application/json'
         Body            = $body
         Headers         = @{
            Authorization = 'Bearer ' + $token
         }
         ErrorAction     = 'Stop'
         UseBasicParsing = $true
      }
      $query = (Invoke-WebRequest @paramInvokeWebRequest)
   }
   catch
   {
      # get error record
      [Management.Automation.ErrorRecord]$e = $_

      # retrieve information about runtime error
      $info = [PSCustomObject]@{
         Exception = $e.Exception.Message
         Reason    = $e.CategoryInfo.Reason
         Target    = $e.CategoryInfo.TargetName
         Script    = $e.InvocationInfo.ScriptName
         Line      = $e.InvocationInfo.ScriptLineNumber
         Column    = $e.InvocationInfo.OffsetInLine
      }

      # output information. Post-process collected info, and log info (optional)
      $info | Out-String | Write-Verbose

      $paramWriteError = @{
         Message      = $e.Exception.Message
         ErrorAction  = 'Stop'
         Exception    = $e.Exception
         TargetObject = $e.CategoryInfo.TargetName
      }
      Write-Error @paramWriteError
   }

   # Extract the Data
   $location = ($query.Headers).Location
   $GroupID = $location.Substring(8, 36)

   # Wait a minute to setup the stuff
   Start-Sleep -Seconds 60

   # Get the Mail info about the new team
   $TeamSiteName = ((Get-Team -groupid $GroupID).MailNickName)

   # Set some defaults
   $SiteURL = 'https://' + $TenantName + '.sharepoint.com/sites/' + $TeamSiteName
   $DocumentLibrary = '/shared documents'

   # Channels
   # Config Variables
   $FolderNames = '01-Management', '02-Developement', '03-Marketing', '04-Finance'

   # Relative URL of the Parent Folder
   $RelativeURL = $DocumentLibrary

   try
   {
      # Connect to PNP Online
      $null = (Connect-PnPOnline -Url $SiteURL -Credentials $Cred)

      #sharepoint online create folder powershell
      foreach ($Folder in $FolderNames)
      {
         $paramAddPnPFolder = @{
            Name        = $Folder
            Folder      = $RelativeURL
            ErrorAction = 'Stop'
         }
         $null = (Add-PnPFolder @paramAddPnPFolder)

         Write-Verbose -Message ("New Folder '{0}' Added!" -f $Folder)
      }
   }
   catch
   {
      # get error record
      [Management.Automation.ErrorRecord]$e = $_

      # retrieve information about runtime error
      $info = [PSCustomObject]@{
         Exception = $e.Exception.Message
         Reason    = $e.CategoryInfo.Reason
         Target    = $e.CategoryInfo.TargetName
         Script    = $e.InvocationInfo.ScriptName
         Line      = $e.InvocationInfo.ScriptLineNumber
         Column    = $e.InvocationInfo.OffsetInLine
      }

      # output information. Post-process collected info, and log info (optional)
      $info | Out-String | Write-Verbose

      $paramWriteError = @{
         Message      = $e.Exception.Message
         ErrorAction  = 'Continue'
         Exception    = $e.Exception
         TargetObject = $e.CategoryInfo.TargetName
      }
      Write-Error @paramWriteError
   }

   # 01-Management
   # Config Variables
   $FolderNames = 'Meetings', 'Presentations'
   $RelativeURL = $DocumentLibrary + '/01-management' #Relative URL of the Parent Folder

   try
   {
      # Connect to PNP Online
      $null = (Connect-PnPOnline -Url $SiteURL -Credentials $Cred)

      # sharepoint online create folder powershell
      foreach ($Folder in $FolderNames)
      {
         $paramAddPnPFolder = @{
            Name        = $Folder
            Folder      = $RelativeURL
            ErrorAction = 'Stop'
         }
         $null = (Add-PnPFolder @paramAddPnPFolder)

         Write-Verbose -Message ("New Folder '{0}' Added!" -f $Folder)
      }
   }
   catch
   {
      # get error record
      [Management.Automation.ErrorRecord]$e = $_

      # retrieve information about runtime error
      $info = [PSCustomObject]@{
         Exception = $e.Exception.Message
         Reason    = $e.CategoryInfo.Reason
         Target    = $e.CategoryInfo.TargetName
         Script    = $e.InvocationInfo.ScriptName
         Line      = $e.InvocationInfo.ScriptLineNumber
         Column    = $e.InvocationInfo.OffsetInLine
      }

      # output information. Post-process collected info, and log info (optional)
      $info | Out-String | Write-Verbose

      $paramWriteError = @{
         Message      = $e.Exception.Message
         ErrorAction  = 'Continue'
         Exception    = $e.Exception
         TargetObject = $e.CategoryInfo.TargetName
      }
      Write-Error @paramWriteError
   }

   # 02-Developement
   # Config Variables
   $FolderNames = 'Design', 'Specs', 'Labeling'

   # Relative URL of the Parent Folder
   $RelativeURL = $DocumentLibrary + '/02-Developement'

   try
   {
      # Connect to PNP Online
      $null = (Connect-PnPOnline -Url $SiteURL -Credentials $Cred)

      # sharepoint online create folder powershell
      foreach ($Folder in $FolderNames)
      {
         $paramAddPnPFolder = @{
            Name        = $Folder
            Folder      = $RelativeURL
            ErrorAction = 'Stop'
         }
         $null = (Add-PnPFolder @paramAddPnPFolder)

         Write-Verbose -Message ("New Folder '{0}' Added!" -f $Folder)
      }
   }
   catch
   {
      # get error record
      [Management.Automation.ErrorRecord]$e = $_

      # retrieve information about runtime error
      $info = [PSCustomObject]@{
         Exception = $e.Exception.Message
         Reason    = $e.CategoryInfo.Reason
         Target    = $e.CategoryInfo.TargetName
         Script    = $e.InvocationInfo.ScriptName
         Line      = $e.InvocationInfo.ScriptLineNumber
         Column    = $e.InvocationInfo.OffsetInLine
      }

      # output information. Post-process collected info, and log info (optional)
      $info | Out-String | Write-Verbose

      $paramWriteError = @{
         Message      = $e.Exception.Message
         ErrorAction  = 'Continue'
         Exception    = $e.Exception
         TargetObject = $e.CategoryInfo.TargetName
      }
      Write-Error @paramWriteError
   }

   # Subfolder
   $FolderNames = 'Sketches', 'Requirements'

   # Relative URL of the Parent Folder
   $RelativeURL = $DocumentLibrary + '/02-Developement/Design'

   try
   {
      # Connect to PNP Online
      $null = (Connect-PnPOnline -Url $SiteURL -Credentials $Cred)

      # sharepoint online create folder powershell
      foreach ($Folder in $FolderNames)
      {
         $paramAddPnPFolder = @{
            Name        = $Folder
            Folder      = $RelativeURL
            ErrorAction = 'Stop'
         }
         $null = (Add-PnPFolder @paramAddPnPFolder)

         Write-Verbose -Message ("New Folder '{0}' Added!" -f $Folder)
      }
   }
   catch
   {
      # get error record
      [Management.Automation.ErrorRecord]$e = $_

      # retrieve information about runtime error
      $info = [PSCustomObject]@{
         Exception = $e.Exception.Message
         Reason    = $e.CategoryInfo.Reason
         Target    = $e.CategoryInfo.TargetName
         Script    = $e.InvocationInfo.ScriptName
         Line      = $e.InvocationInfo.ScriptLineNumber
         Column    = $e.InvocationInfo.OffsetInLine
      }

      # output information. Post-process collected info, and log info (optional)
      $info | Out-String | Write-Verbose

      $paramWriteError = @{
         Message      = $e.Exception.Message
         ErrorAction  = 'Continue'
         Exception    = $e.Exception
         TargetObject = $e.CategoryInfo.TargetName
      }
      Write-Error @paramWriteError
   }

   # 03-Marketing
   # Config Variables
   $FolderNames = 'Communication Brief', 'Competitor Review', 'Consumer Insights', 'Product FAQ', 'Product Information', 'Product Strategy'

   # Relative URL of the Parent Folder
   $RelativeURL = $DocumentLibrary + '/03-Marketing'

   try
   {
      # Connect to PNP Online
      $null = (Connect-PnPOnline -Url $SiteURL -Credentials $Cred)

      # sharepoint online create folder powershell
      foreach ($Folder in $FolderNames)
      {
         $paramAddPnPFolder = @{
            Name        = $Folder
            Folder      = $RelativeURL
            ErrorAction = 'Stop'
         }
         $null = (Add-PnPFolder @paramAddPnPFolder)

         Write-Verbose -Message ("New Folder '{0}' Added!" -f $Folder)
      }
   }
   catch
   {
      # get error record
      [Management.Automation.ErrorRecord]$e = $_

      # retrieve information about runtime error
      $info = [PSCustomObject]@{
         Exception = $e.Exception.Message
         Reason    = $e.CategoryInfo.Reason
         Target    = $e.CategoryInfo.TargetName
         Script    = $e.InvocationInfo.ScriptName
         Line      = $e.InvocationInfo.ScriptLineNumber
         Column    = $e.InvocationInfo.OffsetInLine
      }

      # output information. Post-process collected info, and log info (optional)
      $info | Out-String | Write-Verbose

      $paramWriteError = @{
         Message      = $e.Exception.Message
         ErrorAction  = 'Continue'
         Exception    = $e.Exception
         TargetObject = $e.CategoryInfo.TargetName
      }
      Write-Error @paramWriteError
   }

   # 04-Finance
   # Config Variables
   $FolderNames = 'Budget', 'Presentations'

   # Relative URL of the Parent Folder
   $RelativeURL = $DocumentLibrary + '/04-Finance'

   try
   {
      # Connect to PNP Online
      $null = (Connect-PnPOnline -Url $SiteURL -Credentials $Cred)

      # sharepoint online create folder powershell
      foreach ($Folder in $FolderNames)
      {
         $paramAddPnPFolder = @{
            Name        = $Folder
            Folder      = $RelativeURL
            ErrorAction = 'Stop'
         }
         $null = (Add-PnPFolder @paramAddPnPFolder)

         Write-Verbose -Message ("New Folder '{0}' Added!" -f $Folder)
      }
   }
   catch
   {
      # get error record
      [Management.Automation.ErrorRecord]$e = $_

      # retrieve information about runtime error
      $info = [PSCustomObject]@{
         Exception = $e.Exception.Message
         Reason    = $e.CategoryInfo.Reason
         Target    = $e.CategoryInfo.TargetName
         Script    = $e.InvocationInfo.ScriptName
         Line      = $e.InvocationInfo.ScriptLineNumber
         Column    = $e.InvocationInfo.OffsetInLine
      }

      # output information. Post-process collected info, and log info (optional)
      $info | Out-String | Write-Verbose

      $paramWriteError = @{
         Message      = $e.Exception.Message
         ErrorAction  = 'Continue'
         Exception    = $e.Exception
         TargetObject = $e.CategoryInfo.TargetName
      }
      Write-Error @paramWriteError
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
   - If you disagree with any of the terms, and any conditions declared: Just delete it and build your own solution
#>
#endregion DISCLAIMER
