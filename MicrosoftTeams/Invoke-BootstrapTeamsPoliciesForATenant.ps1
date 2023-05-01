#requires -Version 2.0 -Modules MicrosoftTeams

<#
      .SYNOPSIS
      Bootstrap Teams Policies for a M365 tenant

      .DESCRIPTION
      Bootstrap Teams Policies for a M365 tenant

      .EXAMPLE
      PS C:\> .\Invoke-BootstrapTeamsPoliciesForATenant.ps1

      Bootstrap Teams Policies for a M365 tenant

      .NOTES
      You need the latest MicrosoftTeams PowerShell Module
#>
[CmdletBinding(ConfirmImpact = 'Medium')]
[OutputType([string])]
param ()

begin
{
   # Interactive login (customize it for yourself, if needed)
   Connect-MicrosoftTeams
}

process
{
   $paramSetCsTeamsMessagingPolicy = @{
      Identity                                      = 'Global'
      Description                                   = 'Global Teams Messaging Policy'
      AllowUrlPreviews                              = $true
      AllowOwnerDeleteMessage                       = $true
      AllowUserEditMessage                          = $true
      AllowUserDeleteMessage                        = $true
      AllowUserDeleteChat                           = $true
      AllowUserChat                                 = $true
      AllowRemoveUser                               = $true
      AllowGiphy                                    = $false
      GiphyRatingType                               = 'Strict'
      AllowGiphyDisplay                             = $false
      AllowPasteInternetImage                       = $true
      AllowMemes                                    = $true
      AllowImmersiveReader                          = $true
      AllowStickers                                 = $true
      AllowUserTranslation                          = $true
      ReadReceiptsEnabledType                       = 'UserPreference'
      AllowPriorityMessages                         = $true
      AllowSmartReply                               = $true
      AllowSmartCompose                             = $true
      ChannelsInChatListEnabledType                 = 'EnabledUserOverride'
      AudioMessageEnabledType                       = 'ChatsOnly'
      ChatPermissionRole                            = 'Full'
      AllowFullChatPermissionUserToDeleteAnyMessage = $false
      AllowFluidCollaborate                         = $true
      AllowVideoMessages                            = $true
      AllowCommunicationComplianceEndUserReporting  = $true
      AllowChatWithGroup                            = $true
      AllowSecurityEndUserReporting                 = $true
      InOrganizationChatControl                     = 'BlockingDisallowed'
      Verbose                                       = $true
      Confirm                                       = $false
      Force                                         = $true
      ErrorAction                                   = 'Stop'
      WarningAction                                 = 'SilentlyContinue'
   }
   Set-CsTeamsMessagingPolicy @paramSetCsTeamsMessagingPolicy

   $paramSetCsTeamsMessagingConfiguration = @{
      Identity                        = 'Global'
      EnableVideoMessageCaptions      = $true
      EnableInOrganizationChatControl = $true
      Force                           = $true
      Verbose                         = $true
      ErrorAction                     = 'Stop'
      WarningAction                   = 'SilentlyContinue'
   }
   Set-CsTeamsMessagingConfiguration @paramSetCsTeamsMessagingConfiguration

   $paramSetCsTeamsMeetingBrandingPolicy = @{
      Identity                          = 'Global'
      EnableMeetingOptionsThemeOverride = $true
      EnableMeetingBackgroundImages     = $true
      Force                             = $true
      Verbose                           = $true
      ErrorAction                       = 'Stop'
      WarningAction                     = 'SilentlyContinue'
   }
   Set-CsTeamsMeetingBrandingPolicy @paramSetCsTeamsMeetingBrandingPolicy

   $paramSetCsTeamsMeetingConfiguration = @{
      Identity                               = 'Global'
      LogoURL                                = 'https://www.enatec.net/assets/img/enablingTechnology.png'
      LegalURL                               = 'https://enatec.io/privacy-policy/'
      HelpURL                                = 'https://enatec.support/'
      CustomFooterText                       = 'All online conferencing and dial in services are provided by Microsoft as part of our Microsoft Office 365 subscription. Please review our privacy policy and the privacy policy of Microsoft for Microsoft Office 365 services in Germany/Europe.'
      DisableAnonymousJoin                   = $true
      DisableAppInteractionForAnonymousUsers = $false
      EnableQoS                              = $true
      ClientAudioPort                        = 50000
      ClientAudioPortRange                   = 20
      ClientVideoPort                        = 50020
      ClientVideoPortRange                   = 20
      ClientAppSharingPort                   = 50040
      ClientAppSharingPortRange              = 20
      ClientMediaPortRangeEnabled            = $true
      Confirm                                = $false
   }
   Set-CsTeamsMeetingConfiguration @paramSetCsTeamsMeetingConfiguration

   $paramSetCsTeamsCortanaPolicy = @{
      Identity                         = 'Global'
      Description                      = 'Default Teams Cortana Policy'
      CortanaVoiceInvocationMode       = 'WakeWordPushToTalkUserOverride'
      AllowCortanaVoiceInvocation      = $true
      AllowCortanaAmbientListening     = $true
      AllowCortanaInContextSuggestions = $true
      Confirm                          = $false
   }
   Set-CsTeamsCortanaPolicy @paramSetCsTeamsCortanaPolicy

   $paramSetCsTeamsFilesPolicy = @{
      Identity              = 'Global'
      NativeFileEntryPoints = 'Enabled'
      SPChannelFilesTab     = 'Enabled'
      Confirm               = $false
   }
   Set-CsTeamsFilesPolicy @paramSetCsTeamsFilesPolicy

   $paramSetCsTeamsIPPhonePolicy = @{
      Identity                       = 'Global'
      Description                    = 'Default Teams IP Phone Policy'
      SignInMode                     = 'UserSignIn'
      SearchOnCommonAreaPhoneMode    = 'Disabled'
      AllowHomeScreen                = 'Enabled'
      AllowBetterTogether            = 'Enabled'
      AllowHotDesking                = $true
      HotDeskingIdleTimeoutInMinutes = 180
      Confirm                        = $false
   }
   Set-CsTeamsIPPhonePolicy @paramSetCsTeamsIPPhonePolicy

   if (Get-CsTeamsMobilityPolicy -Identity 'NativeFirst' -ErrorAction SilentlyContinue)
   {
      $paramNewCsTeamsMobilityPolicy = @{
         Identity               = 'NativeFirst'
         Description            = 'Native first Teams Mobility Policy'
         MobileDialerPreference = 'Native'
         IPVideoMobileMode      = 'AllNetworks'
         IPAudioMobileMode      = 'AllNetworks'
         Confirm                = $false
      }
      Set-CsTeamsMobilityPolicy @paramNewCsTeamsMobilityPolicy
   }
   else
   {
      $paramNewCsTeamsMobilityPolicy = @{
         Identity               = 'NativeFirst'
         Description            = 'Native first Teams Mobility Policy'
         MobileDialerPreference = 'Native'
         IPVideoMobileMode      = 'AllNetworks'
         IPAudioMobileMode      = 'AllNetworks'
         Confirm                = $false
      }
      New-CsTeamsMobilityPolicy @paramNewCsTeamsMobilityPolicy
   }
   $paramSetCsTeamsMobilityPolicy = @{
      Identity               = 'Global'
      Description            = 'Default Teams Mobility Policy'
      IPVideoMobileMode      = 'AllNetworks'
      IPAudioMobileMode      = 'AllNetworks'
      MobileDialerPreference = 'Teams'
      Confirm                = $false
   }
   Set-CsTeamsMobilityPolicy @paramSetCsTeamsMobilityPolicy

   $paramSetCsTeamsNetworkRoamingPolicy = @{
      Identity       = 'Global'
      Description    = 'Global Teams Network Roaming Policy'
      AllowIPVideo   = $true
      MediaBitRateKb = 50000
      Confirm        = $false
   }
   Set-CsTeamsNetworkRoamingPolicy @paramSetCsTeamsNetworkRoamingPolicy

   $paramSetCsTeamsNotificationAndFeedsPolicy = @{
      Identity                  = 'Global'
      Description               = 'Global Teams Notification & Feeds Policy'
      SuggestedFeedsEnabledType = 'EnabledUserOverride'
      TrendingFeedsEnabledType  = 'EnabledUserOverride'
      Confirm                   = $false
   }
   Set-CsTeamsNotificationAndFeedsPolicy @paramSetCsTeamsNotificationAndFeedsPolicy

   $paramSetCsTeamsVdiPolicy = @{
      Identity                            = 'Global'
      DisableCallsAndMeetings             = $false
      DisableAudioVideoInCallsAndMeetings = $false
      Confirm                             = $false
   }
   Set-CsTeamsVdiPolicy @paramSetCsTeamsVdiPolicy

   $paramSetCsExternalAccessPolicy = @{
      Identity                          = 'Global'
      Description                       = 'Global External Access Policy'
      EnableFederationAccess            = $true
      EnablePublicCloudAccess           = $true
      EnablePublicCloudAudioVideoAccess = $true
      EnableTeamsSmsAccess              = $true
      EnableOutsideAccess               = $true
      EnableAcsFederationAccess         = $true
      EnableTeamsConsumerAccess         = $true
      EnableTeamsConsumerInbound        = $true
   }
   Set-CsExternalAccessPolicy @paramSetCsExternalAccessPolicy

   $paramSetCsOnlineVoicemailPolicy = @{
      Identity                            = 'Global'
      Description                         = 'Global Voicemail Policy'
      EnableTranscription                 = $true
      ShareData                           = 'Defer'
      EnableTranscriptionProfanityMasking = $false
      EnableEditingCallAnswerRulesSetting = $true
      MaximumRecordingLength              = '00:05:00'
      EnableTranscriptionTranslation      = $true
      PrimarySystemPromptLanguage         = 'en-US'
      SecondarySystemPromptLanguage       = 'de-DE'
      PreambleAudioFile                   = $null
      PostambleAudioFile                  = $null
      PreamblePostambleMandatory          = $false
      Verbose                             = $true
      Force                               = $true
      Confirm                             = $false
      ErrorAction                         = 'Stop'
      WarningAction                       = 'SilentlyContinue'
   }
   Set-CsOnlineVoicemailPolicy @paramSetCsOnlineVoicemailPolicy

   $paramSetCsTeamsChannelsPolicy = @{
      Identity                                      = 'Global'
      Description                                   = 'Default Teams Channels Policy'
      AllowOrgWideTeamCreation                      = $true
      EnablePrivateTeamDiscovery                    = $false
      AllowPrivateChannelCreation                   = $true
      AllowSharedChannelCreation                    = $true
      AllowChannelSharingToExternalUser             = $true
      AllowUserToParticipateInExternalSharedChannel = $true
      Verbose                                       = $true
      Force                                         = $true
      Confirm                                       = $false
      ErrorAction                                   = 'Stop'
      WarningAction                                 = 'SilentlyContinue'
   }
   Set-CsTeamsChannelsPolicy @paramSetCsTeamsChannelsPolicy

   $paramSetCsTeamsComplianceRecordingPolicy = @{
      Identity                                            = 'Global'
      Description                                         = 'Default Teams Compliance Recording Policy'
      Enabled                                             = $true
      WarnUserOnRemoval                                   = $true
      DisableComplianceRecordingAudioNotificationForCalls = $false
      RecordReroutedCalls                                 = $false
      Verbose                                             = $true
      Force                                               = $true
      Confirm                                             = $false
      ErrorAction                                         = 'Stop'
      WarningAction                                       = 'SilentlyContinue'
   }
   Set-CsTeamsComplianceRecordingPolicy @paramSetCsTeamsComplianceRecordingPolicy

   $paramSetCsTeamsEventsPolicy = @{
      Identity          = 'Global'
      Description       = 'Global Teams Events Policy'
      AllowWebinars     = 'Enabled'
      EventAccessType   = 'Everyone'
      AllowTownhalls    = 'Enabled'
      AllowEmailEditing = 'Enabled'
      Verbose           = $true
      Force             = $true
      Confirm           = $false
      ErrorAction       = 'Stop'
      WarningAction     = 'SilentlyContinue'
   }
   Set-CsTeamsEventsPolicy @paramSetCsTeamsEventsPolicy

   $paramSetCsTeamsFeedbackPolicy = @{
      Identity                  = 'Global'
      UserInitiatedMode         = 'Enabled'
      ReceiveSurveysMode        = 'EnabledUserOverride'
      AllowScreenshotCollection = $false
      AllowEmailCollection      = $false
      AllowLogCollection        = $false
      EnableFeatureSuggestions  = $true
      Verbose                   = $true
      Force                     = $true
      Confirm                   = $false
      ErrorAction               = 'Stop'
      WarningAction             = 'SilentlyContinue'
   }
   Set-CsTeamsFeedbackPolicy @paramSetCsTeamsFeedbackPolicy

   $paramSetCsTeamsUpdateManagementPolicy = @{
      Identity            = 'Global'
      Description         = 'Global Teams Update Management Policy'
      AllowManagedUpdates = $false
      AllowPreview        = $false
      UpdateDayOfWeek     = 1
      UpdateTime          = '18:00'
      UpdateTimeOfDay     = '18:00'
      AllowPublicPreview  = 'Disabled'
      UseNewTeamsClient   = 'MicrosoftChoice'
      Verbose             = $true
      Force               = $true
      Confirm             = $false
      ErrorAction         = 'Stop'
      WarningAction       = 'SilentlyContinue'
   }
   Set-CsTeamsUpdateManagementPolicy @paramSetCsTeamsUpdateManagementPolicy

   if (Get-CsTeamsUpdateManagementPolicy -Identity 'Preview' -ErrorAction SilentlyContinue)
   {
      $paramSetCsTeamsUpdateManagementPolicy = @{
         Identity            = 'Preview'
         Description         = 'Preview Teams Update Management Policy'
         AllowManagedUpdates = $true
         AllowPreview        = $true
         UpdateDayOfWeek     = 1
         UpdateTime          = '18:00'
         UpdateTimeOfDay     = '18:00'
         AllowPublicPreview  = 'Forced'
         UseNewTeamsClient   = 'UserChoice'
         Verbose             = $true
         Force               = $true
         Confirm             = $false
         ErrorAction         = 'Stop'
         WarningAction       = 'SilentlyContinue'
      }
      Set-CsTeamsUpdateManagementPolicy @paramSetCsTeamsUpdateManagementPolicy
   }
   else
   {
      $paramNewCsTeamsUpdateManagementPolicy = @{
         Identity            = 'Preview'
         Description         = 'Preview Teams Update Management Policy'
         AllowManagedUpdates = $true
         AllowPreview        = $true
         UpdateDayOfWeek     = 1
         UpdateTime          = '18:00'
         UpdateTimeOfDay     = '18:00'
         AllowPublicPreview  = 'Forced'
         UseNewTeamsClient   = 'UserChoice'
         Verbose             = $true
         Force               = $true
         Confirm             = $false
         ErrorAction         = 'Stop'
         WarningAction       = 'SilentlyContinue'
      }

      New-CsTeamsUpdateManagementPolicy @paramNewCsTeamsUpdateManagementPolicy
   }
}

end
{
   Disconnect-MicrosoftTeams -Confirm:$false
}