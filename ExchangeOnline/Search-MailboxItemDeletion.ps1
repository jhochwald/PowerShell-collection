function Search-MailboxItemDeletion
{
   <#
      .SYNOPSIS
      Search for deletions in mailboxes

      .DESCRIPTION
      Search for deletions in mailboxes, single or all

      .PARAMETER Days
      Day (period) to search, max. 90 (or 30, based on your O365/M365 license).
      The default is 7 (for the last 7 days)
      Minimum is 1, maximum is 90. This will be checked

      .PARAMETER Mailbox
      Mailbox Address
      e.g. info@contoso.com

      .PARAMETER All
      Get all deletes, for all mailboxes

      .EXAMPLE
      PS C:\> Search-MailboxItemDeletion -All

      Get all deletes, for all mailboxes

      .EXAMPLE
      PS C:\> Search-MailboxItemDeletion -Days 2 | Where-Object -FilterScript { $PSItem.Folder -ne 'Deleted Items' }

      Get all deletes of the last 2 days, for all mailboxes, but we exclude one Folder.

      .EXAMPLE
      PS C:\> Search-MailboxItemDeletion -Days 7 | Where-Object -FilterScript { $PSItem.Folder -ne 'Deleted Items' }

      Get all deletes of the last 7 days, for all mailboxes, but we exclude one Folder.

      .EXAMPLE
      PS C:\> Search-MailboxItemDeletion -Days 30 | Where-Object -FilterScript { ($PSItem.Folder -ne 'Drafts') -and ($PSItem.Action -ne 'SoftDelete') }

      Get all deletes of the last 30 days, for all mailboxes, but we exclude one Folder and the 'SoftDelete' action

      .EXAMPLE
      PS C:\> Search-MailboxItemDeletion -Days 21 -All

      Get all deletes for the last 21 days, for all mailboxes

      .EXAMPLE
      PS C:\> Search-MailboxItemDeletion -All | Out-GridView

      Search for Deletions in all mailboxes and open the result in the GridView (e.g. for filtering)

      .EXAMPLE
      PS C:\> Search-MailboxItemDeletion -Mailbox 'info@contoso.com'

      Search for Deletions in the mailbox 'info@contoso.com'

      .EXAMPLE
      PS C:\> Search-MailboxItemDeletion -Mailbox 'info@contoso.com' | Select-Object -Property 'Timestamp', 'Action', 'Status' , 'User', 'Mailbox', 'Subject', 'Folder', 'Client', 'ClientIP'

      Search for Deletions in the mailbox 'info@contoso.com', and get a few more properties (e.g. Status, Client, and ClientIP).
      Might be handy to see from where it was triggered and what client was used.

      .EXAMPLE
      PS C:\> Search-MailboxItemDeletion -Mailbox 'info@contoso.com' | Export-CSV -NoTypeInformation -Path c:\scripts\PowerShell\exports\ExchangeOnlineMailboxDeletes.csv

      Search for Deletions in the mailbox 'info@contoso.com' and export the result into a CSV File (e.g. for a basic reporting or further investigation in Excel)

      .OUTPUTS
      array

      .LINK
      Search-UnifiedAuditLog

      .NOTES
      For now, the following properties are supported:
      Action            string
      AppId             string
      Client            string
      ClientIP          string
      External          bool
      ExternalAccess    bool
      Folder            string
      InternalLogonType int
      InternetMessageId string
      LogonType         int
      Mailbox           string
      MailboxGuid       string
      MessageId         string
      OrganizationId    string
      OrganizationName  string
      OriginatingServer string
      SessionId         string
      Status            string
      Subject           string
      TimeStamp         string
      User              string

      By default, the following properties are returned (all others can be selected):
      TimeStamp         string
      Action            string
      User              string
      Mailbox           string
      Subject           string
      Folder            string

      Requirements:
      PowerShell or Windows PowerShell
      Exchange Online connection (e.g. the installed Module and you need to be connected with a user that has rights to use Search-UnifiedAuditLog)

      A future version might support Wildcards in the Mailbox parameter and/or multi Mailbox searches.
      Workaround: use Where-Object with a powerful FilterScript!
   #>
   [CmdletBinding(DefaultParameterSetName = 'All',
      ConfirmImpact = 'None')]
   [OutputType([array])]
   param
   (
      [Parameter(ValueFromPipeline,
         ValueFromPipelineByPropertyName)]
      [ValidateNotNullOrEmpty()]
      [ValidateNotNull()]
      [int]
      $Days = 7,
      [Parameter(ParameterSetName = 'Single', HelpMessage = 'Mailbox Address e.g. info@contoso.com',
         Mandatory,
         ValueFromPipeline,
         ValueFromPipelineByPropertyName)]
      [ValidateNotNullOrEmpty()]
      [ValidateNotNull()]
      [Alias('MailboxName', 'MailboxAddress')]
      [string]
      $Mailbox,
      [Parameter(ParameterSetName = 'All')]
      [switch]
      $All
   )

   begin
   {
      # Garbage Collection
      [GC]::Collect()

      # Cleanup
      $Records = $null

      # TimeSpan
      $StartDate = (Get-Date).AddDays(-$Days)

      # Now
      $EndDate = (Get-Date)

      #region HelperFunctions
      function Get-StandardMembersFromPSObject
      {
         <#
            .SYNOPSIS
            Filter the given properties from a given Object

            .DESCRIPTION
            Filter the given properties from a given Object

            .PARAMETER InputObject
            The input object, must be a psobject.

            .PARAMETER Properties
            The properties to select from the given input object.
            Multiple values needs to separated by a comma.

            .EXAMPLE
            Get-StandardMembersFromPSObject -InputObject Value -Properties Value
            Describe what this call does

            .OUTPUTS
            psobject

            .NOTES
            Just an internal Helper function

            .LINK
            https://learn-powershell.net/2013/08/03/quick-hits-set-the-default-property-display-in-powershell-on-custom-objects/
            .LINK
            http://stackoverflow.com/questions/1369542/can-you-set-an-objects-defaultdisplaypropertyset-in-a-powershell-v2-script/1891215#1891215

            .INPUTS
            psobject, string
         #>
         [CmdletBinding(ConfirmImpact = 'None')]
         [OutputType([psobject])]
         param
         (
            [Parameter(Mandatory,
               ValueFromPipeline,
               ValueFromPipelineByPropertyName,
               HelpMessage = 'The input object, must be a psobject.')]
            [ValidateNotNull()]
            [ValidateNotNullOrEmpty()]
            [psobject]
            $InputObject,
            [Parameter(ValueFromPipeline,
               ValueFromPipelineByPropertyName)]
            [ValidateNotNull()]
            [ValidateNotNullOrEmpty()]
            [Alias('DefaultProperties')]
            [string[]]
            $Properties = $null
         )

         process
         {
            try
            {
               $defaultDisplayPropertySet = (New-Object -TypeName System.Management.Automation.PSPropertySet -ArgumentList ('DefaultDisplayPropertySet', [string[]]$Properties))
               $PSStandardMembers = ([Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet))
               $InputObject | Add-Member -MemberType MemberSet -Name PSStandardMembers -Value $PSStandardMembers -Force
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

               # output information. Post-process collected info, and log info (optional)
               $info | Out-String | Write-Verbose
               #endregion ErrorHandler
            }
         }
      }
      #endregion HelperFunctions
   }

   process
   {
      # Get the UnifiedAuditLog Data, with the delete operations
      $Records = (Search-UnifiedAuditLog -StartDate $StartDate -EndDate $EndDate -Operations 'HardDelete', 'SoftDelete')

      # Do we have a result
      if ($Records)
      {
         Write-Verbose -Message ('Processing ' + $Records.Count + ' audit records...')

         # Create a new Object
         $Report = [Collections.Generic.List[Object]]::new()

         foreach ($Rec in $Records)
         {
            $AuditData = (ConvertFrom-Json -InputObject $Rec.Auditdata)

            if ($AuditData.ResultStatus -eq 'PartiallySucceeded')
            {
               $MessageSubject = '# Not fully deleted by' + $AuditData.ClientInfoString + ' #'
            }
            else
            {
               $MessageSubject = ($AuditData.AffectedItems.Subject -split '\n')[0]
            }

            $ReportLine = [PSCustomObject] @{
               TimeStamp         = (Get-Date -Date ($AuditData.CreationTime) -Format g)
               User              = $AuditData.UserId
               Action            = $AuditData.Operation
               Status            = $AuditData.ResultStatus
               Mailbox           = $AuditData.MailboxOwnerUPN
               MailboxGuid       = $AuditData.MailboxGuid
               Subject           = $MessageSubject
               MessageId         = ($AuditData.AffectedItems.Id -split '\n')[0]
               InternetMessageId = ($AuditData.AffectedItems.InternetMessageId -split '\n')[0]
               Folder            = $AuditData.Folder.Path.Split('\')[1]
               Client            = $AuditData.ClientInfoString
               AppId             = $AuditData.AppId
               ClientIP          = $AuditData.ClientIP
               External          = $AuditData.ExternalAccess
               SessionId         = $AuditData.SessionId
               ExternalAccess    = $AuditData.ExternalAccess
               InternalLogonType = $AuditData.InternalLogonType
               LogonType         = $AuditData.LogonType
               OrganizationName  = $AuditData.OrganizationName
               OrganizationId    = $AuditData.OrganizationId
               OriginatingServer = $AuditData.OriginatingServer
            }

            # Define the default properties and support Select-Object
            Get-StandardMembersFromPSObject -InputObject $ReportLine -Properties 'Timestamp', 'Action', 'User', 'Mailbox', 'Subject', 'Folder'

            # Add to the reporting
            $Report.Add($ReportLine)
         }

         $Records = $null
      }
      else
      {
         Write-Output -InputObject 'No deletion records found.'
         break
      }

      # Create a new array object
      $Output = @()

      # Single or all ?
      switch ($PsCmdlet.ParameterSetName)
      {
         'Single'
         {
            $Output = ($Report | Where-Object -FilterScript {
                  # You might want to tweak the filter to support Wildcards or more the one mailbox
                  $PSItem.Mailbox -eq $Mailbox
               })
         }
         'All'
         {
            $Output = ($Report | Sort-Object -Property Mailbox)
         }
      }

      # Cleanup
      $Report = $null
   }

   end
   {
      # Just dump the result to the terminal
      $Output

      # Cleanup
      $Output = $null

      # Garbage Collection
      [GC]::Collect()
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
