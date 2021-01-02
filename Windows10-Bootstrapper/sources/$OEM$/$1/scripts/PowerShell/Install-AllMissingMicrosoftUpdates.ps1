#requires -Version 3.0 -Modules PSWindowsUpdate -RunAsAdministrator

<#
   .SYNOPSIS
   Install all missing Microsoft updated

   .DESCRIPTION
   Install all missing Microsoft updated using the PSWindowsUpdate module

   .NOTES
   Version 1.0.3

   .LINK
   http://enatec.io
#>
[CmdletBinding(ConfirmImpact = 'Low')]
param ()

begin
{
   Write-Output -InputObject 'Install all missing Microsoft updated'

   #region Defaults
   $SCT = 'SilentlyContinue'
   #endregion Defaults

   if (Get-Command -Name 'Set-MpPreference' -ErrorAction $SCT)
   {
      $null = (Set-MpPreference -EnableControlledFolderAccess Disabled -Force -ErrorAction $SCT)
   }

   #region HelperFunctions
   function Test-GetWUServiceManager
   {
      <#
         .SYNOPSIS
         Check if WUServiceManager is configured

         .DESCRIPTION
         Check if WUServiceManager is configured

         .EXAMPLE
         PS C:\> Test-GetWUServiceManager

         .NOTES
         Additional information about the function.
      #>
      [CmdletBinding(ConfirmImpact = 'None',
         SupportsShouldProcess)]
      [OutputType([bool])]
      param ()

      begin
      {
         #region Defaults
         $SCT = 'SilentlyContinue'
         $ServiceID = '7971f918-a847-4430-9279-4a52d1efe18d'
         #endregion Defaults
      }

      process
      {
         $paramGetWUServiceManager = @{
            ComputerName = $env:COMPUTERNAME
            ServiceID    = $ServiceID
            ErrorAction  = $SCT
         }
         $WUServiceManager = (Get-WUServiceManager @paramGetWUServiceManager)

         if (-not ($WUServiceManager))
         {
            $paramAddWUServiceManager = @{
               ComputerName = $env:COMPUTERNAME
               ServiceID    = $ServiceID
               Confirm      = $false
               ErrorAction  = $SCT
            }
            $null = (Add-WUServiceManager @paramAddWUServiceManager)

            return $false
         }
         else
         {
            return $true
         }
      }
   }

   function Invoke-GetWindowsUpdate
   {
      <#
            .SYNOPSIS
            Wrapper for Get-WindowsUpdate

            .DESCRIPTION
            Wrapper for Get-WindowsUpdate

            .EXAMPLE
            PS C:\> Invoke-GetWindowsUpdate

            .NOTES
            Additional information about the function.
         #>
      [CmdletBinding(ConfirmImpact = 'Low',
         SupportsShouldProcess)]
      param ()

      begin
      {
         #region Defaults
         $SCT = 'SilentlyContinue'
         #endregion Defaults

         $paramGetWindowsUpdate = @{
            ComputerName    = $env:COMPUTERNAME
            MicrosoftUpdate = $true
            Install         = $true
            ForceInstall    = $true
            IgnoreUserInput = $true
            AcceptAll       = $true
            AutoReboot      = $false
            IgnoreReboot    = $true
            Criteria        = "IsHidden=0 and IsInstalled=0 and Type='Software'"
            WhatIf          = $false
            Verbose         = $true
            ErrorAction     = $SCT
            WarningAction   = $SCT
         }
      }

      process
      {
         $null = (Get-WindowsUpdate @paramGetWindowsUpdate)
      }
   }
   #endregion HelperFunctions
}

process
{
   if (Test-GetWUServiceManager -ErrorAction $SCT)
   {
      # Stop Search - Gain performance
      $paramStopService = @{
         Force       = $true
         Confirm     = $false
         ErrorAction = $SCT
      }

      $paramGetService = @{
         Name        = 'WSearch'
         ErrorAction = $SCT
      }
      $null = (Get-Service @paramGetService | Where-Object {
            $_.Status -eq 'Running'
         } | Stop-Service @paramStopService)
      $null = (Invoke-GetWindowsUpdate -ErrorAction $SCT)
   }
   else
   {
      # Stop Search - Gain performance
      $paramStopService = @{
         Force       = $true
         Confirm     = $false
         ErrorAction = $SCT
      }
      $paramGetService = @{
         Name        = 'WSearch'
         ErrorAction = $SCT
      }
      $null = (Get-Service @paramGetService | Where-Object {
            $_.Status -eq 'Running'
         } | Stop-Service @paramStopService)

      # Retry to fix it
      $null = (Test-GetWUServiceManager -ErrorAction $SCT)

      $Retry = $true
   }

   if ($Retry -eq $true)
   {
      if (Test-GetWUServiceManager -ErrorAction $SCT)
      {
         # Stop Search - Gain performance
         $paramGetService = @{
            Name        = 'WSearch'
            ErrorAction = $SCT
         }
         $paramStopService = @{
            Force       = $true
            Confirm     = $false
            ErrorAction = $SCT
         }
         $null = (Get-Service @paramGetService | Where-Object {
               $_.Status -eq 'Running'
            } | Stop-Service @paramStopService)

         $null = (Invoke-GetWindowsUpdate -ErrorAction $SCT)
      }
      else
      {
         Write-Warning -Message 'Unable to apply the latest Microsoft updates, please check and apply them manually!' -WarningAction Stop
      }
   }
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
