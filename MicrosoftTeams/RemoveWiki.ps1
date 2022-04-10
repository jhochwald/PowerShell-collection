<#
      .SYNOPSIS
      Remove the Wiki tab on Microsoft Teams teams

      .DESCRIPTION
      Remove the Wiki tab on Microsoft Teams teams
      I like Teams, but I never use the Wiki within Teams.
      Alexander Holmeset figured out a smart way to get rid of the Wiki tab.

      .PARAMETER ClientId
      Azure AD Application (client) ID

      .PARAMETER TenantId
      Azure AD Tenant ID

      .PARAMETER ClientSecret
      Azure AD secret

      .EXAMPLE
      PS C:\> .\RemoveWiki.ps1 -ClientId 'Value1' -TenantId 'Value2' -ClientSecret 'Value3'

      .NOTES
      Original found in Alexander Holmeset's Blog
      My version starts to make it a bit more flexible (e.g. more parameters)

      .LINK
      https://alexholmeset.blog/2019/05/10/remove-the-wiki-tab/

      .LINK
      https://gist.github.com/AlexanderHolmeset/e40c7e9297ae9cc01cb832871a9ff770
#>
[CmdletBinding(ConfirmImpact = 'Low')]
param
(
   [Parameter(Mandatory,
      ValueFromPipeline,
      ValueFromPipelineByPropertyName,
      Position = 0,
      HelpMessage = 'Azure AD Application (client) ID')]
   [ValidateNotNullOrEmpty()]
   [Alias('OAuthClientId')]
   [string]
   $ClientId,
   [Parameter(Mandatory,
      ValueFromPipeline,
      ValueFromPipelineByPropertyName,
      Position = 1,
      HelpMessage = 'Azure AD Tenant ID')]
   [ValidateNotNullOrEmpty()]
   [Alias('OAuthTenantId')]
   [string]
   $TenantId,
   [Parameter(Mandatory,
      ValueFromPipeline,
      ValueFromPipelineByPropertyName,
      Position = 2,
      HelpMessage = 'Azure AD secret')]
   [ValidateNotNullOrEmpty()]
   [Alias('OAuthClientSecret')]
   [string]
   $ClientSecret
)

process
{
   # Contruct URI
   $uri = 'https://login.microsoftonline.com/' + $TenantId + '/oauth2/v2.0/token'

   try
   {
      # Construct Body
      $body1 = @{
         client_id     = $ClientId
         scope         = 'https://graph.microsoft.com/.default'
         client_secret = $ClientSecret
         grant_type    = 'client_credentials'
      }

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
   $token = ($tokenRequest.Content | ConvertFrom-Json).access_token

   # Just in case
   Write-Verbose -Message $token

   try
   {
      # URI to call
      $uri = 'https://graph.microsoft.com/v1.0/groups'
      $paramInvokeRestMethod = @{
         Method      = 'GET'
         Uri         = $uri
         ContentType = 'application/json'
         Headers     = @{
            Authorization = 'Bearer ' + $token
         }
         ErrorAction = 'Stop'
      }
      $query = (Invoke-RestMethod @paramInvokeRestMethod)
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

   # Extract the Value
   $groups = $query.value

   foreach ($group in $groups)
   {
      try
      {
         if ($group.resourceProvisioningOptions -contains 'Team')
         {
            # Extract the ID
            $id = $group.id

            # Build the URI
            $uri2 = 'https://graph.microsoft.com/v1.0/teams/' + $id + '/channels'

            $paramInvokeRestMethod = @{
               Method      = 'Get'
               Uri         = $uri2
               ContentType = 'application/json'
               Headers     = @{
                  Authorization = 'Bearer ' + $token
               }
            }
            $query2 = (Invoke-RestMethod @paramInvokeRestMethod)

            # Extract the Value
            $Channels = $query2.value

            foreach ($Channel in $Channels)
            {
               $id2 = $Channel.id
               $uri3 = 'https://graph.microsoft.com/v1.0/teams/' + $id + '/channels/' + $id2 + '/tabs'
               $paramInvokeRestMethod = @{
                  Method      = 'Get'
                  Uri         = $uri3
                  ContentType = 'application/json'
                  Headers     = @{
                     Authorization = 'Bearer ' + $token
                  }
               }
               $query3 = (Invoke-RestMethod @paramInvokeRestMethod)

               # Extract the Value
               $tabs = $query3.value

               # Find the Wiki Tab
               $WikiTabs = ($tabs | Where-Object -FilterScript {
                     $PSItem.displayname -eq 'Wiki'
                  })

               if ($WikiTabs)
               {
                  foreach ($wikitab in $WikiTabs)
                  {
                     # Extract the ID
                     $wikitabID = $wikitab.id

                     # Build the URI
                     $uri4 = 'https://graph.microsoft.com/v1.0/teams/' + $id + '/channels/' + $id2 + '/tabs/' + $wikitabID

                     $paramInvokeRestMethod = @{
                        Method      = 'DELETE'
                        Uri         = $uri4
                        ContentType = 'application/json'
                        Headers     = @{
                           Authorization = 'Bearer ' + $token
                        }
                     }
                     $query4 = (Invoke-RestMethod @paramInvokeRestMethod)

                     Write-Verbose -Message $query4

                     Write-Output -InputObject 'wikitab removed'
                  }
               }
            }
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
