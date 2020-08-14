#requires -RunAsAdministrator
#requires -Version 3.0 -Modules NetQos
<#
      .SYNOPSIS
      Apply QoS Settings for Microsoft Teams Room Devices

      .DESCRIPTION
      Apply Network Quality of Service (QoS) settings for Microsoft Teams Room Devices.
      I use this script to deploy the QoS settings to MTR devices via Intune.

      .PARAMETER AppPathNameMatchCondition
      Specifies the name by which an application is run, such as application.exe or %ProgramFiles%\application.exe application.

      .EXAMPLE
      PS C:\> .\Set-QoSForMicrosoftTeamsRoomDevices.ps1

      .EXAMPLE
      PS C:\> .\Set-QoSForMicrosoftTeamsRoomDevices.ps1 -AppPathNameMatchCondition 'Teams.exe'

      .NOTES
      Idea based on a Twitter chat with @StaleHansen

      Please ensure to check the Ports!
      They must match you Teams Admin Centr (TAC) settings.

      .LINK
      Get-NetQosPolicy

      .LINK
      New-NetQosPolicy

      .LINK
      https://docs.microsoft.com/en-us/microsoftteams/qos-in-teams-clients

      .LINK
      https://twitter.com/StaleHansen/status/1294341225647083522
#>
[CmdletBinding(ConfirmImpact = 'Low',
SupportsShouldProcess)]
param
(
   [Parameter(ValueFromPipeline,
   ValueFromPipelineByPropertyName)]
   [Alias('AppName')]
   [string]
   $AppPathNameMatchCondition = $null
)

begin
{
   $AppSharingPolicy = 'MTR AppSharing'
   $VideoPolicy = 'MTR Video'
   $AudioPoliy = 'MTR Audio'
}

process
{
   if ($pscmdlet.ShouldProcess('QoS-Settings', 'Apply'))
   {
      #region Audio
      if (-not (Get-NetQosPolicy -Name $AudioPoliy -ErrorAction SilentlyContinue -WarningAction SilentlyContinue))
      {
         try
         {
            # Splat the parameters
            $paramNewNetQosPolicy = @{
               NetworkProfile               = 'All'
               IPSrcPortStartMatchCondition = 50000
               IPSrcPortEndMatchCondition   = 50019
               DSCPAction                   = 46
               IPProtocolMatchCondition     = 'Both'
               Name                         = $AudioPoliy
               Confirm                      = $false
               WarningAction                = 'Continue'
               ErrorAction                  = 'Stop'
            }

            # Do we have an application name?
            if ($AppPathNameMatchCondition)
            {
               $paramNewNetQosPolicy.Add('AppPathNameMatchCondition', $AppPathNameMatchCondition)
            }

            $null = (New-NetQosPolicy @paramNewNetQosPolicy)
         }
         catch
         {
            Write-Warning -Message ('Unable to apply {0} QoS Poliy' -f $AudioPoliy)
         }
      }
      #endregion Audio

      #region Video
      if (-not (Get-NetQosPolicy -Name $VideoPolicy -ErrorAction SilentlyContinue -WarningAction SilentlyContinue))
      {
         try
         {
            # Splat the parameters
            $paramNewNetQosPolicy = @{
               NetworkProfile               = 'All'
               IPSrcPortStartMatchCondition = 50020
               IPSrcPortEndMatchCondition   = 50039
               DSCPAction                   = 34
               IPProtocolMatchCondition     = 'Both'
               Name                         = $VideoPolicy
               Confirm                      = $false
               WarningAction                = 'Continue'
               ErrorAction                  = 'Stop'
            }

            # Do we have an application name?
            if ($AppPathNameMatchCondition)
            {
               $paramNewNetQosPolicy.Add('AppPathNameMatchCondition', $AppPathNameMatchCondition)
            }

            $null = (New-NetQosPolicy @paramNewNetQosPolicy)
         }
         catch
         {
            Write-Warning -Message ('Unable to apply {0} QoS Poliy' -f $VideoPolicy)
         }
      }
      #endregion Video

      #region AppSharing
      if (-not (Get-NetQosPolicy -Name $AppSharingPolicy -ErrorAction SilentlyContinue -WarningAction SilentlyContinue))
      {
         try
         {
            # Splat the parameters
            $paramNewNetQosPolicy = @{
               NetworkProfile               = 'All'
               IPSrcPortStartMatchCondition = 50040
               IPSrcPortEndMatchCondition   = 50059
               DSCPAction                   = 28
               IPProtocolMatchCondition     = 'Both'
               Name                         = $AppSharingPolicy
               Confirm                      = $false
               WarningAction                = 'Continue'
               ErrorAction                  = 'Stop'
            }

            # Do we have an application name?
            if ($AppPathNameMatchCondition)
            {
               $paramNewNetQosPolicy.Add('AppPathNameMatchCondition', $AppPathNameMatchCondition)
            }

            $null = (New-NetQosPolicy @paramNewNetQosPolicy)
         }
         catch
         {
            Write-Warning -Message ('Unable to apply {0} QoS Poliy' -f $AppSharingPolicy)
         }
      }
      #end AppSharing
   }
}