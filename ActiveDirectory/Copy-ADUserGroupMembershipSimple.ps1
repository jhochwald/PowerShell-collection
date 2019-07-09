function Copy-ADUserGroupMembershipSimple
{
   <#
         .SYNOPSIS
         Copy group memberships from a given Source User to a Target User(s) in Active Directory

         .DESCRIPTION
         Copy group memberships from a given Source User to a Target User(s) in Active Directory.
         Simple Version of Copy-ADUserGroupMemberships

         .PARAMETER SourceUser
         Source-User Object.

         Specifies an Active Directory group object by providing one of the following values.
         The identifier in parentheses is the LDAP display name for the attribute.

         Distinguished Name
         Example: CN=johndoe,OU=europe,CN=users,DC=corp,DC=contoso,DC=com

         GUID (objectGUID)
         Example: 599c3d2e-f72d-4d20-8a88-030d99495f20

         Security Identifier (objectSid)
         Example: S-1-5-21-3165297888-301567370-576410423-1103

         Security Accounts Manager (SAM) Account Name (sAMAccountName)
         Example: johndoe

         .PARAMETER TargetUser
         Target-User Object.

         Specifies an Active Directory group object by providing one of the following values.
         The identifier in parentheses is the LDAP display name for the attribute.

         Distinguished Name
         Example: CN=janedoe,OU=europe,CN=users,DC=corp,DC=contoso,DC=com

         GUID (objectGUID)
         Example: 599c3d2e-f72d-4d20-8a88-030d99495f20

         Security Identifier (objectSid)
         Example: S-1-5-21-3165297888-301567370-576410423-1103

         Security Accounts Manager (SAM) Account Name (sAMAccountName)
         Example: janedoe

         .PARAMETER PassThru
         Use the -PassThru parameter with the previous command to receive feedback about what groups the Target is being added as a member of.

         .EXAMPLE
         PS C:\> Copy-ADUserGroupMembershipSimple -SourceUser 'SourceUser' -TargetUser 'TargetUser'

         Copy group memberships from SourceUser to TargetUser

         .EXAMPLE
         PS C:\> Copy-ADUserGroupMembershipSimple -SourceUser 'SourceUser' -TargetUser 'TargetUser1', 'TargetUser2'

         Copy group memberships from SourceUser to TargetUser1 and TargetUser2

         .EXAMPLE
         PS C:\> Copy-ADUserGroupMembershipSimple -SourceUser 'SourceUser' -TargetUser 'TargetUser' -PassThru

         Use the -PassThru parameter with the previous command to receive feedback about what groups the Target is being added as a member of.

         .NOTES
         Version: 1.0.0

         GUID: 71152a07-f167-44ff-bf1b-f0f7a0149717

         Author: Joerg Hochwald

         Companyname: enabling Technology

         Copyright: Copyright (c) 2019, enabling Technology - All rights reserved.

         License: https://opensource.org/licenses/BSD-3-Clause

         Releasenotes:
         1.0.0 2019-07-09: Initial Release

         THIS CODE IS MADE AVAILABLE AS IS, WITHOUT WARRANTY OF ANY KIND. THE ENTIRE RISK OF THE USE OR THE RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.

         .LINK
         Copy-ADUserGroupMemberships

         .LINK
         https://github.com/jhochwald/PowerShell-collection/

         .LINK
         Get-ADUser

         .LINK
         Add-ADGroupMember
   #>

   [CmdletBinding(ConfirmImpact = 'Low',
   SupportsShouldProcess = $true)]
   param
   (
      [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0,
      HelpMessage = 'Source-User Object.')]
      [ValidateNotNullOrEmpty()]
      [Alias('Source')]
      [string]
      $SourceUser,
      [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1,
      HelpMessage = 'Target-User Object.')]
      [ValidateNotNullOrEmpty()]
      [Alias('Target')]
      [string[]]
      $TargetUser,
      [Parameter(ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
      Position = 2)]
      [switch]
      $PassThru = $null
   )

   process
   {
      if ($pscmdlet.ShouldProcess($TargetUser, 'Modify/add Group Membership'))
      {
         try
         {
            $paramGetADUser = @{
               Identity   = $SourceUser
               Properties = 'memberof'
               Verbose    = $(if ($pscmdlet.MyInvocation.BoundParameters['Verbose'].IsPresent)
                  {
                     $true
                  }
                  else
                  {
                     $false
                  }
               )
            }

            $paramAddADGroupMember = @{
               Members  = $TargetUser
               Verbose  = $(if ($pscmdlet.MyInvocation.BoundParameters['Verbose'].IsPresent)
                  {
                     $true
                  }
                  else
                  {
                     # Workaround: If not present it is empty not false
                     $false
                  }
               )
               PassThru = $(if ($pscmdlet.MyInvocation.BoundParameters['PassThru'].IsPresent)
                  {
                     $true
                  }
                  else
                  {
                     # Workaround: If not present it is empty not false
                     $false
                  }
               )
            }

            if (($pscmdlet.MyInvocation.BoundParameters['PassThru'].IsPresent))
            {
               # Show the output / PassThru in a nice format
               ((Get-ADUser @paramGetADUser) | Select-Object -ExpandProperty memberof | Add-ADGroupMember @paramAddADGroupMember | Select-Object -ExpandProperty SamAccountName)
            }
            else
            {
               # Do not show any output / Verbose will be shown
               $null = ((Get-ADUser @paramGetADUser) | Select-Object -ExpandProperty memberof | Add-ADGroupMember @paramAddADGroupMember)
            }
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

            Write-Verbose -Message $info

            Write-Error -Message ($info.Exception) -ErrorAction Stop

            # Only here to catch a global ErrorAction overwrite
            break
            #endregion ErrorHandler
         }
      }
   }
}
