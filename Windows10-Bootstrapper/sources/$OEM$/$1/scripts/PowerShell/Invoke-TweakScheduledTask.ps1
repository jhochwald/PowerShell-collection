#requires -Version 2.0 -Modules ScheduledTasks

<#
      .SYNOPSIS
      Cleanup some scheduled tasks

      .DESCRIPTION
      Cleanup some scheduled tasks, mostly auto update related

      .NOTES
      The Auto updates are great! But we use Choco and our own solution to deploy updates.

      Version 1.0.0

      .LINK
      http://enatec.io
#>
[CmdletBinding(ConfirmImpact = 'Low')]
param ()

begin
{
   Write-Output -InputObject 'Cleanup some scheduled tasks'

   #region Defaults
   $SCT = 'SilentlyContinue'
   #endregion Defaults
}

process
{
   # Disable the Brave (Browser) Updater Tasks
   $paramGetScheduledTask = @{
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   $paramDisableScheduledTask = @{
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   $null = (Get-ScheduledTask @paramGetScheduledTask | Where-Object -FilterScript {
         (($_.TaskName -like 'BraveSoftwareUpdateTask*') -and ($_.State -ne 'Disabled'))
      } | Disable-ScheduledTask @paramDisableScheduledTask)

   # Disable the Google Chrome (Browser) Updater Tasks
   $paramGetScheduledTask = @{
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   $paramDisableScheduledTask = @{
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   $null = (Get-ScheduledTask @paramGetScheduledTask | Where-Object -FilterScript {
         (($_.TaskName -like 'GoogleUpdateTaskMachine*') -and ($_.State -ne 'Disabled'))
      } | Disable-ScheduledTask @paramDisableScheduledTask)

   <#
         # Disable the Microsoft Chromium Edge (Browser) Updater Tasks
         $paramGetScheduledTask = @{
         ErrorAction   = $SCT
         WarningAction = $SCT
         }
         $paramDisableScheduledTask = @{
         ErrorAction   = $SCT
         WarningAction = $SCT
         }
         $null = (Get-ScheduledTask @paramGetScheduledTask | Where-Object -FilterScript {
         (($_.TaskName -like 'MicrosoftEdgeUpdateTaskMachine*') -and ($_.State -ne 'Disabled'))
         } | Disable-ScheduledTask @paramDisableScheduledTask)
   #>

   # Disable the HP WarrantyChecker Tasks
   $paramGetScheduledTask = @{
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   $paramDisableScheduledTask = @{
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   $null = (Get-ScheduledTask @paramGetScheduledTask | Where-Object -FilterScript {
         (($_.TaskName -like 'WarrantyChecker*') -and ($_.State -ne 'Disabled'))
      } | Disable-ScheduledTask @paramDisableScheduledTask)

   # Disable the Firefox Default Browser Agent Tasks
   $paramGetScheduledTask = @{
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   $paramDisableScheduledTask = @{
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   $null = (Get-ScheduledTask @paramGetScheduledTask | Where-Object -FilterScript {
         (($_.TaskName -like 'Firefox Default Browser Agent*') -and ($_.State -ne 'Disabled'))
      } | Disable-ScheduledTask @paramDisableScheduledTask)
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
