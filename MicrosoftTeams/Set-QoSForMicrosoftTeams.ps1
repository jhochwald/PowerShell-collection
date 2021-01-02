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
      http://enatec.io
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
