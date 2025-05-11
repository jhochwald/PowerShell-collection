#requires -Version 2.0

<#
      .SYNOPSIS
      Bootstrap a Office 365 Tenant

      .DESCRIPTION
      Bootstrap a Office 365 Tenant
      It Applies some of the enabling Technology best practice settings, mostly related to security and Exchange Online.

      .NOTES
      Please Review all the settings carefully before your run the script!

      You must have a connection to the following Office 365 services:
      - Skype for Business Online
      - Exchange Online
      - Security and Compliance Center
      - AzureAD (Regular Module or Preview)

      All features should work with your default Office 365 Enterprise plan. Business plans are not tested!

      PLEASE NOTE:
      This is really just a basic setup. It does NOT replace an security advice by a security consultant!

      It should elevate your Security score a bit. But you still need to configure a bit more (manually or by other scripts)!

      .LINK
      https://hochwald.net/office-365-minimum-security-baseline/

      .LINK
      http://www.enatec.io
#>
[CmdletBinding(ConfirmImpact = 'Low')]
param ()

begin
{
   # Variables
   [string[]]$AdminMail = 'support@contoso.com'
   [string]$EmailCulture = 'en-US'

   #region Defaults
   [string]$SCT = 'SilentlyContinue'
   [string]$STP = 'Stop'
   #endregion Defaults
}

