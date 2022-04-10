#requires -Version 3.0 -RunAsAdministrator

<#
   .SYNOPSIS
   Set the Windows Power Plan based on the computer type

   .DESCRIPTION
   Set the Windows Power Plan based on the computer type, it also set the Hybernation
   With Version 1.1 we introduced Support for the Parallels Power Schema

   .EXAMPLE
   PS C:\> .\Set-PowerPlanToAuto.ps1

   .NOTES

   Version 1.1.0

   .LINK
   http://beyond-datacenter.com
#>
[CmdletBinding(ConfirmImpact = 'Low')]
param ()

begin
{
   Write-Output -InputObject 'Set the Windows Power Plan to Auto'

   #region
   $SCT = 'SilentlyContinue'
   #endregion

   #region
   $paramGetWmiObject = @{
      Namespace   = 'root\cimv2\power'
      Class       = 'Win32_PowerPlan'
      ErrorAction = $SCT
   }
   #endregion

   #region
   if (Get-Command -Name 'Set-MpPreference' -ErrorAction $SCT)
   {
      $null = (Set-MpPreference -EnableControlledFolderAccess Disabled -Force -ErrorAction $SCT)
   }
   #endregion

   #region
   function Get-ActiveWindowsPowerPlan
   {
      <#
      .SYNOPSIS
      Get the active Windows Power Plan

      .DESCRIPTION
      Get the active Windows Power Plan

      .PARAMETER AllPowerPlans
      All Power Plans that Windows knows about

      .EXAMPLE
      PS C:\> Get-ActiveWindowsPowerPlan

      .NOTES
      Internal Helper
      #>
      [CmdletBinding(ConfirmImpact = 'None')]
      [OutputType([string])]
      param
      (
         [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 0,
            HelpMessage = 'Object with all Power Plans')]
         [ValidateNotNullOrEmpty()]
         [psobject]
         $AllPowerPlans
      )

      begin
      {
         #region
         $ActivePowerPlan = $null
         #endregion
      }

      process
      {
         #$AllPowerPlans = (Get-WmiObject @paramGetWmiObject | Select-Object -Property ElementName, InstanceID, IsActive)
         $ActivePowerPlan = ($AllPowerPlans | Where-Object -FilterScript {
               $PSItem.IsActive -eq $true
            } | Select-Object -ExpandProperty ElementName)
      }

      end
      {
         $ActivePowerPlan
      }
   }
   #endregion
}

process
{
   # Get all Power Plans
   $AllPowerPlans = (Get-WmiObject @paramGetWmiObject | Select-Object -Property ElementName, InstanceID, IsActive)

   # Get the active Power Plan
   $ActivePowerPlan = (Get-ActiveWindowsPowerPlan -AllPowerPlans $AllPowerPlans -ErrorAction $SCT)

   Write-Verbose -Message ('Active Power Plan: {0}' -f $ActivePowerPlan)

   if ((($AllPowerPlans).ElementName) -ccontains 'Parallels')
   {
      # Looks like this system is a VM on Parallels
      $RunOnParallels = ($AllPowerPlans | Where-Object {
            $PSItem.ElementName -ccontains 'Parallels'
         } | Select-Object -ExpandProperty InstanceID)

      # Extract the ID of the Power Schema
      $RunOnParallels = ([Regex]::Matches($RunOnParallels, '(?<={)(.*?)(?=})') | Select-Object -ExpandProperty Value)

      # Activate the Parallels Schema
      $null = (& "$env:windir\system32\powercfg.exe" /SETACTIVE $RunOnParallels)

      # Disable Hybernation
      $null = (& "$env:windir\system32\powercfg.exe" /HIBERNATE OFF)
   }
   elseif ((Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction $SCT).PCSystemType -eq 2)
   {
      # Balanced for laptop
      $null = (& "$env:windir\system32\powercfg.exe" /SETACTIVE SCHEME_BALANCED)

      # Enable Hybernation
      $null = (& "$env:windir\system32\powercfg.exe" /HIBERNATE ON)
   }
   else
   {
      # High performance for desktop
      $null = (& "$env:windir\system32\powercfg.exe" /SETACTIVE SCHEME_MIN)

      # Disable Hybernation
      $null = (& "$env:windir\system32\powercfg.exe" /HIBERNATE OFF)
   }

   # Get all Power Plans
   $AllPowerPlans = (Get-WmiObject @paramGetWmiObject | Select-Object -Property ElementName, InstanceID, IsActive)

   # Get the active Power Plan
   $ActivePowerPlan = (Get-ActiveWindowsPowerPlan -AllPowerPlans $AllPowerPlans -ErrorAction $SCT)

   Write-Verbose -Message ('Active Power Plan: {0}' -f $ActivePowerPlan)
}

end
{
   #region
   if (Get-Command -Name 'Set-MpPreference' -ErrorAction $SCT)
   {
      $null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction $SCT)
   }
   #endregion
}

#region LICENSE
<#
   BSD 3-Clause License

   Copyright (c) 2022, Beyond Datacenter
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
