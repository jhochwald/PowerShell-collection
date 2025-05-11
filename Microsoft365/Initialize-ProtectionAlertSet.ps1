function Initialize-ProtectionAlertSet
{
   <#
         .SYNOPSIS
         Create good practice Ruleset of Office 365 Protection Alert's

         .DESCRIPTION
         Create good practice Ruleset of Office 365 Protection Alert's
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
         PS C:\> Initialize-ProtectionAlertSet -NotifyUser 'alert@contoso.com'

         Create good practice Ruleset of Office 365 Protection Alert's and send all alerts to 'alert@contoso.com'

         .EXAMPLE
         PS C:\> Initialize-ProtectionAlertSet -NotifyUser 'alert@contoso.com -EmailCulture 'de-DE'

         Create good practice Ruleset of Office 365 Protection Alert's and send all alerts in German to 'alert@contoso.com'

         .NOTES
         Please Review all the settings carefully before your run the script!

         You must have a connection to the following Office 365 services:
         - Security and Compliance Center

         All features should work with your default Office 365 Enterprise plan. Business plans are not tested!

         PLEASE NOTE:
         This is really just a basic setup. It does NOT replace an security advice by a security consultant!

         .LINK
         New-ProtectionAlert
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

      Write-Output -InputObject "Create good practice Ruleset of Office 365 Protection Alert's"
   }

   process
   {
      #region
      try
      {
         # Office 365 E5 subscription or Office 365 E3 subscription with an Office 365 Threat Intelligence required
         $paramNewProtectionAlert = @{
            Name            = 'OneDrive deleted item threshold reached'
            Category        = 'DataGovernance'
            NotifyUser      = $NotifyUser
            ThreatType      = 'Activity'
            Description     = 'OneDrive deleted item threshold exceeds 50 in an hour'
            AggregationType = 'SimpleAggregation'
            Operation       = 'FileDeleted'
            Severity        = 'Medium'
            Filter          = "Activity.SiteUrl -like '*-my.sharepoint.com/personal/*'"
            Threshold       = 50
            TimeWindow      = 60
            ErrorAction     = 'Stop'
            WarningAction   = 'Continue'
         }
         New-ProtectionAlert @paramNewProtectionAlert
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
         $paramNewProtectionAlert = @{
            Name            = 'MailRedirect created'
            Category        = 'DataLossPrevention'
            ThreatType      = 'Activity'
            Operation       = 'MailRedirect'
            Severity        = 'Medium'
            NotifyUser      = $NotifyUser
            AggregationType = 'None'
            Description     = 'Email forward created'
            ErrorAction     = 'Stop'
            WarningAction   = 'Continue'
         }
         New-ProtectionAlert @paramNewProtectionAlert
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
         $paramNewProtectionAlert = @{
            Name            = 'Granted Mailbox Permission'
            Category        = 'DataLossPrevention'
            ThreatType      = 'Activity'
            Operation       = 'AddMailboxPermission'
            Severity        = 'Medium'
            NotifyUser      = $NotifyUser
            AggregationType = 'None'
            Description     = 'Granted Mailbox Permission'
            ErrorAction     = 'Stop'
            WarningAction   = 'Continue'
         }
         New-ProtectionAlert @paramNewProtectionAlert
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
         $paramNewProtectionAlert = @{
            Name            = 'Outbound Phishing'
            Category        = 'ThreatManagement'
            NotifyUser      = $NotifyUser
            ThreatType      = 'Phish'
            Description     = 'Alert Outbound Phishing detected'
            AggregationType = 'none'
            Operation       = $null
            Filter          = "(Mail.IsSystemZap -eq '0') -and (Mail.Direction -eq 'Outbound')"
            Severity        = 'High'
            ErrorAction     = 'Stop'
            WarningAction   = 'Continue'
         }
         New-ProtectionAlert @paramNewProtectionAlert
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
         $paramNewProtectionAlert = @{
            Name            = 'Inbound Phishing'
            Category        = 'ThreatManagement'
            NotifyUser      = $NotifyUser
            ThreatType      = 'Phish'
            Description     = 'Alert Inbound Phishing detected'
            AggregationType = 'none'
            Operation       = $null
            Filter          = "(Mail.IsSystemZap -eq '0') -and (Mail.Direction -eq 'Inbound')"
            Severity        = 'High'
            ErrorAction     = 'Stop'
            WarningAction   = 'Continue'
         }
         New-ProtectionAlert @paramNewProtectionAlert
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
         $paramNewProtectionAlert = @{
            Name            = 'Office 365 Group deleted'
            Category        = 'DataGovernance'
            NotifyUser      = $NotifyUser
            ThreatType      = 'Activity'
            Description     = 'Alert if Office 365 Group is deleted'
            AggregationType = 'none'
            Operation       = 'GroupRemoved'
            Severity        = 'Medium'
            ErrorAction     = 'Stop'
            WarningAction   = 'Continue'
         }
         New-ProtectionAlert @paramNewProtectionAlert
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
         $paramNewProtectionAlert = @{
            Name            = 'Office 365 Group Created'
            Category        = 'DataGovernance'
            NotifyUser      = $NotifyUser
            ThreatType      = 'Activity'
            Description     = 'Alert if Office 365 Group is created'
            AggregationType = 'none'
            Operation       = 'GroupCreated'
            Severity        = 'Medium'
            ErrorAction     = 'Stop'
            WarningAction   = 'Continue'
         }
         New-ProtectionAlert @paramNewProtectionAlert
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
         $paramNewProtectionAlert = @{
            Name            = 'Sharing Policy Changed'
            Category        = 'DataLossPrevention'
            NotifyUser      = $NotifyUser
            ThreatType      = 'Activity'
            Description     = 'Alert if Sharing Policy is changed'
            AggregationType = 'none'
            Operation       = 'SharingPolicyChanged'
            Severity        = 'High'
            ErrorAction     = 'Stop'
            WarningAction   = 'Continue'
         }
         New-ProtectionAlert @paramNewProtectionAlert
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
         $paramNewProtectionAlert = @{
            Name            = 'Compromised Account Activity'
            Category        = 'DataLossPrevention'
            NotifyUser      = $NotifyUser
            ThreatType      = 'Activity'
            Description     = 'Alert if Compromised Account activity is detected'
            AggregationType = 'none'
            Operation       = 'CompromisedAccount'
            Severity        = 'High'
            ErrorAction     = 'Stop'
            WarningAction   = 'Continue'
         }
         New-ProtectionAlert @paramNewProtectionAlert
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
      Write-Output "Check the new Protection Alert's in your Office 365 Security & Compliance Center"
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
