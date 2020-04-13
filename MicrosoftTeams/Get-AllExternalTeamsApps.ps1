#requires -Version 2.0 -Modules MicrosoftTeams

<#
   .SYNOPSIS
   Get a List of external Microsoft Teams Applications

   .DESCRIPTION
   Get a List of external Microsoft Teams Applications for the tenant.

   .EXAMPLE
   PS C:\> .\Get-AllExternalTeamsApps.ps1

   Get a List of external Microsoft Teams Applications for the tenant.

   .EXAMPLE
   PS C:\> .\Get-AllExternalTeamsApps.ps1 | Select-Object -Property DisplayName, DistributionMethod

   Get a List of external Microsoft Teams Applications for the tenant.

   .NOTES
   You need to use the Microsoft Teams Cmdlets module

   If you don't have, install it from the gallery:
   Install-Module -Name MicrosoftTeams
#>
[CmdletBinding(ConfirmImpact = 'None')]
param ()

<#
	Simple filter: External Apps will have the ExternalId field filled,
	where store apps (from the Microsoft Teams App Store) not.
#>
Get-TeamsApp | Where-Object -FilterScript {
   $_.ExternalId
}
