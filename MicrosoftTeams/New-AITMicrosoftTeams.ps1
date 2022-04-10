#requires -Version 3.0

<#
      .SYNOPSIS
      Creates a new Microsoft Teams team with the MicrosoftTeams Module.

      .DESCRIPTION
      Creates a new Microsoft Teams team with the MicrosoftTeams Module.
      The new team will be backed by a newly created unified group and SharePoint Online Site.

      The script depends on Microsoft's Version 0.9.6 of the MicrosoftTeams Module.
      Please note: Not all authentications methods of the latest MicrosoftTeams Module are supported!

      .PARAMETER msTeamsCreds
      Specifies a PSCredential object. For more information about the PSCredential object, type Get-Help Get-Credential.
      The PSCredential object provides the user ID and password for organizational ID credentials.

      .PARAMETER mfa
      Use the web based authentication. Supports MFA and prevents issues in non ADFS implementations.

      .PARAMETER DisplayName
      Todeam display name. Team Name Characters Limit is 256.

      .PARAMETER Alias
      Same as displayName without any spaces. Team Alias Characters Limit is 64

      .PARAMETER Description
      Team description. Team Description Characters Limit is 1024.

      .PARAMETER AccessType
      Team access type. Valid values are "Private" and "Public". Default is "Private". (This parameter has the same meaning as -AccessType in New-UnifiedGroup.)

      .PARAMETER AddCreatorAsMember
      This setting lets you decide if you will be added as a member of the team.  The default is false.

      .PARAMETER Owner
      UPN/Mail of the Teams Owner, multiple values are supported!

      .PARAMETER User
      member Users for the Group, Please use UPN or Mail.
      Multiple values are supported.

      .EXAMPLE
      PS C:\> .\New-AITMicrosoftTeams -mfa -DisplayName 'Contoso Support'

      Creates the Microsoft Team 'Contoso Support'. Uses Weblog (supports MFA)

      .EXAMPLE
      PS C:\> .\New-AITMicrosoftTeams -msTeamsCreds $O365 -DisplayName 'Contoso Support'

      Creates the Microsoft Team 'Contoso Support'. Uses existing credentials stored in the variable $O365 to authenticate.
      This might be the perfect way for automation, but use stored credentials might also be insecure.

      .EXAMPLE
      PS C:\> .\New-AITMicrosoftTeams -DisplayName 'Contoso Support'

      Creates the Microsoft Team 'Contoso Support'

      .EXAMPLE
      PS C:\> .\New-AITMicrosoftTeams -DisplayName 'Contoso Support' -Alias 'AITSupport'

      Creates the Microsoft Team 'Contoso Support' with an Alias 'AITSupport'

      .EXAMPLE
      PS C:\> .\New-AITMicrosoftTeams -DisplayName 'Contoso Info-pool' -AccessType 'public'

      Creates the Microsoft Team 'Contoso Info-pool', public mean open to join for every member of the organization.

      .EXAMPLE
      PS C:\> .\New-AITMicrosoftTeams -DisplayName 'Contoso Development' -Description 'Contoso IT Development Team' -Owner 'john.doe@acontoso.com'

      Creates the Microsoft Team 'Contoso Development', sets a description and add 'john.doe@contoso.com' as Owner.

      .EXAMPLE
      PS C:\> .\New-AITMicrosoftTeams -DisplayName 'Contoso Core Dev' -AddCreatorAsMember $true

      Creates the Microsoft Team 'Contoso Core Dev' and adds the creator to the new Team.

      .EXAMPLE
      PS C:\> Install-Module -Name MicrosoftTeams

      Install the dependency Module from Microsoft via PowerShellGet.

      .NOTES
      Releasenotes:
      1.0.3 2019-04-26: Fix Module Statement to use the correct version (0.9.6) to avoid issues with our workaround.
      1.0.2 2019-02-05: Reintroduce the -MFA switch to support the web based authentication. Prevent issues in non ADFS implementations.
      1.0.1 2019-02-04: Add workaround for AddCreatorAsMember Bug (Creator is added as owner all the time)
      1.0.0 2018-12-31: Internal Release

      THIS CODE IS MADE AVAILABLE AS IS, WITHOUT WARRANTY OF ANY KIND. THE ENTIRE RISK OF THE USE OR THE RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.

      Dependencies:
      The script depends on Microsoft's Version 0.9.6 of the MicrosoftTeams PowerShell Module.
      The MicrosoftTeams PowerShell Module GA Version (1.0.0) is not yet tested!

      Install it with PowerShellGet:
      PS C:\> Install-Module -Name MicrosoftTeams -RequiredVersion 0.9.6

      .LINK
      https://www.powershellgallery.com/packages/MicrosoftTeams/0.9.6

      .LINK
      https://aka.ms/InstallModule
