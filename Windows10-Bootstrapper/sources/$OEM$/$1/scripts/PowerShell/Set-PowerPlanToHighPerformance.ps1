#requires -Version 2.0 -RunAsAdministrator

<#
   .SYNOPSIS
   Set the Windows Power Plan to High Performance

   .DESCRIPTION
   Set the Windows Power Plan to High Performance, it also disables Hybernation and System Standby

   .EXAMPLE
   PS C:\> .\Set-PowerPlanToHighPerformance.ps1

   .NOTES
   Works fine on Windows Server 2016 (Developed for server use) and Windows 10.

   Version 1.5.9

   .LINK
   http://enatec.io
#>
[CmdletBinding(ConfirmImpact = 'Low')]
param ()

begin
{
   Write-Output -InputObject 'Set the Windows Power Plan to High Performance'

   $SCT = 'SilentlyContinue'

   if (Get-Command -Name 'Set-MpPreference' -ErrorAction $SCT)
   {
      $null = (Set-MpPreference -EnableControlledFolderAccess Disabled -Force -ErrorAction $SCT)
   }
}

process
{
   # Stop Search - Gain performance
   $null = (Get-Service -Name 'WSearch' -ErrorAction $SCT | Where-Object -FilterScript {
         $_.Status -eq 'Running'
      } | Stop-Service -Force -Confirm:$false -ErrorAction $SCT)

   #region
   $null = (& "$env:windir\system32\powercfg.exe" /SETACTIVE 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c)
   #endregion

   #region Cleanup
   $ActivePowerPlan = $null
   $PowerPlanHighPowerState = $null
   #endregion Cleanup

   #region InformationGathering
   # Splat the parameters
   $paramGetWmiObject = @{
      Namespace   = 'root\cimv2\power'
      Class       = 'Win32_PowerPlan'
      ErrorAction = $SCT
   }

   # Gather the PowerPlan information
   $ActivePowerPlan = (Get-WmiObject @paramGetWmiObject | Select-Object -Property ElementName, InstanceID, IsActive)

   # Filter the 'High Performance' plan info
   $PowerPlanHighPowerState = $ActivePowerPlan | Where-Object -FilterScript {
      $_.InstanceID -eq 'Microsoft:PowerPlan\{8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c}'
   }
   #endregion InformationGathering

   #region CheckIfTheTweakIsNeeded
   if ($PowerPlanHighPowerState.IsActive -ne $true)
   {
      $null = (& "$env:windir\system32\powercfg.exe" /SETACTIVE 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c)
      $null = (& "$env:windir\system32\powercfg.exe" /SETACTIVE 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c)
   }
   #endregion CheckIfTheTweakIsNeeded

   #region Cleanup
   $PowerPlanHighPowerState = $null
   #endregion Cleanup

   #region Retest
   $PowerPlanHighPowerState = $ActivePowerPlan | Where-Object -FilterScript {
      $_.InstanceID -eq 'Microsoft:PowerPlan\{8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c}'
   }

   # Filter the 'High Performance' plan info
   if ($PowerPlanHighPowerState.IsActive -ne $true)
   {
      Write-Warning -Message "Unable to set the PowerPlan to 'High Performance'"
   }
   #endregion Retest

   #region NoStandBy
   $null = (& "$env:windir\system32\powercfg.exe" -change -standby-timeout-ac 0)
   #endregion NoStandBy

   #region DisableHybernationSupport
   $null = (& "$env:windir\system32\powercfg.exe" /HIBERNATE OFF)
   $null = (& "$env:windir\system32\powercfg.exe" -change -hibernate-timeout-ac 0)
   #endregion DisableHybernationSupport
}

end
{
   if (Get-Command -Name 'Set-MpPreference' -ErrorAction $SCT)
   {
      $null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction $SCT)
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
   - If you disagree with any of the Terms, and any Conditions declared: Just delete it and build your own solution
#>
#endregion DISCLAIMER
