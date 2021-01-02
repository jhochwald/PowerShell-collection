function Copy-ADGroupUserMembership
{
   <#
         .SYNOPSIS
         Copy the membership of a given group to another group in Active Directory

         .DESCRIPTION
         Copy the membership of a given group to another group in Active Directory.
         By default only the members of the Source Group will be copied to the Target Group.
         If the Parameter FULL is used, the members of the Target Group that are not a member of the Source Group will be removed.
         If the Parameter SYNC is used, the Membership is synced between both groups. If a User is Member of the Target Group only, this membership will be copied to the Source as well.

         .PARAMETER SourceGroup
         Source-Group Object.

         Specifies an Active Directory group object by providing one of the following values. The identifier in
         parentheses is the LDAP display name for the attribute.

         Distinguished Name

         Example: CN=saradavisreports,OU=europe,CN=users,DC=corp,DC=contoso,DC=com

         GUID (objectGUID)

         Example: 599c3d2e-f72d-4d20-8a88-030d99495f20

         Security Identifier (objectSid)

         Example: S-1-5-21-3165297888-301567370-576410423-1103

         Security Accounts Manager (SAM) Account Name (sAMAccountName)

         Example: saradavisreports

         The cmdlet searches the default naming context or partition to find the object. If two or more objects are
         found, the cmdlet returns a non-terminating error.

         This parameter can also get this object through the pipeline or you can set this parameter to an object
         instance.

         .PARAMETER TargetGroup
         Target-Group Object.

         Specifies an Active Directory group object by providing one of the following values. The identifier in
         parentheses is the LDAP display name for the attribute.

         Distinguished Name

         Example: CN=saradavisreports,OU=europe,CN=users,DC=corp,DC=contoso,DC=com

         GUID (objectGUID)

         Example: 599c3d2e-f72d-4d20-8a88-030d99495f20

         Security Identifier (objectSid)

         Example: S-1-5-21-3165297888-301567370-576410423-1103

         Security Accounts Manager (SAM) Account Name (sAMAccountName)

         Example: saradavisreports

         The cmdlet searches the default naming context or partition to find the object. If two or more objects are
         found, the cmdlet returns a non-terminating error.

         This parameter can also get this object through the pipeline or you can set this parameter to an object
         instance.

         .PARAMETER full
         Remove all memberships from the Targewt that does NOT exist in the the Source.

         .PARAMETER sync
         Synchronies the group membership between Source-Group and Target-Group.
         Even if a user is a member of the Target-Group only, it will be copied to the Source-Group as well.

         .EXAMPLE
         PS C:\> Copy-ADGroupUserMembership -SourceGroup 'Sales' -TargetGroup 'Salesforce'

         Copy the membership of the Group 'Sales' to 'Salesforce'

         .EXAMPLE
         PS C:\> Copy-ADGroupUserMembership -SourceGroup 'Sales' -TargetGroup 'Salesforce' -sync

         Copy the membership of the Group 'Sales' to 'Salesforce' and the other way around.
         All Memberships of 'Salesforce' that does NOT exist in 'Sales' will be created in 'Sales' as well.

         .EXAMPLE
         PS C:\> Copy-ADGroupUserMembership -SourceGroup 'Sales' -TargetGroup 'Salesforce' -full

         Copy the membership of the Group 'Sales' to 'Salesforce'.
         All Memberships of 'Salesforce' that does NOT exist in 'Sales' will be removed.

         .NOTES
         Initial AIT version of the function

         .LINK
         https://github.com/jhochwald/PowerShell-collection/

         .LINK
         Get-ADGroupMember

         .LINK
         Remove-ADGroupMember

         .LINK
         Add-ADGroupMember

         .LINK
         Copy-ADUserGroupMemberships
   #>
   [CmdletBinding(DefaultParameterSetName = 'default',
      ConfirmImpact = 'Low',
      SupportsShouldProcess)]
   param
   (
      [Parameter(Mandatory,
         ValueFromPipeline,
         ValueFromPipelineByPropertyName,
         Position = 0,
         HelpMessage = 'Source-Group Object.')]
      [ValidateNotNullOrEmpty()]
      [Alias('Source')]
      [string]
      $SourceGroup,
      [Parameter(Mandatory,
         ValueFromPipeline,
         ValueFromPipelineByPropertyName,
         Position = 1,
         HelpMessage = 'Target-Group Object.')]
      [ValidateNotNullOrEmpty()]
      [Alias('Target')]
      [string]
      $TargetGroup,
      [Parameter(ParameterSetName = 'full',
         ValueFromPipeline,
         ValueFromPipelineByPropertyName,
         Position = 2)]
      [Alias('RemoveTargetOnlyMembers')]
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
      if ($pscmdlet.ShouldProcess('Groups', 'Get information from Active Directory'))
      {
         try
         {
            $SourceMembers = (Get-ADGroupMember -Identity $SourceGroup -ErrorAction Stop | Select-Object -ExpandProperty distinguishedName | Sort-Object)
            $TargetMembers = (Get-ADGroupMember -Identity $TargetGroup -ErrorAction Stop | Select-Object -ExpandProperty distinguishedName | Sort-Object)

            # Check if we have any diferences
            if (($SourceMembers) -and ($TargetMembers))
            {
               # Yep, there are differences
               $Differences = (Compare-Object -ReferenceObject $SourceMembers -DifferenceObject $TargetMembers)
            }
            elseif (($SourceMembers) -and (-not($TargetMembers)))
            {
               # Target has no members
               $Differences = 'SourceOnly'
            }
            elseif (-not($SourceMembers))
            {
               # Source has no members
               Write-Error -Message ('{0} has no members!' -f $SourceGroup) -ErrorAction Stop
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
            if ($pscmdlet.ShouldProcess($TargetGroup, 'Set'))
            {
               if ($Differences)
               {
                  Write-Verbose -Message 'Remove Target-User from all groups where the Source-User is not a member of.'

                  $TargetOnlyMembers = ($Differences | Where-Object -Property SideIndicator -EQ -Value '=>')

                  if ($TargetOnlyMembers)
                  {
                     try
                     {
                        foreach ($TargetOnlyMember in $TargetOnlyMembers.InputObject)
                        {
                           Write-Verbose -Message ('Process: {0}' -f $TargetOnlyMember)

                           $paramRemoveADGroupMember = @{
                              Identity    = $TargetGroup
                              Members     = $TargetOnlyMember
                              ErrorAction = 'Stop'
                              Confirm     = $false
                           }
                           $null = (Remove-ADGroupMember @paramRemoveADGroupMember -Verbose)
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

                        Write-Warning -Message $e.Exception.Message -ErrorAction Continue -WarningAction Continue
                     }
                  }
                  else
                  {
                     Write-Verbose -Message 'No group difference found where the Target-User is a member and Source-User is not.'
                  }
               }
            }
         }
         'sync'
         {
            if ($pscmdlet.ShouldProcess($SourceGroup, 'Set'))
            {
               if ($Differences)
               {
                  Write-Verbose -Message 'Make the Source-user a Member of all Groups only the Target-User is a member of.'

                  $TargetOnlyMembers = ($Differences | Where-Object -Property SideIndicator -EQ -Value '=>')

                  if ($TargetOnlyMembers)
                  {
                     Write-Verbose -Message ('Process: {0}' -f $TargetOnlyMembers)

                     try
                     {
                        $paramAddADGroupMember = @{
                           Identity    = $SourceGroup
                           Members     = $TargetOnlyMembers.InputObject
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
                  else
                  {
                     Write-Verbose -Message 'No group difference found where the Target-User is a member and Source-User is not.'
                  }
               }
            }
         }
         'default'
         {
            # Do nothing special
         }
      }

      if ($pscmdlet.ShouldProcess($TargetGroup, 'Set'))
      {
         if ($Differences)
         {
            try
            {
               Write-Verbose -Message 'Process all Source-Group only members.'

               $paramAddADGroupMember = @{
                  Identity    = $TargetGroup
                  ErrorAction = 'Stop'
                  Confirm     = $false
               }

               if ($Differences -eq 'SourceOnly')
               {
                  # Target has no members
                  $paramAddADGroupMember.Members = $SourceMembers
               }
               else
               {
                  $paramAddADGroupMember.Members = ($Differences | Where-Object -Property SideIndicator -EQ -Value '<=' | Select-Object -ExpandProperty InputObject)
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