#>
[CmdletBinding(DefaultParameterSetName = 'MFA',
   ConfirmImpact = 'None')]
param
(
   [Parameter(ParameterSetName = 'Credentials',
      ValueFromPipeline,
      ValueFromPipelineByPropertyName,
      Position = 0)]
   [System.Management.Automation.Credential()]
   [Alias('TeamsCredentials', 'TeamsAdminCredentials', 'Office365creds')]
   [pscredential]
   $msTeamsCreds,
   [Parameter(ParameterSetName = 'MFA',
      ValueFromPipeline,
      ValueFromPipelineByPropertyName,
      Position = 0)]
   [Alias('UseMFA')]
   [switch]
   $mfa,
   [Parameter(Mandatory,
      ValueFromPipeline,
      ValueFromPipelineByPropertyName,
      Position = 1,
      HelpMessage = 'Team display name.')]
   [ValidateNotNullOrEmpty()]
   [Alias('TeamsDisplayName')]
   [string]
   $DisplayName,
   [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName,
      Position = 2)]
   [Alias('TeamsAlias')]
   [string]
   $Alias,
   [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName,
      Position = 3)]
   [Alias('TeamsDescription')]
   [string]
   $Description,
   [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName,
      Position = 4)]
   [ValidateSet('HiddenMembership', 'Private', 'Public', IgnoreCase = $true)]
   [Alias('TeamsAccessType')]
   [string]
   $AccessType = 'Private',
   [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName,
      Position = 5)]
   [Alias('AddCreatorAsTeamsMember')]
   [switch]
   $AddCreatorAsMember = $false,
   [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName,
      Position = 6)]
   [Alias('TeamsOwner')]
   [string[]]
   $Owner,
   [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName,
      Position = 7)]
   [Alias('TeamsUser', 'TeamsMember')]
   [string[]]
   $User
)

begin
{
   #region VersionRequirement
   try
   {
      $paramRemoveModule = @{
         Name          = 'MicrosoftTeams'
         Force         = $true
         ErrorAction   = 'SilentlyContinue'
         WarningAction = 'SilentlyContinue'
      }
      $null = (Remove-Module @paramRemoveModule)

      $paramImportModule = @{
         Name           = 'MicrosoftTeams'
         MaximumVersion = '0.9.6'
         Force          = $true
         ErrorAction    = 'Stop'
         WarningAction  = 'SilentlyContinue'
      }
      $null = (Import-Module @paramImportModule)
   }
   catch
   {
      $paramWriteError = @{
         Message           = 'Microsoft´s Version 0.9.6 of the MicrosoftTeams PowerShell Module'
         ErrorAction       = 'Stop'
         Category          = 'NotInstalled'
         Exception         = 'Required Module not found'
         RecommendedAction = 'Please install Version 0.9.6 of the MicrosoftTeams PowerShell Module via Install-Module -Name MicrosoftTeams -RequiredVersion 0.9.6'
      }
      Write-Error @paramWriteError

      # Only here to catch a global ErrorAction overwrite
      break
   }
   #endregion VersionRequirement

   #region AuthChecker
   if (($msTeamsCreds) -and ($mfa))
   {
      $paramWriteError = @{
         Message     = 'You have selected muliple authentication methods. This is not valid'
         Exception   = 'Muliple authentication methods selected'
         Category    = 'AuthenticationError'
         ErrorAction = 'Stop'
      }
      Write-Error @paramWriteError

      # Only here to catch a global ErrorAction overwrite
      break
   }
   #endregion AuthChecker

   #region Defaults
   #region AccessType
   if (-not ($AccessType))
   {
      $AccessType = 'Private'
   }
   #endregion AccessType

   #region AddCreatorAsMember
   if (-not ($AddCreatorAsMember))
   {
      $AddCreatorAsMember = $false
   }
   #endregion AddCreatorAsMember
   #endregion defaults
}

