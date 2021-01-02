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

            $info | Out-String | Write-Verbose

            Write-Error -Message ($info.Exception) -ErrorAction Stop

            # Only here to catch a global ErrorAction overwrite
            break
            #endregion ErrorHandler
         }
      }
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
