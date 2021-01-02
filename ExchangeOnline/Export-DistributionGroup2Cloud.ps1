function Export-DistributionGroup2Cloud
{
   <#
      .SYNOPSIS
      Function to convert/migrate on-premises Exchange distribution group to a Cloud (Exchange Online) distribution group

      .DESCRIPTION
      Copies attributes of a synchronized group to a placeholder group and CSV file.
      After initial export of group attributes, the on-premises group can have the attribute "AdminDescription" set to "Group_NoSync" which will stop it from be synchronized.
      The "-Finalize" switch can then be used to write the addresses to the new group and convert the name.  The final group will be a cloud group with the same attributes as the previous but with the additional ability of being able to be "self-managed".
      Once the contents of the new group are validated, the on-premises group can be deleted.

      .PARAMETER Group
      Name of group to recreate.

      .PARAMETER CreatePlaceHolder
      Create placeholder DistributionGroup wit ha given name.

      .PARAMETER Finalize
      Convert a given placeholder group to final DistributionGroup.

      .PARAMETER ExportDirectory
      Export Directory for internal CSV handling.

      .EXAMPLE
      PS> Export-DistributionGroup2Cloud -Group "DL-Marketing" -CreatePlaceHolder

      Create the Placeholder for the distribution group "DL-Marketing"

      .EXAMPLE
      PS> Export-DistributionGroup2Cloud -Group "DL-Marketing" -Finalize

      Transform the Placeholder for the distribution group "DL-Marketing" to the real distribution group in the cloud

      .NOTES
      This function is based on the Recreate-DistributionGroup.ps1 script of Joe Palarchio

      License: BSD 3-Clause

      .LINK
      https://gallery.technet.microsoft.com/PowerShell-Script-to-Move-5c3cd668

      .LINK
      http://blogs.perficient.com/microsoft/?p=32092
   #>
   [CmdletBinding(ConfirmImpact = 'Low')]
   param
   (
      [Parameter(Mandatory,
         HelpMessage = 'Name of group to recreate.')]
      [string]
      $Group,
      [switch]
      $CreatePlaceHolder,
      [switch]
      $Finalize,
      [ValidateNotNullOrEmpty()]
      [string]
      $ExportDirectory = 'C:\scripts\PowerShell\exports\ExportedAddresses\'
   )

   begin
   {
      # Defaults
      $SCN = 'SilentlyContinue'
      $CNT = 'Continue'
      $STP = 'Stop'
   }

   process
   {
      If ($CreatePlaceHolder.IsPresent)
      {
         # Create the Placeholder
         If (((Get-DistributionGroup -Identity $Group -ErrorAction $SCN).IsValid) -eq $True)
         {
            # Splat to make it more human readable
            $paramGetDistributionGroup = @{
               Identity      = $Group
               ErrorAction   = $STP
               WarningAction = $CNT
            }
            try
            {
               $OldDG = (Get-DistributionGroup @paramGetDistributionGroup)
            }
            catch
            {
               $line = ($_.InvocationInfo.ScriptLineNumber)

               # Dump the Info
               Write-Warning -Message ('Error was in Line {0}' -f $line)

               # Dump the Error catched
               Write-Error -Message $_ -ErrorAction $STP

               # Something that should never be reached
               break
            }

            try
            {
               [IO.Path]::GetInvalidFileNameChars() | ForEach-Object -Process {
                  $Group = $Group.Replace($_, '_')
               }
            }
            catch
            {
               $line = ($_.InvocationInfo.ScriptLineNumber)

               # Dump the Info
               Write-Warning -Message ('Error was in Line {0}' -f $line)

               # Dump the Error catched
               Write-Error -Message $_ -ErrorAction $STP

               # Something that should never be reached
               break
            }

            $OldName = [string]$OldDG.Name
            $OldDisplayName = [string]$OldDG.DisplayName
            $OldPrimarySmtpAddress = [string]$OldDG.PrimarySmtpAddress
            $OldAlias = [string]$OldDG.Alias

            # Splat to make it more human readable
            $paramGetDistributionGroupMember = @{
               Identity      = $OldDG.Name
               ErrorAction   = $STP
               WarningAction = $CNT
            }
            try
            {
               $OldMembers = ((Get-DistributionGroupMember @paramGetDistributionGroupMember).Name)
            }
            catch
            {
               $line = ($_.InvocationInfo.ScriptLineNumber)

               # Dump the Info
               Write-Warning -Message ('Error was in Line {0}' -f $line)

               # Dump the Error catched
               Write-Error -Message $_ -ErrorAction $STP

               # Something that should never be reached
               break
            }

            If (!(Test-Path -Path $ExportDirectory -ErrorAction $SCN -WarningAction $CNT))
            {
               Write-Verbose -Message ('  Creating Directory: {0}' -f $ExportDirectory)

               # Splat to make it more human readable
               $paramNewItem = @{
                  ItemType      = 'directory'
                  Path          = $ExportDirectory
                  Force         = $True
                  Confirm       = $False
                  ErrorAction   = $STP
                  WarningAction = $CNT
               }
               try
               {
                  $null = (New-Item @paramNewItem)
               }
               catch
               {
                  $line = ($_.InvocationInfo.ScriptLineNumber)

                  # Dump the Info
                  Write-Warning -Message ('Error was in Line {0}' -f $line)

                  # Dump the Error catched
                  Write-Error -Message $_ -ErrorAction $STP

                  # Something that should never be reached
                  break
               }
            }

            # Define variables - mostly for future use
            $ExportDirectoryGroupCsv = $ExportDirectory + '\' + $Group + '.csv'

            try
            {
               # TODO: Refactor in future version
               'EmailAddress' > $ExportDirectoryGroupCsv
               $OldDG.EmailAddresses >> $ExportDirectoryGroupCsv
               'x500:' + $OldDG.LegacyExchangeDN >> $ExportDirectoryGroupCsv
            }
            catch
            {
               $line = ($_.InvocationInfo.ScriptLineNumber)

               # Dump the Info
               Write-Warning -Message ('Error was in Line {0}' -f $line)

               # Dump the Error catched
               Write-Error -Message $_ -ErrorAction $STP

               # Something that should never be reached
               break
            }

            # Define variables - mostly for future use
            $NewDistributionGroupName = 'Cloud- ' + $OldName
            $NewDistributionGroupAlias = 'Cloud-' + $OldAlias
            $NewDistributionGroupDisplayName = 'Cloud-' + $OldDisplayName
            $NewDistributionGroupPrimarySmtpAddress = 'Cloud-' + $OldPrimarySmtpAddress

            # TODO: Replace with Write-Verbose in future version of the function
            Write-Output -InputObject ('  Creating Group: {0}' -f $NewDistributionGroupDisplayName)

            # Splat to make it more human readable
            $paramNewDistributionGroup = @{
               Name               = $NewDistributionGroupName
               Alias              = $NewDistributionGroupAlias
               DisplayName        = $NewDistributionGroupDisplayName
               ManagedBy          = $OldDG.ManagedBy
               Members            = $OldMembers
               PrimarySmtpAddress = $NewDistributionGroupPrimarySmtpAddress
               ErrorAction        = $STP
               WarningAction      = $CNT
            }
            try
            {
               $null = (New-DistributionGroup @paramNewDistributionGroup)
            }
            catch
            {
               $line = ($_.InvocationInfo.ScriptLineNumber)
               # Dump the Info
               Write-Warning -Message ('Error was in Line {0}' -f $line)

               # Dump the Error catched
               Write-Error -Message $_ -ErrorAction $STP

               # Something that should never be reached
               break
            }

            # Wait for 3 seconds
            $null = (Start-Sleep -Seconds 3)

            # Define variables - mostly for future use
            $SetDistributionGroupIdentity = 'Cloud-' + $OldName
            $SetDistributionGroupDisplayName = 'Cloud-' + $OldDisplayName

            # TODO: Replace with Write-Verbose in future version of the function
            Write-Output -InputObject ('  Setting Values For: {0}' -f $SetDistributionGroupDisplayName)

            # Splat to make it more human readable
            $paramSetDistributionGroup = @{
               Identity                               = $SetDistributionGroupIdentity
               AcceptMessagesOnlyFromSendersOrMembers = $OldDG.AcceptMessagesOnlyFromSendersOrMembers
               RejectMessagesFromSendersOrMembers     = $OldDG.RejectMessagesFromSendersOrMembers
               ErrorAction                            = $STP
               WarningAction                          = $CNT
            }
            try
            {
               $null = (Set-DistributionGroup @paramSetDistributionGroup)
            }
            catch
            {
               $line = ($_.InvocationInfo.ScriptLineNumber)

               # Dump the Info
               Write-Warning -Message ('Error was in Line {0}' -f $line)

               # Dump the Error catched
               Write-Error -Message $_ -ErrorAction $STP

               # Something that should never be reached
               break
            }

            # Define variables - mostly for future use
            $SetDistributionGroupIdentity = 'Cloud-' + $OldName

            # Splat to make it more human readable
            $paramSetDistributionGroup = @{
               Identity                             = $SetDistributionGroupIdentity
               AcceptMessagesOnlyFrom               = $OldDG.AcceptMessagesOnlyFrom
               AcceptMessagesOnlyFromDLMembers      = $OldDG.AcceptMessagesOnlyFromDLMembers
               BypassModerationFromSendersOrMembers = $OldDG.BypassModerationFromSendersOrMembers
               BypassNestedModerationEnabled        = $OldDG.BypassNestedModerationEnabled
               CustomAttribute1                     = $OldDG.CustomAttribute1
               CustomAttribute2                     = $OldDG.CustomAttribute2
               CustomAttribute3                     = $OldDG.CustomAttribute3
               CustomAttribute4                     = $OldDG.CustomAttribute4
               CustomAttribute5                     = $OldDG.CustomAttribute5
               CustomAttribute6                     = $OldDG.CustomAttribute6
               CustomAttribute7                     = $OldDG.CustomAttribute7
               CustomAttribute8                     = $OldDG.CustomAttribute8
               CustomAttribute9                     = $OldDG.CustomAttribute9
               CustomAttribute10                    = $OldDG.CustomAttribute10
               CustomAttribute11                    = $OldDG.CustomAttribute11
               CustomAttribute12                    = $OldDG.CustomAttribute12
               CustomAttribute13                    = $OldDG.CustomAttribute13
               CustomAttribute14                    = $OldDG.CustomAttribute14
               CustomAttribute15                    = $OldDG.CustomAttribute15
               ExtensionCustomAttribute1            = $OldDG.ExtensionCustomAttribute1
               ExtensionCustomAttribute2            = $OldDG.ExtensionCustomAttribute2
               ExtensionCustomAttribute3            = $OldDG.ExtensionCustomAttribute3
               ExtensionCustomAttribute4            = $OldDG.ExtensionCustomAttribute4
               ExtensionCustomAttribute5            = $OldDG.ExtensionCustomAttribute5
               GrantSendOnBehalfTo                  = $OldDG.GrantSendOnBehalfTo
               HiddenFromAddressListsEnabled        = $True
               MailTip                              = $OldDG.MailTip
               MailTipTranslations                  = $OldDG.MailTipTranslations
               MemberDepartRestriction              = $OldDG.MemberDepartRestriction
               MemberJoinRestriction                = $OldDG.MemberJoinRestriction
               ModeratedBy                          = $OldDG.ModeratedBy
               ModerationEnabled                    = $OldDG.ModerationEnabled
               RejectMessagesFrom                   = $OldDG.RejectMessagesFrom
               RejectMessagesFromDLMembers          = $OldDG.RejectMessagesFromDLMembers
               ReportToManagerEnabled               = $OldDG.ReportToManagerEnabled
               ReportToOriginatorEnabled            = $OldDG.ReportToOriginatorEnabled
               RequireSenderAuthenticationEnabled   = $OldDG.RequireSenderAuthenticationEnabled
               SendModerationNotifications          = $OldDG.SendModerationNotifications
               SendOofMessageToOriginatorEnabled    = $OldDG.SendOofMessageToOriginatorEnabled
               BypassSecurityGroupManagerCheck      = $True
               ErrorAction                          = $STP
               WarningAction                        = $CNT
            }
            try
            {
               $null = (Set-DistributionGroup @paramSetDistributionGroup)
            }
            catch
            {
               $line = ($_.InvocationInfo.ScriptLineNumber)
               # Dump the Info
               Write-Warning -Message ('Error was in Line {0}' -f $line)

               # Dump the Error catched
               Write-Error -Message $_ -ErrorAction $STP

               # Something that should never be reached
               break
            }
         }
         Else
         {
            Write-Error -Message ('The distribution group {0} was not found' -f $Group) -ErrorAction $CNT
         }
      }
      ElseIf ($Finalize.IsPresent)
      {
         # Do the final steps

         # Define variables - mostly for future use
         $GetDistributionGroupIdentity = 'Cloud-' + $Group

         # Splat to make it more human readable
         $paramGetDistributionGroup = @{
            Identity      = $GetDistributionGroupIdentity
            ErrorAction   = $STP
            WarningAction = $CNT
         }
         try
         {
            $TempDG = (Get-DistributionGroup @paramGetDistributionGroup)
         }
         catch
         {
            $line = ($_.InvocationInfo.ScriptLineNumber)

            # Dump the Info
            Write-Warning -Message ('Error was in Line {0}' -f $line)

            # Dump the Error catched
            Write-Error -Message $_ -ErrorAction $STP

            # Something that should never be reached
            break
         }

         $TempPrimarySmtpAddress = $TempDG.PrimarySmtpAddress

         try
         {
            [IO.Path]::GetInvalidFileNameChars() | ForEach-Object -Process {
               $Group = $Group.Replace($_, '_')
            }
         }
         catch
         {
            $line = ($_.InvocationInfo.ScriptLineNumber)

            # Dump the Info
            Write-Warning -Message ('Error was in Line {0}' -f $line)

            # Dump the Error catched
            Write-Error -Message $_ -ErrorAction $STP

            # Something that should never be reached
            break
         }

         $OldAddressesPatch = $ExportDirectory + '\' + $Group + '.csv'

         # Splat to make it more human readable
         $paramImportCsv = @{
            Path          = $OldAddressesPatch
            ErrorAction   = $STP
            WarningAction = $CNT
         }
         try
         {
            $OldAddresses = @(Import-Csv @paramImportCsv)
         }
         catch
         {
            $line = ($_.InvocationInfo.ScriptLineNumber)

            # Dump the Info
            Write-Warning -Message ('Error was in Line {0}' -f $line)

            # Dump the Error catched
            Write-Error -Message $_ -ErrorAction $STP

            # Something that should never be reached
            break
         }

         try
         {
            $NewAddresses = $OldAddresses | ForEach-Object -Process {
               $_.EmailAddress.Replace('X500', 'x500')
            }
         }
         catch
         {
            $line = ($_.InvocationInfo.ScriptLineNumber)

            # Dump the Info
            Write-Warning -Message ('Error was in Line {0}' -f $line)

            # Dump the Error catched
            Write-Error -Message $_ -ErrorAction $STP

            # Something that should never be reached
            break
         }

         $NewDGName = $TempDG.Name.Replace('Cloud-', '')
         $NewDGDisplayName = $TempDG.DisplayName.Replace('Cloud-', '')
         $NewDGAlias = $TempDG.Alias.Replace('Cloud-', '')

         try
         {
            $NewPrimarySmtpAddress = ($NewAddresses | Where-Object -FilterScript {
                  $_ -clike 'SMTP:*'
               }).Replace('SMTP:', '')
         }
         catch
         {
            $line = ($_.InvocationInfo.ScriptLineNumber)
            # Dump the Info
            Write-Warning -Message ('Error was in Line {0}' -f $line)

            # Dump the Error catched
            Write-Error -Message $_ -ErrorAction $STP

            # Something that should never be reached
            break
         }

         # Splat to make it more human readable
         $paramSetDistributionGroup = @{
            Identity                        = $TempDG.Name
            Name                            = $NewDGName
            Alias                           = $NewDGAlias
            DisplayName                     = $NewDGDisplayName
            PrimarySmtpAddress              = $NewPrimarySmtpAddress
            HiddenFromAddressListsEnabled   = $False
            BypassSecurityGroupManagerCheck = $True
            ErrorAction                     = $STP
            WarningAction                   = $CNT
         }
         try
         {
            $null = (Set-DistributionGroup @paramSetDistributionGroup)
         }
         catch
         {
            $line = ($_.InvocationInfo.ScriptLineNumber)
            # Dump the Info
            Write-Warning -Message ('Error was in Line {0}' -f $line)

            # Dump the Error catched
            Write-Error -Message $_ -ErrorAction $STP

            # Something that should never be reached
            break
         }

         $paramSetDistributionGroup = @{
            Identity                        = $NewDGName
            EmailAddresses                  = @{
               Add = $NewAddresses
            }
            BypassSecurityGroupManagerCheck = $True
            ErrorAction                     = $STP
            WarningAction                   = $CNT
         }
         try
         {
            $null = (Set-DistributionGroup @paramSetDistributionGroup)
         }
         catch
         {
            $line = ($_.InvocationInfo.ScriptLineNumber)
            # Dump the Info
            Write-Warning -Message ('Error was in Line {0}' -f $line)

            # Dump the Error catched
            Write-Error -Message $_ -ErrorAction $STP

            # Something that should never be reached
            break
         }

         # Splat to make it more human readable
         $paramSetDistributionGroup = @{
            Identity                        = $NewDGName
            EmailAddresses                  = @{
               Remove = $TempPrimarySmtpAddress
            }
            BypassSecurityGroupManagerCheck = $True
            ErrorAction                     = $STP
            WarningAction                   = $CNT
         }
         try
         {
            $null = (Set-DistributionGroup @paramSetDistributionGroup)
         }
         catch
         {
            $line = ($_.InvocationInfo.ScriptLineNumber)

            # Dump the Info
            Write-Warning -Message ('Error was in Line {0}' -f $line)

            # Dump the Error catched
            Write-Error -Message $_ -ErrorAction $STP

            # Something that should never be reached
            break
         }
      }
      Else
      {
         Write-Error -Message "  ERROR: No options selected, please use '-CreatePlaceHolder' or '-Finalize'" -ErrorAction $STP

         # Something that should never be reached
         break
      }
   }

   end
   {
      <#
         From the original Script Author

         Name:        Recreate-DistributionGroup.ps1

         Version:     1.0

         Description: Copies attributes of a synchronized group to a placeholder group and CSV file.
         After initial export of group attributes, the on-premises group can have the attribute "AdminDescription" set to "Group_NoSync" which will stop it from be synchronized.
         The "-Finalize" switch can then be used to write the addresses to the new group and convert the name.  The final group will be a cloud group with the same attributes as the previous but with the additional ability of being able to be "self-managed".
         Once the contents of the new group are validated, the on-premises group can be deleted.

         Requires:    Remote PowerShell Connection to Exchange Online

         Author:      Joe Palarchio

         Usage:       Additional information on the usage of this script can found at the following blog post: http://blogs.perficient.com/microsoft/?p=32092

         Disclaimer:  This script is provided AS IS without any support. Please test in a lab environment prior to production use.
      #>
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