process
{
   if ($pscmdlet.ShouldProcess($DisplayName, 'Create'))
   {
      try
      {
         #region Authentication
         if (-not ($mfa))
         {
            #region CredentialHandler
            if (-not ($msTeamsCreds))
            {
               # Get the credentials / Use it within the script only
               $script:msTeamsCreds = (Get-Credential -Message 'Please use credentials with Teams Admin capabilities.')
            }
            #endregion CredentialHandler

            #region ConnectMicrosoftTeams
            $paramConnectMicrosoftTeams = @{
               Credential  = $msTeamsCreds
               Confirm     = $false
               ErrorAction = 'Stop'
            }
            $null = (Connect-MicrosoftTeams @paramConnectMicrosoftTeams)
            #endregion ConnectMicrosoftTeams
         }
         else
         {
            #region ConnectMicrosoftTeams
            # Use the Web login
            $paramConnectMicrosoftTeams = @{
               Confirm     = $false
               ErrorAction = 'Stop'
            }
            $null = (Connect-MicrosoftTeams @paramConnectMicrosoftTeams)
            #endregion ConnectMicrosoftTeams
         }
         #endregion Authentication

         #region NewTeam
         #region SplatDefaults
         $paramNewTeam = @{
            DisplayName = $DisplayName
            Visibility  = $AccessType
            ErrorAction = 'Stop'
         }
         #endregion SplatDefaults

         #region Optionals
         if (($msTeamsCreds.UserName) -and ($AddCreatorAsMember -eq $true))
         {
            $paramNewTeam | Add-Member -MemberType NoteProperty -Name Owner -Value $msTeamsCreds.UserName
         }

         if ($Alias)
         {
            $paramNewTeam | Add-Member -MemberType NoteProperty -Name Alias -Value $Alias
         }

         if ($Description)
         {
            $paramNewTeam | Add-Member -MemberType NoteProperty -Name Description -Value $Description
         }
         #region Optionals

         #region CreateTeam
         $NewTeam = (New-Team @paramNewTeam)
         #endregion CreateTeam

         if (-not ($NewTeam.GroupId))
         {
            Write-Error -Message ('Error while try to create {0}' -f $DisplayName)
         }
         else
         {
            Write-Verbose -Message "The new Team id is $($NewTeam.GroupId)"

            #region BugWorkAround
            #BUG: There is a bug in the AddCreatorAsMember implemntation of Microsoft
            if ($AddCreatorAsMember -eq $false)
            {
               Write-Verbose -Message 'Workaround: Workaround for the AddCreatorAsMember of the Microsoft MicrosoftTeams Module'
               Remove-TeamUser -GroupId $NewTeam.GroupId -User $msTeamsCreds.UserName -ErrorAction SilentlyContinue
            }
            #endregion BugWorkAround

            #region SetOwner
            if ($Owner)
            {
               foreach ($Admin in $Owner)
               {
                  try
                  {
                     $paramAddTeamUser = @{
                        GroupId     = $NewTeam.GroupId
                        User        = $Admin
                        Role        = 'Owner'
                        ErrorAction = 'Stop'
                     }
                     $null = (Add-TeamUser @paramAddTeamUser)
                  }
                  catch
                  {
                     Write-Warning -Message ('Unable to add {0} as owner to the Team {1}' -f $Admin, $DisplayName)
                  }
               }
            }
            else
            {
               Write-Warning -Message ('The Team {0} has no owner!' -f $DisplayName)
            }
            #endregion SetOwner

            #region Setmember
            if ($User)
            {
               foreach ($Member in $User)
               {
                  try
                  {
                     $paramAddTeamUser = @{
                        GroupId     = $NewTeam.GroupId
                        User        = $Member
                        Role        = 'Member'
                        ErrorAction = 'Stop'
                     }
                     $null = (Add-TeamUser @paramAddTeamUser)
                  }
                  catch
                  {
                     Write-Warning -Message ('Unable to add {0} as member to the Team {1}' -f $Member, $DisplayName)
                  }
               }
            }
            #endregion Setmember
         }
         #endregion NewTeam
      }
      catch
      {
         #region ErrorHandler
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

         $info | Out-String | Write-Verbose

         Write-Error -Message ($info.Exception) -ErrorAction Stop

         # Only here to catch a global ErrorAction overwrite
         break
         #endregion ErrorHandler
      }
      finally
      {
         #region Cleanup
         $null = (Disconnect-MicrosoftTeams -Confirm:$false)
         #endregion Cleanup
      }
   }
}

end
{
   Write-Verbose -Message ('Created the Team {0}' -f $DisplayName)
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
