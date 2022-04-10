# Use the latest Microsoft Teams PowerShell Module to connect
# Not the Skype for Business Online Module (outdated)

# Get all Teams Meeting Policies
Get-CsTeamsMeetingPolicy | Select-Object -ExpandProperty Identity

# Get all Teams Meeting Policies, exclude all TAG Policies (You can not modify them with Get-CsTeamsMeetingPolicy)
Get-CsTeamsMeetingPolicy | Where-Object -FilterScript {
   $PSItem.Identity -notlike 'Tag:*'
} | Select-Object -ExpandProperty Identity

# Modify the Global Policy
Set-CsTeamsMeetingPolicy -Identity Global -AllowEngagementReport Enabled

# Modify any Policy by name
Set-CsTeamsMeetingPolicy -Identity 'Meetings' | Set-CsTeamsMeetingPolicy -AllowEngagementReport Enabled

# Modify all Policies (exclude the TAG Policies, because you can not modify them with Get-CsTeamsMeetingPolicy)
Get-CsTeamsMeetingPolicy | Where-Object -FilterScript {
   $PSItem.Identity -notlike 'Tag:*'
} | ForEach-Object -Process {
   Set-CsTeamsMeetingPolicy -Identity $PSItem.Identity -AllowEngagementReport Enabled -ErrorAction Continue
}
