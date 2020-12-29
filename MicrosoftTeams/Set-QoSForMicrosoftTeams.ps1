#requires -Version 3.0 -Modules NetQos -RunAsAdministrator
<#
      .SYNOPSIS
      Apply QoS Settings for Microsoft Teams

      .DESCRIPTION
      Apply Network Quality of Service (QoS) settings for Microsoft Teams.

      .PARAMETER AppPathNameMatchCondition
      Specifies the name by which an application is run, such as application.exe or %ProgramFiles%\application.exe application.

      .EXAMPLE
      PS C:\> .\Set-QoSForMicrosoftTeams.ps1

      .EXAMPLE
      PS C:\> .\Set-QoSForMicrosoftTeamsRoom.ps1 -AppPathNameMatchCondition 'Teams.exe'

      .NOTES
      Changelog:
      1.0.0: Initial Release (Adopted from Set-QoSForMicrosoftTeamsRoomDevices.ps1)

      Version 1.0.0

      .LINK
      Get-NetQosPolicy

      .LINK
      New-NetQosPolicy

      .LINK
      https://docs.microsoft.com/en-us/microsoftteams/qos-in-teams-clients

      .LINK
      http://beyond-datacenter.com
#>
[CmdletBinding(ConfirmImpact = 'Low',
SupportsShouldProcess)]
param
(
   [Parameter(ValueFromPipeline,
   ValueFromPipelineByPropertyName)]
   [Alias('AppName')]
   [string]
   $AppPathNameMatchCondition = 'Teams.exe'
)

begin
{
   Write-Output -InputObject 'Apply Network Quality of Service (QoS) settings for Microsoft Teams'

   #region Defaults
   $CNT = 'Continue'
   $STP = 'Stop'
   $SCT = 'SilentlyContinue'

   [string]$AppSharingPolicy = 'Microsoft Teams AppSharing'
   [string]$VideoPolicy = 'Microsoft Teams Video'
   [string]$AudioPoliy = 'Microsoft Teams Audio'
   #endregion Defaults
}

process
{
   if ($pscmdlet.ShouldProcess('QoS-Settings', 'Apply'))
   {
      #region Audio
      $paramGetNetQosPolicy = @{
         Name          = $AudioPoliy
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      if (-not (Get-NetQosPolicy @paramGetNetQosPolicy))
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
               WarningAction                = $CNT
               ErrorAction                  = $STP
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
      $paramGetNetQosPolicy = @{
         Name          = $VideoPolicy
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      if (-not (Get-NetQosPolicy @paramGetNetQosPolicy))
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
               WarningAction                = $CNT
               ErrorAction                  = $STP
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
      $paramGetNetQosPolicy = @{
         Name          = $AppSharingPolicy
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      if (-not (Get-NetQosPolicy @paramGetNetQosPolicy))
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
               WarningAction                = $CNT
               ErrorAction                  = $STP
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
      #endregion AppSharing
   }
}
