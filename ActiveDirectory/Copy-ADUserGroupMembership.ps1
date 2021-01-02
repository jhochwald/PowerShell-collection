function Copy-ADUserGroupMembership
{
   <#
         .SYNOPSIS
         Copy group memberships from a given Source-User to a Target-User in Active Directory

         .DESCRIPTION
         Copy group memberships from a given Source-User to a Target-User in Active Directory.
         The function can also remove the Target-User from all groups where the Source-User is not a member off (optional) or make the Source-User a member of all groups where only the Target-User is a member of.

         .PARAMETER SourceUser
         Source-User Object.

         Specifies an Active Directory user object by providing one of the following property values.
         The identifier in parentheses is the LDAP display name for the attribute.

         Distinguished Name

         Example:  CN=SaraDavis,CN=Europe,CN=Users,DC=corp,DC=contoso,DC=com

         GUID (objectGUID)

         Example: 599c3d2e-f72d-4d20-8a88-030d99495f20

         Security Identifier (objectSid)

         Example: S-1-5-21-3165297888-301567370-576410423-1103

         SAM account name  (sAMAccountName)

         Example: saradavis

         .PARAMETER TargetUser
         Target-User Object.

         Specifies an Active Directory user object by providing one of the following property values.
         The identifier in parentheses is the LDAP display name for the attribute.

         Distinguished Name

         Example:  CN=SaraDavis,CN=Europe,CN=Users,DC=corp,DC=contoso,DC=com

         GUID (objectGUID)

         Example: 599c3d2e-f72d-4d20-8a88-030d99495f20

         Security Identifier (objectSid)

         Example: S-1-5-21-3165297888-301567370-576410423-1103

         SAM account name  (sAMAccountName)

         Example: saradavis

         .PARAMETER full
         Remove the Target User from all groups where the Source-User is not a member of.

         .PARAMETER sync
         Make the Source-User a member of all Groups where only the Target-User is a member of.

         .EXAMPLE
         PS C:\> Copy-ADUserGroupMembership -SourceUser 'johndoe' -TargetUser 'janedoe'

         Make janedoe a member of all groups where johndoe is a member of. Existing group memberships of janedoe will NOT be removed.

         .EXAMPLE
         PS C:\> Copy-ADUserGroupMembership -SourceUser 'johndoe' -TargetUser 'janedoe' -full

         Make janedoe a member of all groups where johndoe is a member of. Existing group memberships of janedoe WILL be removed.

         .EXAMPLE
         PS C:\> Copy-ADUserGroupMembership -SourceUser 'johndoe' -TargetUser 'janedoe' -sync

         Make janedoe a member of all groups where johndoe is a member of. Existing group memberships of janedoe WILL be applied to johndoe.
         Lets call this a reverse Full Sync :)

         .NOTES
         Initial AIT version of the function

         .LINK
         https://github.com/jhochwald/PowerShell-collection/

         .LINK
         Get-ADUser

         .LINK
         Remove-ADGroupMember

         .LINK
         Add-ADGroupMember

         .LINK
         Copy-ADGroupUserMemberships
   #>
   [CmdletBinding(DefaultParameterSetName = 'default',
      SupportsShouldProcess)]
   param
   (
      [Parameter(Mandatory,
         ValueFromPipeline,
         ValueFromPipelineByPropertyName,
         Position = 0,
         HelpMessage = 'Source-User Object.')]
      [ValidateNotNullOrEmpty()]
      [Alias('Source')]
      [string]
      $SourceUser,
      [Parameter(Mandatory,
         ValueFromPipeline,
         ValueFromPipelineByPropertyName,
         Position = 1,
         HelpMessage = 'Target-User Object.')]
      [ValidateNotNullOrEmpty()]
      [Alias('Target')]
      [string]
      $TargetUser,
      [Parameter(ParameterSetName = 'full',
         ValueFromPipeline,
         ValueFromPipelineByPropertyName,
         Position = 2)]
      [Alias('RemoveTargetOnlyGroups')]
      [switch]
      $full = $null,
      [Parameter(ParameterSetName = 'sync',
         ValueFromPipeline,
         ValueFromPipelineByPropertyName,
         Position = 2)]
      [Alias('MakeFullSync')]
      [switch]
      $sync = $null
   )

   begin
   {
      if ($pscmdlet.ShouldProcess('User', 'Get information from Active Directory'))
      {
         try
         {
            # Get the Target-User
            $TargetUserObject = (Get-ADUser -Identity $TargetUser -Properties memberOf -ErrorAction Stop)

            # Get the Source-User
            $SourceUserObject = (Get-ADUser -Identity $SourceUser -Properties memberOf -ErrorAction Stop)

            # Sort and save the information we collected above
            $SourceUserMembership = ($SourceUserObject.MemberOf | Sort-Object)
            $TargetUserMembership = ($TargetUserObject.MemberOf | Sort-Object)

            # Check if we have any diferences
            if (($SourceUserMembership) -and ($TargetUserMembership))
            {
               # Yep, there are differences
               $Differences = (Compare-Object -ReferenceObject $SourceUserMembership -DifferenceObject $TargetUserMembership)
            }
            else
            {
               # Nope, there are no differences
               $Differences = $null
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

            $info | Out-String | Write-Verbose

            Write-Error -Message $e.Exception.Message -ErrorAction Stop

            break
         }
      }
   }

   process
   {
      switch ($pscmdlet.ParameterSetName)
      {
         'full'
         {
            if ($pscmdlet.ShouldProcess($SourceUser, 'Set'))
            {
               if ($Differences)
               {
                  Write-Verbose -Message 'Remove Target-User from all groups where the Source-User is not a member of.'

                  $TargetOnlyGroups = ($Differences | Where-Object -Property SideIndicator -EQ -Value '=>')

                  if ($TargetOnlyGroups)
                  {
                     foreach ($TargetOnlyGroup in $TargetOnlyGroups.InputObject)
                     {
                        Write-Verbose -Message ('Process: {0}' -f $TargetOnlyGroup)

                        try
                        {
                           $paramRemoveADGroupMember = @{
                              Identity    = $TargetOnlyGroup
                              Members     = $TargetUser
                              ErrorAction = 'Stop'
                              Confirm     = $false
                           }
                           $null = (Remove-ADGroupMember @paramRemoveADGroupMember)
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

                           $info | Out-String | Write-Verbose

                           Write-Warning -Message $e.Exception.Message -ErrorAction Continue -WarningAction Continue
                        }
                     }
                  }
                  else
                  {
                     Write-Verbose -Message 'No group difference fround where the Target-User is a member and Source-User is not.'
                  }
               }
            }
         }
         'sync'
         {
            if ($pscmdlet.ShouldProcess($SourceUser, 'Set'))
            {
               if ($Differences)
               {
                  Write-Verbose -Message 'Make the Source-user a Member of all Groups only the Target-User is a member of.'

                  $TargetOnlyGroups = ($Differences | Where-Object -Property SideIndicator -EQ -Value '=>')

                  if ($TargetOnlyGroups)
                  {
                     foreach ($TargetOnlyGroup in $TargetOnlyGroups.InputObject)
                     {
                        Write-Verbose -Message ('Process: {0}' -f $TargetOnlyGroup)

                        try
                        {
                           $paramAddADGroupMember = @{
                              Identity    = $TargetOnlyGroup
                              Members     = $SourceUser
                              ErrorAction = 'Stop'
                              Confirm     = $false
                           }
                           $null = (Add-ADGroupMember @paramAddADGroupMember)
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

                           $info | Out-String | Write-Verbose

                           Write-Warning -Message $e.Exception.Message -ErrorAction Continue -WarningAction Continue
                        }
                     }
                  }
                  else
                  {
                     Write-Verbose -Message 'No group difference fround where the Target-User is a member and Source-User is not.'
                  }
               }
            }
         }
         'default'
         {
            # Do nothing special
         }
      }

      if ($pscmdlet.ShouldProcess($TargetUser, 'Set'))
      {
         if ($Differences)
         {
            $SourceOnlyGroups = ($Differences | Where-Object -Property SideIndicator -EQ -Value '<=')

            if ($SourceOnlyGroups)
            {
               Write-Verbose -Message 'Process all Groups where only the Source-user is a member of.'

               foreach ($SourceOnlyGroup in $SourceOnlyGroups.InputObject)
               {
                  Write-Verbose -Message ('Process: {0}' -f $SourceOnlyGroup)

                  try
                  {
                     $paramAddADGroupMember = @{
                        Identity    = $SourceOnlyGroup
                        Members     = $TargetUser
                        ErrorAction = 'Stop'
                        Confirm     = $false
                     }
                     $null = (Add-ADGroupMember @paramAddADGroupMember)
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

                     $info | Out-String | Write-Verbose

                     Write-Warning -Message $e.Exception.Message -ErrorAction Continue -WarningAction Continue
                  }
               }
            }
         }
         else
         {
            Write-Warning -Message 'No group difference fround where the Source-User is a member and Source-User is not.' -WarningAction Continue
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
