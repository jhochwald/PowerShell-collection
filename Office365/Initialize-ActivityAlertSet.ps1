function Initialize-ActivityAlertSet
{
   <#
         .SYNOPSIS
         Create good practice Ruleset of Office 365 Activity Alert's

         .DESCRIPTION
         Create good practice Ruleset of Office 365 Activity Alert's
         You need a PowerShell connection to the Security and Compliance Center

         .PARAMETER NotifyUser
         The NotifyUser parameter specifies the email addresses for notification messages.
         You can specify internal and external email addresses (even mix them).
         You can specify multiple email addresses separated by commas.

         .PARAMETER UserId
         The UserId parameter specifies who you want to monitor.
         If you specify a user's email address, you'll receive an email notification when the user performs the specified activity.
         You can specify multiple email addresses separated by commas.

         If this parameter is blank ($null), you'll receive an email notification when any user in your organization performs the specified activity.

         Default is $null (Activity alert is triggered for any user)

         .PARAMETER EmailCulture
         The EmailCulture parameter specifies the language of the notification email message.
         Valid input for this parameter is a supported culture code value from the Microsoft .NET Framework CultureInfo class.
         For example, de-DE for German, da-DK for Danish or ja-JP for Japanese.

         The default is en-US

         .EXAMPLE
         PS C:\> Initialize-ActivityAlertSet -NotifyUser 'alert@contoso.com'

         Create good practice Ruleset of Office 365 Activity Alert's and send all alters to 'alert@contoso.com'

         .EXAMPLE
         PS C:\> Initialize-ActivityAlertSet -NotifyUser 'alert@contoso.com -UserId 'john.doe@contoso.com'

         Create good practice Ruleset of Office 365 Activity Alert's and send all alters to 'alert@contoso.com',
         only monitor the user 'john.doe@contoso.com'

         .EXAMPLE
         PS C:\> Initialize-ActivityAlertSet -NotifyUser 'alert@contoso.com -UserId 'john.doe@contoso.com' -EmailCulture 'de-DE'

         Create good practice Ruleset of Office 365 Activity Alert's and send all alters to 'alert@contoso.com',
         only monitor the user 'john.doe@contoso.com' and send all alters in German!

         .EXAMPLE
         PS C:\> Initialize-ActivityAlertSet -NotifyUser 'alert@contoso.com -UserId 'john.doe@contoso.com', 'jane.doe@contoso.com'

         Create good practice Ruleset of Office 365 Activity Alert's and send all alters to 'alert@contoso.com',
         only monitor the users 'john.doe@contoso.com' and 'jane.doe@contoso.com'

         .NOTES
         Please Review all the settings carefully before your run the script!

         You must have a connection to the following Office 365 services:
         - Security and Compliance Center

         All features should work with your default Office 365 Enterprise plan. Business plans are not tested!

         PLEASE NOTE:
         This is really just a basic setup. It does NOT replace an security advice by a security consultant!

         .LINK
         New-ActivityAlert
   #>
   [CmdletBinding(ConfirmImpact = 'Low')]
   param
   (
      [Parameter(Mandatory,
         ValueFromPipeline,
         ValueFromPipelineByPropertyName,
         HelpMessage = 'The NotifyUser parameter specifies the email addressesfor notification messages.')]
      [ValidateNotNullOrEmpty()]
      [Alias('AlertMail')]
      [string[]]
      $NotifyUser,
      [Parameter(ValueFromPipeline,
         ValueFromPipelineByPropertyName)]
      [AllowEmptyCollection()]
      [AllowEmptyString()]
      [AllowNull()]
      [string[]]
      $UserId = $null,
      [Parameter(ValueFromPipeline,
         ValueFromPipelineByPropertyName)]
      [ValidateNotNullOrEmpty()]
      [cultureinfo]
      $EmailCulture = 'en-US'
   )

   begin
   {
      if (-not (Get-Command -Name New-ProtectionAlert))
      {
         Write-Error -Exception 'Not connected to the Office 365 Security & Compliance Center' -Message 'Use ''Connect-IPPSSession'' to connect to the Office 365 Security & Compliance Center' -Category OperationStopped -RecommendedAction 'Use ''Connect-IPPSSession'' to connect to the Office 365 Security & Compliance Center' -ErrorAction Stop
         exit 1
      }

      Write-Output -InputObject "Create good practice Ruleset of Office 365 Activity Alert's"
   }

   process
   {
      #region
      try
      {
         $paramNewActivityAlert = @{
            Name          = 'File and Page Alert'
            Operation     = 'Filemalwaredetected'
            NotifyUser    = $NotifyUser
            UserId        = $UserId
            EmailCulture  = $EmailCulture
            Description   = 'SharePoint anti-virus engine detects malware in a file.'
            Severity      = 'Low'
            Type          = 'Custom'
            ErrorAction   = 'Stop'
            WarningAction = 'Continue'
            Category      = 'ThreatManagement'
         }
         $null = (New-ActivityAlert @paramNewActivityAlert)
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

         Write-Warning -Message $info.Exception -WarningAction Continue -ErrorAction SilentlyContinue
      }
      #endregion

      #region
      try
      {
         $paramNewActivityAlert = @{
            Name          = 'Anonymous Links Alert'
            Operation     = 'Anonymouslinkcreated', 'Anonymouslinkupdated'
            NotifyUser    = $NotifyUser
            UserId        = $UserId
            EmailCulture  = $EmailCulture
            Description   = "An anonymous link (also called an 'Anyone' link) was created/updated for a resource."
            Severity      = 'High'
            Type          = 'Custom'
            ErrorAction   = 'Stop'
            WarningAction = 'Continue'
            Category      = 'DataLossPrevention'
         }
         $null = (New-ActivityAlert @paramNewActivityAlert)
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

         Write-Warning -Message $info.Exception -WarningAction Continue -ErrorAction SilentlyContinue
      }
      #endregion

      #region
      try
      {
         $paramNewActivityAlert = @{
            Name          = 'Anonymous Links Access Alert'
            Operation     = 'Anonymouslinkused'
            NotifyUser    = $NotifyUser
            UserId        = $UserId
            EmailCulture  = $EmailCulture
            Description   = "An anonymous link (also called an 'Anyone' link) was used for a resource."
            Severity      = 'High'
            Type          = 'Custom'
            ErrorAction   = 'Stop'
            WarningAction = 'Continue'
            Category      = 'DataLossPrevention'
         }
         $null = (New-ActivityAlert @paramNewActivityAlert)
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

         Write-Warning -Message $info.Exception -WarningAction Continue -ErrorAction SilentlyContinue
      }
      #endregion

      #region
      try
      {
         $paramNewActivityAlert = @{
            Name          = 'Sharing Alert'
            Operation     = 'Sharinginvitationcreated', 'Sharingpolicychanged'
            NotifyUser    = $NotifyUser
            UserId        = $UserId
            EmailCulture  = $EmailCulture
            Description   = "User shared a resource in SharePoint Online or OneDrive for Business with a user who isn't in your organization's directory. A SharePoint or global administrator changed a SharePoint sharing policy."
            Severity      = 'Low'
            Type          = 'Custom'
            ErrorAction   = 'Stop'
            WarningAction = 'Continue'
            Category      = 'DataLossPrevention'
         }
         $null = (New-ActivityAlert @paramNewActivityAlert)
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

         Write-Warning -Message $info.Exception -WarningAction Continue -ErrorAction SilentlyContinue
      }
      #endregion

      #region
      try
      {
         $paramNewActivityAlert = @{
            Name          = 'Access Alert'
            Operation     = 'Deviceaccesspolicychanged', 'Networkaccesspolicychanged'
            NotifyUser    = $NotifyUser
            UserId        = $UserId
            EmailCulture  = $EmailCulture
            Description   = 'Change in the unmanaged devices policy. Change in the location-based access policy (also called a trusted network boundary).'
            Severity      = 'Low'
            Type          = 'Custom'
            ErrorAction   = 'Stop'
            WarningAction = 'Continue'
         }
         $null = (New-ActivityAlert @paramNewActivityAlert)
      }
      catch
      {

      }
      #endregion

      #region
      try
      {
         $paramNewActivityAlert = @{
            Name          = 'Site Alert'
            Operation     = 'Sitecollectioncreated', 'Sitedeleted', 'Sitecollectionadminadded'
            NotifyUser    = $NotifyUser
            UserId        = $UserId
            EmailCulture  = $EmailCulture
            Description   = 'Creation of a new site collection OneDrive for Business site provisioned. A site was deleted.Site collection administrator or owner adds a person as a site collection administrator for a site.'
            Severity      = 'Low'
            Type          = 'Custom'
            ErrorAction   = 'Stop'
            WarningAction = 'Continue'
            Category      = 'DataGovernance'
         }
         $null = (New-ActivityAlert @paramNewActivityAlert)
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

         Write-Warning -Message $info.Exception -WarningAction Continue -ErrorAction SilentlyContinue
      }
      #endregion

      #region
      try
      {
         $paramNewActivityAlert = @{
            Name          = 'Office Alert'
            Operation     = 'Officeondemandset'
            NotifyUser    = $NotifyUser
            UserId        = $UserId
            EmailCulture  = $EmailCulture
            Description   = 'Site administrator enables Office on Demand, which lets users access the latest version of Office desktop applications.'
            Severity      = 'Low'
            Type          = 'Custom'
            ErrorAction   = 'Stop'
            WarningAction = 'Continue'
            Category      = 'Others'
         }
         $null = (New-ActivityAlert @paramNewActivityAlert)
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

         Write-Warning -Message $info.Exception -WarningAction Continue -ErrorAction SilentlyContinue
      }
      #endregion

      #region
      try
      {
         $paramNewActivityAlert = @{
            Name          = 'Mailbox Alert'
            Operation     = 'Add-MailboxPermission', 'Remove-MailboxPermission'
            NotifyUser    = $NotifyUser
            UserId        = $UserId
            EmailCulture  = $EmailCulture
            Description   = "An administrator assigned/removed the FullAccess mailbox permission to a user (known as a delegate) to another person`'s mailbox"
            Severity      = 'Medium'
            Type          = 'Custom'
            ErrorAction   = 'Stop'
            WarningAction = 'Continue'
            Category      = 'AccessGovernance'
         }
         $null = (New-ActivityAlert @paramNewActivityAlert)
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

         Write-Warning -Message $info.Exception -WarningAction Continue -ErrorAction SilentlyContinue
      }
      #endregion

      #region
      try
      {
         $paramNewActivityAlert = @{
            Name          = 'Password Alert'
            Operation     = 'Change user password.', 'Reset user password.', 'Set force change user password.'
            NotifyUser    = $NotifyUser
            UserId        = $UserId
            EmailCulture  = $EmailCulture
            Description   = 'User password changes'
            Severity      = 'Medium'
            Type          = 'Custom'
            ErrorAction   = 'Stop'
            WarningAction = 'Continue'
            Category      = 'ThreatManagement'
         }
         $null = (New-ActivityAlert @paramNewActivityAlert)
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

         Write-Warning -Message $info.Exception -WarningAction Continue -ErrorAction SilentlyContinue
      }
      #endregion

      #region
      try
      {
         $paramNewActivityAlert = @{
            Name          = 'Role Alert'
            Operation     = 'Add member to role.', 'Remove member from role.'
            NotifyUser    = $NotifyUser
            UserId        = $UserId
            EmailCulture  = $EmailCulture
            Description   = 'Added/Removed a user to an admin role in Office 365.'
            Severity      = 'Medium'
            Type          = 'Custom'
            ErrorAction   = 'Stop'
            WarningAction = 'Continue'
            Category      = 'AccessGovernance'
         }
         $null = (New-ActivityAlert @paramNewActivityAlert)
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

         Write-Warning -Message $info.Exception -WarningAction Continue -ErrorAction SilentlyContinue
      }
      #endregion

      #region
      try
      {
         $paramNewActivityAlert = @{
            Name          = 'Company Information Alert'
            Operation     = 'Set company contact information.', 'Set company information.', 'Set password policy.', 'Remove partner from company.'
            NotifyUser    = $NotifyUser
            UserId        = $UserId
            EmailCulture  = $EmailCulture
            Description   = 'Change company information or password policy'
            Severity      = 'Medium'
            Type          = 'Custom'
            ErrorAction   = 'Stop'
            WarningAction = 'Continue'
            Category      = 'DataGovernance'
         }
         $null = (New-ActivityAlert @paramNewActivityAlert)
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

         Write-Warning -Message $info.Exception -WarningAction Continue -ErrorAction SilentlyContinue
      }
      #endregion

      #region
      try
      {
         $paramNewActivityAlert = @{
            Name          = 'Domain Alert'
            Operation     = 'Add domain to company.', 'Update domain.'
            NotifyUser    = $NotifyUser
            UserId        = $UserId
            EmailCulture  = $EmailCulture
            Description   = 'Change of a custom domain in a tenant'
            Severity      = 'Low'
            Type          = 'Custom'
            ErrorAction   = 'Stop'
            WarningAction = 'Continue'
            Category      = 'DataGovernance'
         }
         $null = (New-ActivityAlert @paramNewActivityAlert)
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

         Write-Warning -Message $info.Exception -WarningAction Continue -ErrorAction SilentlyContinue
      }
      #endregion

      #region
      try
      {
         $paramNewActivityAlert = @{
            Name          = 'Domain Remove Alert'
            Operation     = 'Remove domain from company.'
            NotifyUser    = $NotifyUser
            UserId        = $UserId
            EmailCulture  = $EmailCulture
            Description   = 'Remove of a custom domain in a tenant'
            Severity      = 'Medium'
            Type          = 'Custom'
            ErrorAction   = 'Stop'
            WarningAction = 'Continue'
            Category      = 'DataGovernance'
         }
         $null = (New-ActivityAlert @paramNewActivityAlert)
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

         Write-Warning -Message $info.Exception -WarningAction Continue -ErrorAction SilentlyContinue
      }
      #endregion

      #region
      try
      {
         $paramNewActivityAlert = @{
            Name          = 'First and Second Stage Recycle Bin'
            Operation     = @('filedeletedfirststagerecyclebin', 'filedeletedsecondstagerecyclebin', 'folderdeletedfirststagerecyclebin', 'folderdeletedsecondstagerecyclebin')
            NotifyUser    = $NotifyUser
            UserId        = $UserId
            EmailCulture  = $EmailCulture
            Description   = 'Notify when items are deleted from first or second stage recycle bin'
            Severity      = 'High'
            Type          = 'Custom'
            ErrorAction   = 'Stop'
            WarningAction = 'Continue'
            Category      = 'DataLossPrevention'
         }
         $null = (New-ActivityAlert @paramNewActivityAlert)
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

         Write-Warning -Message $info.Exception -WarningAction Continue -ErrorAction SilentlyContinue
      }
      #endregion

      #region
      try
      {
         $paramNewActivityAlert = @{
            Name          = 'Transport Rules Monitoring Alerts'
            Operation     = 'New-TransportRule', 'Set-TransportRule', 'Remove-TransportRule'
            NotifyUser    = $NotifyUser
            UserId        = $UserId
            EmailCulture  = $EmailCulture
            Description   = 'Creation, Modification and Deletion of Transport Rules'
            Severity      = 'High'
            Type          = 'Custom'
            ErrorAction   = 'Stop'
            WarningAction = 'Continue'
            RecordType    = 'ExchangeAdmin'
            Category      = 'ThreatManagement'
         }
         $null = (New-ActivityAlert @paramNewActivityAlert)
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

         Write-Warning -Message $info.Exception -WarningAction Continue -ErrorAction SilentlyContinue
      }
      #endregion

      #region
      try
      {
         # MCAS might be the better option, but this requires proper licensing to fully use all of its functionality
         $paramNewActivityAlert = @{
            Name          = 'Sharepoint Folder or File is shared with an external party'
            Operation     = 'securelinkcreated'
            NotifyUser    = $NotifyUser
            UserId        = $UserId
            EmailCulture  = $EmailCulture
            Description   = "A user has created a 'specific people link' to share a resource with a specific person. This target user may be someone who's external to your organization"
            Severity      = 'Medium'
            Type          = 'Custom'
            ErrorAction   = 'Stop'
            WarningAction = 'Continue'
            Category      = 'DataLossPrevention'
         }
         $null = (New-ActivityAlert @paramNewActivityAlert)
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

         Write-Warning -Message $info.Exception -WarningAction Continue -ErrorAction SilentlyContinue
      }
      #endregion

      #region
      try
      {
         # MCAS might be the better option, but this requires proper licensing to fully use all of its functionality
         $paramNewActivityAlert = @{
            Name          = 'Sharepoint Folder or File is shared company-wide'
            Operation     = 'CompanylinkCreated'
            NotifyUser    = $NotifyUser
            UserId        = $UserId
            EmailCulture  = $EmailCulture
            Description   = "User created a company-wide link to a resource. company-wide links can only be used by members in your organization. They can't be used by guests."
            Severity      = 'Low'
            Type          = 'Custom'
            ErrorAction   = 'Stop'
            WarningAction = 'Continue'
            Category      = 'DataGovernance'
         }
         $null = (New-ActivityAlert @paramNewActivityAlert)
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

         Write-Warning -Message $info.Exception -WarningAction Continue -ErrorAction SilentlyContinue
      }
      #endregion
   }

   end
   {
      Write-Output "Check the new Activity Alert's in your Office 365 Security & Compliance Center"
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
