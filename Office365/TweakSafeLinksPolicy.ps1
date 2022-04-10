# Get your active SafeLinks Policy/Policies
Get-SafeLinksPolicy | Where-Object -FilterScript {
   $PSItem.IsEnabled -eq $true
} | Select-Object -ExpandProperty Identity

# I use the default policy in this example
$SafeLinksPolicyIdentity = 'Recommended safe links policy'

# A list of URLs to exclude from rewriting
$DoNotRewriteUrls = @(
   '*.webex.com/*'
   '*.zoom.us/*'
   'zoom.us/*'
   '*.teams.microsoft.com/*'
   'zoom.com/*'
   '*.zoom.com/*'
   'teams.microsoft.com/*'
)

# I use the default policy in this example
Set-SafeLinksPolicy -Identity $SafeLinksPolicyIdentity -DoNotRewriteUrls $DoNotRewriteUrls
<#
      Note:
      The WhiteListedUrls and ExcludedUrls parameters are deprecated
      Only use the DoNotRewriteUrls parameter
#>

# Remove all URLs from the SafeLinks Policy/Policies
$DoNotRewriteUrls = @()
Set-SafeLinksPolicy -Identity $SafeLinksPolicyIdentity -DoNotRewriteUrls $DoNotRewriteUrls

# Apply my recommended settings to the policy/policies
$paramSetSafeLinksPolicy = @{
   Identity                 = $SafeLinksPolicyIdentity
   DoNotTrackUserClicks     = $false
   DoNotAllowClickThrough   = $true
   ScanUrls                 = $true
   EnableForInternalSenders = $true
   DeliverMessageAfterScan  = $true
}
Set-SafeLinksPolicy @paramSetSafeLinksPolicy

<#
      Identity					    = The Identity parameter specifies the Safe Links policy that you want to modify
      DoNotTrackUserClicks	    = Track user clicks related to links in email messages and Microsoft Teams
      DoNotAllowClickThrough   = Disallow users to click through to the original URL
      ScanUrls					    = Enable real-time scanning of links in email messages
      EnableForInternalSenders = The policy is applied to internal and external senders
      DeliverMessageAfterScan  = Wait until Safe Links scanning is complete before delivering the message
#>

# This is fine, no panic:
# WARNING: The command completed successfully but no settings of 'Recommended safe links policy' have been modified.

# Do this for all your Teams Room Devices that should except external invitations
Set-CalendarProcessing -Identity '<Your Device here>' -ProcessExternalMeetingMessages $true