process
{
   #region
   # Enable Unified audit log
   $paramGetAdminAuditLogConfig = @{
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if (((Get-AdminAuditLogConfig @paramGetAdminAuditLogConfig) | Select-Object -ExpandProperty UnifiedAuditLogIngestionEnabled) -ne $true)
   {
      try
      {
         $paramSetAdminAuditLogConfig = @{
            UnifiedAuditLogIngestionEnabled = $true
            ErrorAction                     = $SCT
            WarningAction                   = $STP
         }
         $null = (Set-AdminAuditLogConfig @paramSetAdminAuditLogConfig)
         Write-Output -InputObject 'Unified audit log is enabled'
      }
      catch
      {
         Write-Warning -Message 'Unable to enable Unified audit log'
      }
   }
   else
   {
      Write-Output -InputObject 'Unified audit log is already enabled'
   }

   $paramGetAdminAuditLogConfig = $null
   $paramSetAdminAuditLogConfig = $null
   #endregion

   #region
   # Enable Admin audit log
   $paramGetAdminAuditLogConfig = @{
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if (((Get-AdminAuditLogConfig @paramGetAdminAuditLogConfig) | Select-Object -ExpandProperty AdminAuditLogEnabled) -ne $true)
   {
      try
      {
         $paramSetAdminAuditLogConfig = @{
            AdminAuditLogEnabled    = $true
            AdminAuditLogCmdlets    = '*'
            AdminAuditLogParameters = '*'
            ErrorAction             = $STP
            WarningAction           = $SCT
         }
         $null = (Set-AdminAuditLogConfig @paramSetAdminAuditLogConfig)
         Write-Output -InputObject 'Admin audit log enabled'
      }
      catch
      {
         Write-Warning -Message 'Unable to enable Admin audit log'
      }
   }
   else
   {
      Write-Output -InputObject 'Admin audit log is already enabled'
   }

   $paramGetAdminAuditLogConfig = $null
   $paramSetAdminAuditLogConfig = $null
   #endregion

   #region
   # Enable Mailbox Audit Logging for all mailboxes
   $paramGetOrganizationConfig = @{
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if (((Get-OrganizationConfig @paramGetOrganizationConfig) | Select-Object -ExpandProperty AuditDisabled) -ne $false)
   {
      try
      {
         $paramSetOrganizationConfig = @{
            AuditDisabled = $false
            ErrorAction   = $STP
            WarningAction = $SCT
         }
         $null = (Set-OrganizationConfig @paramSetOrganizationConfig)
         Write-Output -InputObject 'Mailbox Audit Logging enabled'
      }
      catch
      {
         Write-Warning -Message 'Unable to enable Mailbox Audit Logging'
      }
   }
   else
   {
      Write-Output -InputObject 'Mailbox Audit Logging was already enabled'
   }

   $paramGetOrganizationConfig = $null
   $paramSetOrganizationConfig = $null
   #endregion

   #region
   # Block sign-in for all Shared, Room, and Equipment Mailboxes
   <#
         PLEASE NOTE:
         If you use a resource like an Microsoft Teams Rooms, or a Surface Hub you might need to re-enable them afterwards!
         Otherwise, your resource might not work as expected.

         The same applies to multi-factor authentication (MFA)! You will need to exclude devices like this!
   #>
   $paramGetMailbox = @{
      ResultSize           = 'unlimited'
      RecipientTypeDetails = 'SharedMailbox', 'RoomMailbox', 'EquipmentMailbox'
      ErrorAction          = $SCT
      WarningAction        = $SCT
   }
   $null = (Get-Mailbox @paramGetMailbox | Select-Object -ExpandProperty UserPrincipalName | ForEach-Object {
         $paramSetAzureAdUser = @{
            ObjectId       = $_
            AccountEnabled = $false
            ErrorAction    = $SCT
            WarningAction  = $SCT
         }
         Set-AzureADUser @paramSetAzureAdUser
      })
   #endregion

   #region
   # Apply and activate for each Mailbox
   try
   {
      $paramGetMailbox = @{
         ResultSize    = 'Unlimited'
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = ((Get-Mailbox @paramGetMailbox) | Where-Object -FilterScript {
            ($PSItem.RecipientTypeDetails -ne 'DiscoveryMailbox') -and ($PSItem.AuditEnabled -ne $true)
         } | ForEach-Object -Process {
            $paramSetMailbox = @{
               Identity      = $PSItem.UserPrincipalName
               AuditEnabled  = $true
               ErrorAction   = $SCT
               WarningAction = $SCT
            }
            $null = (Set-Mailbox @paramSetMailbox)
         })
      Write-Output -InputObject 'Applied and activated audit for each Mailbox'
   }
   catch
   {
      Write-Warning -Message 'Unable to apply and/or activate audit for each Mailbox'
   }
   finally
   {
      $paramGetMailbox = $null
      $paramSetMailbox = $null
   }
   #endregion

   #region
   # Disable POP3/IMAP4
   try
   {
      $paramGetCASMailboxPlan = @{
         Filter        = {
            ImapEnabled -eq 'true' -or PopEnabled -eq 'true'
         }
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $paramSetCASMailboxPlan = @{
         ImapEnabled   = $false
         PopEnabled    = $false
         ErrorAction   = $STP
         WarningAction = $SCT
      }
      $null = (Get-CASMailboxPlan @paramGetCASMailboxPlan | set-CASMailboxPlan @paramSetCASMailboxPlan)
      Write-Output -InputObject 'POP3 and IMAP4 are disabled - CAS Mailbox Plan'
   }
   catch
   {
      Write-Warning -Message 'Unable to disable POP3 and IMAP4 - CAS Mailbox Plan'
   }
   finally
   {
      $paramGetCASMailboxPlan = $null
      $paramSetCASMailboxPlan = $null
   }

   try
   {
      $paramGetCASMailbox = @{
         Filter        = {
            ImapEnabled -eq 'true' -or PopEnabled -eq 'true'
         }
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $paramSetCASMailbox = @{
         ImapEnabled   = $false
         PopEnabled    = $false
         ErrorAction   = $STP
         WarningAction = $SCT
      }
      $null = (Get-CASMailbox @paramGetCASMailbox | Select-Object -Property @{
            Name       = 'Identity'
            Expression = {
               $PSItem.PrimarySmtpAddress
            }
         } | Set-CASMailbox @paramSetCASMailbox)
      Write-Output -InputObject 'POP3 and IMAP4 are disabled - CAS Mailbox'
   }
   catch
   {
      Write-Warning -Message 'Unable to disable POP3 and IMAP4 - CAS Mailbox'
   }
   finally
   {
      $paramGetCASMailbox = $null
      $paramSetCASMailbox = $null
   }
   #endregion

   #region
   # Enable/Set End User Spam Notification
   try
   {
      $ExistingHostedContentFilterPolicy = (Get-HostedContentFilterPolicy -Identity Default -ErrorAction $SCT -WarningAction $SCT | Select-Object -Property EndUserSpamNotificationFrequency, HighConfidenceSpamAction, EnableEndUserSpamNotifications)

      if ((-not ($ExistingHostedContentFilterPolicy.EndUserSpamNotificationFrequency -eq 1)) -and (-not ($ExistingHostedContentFilterPolicy.HighConfidenceSpamAction -eq 'HighConfidenceSpamAction')) -and (-not ($ExistingHostedContentFilterPolicy.EnableEndUserSpamNotifications -eq $true)))
      {
         $paramSetHostedContentFilterPolicy = @{
            Identity                         = 'Default'
            EndUserSpamNotificationFrequency = 1
            EndUserSpamNotificationLanguage  = 'Default'
            HighConfidenceSpamAction         = 'Quarantine'
            EnableEndUserSpamNotifications   = $true
            ErrorAction                      = $STP
            WarningAction                    = $SCT
         }
         $null = (Set-HostedContentFilterPolicy @paramSetHostedContentFilterPolicy)
         Write-Output -InputObject 'Hosted Content Filter Policy was fixed'
      }
      else
      {
         Write-Output -InputObject 'Hosted Content Filter Policy was not fixed'
      }
   }
   catch
   {
      Write-Warning -Message 'Unable to fix Hosted Content Filter Policy'
   }
   finally
   {
      $ExistingHostedContentFilterPolicy = $null
      $paramSetHostedContentFilterPolicy = $null
   }
   #endregion

   #region
   # Enable/Set Outbound Spam Filter Notification
   try
   {
      $ExistingHostedOutboundSpamFilterPolicy = (Get-HostedOutboundSpamFilterPolicy -Identity Default -ErrorAction $SCT -WarningAction $SCT | Select-Object -Property NotifyOutboundSpamRecipients, NotifyOutboundSpam)

      if ((-not ($ExistingHostedOutboundSpamFilterPolicy.NotifyOutboundSpamRecipients -eq $AdminMail)) -and (-not ($ExistingHostedOutboundSpamFilterPolicy.NotifyOutboundSpam -eq $true)))
      {
         $paramSetHostedOutboundSpamFilterPolicy = @{
            Identity                     = 'Default'
            NotifyOutboundSpamRecipients = $AdminMail
            NotifyOutboundSpam           = $true
            ErrorAction                  = $STP
            WarningAction                = $SCT
         }
         $null = (Set-HostedOutboundSpamFilterPolicy @paramSetHostedOutboundSpamFilterPolicy)
         Write-Output -InputObject 'Hosted Outbound Spam Filter Policy was fixed'
      }
      else
      {
         Write-Output -InputObject 'Hosted Outbound Spam Filter Policy was not fixed'
      }
   }
   catch
   {
      Write-Warning -Message 'Unable to fix the Hosted Outbound Spam Filter Policy'
   }
   finally
   {
      $ExistingHostedOutboundSpamFilterPolicy = $null
      $paramSetHostedOutboundSpamFilterPolicy = $null
   }
   #endregion

   #region
   # Deploying minimum baseline MobileDeviceMailboxPolicy
   $paramGetMobileDeviceMailboxPolicy = @{
      Identity      = 'Default'
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   $DefaultMobileDeviceMailboxPolicy = (Get-MobileDeviceMailboxPolicy @paramGetMobileDeviceMailboxPolicy | Select-Object -Property PasswordEnabled, AllowSimplePassword, AlphanumericPasswordRequired, MinPasswordLength, RequireDeviceEncryption, AllowNonProvisionableDevices)
   #endregion

   #region
   # Check existing settings
   if (($DefaultMobileDeviceMailboxPolicy.PasswordEnabled -eq $true) -and (($DefaultMobileDeviceMailboxPolicy.AllowSimplePassword -eq $true) -or ($DefaultMobileDeviceMailboxPolicy.AlphanumericPasswordRequired -eq $true)) -and ($DefaultMobileDeviceMailboxPolicy.MinPasswordLength -ge 4) -and ($DefaultMobileDeviceMailboxPolicy.RequireDeviceEncryption -eq $true) -and ($DefaultMobileDeviceMailboxPolicy.AllowNonProvisionableDevices -eq $false))
   {
      Write-Output -InputObject 'Minimum, or better, baseline MobileDeviceMailboxPolicy already applied'
   }
   else
   {
      try
      {
         $paramSetMobileDeviceMailboxPolicy = @{
            Identity                     = 'Default'
            PasswordEnabled              = $true
            AllowSimplePassword          = $true
            MinPasswordLength            = 4
            RequireDeviceEncryption      = $true
            AllowNonProvisionableDevices = $false
            ErrorAction                  = $STP
            WarningAction                = $SCT
         }
         $null = (Set-MobileDeviceMailboxPolicy @paramSetMobileDeviceMailboxPolicy)
         Write-Output -InputObject 'Minimum baseline MobileDeviceMailboxPolicy applied'
      }
      catch
      {
         Write-Warning -Message 'Unable to change and/or apply the Minimum baseline MobileDeviceMailboxPolicy'
      }
   }

   $paramGetMobileDeviceMailboxPolicy = $null
   $DefaultMobileDeviceMailboxPolicy = $null
   $paramSetMobileDeviceMailboxPolicy = $null
   #endregion

   #region
   # Enable general Modern Authentication
   <#
      PLEASE NOTE:
      Microsoft Teams Rooms does NOT support Modern Authentication yet! (At least not with version 4.3.42.0 from 03/02/2019)
      If you have a device like the Microsoft Teams Rooms, you might not be able to disable legacy Auth (basic authentication).
      This will break the function and your device will no longer be able to authenticate.

      Please check for the latest release notes:
      https://docs.microsoft.com/en-us/MicrosoftTeams/rooms/rooms-release-note
   #>
   $paramGetOrganizationConfig = @{
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if (((Get-OrganizationConfig @paramGetOrganizationConfig) | Select-Object -ExpandProperty OAuth2ClientProfileEnabled) -ne $true)
   {
      try
      {
         $paramSetOrganizationConfig = @{
            OAuth2ClientProfileEnabled = $true
            ErrorAction                = $STP
            WarningAction              = $SCT
         }
         $null = (Set-OrganizationConfig @paramSetOrganizationConfig)
         Write-Output -InputObject 'Modern Authentication is enabled'
      }
      catch
      {
         Write-Warning -Message 'Unable to enable Modern Authentication'
      }
   }
   else
   {
      Write-Output -InputObject 'Modern Authentication is already enabled'
   }

   $paramGetOrganizationConfig = $null
   $paramSetOrganizationConfig = $null
   #endregion

   #region
   # Enable Modern Authentication in Skype for Business Online
   $paramGetCsOAuthConfiguration = @{
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if (((Get-CsOAuthConfiguration @paramGetCsOAuthConfiguration) | Select-Object -ExpandProperty ClientAdalAuthOverride) -ne 'Allowed')
   {
      try
      {
         $paramSetCsOAuthConfiguration = @{
            ClientAdalAuthOverride = 'Allowed'
            ErrorAction            = $STP
            WarningAction          = $SCT
         }
         $null = (Set-CsOAuthConfiguration @paramSetCsOAuthConfiguration)
         Write-Output -InputObject 'Modern Authentication was enabled for Skype for Business Online'
      }
      catch
      {
         Write-Warning -Message 'Unable to enable Modern Authentication for Skype for Business Online'
      }
   }
   else
   {
      Write-Output -InputObject 'Modern Authentication is already enabled for Skype for Business Online'
   }

   $paramGetCsOAuthConfiguration = $null
   $paramSetCsOAuthConfiguration = $null
   #endregion

   #region
   # Block forwarding mail externally
   $BlockForwardingRuleName = 'Block forwarding mail externally'

   $paramGetTransportRule = @{
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if (-not (Get-TransportRule @paramGetTransportRule | Where-Object -FilterScript {
            $PSItem.Name -eq $BlockForwardingRuleName
         }))
   {
      try
      {
         $paramNewTransportRule = @{
            Name                            = $BlockForwardingRuleName
            Priority                        = 1
            SentToScope                     = 'NotInOrganization'
            FromScope                       = 'InOrganization'
            SenderAddressLocation           = 'HeaderOrEnvelope'
            MessageTypeMatches              = 'AutoForward'
            RejectMessageEnhancedStatusCode = '5.7.1'
            RejectMessageReasonText         = ('To improve security, auto-forwarding rules to external addresses has been disabled. Please contact ' + $AdminMail + " if you'd like to set up an exception.")
            Mode                            = 'Audit'
            Comments                        = 'Block forwarding mail externally'
            ErrorAction                     = $STP
            WarningAction                   = $SCT
         }
         $null = (New-TransportRule @paramNewTransportRule)
         Write-Output -InputObject 'Block auto-forwarding rules to external addresses was created'
      }
      catch
      {
         Write-Warning -Message 'Block auto-forwarding rules to external addresses was not created'
      }
   }
   else
   {
      Write-Output -InputObject 'Block auto-forwarding rules to external addresses already exists'
   }

   $BlockForwardingRuleName = $null
   $paramGetTransportRule = $null
   $paramNewTransportRule = $null
   #endregion

   #region
   # Warn users if inbound external mail with display name matching internal users
   $ExternalSenderWithInternalDisplayNameRuleName = 'External Senders with matching Display Names'

   $paramGetTransportRule = @{
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if (-not (Get-TransportRule @paramGetTransportRule | Where-Object -FilterScript {
            $PSItem.Name -eq $ExternalSenderWithInternalDisplayNameRuleName
         }))
   {
      try
      {
         # Please review! This text will be displayed to your users!!!
         $ApplyHtmlDisclaimerText = "<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 align=left width='100%' style='width:100.0%;mso-cellspacing:0cm;mso-yfti-tbllook:1184; mso-table-lspace:2.25pt;mso-table-rspace:2.25pt;mso-table-anchor-vertical:paragraph;mso-table-anchor-horizontal:column;mso-table-left:left;mso-padding-alt:0cm 0cm 0cm 0cm'>  <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'><td style='background:red;padding:5.25pt 1.5pt 5.25pt 1.5pt'></td><td width='100%' style='width:100.0%;background:#ffe4e1;padding:5.25pt 3.75pt 5.25pt 11.25pt; word-wrap:break-word' cellpadding='7px 5px 7px 15px' color='#212121'><div><p class=MsoNormal style='mso-element:frame;mso-element-frame-hspace:2.25pt; mso-element-wrap:around;mso-element-anchor-vertical:paragraph;mso-element-anchor-horizontal: column;mso-height-rule:exactly'><span style='font-size:9.0pt;font-family: 'Segoe UI',sans-serif;mso-fareast-font-family:'Times New Roman';color:#212121'><strong>CAUTION:</strong> This email originated from <strong>outside</strong> of the organization by someone with a display name matching a user in your organization. Please do not click links or open attachments unless you recognize the source of this email and know the content is safe.<o:p></o:p></span></p></div></td></tr></table><p>&nbsp;</p>"

         $paramNewTransportRule = @{
            Name                              = $ExternalSenderWithInternalDisplayNameRuleName
            Priority                          = 2
            FromScope                         = 'NotInOrganization'
            SenderAddressLocation             = 'HeaderOrEnvelope'
            ApplyHtmlDisclaimerLocation       = 'Prepend'
            HeaderMatchesMessageHeader        = 'From'
            HeaderMatchesPatterns             = ((Get-Mailbox -ResultSize Unlimited -RecipientTypeDetails UserMailbox, SharedMailbox) | Select-Object -ExpandProperty DisplayName)
            ApplyHtmlDisclaimerText           = $ApplyHtmlDisclaimerText
            ApplyHtmlDisclaimerFallbackAction = 'Wrap'
            SetHeaderName                     = 'X-bdcRule'
            SetHeaderValue                    = $ExternalSenderWithInternalDisplayNameRuleName
            ErrorAction                       = $STP
            WarningAction                     = $SCT
         }
         $null = (New-TransportRule @paramNewTransportRule)
         Write-Output -InputObject 'External Sender with internal Display Name Rule was created'
      }
      catch
      {
         Write-Warning -Message 'External Sender with internal Display Name Rule was not created'
      }
   }
   else
   {
      Write-Output -InputObject 'External Sender with internal Display Name Rule already exists'
   }

   $ExternalSenderWithInternalDisplayNameRuleName = $null
   $ApplyHtmlDisclaimerText = $null
   $paramGetTransportRule = $null
   $paramNewTransportRule = $null
   #endregion

   #region
   # Mark all external Messages
   $MarkExternalMessagesRuleName = 'Mark external Messages'

   $paramGetTransportRule = @{
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if (-not (Get-TransportRule @paramGetTransportRule | Where-Object -FilterScript {
            $PSItem.Name -eq $MarkExternalMessagesRuleName
         }))
   {
      try
      {
         # Please review! This text will be displayed to your users!!!
         $ApplyHtmlDisclaimerText = "<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 align=left width='100%' style='width:100.0%;mso-cellspacing:0cm;mso-yfti-tbllook:1184; mso-table-lspace:2.25pt;mso-table-rspace:2.25pt;mso-table-anchor-vertical:paragraph;mso-table-anchor-horizontal:column;mso-table-left:left;mso-padding-alt:0cm 0cm 0cm 0cm'>  <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'><td style='background:yellow;padding:5.25pt 1.5pt 5.25pt 1.5pt'></td><td width='100%' style='width:100.0%;background:#ffffe0;padding:5.25pt 3.75pt 5.25pt 11.25pt; word-wrap:break-word' cellpadding='7px 5px 7px 15px' color='#212121'><div><p class=MsoNormal style='mso-element:frame;mso-element-frame-hspace:2.25pt; mso-element-wrap:around;mso-element-anchor-vertical:paragraph;mso-element-anchor-horizontal: column;mso-height-rule:exactly'><span style='font-size:9.0pt;font-family: 'Segoe UI',sans-serif;mso-fareast-font-family:'Times New Roman';color:#212121'><strong>CAUTION:</strong> This email originated from <strong>outside</strong> of the organization. Please do not click links or open attachments unless you recognize the source of this email and know the content is safe.<o:p></o:p></span></p></div></td></tr></table><p>&nbsp;</p>"

         $paramNewTransportRule = @{
            Name                              = $MarkExternalMessagesRuleName
            Priority                          = 3
            FromScope                         = 'NotInOrganization'
            SenderAddressLocation             = 'HeaderOrEnvelope'
            ApplyHtmlDisclaimerLocation       = 'Prepend'
            ApplyHtmlDisclaimerText           = $ApplyHtmlDisclaimerText
            ApplyHtmlDisclaimerFallbackAction = 'Wrap'
            SetHeaderName                     = 'X-bdcRule'
            SetHeaderValue                    = $MarkExternalMessagesRuleName
            ErrorAction                       = $STP
            WarningAction                     = $SCT
         }
         $null = (New-TransportRule @paramNewTransportRule)
         Write-Output -InputObject 'Mark External Messages Rule was created'
      }
      catch
      {
         Write-Warning -Message 'Mark External Messages Rule was not created'
      }
   }
   else
   {
      Write-Output -InputObject 'Mark External Messages Rule already exists'
   }

   $MarkExternalMessagesRuleName = $null
   $ApplyHtmlDisclaimerText = $null
   $paramGetTransportRule = $null
   $paramNewTransportRule = $null
   #endregion

   #region
   # See the Description field, that will explain what each alter will do.
   try
   {
      $paramNewActivityAlert = @{
         Name          = 'File and Page Alert'
         Operation     = 'Filemalwaredetected'
         NotifyUser    = $AdminMail
         UserId        = $null
         Description   = 'SharePoint anti-virus engine detects malware in a file.'
         ErrorAction   = $STP
         WarningAction = $SCT
         Severity      = 'High'
         EmailCulture  = $EmailCulture
         Disabled      = $false
      }
      if (-not (Get-ActivityAlert -Name $paramNewActivityAlert.Name -ErrorAction $SCT))
      {
         $null = (New-ActivityAlert @paramNewActivityAlert)
         Write-Output -InputObject ('The ' + $paramNewActivityAlert.Name + ' Activity Alert was created')
      }
      else
      {
         Write-Output -InputObject ('The ' + $paramNewActivityAlert.Name + ' Activity Alert exists')
      }
   }
   catch
   {
      Write-Warning -Message ('The ' + $paramNewActivityAlert.Name + ' Activity Alert was not')
   }

   $paramNewActivityAlert = $null

   try
   {
      $paramNewActivityAlert = @{
         Name          = 'Anonymous Links Alert'
         Operation     = 'Anonymouslinkcreated', 'Anonymouslinkupdated', 'Anonymouslinkused'
         NotifyUser    = $AdminMail
         UserId        = $null
         Description   = 'User created an anonymous link to a resource. User updated an anonymous link to a resource. An anonymous user accessed a resource by using an anonymous link.'
         ErrorAction   = $STP
         WarningAction = $SCT
         Severity      = 'Medium'
         EmailCulture  = $EmailCulture
         Disabled      = $false
      }
      if (-not (Get-ActivityAlert -Name $paramNewActivityAlert.Name -ErrorAction $SCT))
      {
         $null = (New-ActivityAlert @paramNewActivityAlert)
         Write-Output -InputObject ('The ' + $paramNewActivityAlert.Name + ' Activity Alert was created')
      }
      else
      {
         Write-Output -InputObject ('The ' + $paramNewActivityAlert.Name + ' Activity Alert exists')
      }
   }
   catch
   {
      Write-Warning -Message ('The ' + $paramNewActivityAlert.Name + ' Activity Alert was not created')
   }

   $paramNewActivityAlert = $null

   try
   {
      $paramNewActivityAlert = @{
         Name          = 'Sharing Alert'
         Operation     = 'Sharinginvitationcreated', 'Sharingpolicychanged'
         NotifyUser    = $AdminMail
         UserId        = $null
         Description   = "User shared a resource in SharePoint Online or OneDrive for Business with a user who isn't in your organization's directory. A SharePoint or global administrator changed a SharePoint sharing policy."
         ErrorAction   = $STP
         WarningAction = $SCT
         Severity      = 'None'
         EmailCulture  = $EmailCulture
         Disabled      = $false
      }
      if (-not (Get-ActivityAlert -Name $paramNewActivityAlert.Name -ErrorAction $SCT))
      {
         $null = (New-ActivityAlert @paramNewActivityAlert)
         Write-Output -InputObject ('The ' + $paramNewActivityAlert.Name + ' Activity Alert was created')
      }
      else
      {
         Write-Output -InputObject ('The ' + $paramNewActivityAlert.Name + ' Activity Alert exists')
      }
   }
   catch
   {
      Write-Warning -Message ('The ' + $paramNewActivityAlert.Name + ' Activity Alert was not created')
   }

   $paramNewActivityAlert = $null

   try
   {
      $paramNewActivityAlert = @{
         Name          = 'Access Alert'
         Operation     = 'Deviceaccesspolicychanged', 'Networkaccesspolicychanged'
         NotifyUser    = $AdminMail
         UserId        = $null
         Description   = 'Change in the unmanaged devices policy.Change in the location-based access policy (also called a trusted network boundary).'
         ErrorAction   = $STP
         WarningAction = $SCT
         Severity      = 'Medium'
         EmailCulture  = $EmailCulture
         Disabled      = $false
      }
      if (-not (Get-ActivityAlert -Name $paramNewActivityAlert.Name -ErrorAction $SCT))
      {
         $null = (New-ActivityAlert @paramNewActivityAlert)
         Write-Output -InputObject ('The ' + $paramNewActivityAlert.Name + ' Activity Alert was created')
      }
      else
      {
         Write-Output -InputObject ('The ' + $paramNewActivityAlert.Name + ' Activity Alert exists')
      }
   }
   catch
   {
      Write-Warning -Message ('The ' + $paramNewActivityAlert.Name + ' Activity Alert was not created')
   }

   $paramNewActivityAlert = $null

   try
   {
      $paramNewActivityAlert = @{
         Name          = 'Site Alert'
         Operation     = 'Sitecollectioncreated', 'Sitedeleted', 'Sitecollectionadminadded'
         NotifyUser    = $AdminMail
         UserId        = $null
         Description   = 'Creation of a new site collection OneDrive for Business site provisioned. A site was deleted.Site collection administrator or owner adds a person as a site collection administrator for a site.'
         ErrorAction   = $STP
         WarningAction = $SCT
         Severity      = 'None'
         EmailCulture  = $EmailCulture
         Disabled      = $false
      }
      if (-not (Get-ActivityAlert -Name $paramNewActivityAlert.Name -ErrorAction $SCT))
      {
         $null = (New-ActivityAlert @paramNewActivityAlert)
         Write-Output -InputObject ('The ' + $paramNewActivityAlert.Name + ' Activity Alert was created')
      }
      else
      {
         Write-Output -InputObject ('The ' + $paramNewActivityAlert.Name + ' Activity Alert exists')
      }
   }
   catch
   {
      Write-Warning -Message ('The ' + $paramNewActivityAlert.Name + ' Activity Alert was not created')
   }

   $paramNewActivityAlert = $null

   try
   {
      $paramNewActivityAlert = @{
         Name          = 'Office Alert'
         Operation     = 'Officeondemandset'
         NotifyUser    = $AdminMail
         UserId        = $null
         Description   = 'Site administrator enables Office on Demand, which lets users access the latest version of Office desktop applications.'
         ErrorAction   = $STP
         WarningAction = $SCT
         Severity      = 'None'
         EmailCulture  = $EmailCulture
         Disabled      = $false
      }
      if (-not (Get-ActivityAlert -Name $paramNewActivityAlert.Name -ErrorAction $SCT))
      {
         $null = (New-ActivityAlert @paramNewActivityAlert)
         Write-Output -InputObject ('The ' + $paramNewActivityAlert.Name + ' Activity Alert was created')
      }
      else
      {
         Write-Output -InputObject ('The ' + $paramNewActivityAlert.Name + ' Activity Alert exists')
      }
   }
   catch
   {
      Write-Warning -Message ('The ' + $paramNewActivityAlert.Name + ' Activity Alert was not created')
   }

   $paramNewActivityAlert = $null

   try
   {
      $paramNewActivityAlert = @{
         Name          = 'Mailbox Alert'
         Operation     = 'Add-mailboxpermission', 'Remove-mailboxpermission'
         NotifyUser    = $AdminMail
         UserId        = $null
         Description   = "An administrator assigned/removed the FullAccess mailbox permission to a user (known as a delegate) to another person`'s mailbox"
         ErrorAction   = $STP
         WarningAction = $SCT
         Severity      = 'None'
         EmailCulture  = $EmailCulture
         Disabled      = $false
      }
      if (-not (Get-ActivityAlert -Name $paramNewActivityAlert.Name -ErrorAction $SCT))
      {
         $null = (New-ActivityAlert @paramNewActivityAlert)
         Write-Output -InputObject ('The ' + $paramNewActivityAlert.Name + ' Activity Alert was created')
      }
      else
      {
         Write-Output -InputObject ('The ' + $paramNewActivityAlert.Name + ' Activity Alert exists')
      }
   }
   catch
   {
      Write-Warning -Message ('The ' + $paramNewActivityAlert.Name + ' Activity Alert was not created')
   }

   $paramNewActivityAlert = $null

   try
   {
      $paramNewActivityAlert = @{
         Name          = 'Password Alert'
         Operation     = 'Change user password.', 'Reset user password.', 'Set force change user password.'
         NotifyUser    = $AdminMail
         UserId        = $null
         Description   = 'User password changes'
         ErrorAction   = $STP
         WarningAction = $SCT
         Severity      = 'None'
         EmailCulture  = $EmailCulture
         Disabled      = $false
      }
      if (-not (Get-ActivityAlert -Name $paramNewActivityAlert.Name -ErrorAction $SCT))
      {
         $null = (New-ActivityAlert @paramNewActivityAlert)
         Write-Output -InputObject ('The ' + $paramNewActivityAlert.Name + ' Activity Alert was created')
      }
      else
      {
         Write-Output -InputObject ('The ' + $paramNewActivityAlert.Name + ' Activity Alert exists')
      }
   }
   catch
   {
      Write-Warning -Message ('The ' + $paramNewActivityAlert.Name + ' Activity Alert was not created')
   }

   $paramNewActivityAlert = $null

   try
   {
      $paramNewActivityAlert = @{
         Name          = 'Role Alert'
         Operation     = 'Add member to role.', 'Remove member from role.'
         NotifyUser    = $AdminMail
         UserId        = $null
         Description   = 'Added/Removed a user to an admin role in Office 365.'
         ErrorAction   = $STP
         WarningAction = $SCT
         Severity      = 'Medium'
         EmailCulture  = $EmailCulture
         Disabled      = $false
      }
      if (-not (Get-ActivityAlert -Name $paramNewActivityAlert.Name -ErrorAction $SCT))
      {
         $null = (New-ActivityAlert @paramNewActivityAlert)
         Write-Output -InputObject ('The ' + $paramNewActivityAlert.Name + ' Activity Alert was created')
      }
      else
      {
         Write-Output -InputObject ('The ' + $paramNewActivityAlert.Name + ' Activity Alert exists')
      }
   }
   catch
   {
      Write-Warning -Message ('The ' + $paramNewActivityAlert.Name + ' Activity Alert was not created')
   }

   $paramNewActivityAlert = $null

   try
   {
      $paramNewActivityAlert = @{
         Name          = 'Company Information Alert'
         Operation     = 'Set company contact information.', 'Set company information.', 'Set password policy.', 'Remove partner from company.'
         NotifyUser    = $AdminMail
         UserId        = $null
         Description   = 'Change company information or password policy'
         ErrorAction   = $STP
         WarningAction = $SCT
         Severity      = 'High'
         EmailCulture  = $EmailCulture
         Disabled      = $false
      }
      if (-not (Get-ActivityAlert -Name $paramNewActivityAlert.Name -ErrorAction $SCT))
      {
         $null = (New-ActivityAlert @paramNewActivityAlert)
         Write-Output -InputObject ('The ' + $paramNewActivityAlert.Name + ' Activity Alert was created')
      }
      else
      {
         Write-Output -InputObject ('The ' + $paramNewActivityAlert.Name + ' Activity Alert exists')
      }
   }
   catch
   {
      Write-Warning -Message ('The ' + $paramNewActivityAlert.Name + ' Activity Alert was not created')
   }

   $paramNewActivityAlert = $null

   try
   {
      $paramNewActivityAlert = @{
         Name          = 'Domain Alert'
         Operation     = 'Add domain to company.', 'Remove domain from company.', 'Update domain.'
         NotifyUser    = $AdminMail
         UserId        = $null
         Description   = 'Change of a custom domain in a tenant'
         ErrorAction   = $STP
         WarningAction = $SCT
         Severity      = 'High'
         EmailCulture  = $EmailCulture
         Disabled      = $false
      }
      if (-not (Get-ActivityAlert -Name $paramNewActivityAlert.Name -ErrorAction $SCT))
      {
         $null = (New-ActivityAlert @paramNewActivityAlert)
         Write-Output -InputObject ('The ' + $paramNewActivityAlert.Name + ' Activity Alert was created')
      }
      else
      {
         Write-Output -InputObject ('The ' + $paramNewActivityAlert.Name + ' Activity Alert exists')
      }
   }
   catch
   {
      Write-Warning -Message ('The ' + $paramNewActivityAlert.Name + ' Activity Alert was not created')
   }

   $paramNewActivityAlert = $null
   #endregion
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
