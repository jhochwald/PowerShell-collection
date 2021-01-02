#requires -Version 2.0 -Modules ScheduledTasks

<#
      .SYNOPSIS
      Creates a Scheduled Task to keep all Chocolatey Packages up-to-date

      .DESCRIPTION
      Creates a Scheduled Task to keep all Chocolatey Packages up-to-date, it runs each time a user logs in to this system

      .NOTES
      Version 1.0.0

      .LINK
      http://enatec.io
#>
[CmdletBinding(ConfirmImpact = 'Low')]
param ()

begin
{
   Write-Output -InputObject 'Creates a Scheduled Task to keep all Chocolatey Packages up-to-date'

   #region Defaults
   $STP = 'Stop'
   $SCT = 'SilentlyContinue'
   #endregion Defaults

   # Define the Name
   $ScheduledTaskName = 'Run Choco Upgrade at Login'

   # Define the description as string
   $ScheduledTaskDescription = 'Scheduled Task to keep all Chocolatey Packages up-to-date'

   # See if choco.exe is available. If not, stop execution
   $paramGetCommand = @{
      Name          = 'choco.exe'
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   $chocoCmd = (Get-Command @paramGetCommand | Select-Object -ExpandProperty Source)
}

process
{
   try
   {
      if (-not ($chocoCmd))
      {
         Write-Error -Message 'Chocolatey executable not found' -ErrorAction $STP
      }
      else
      {
         $paramGetScheduledTask = @{
            TaskName      = $ScheduledTaskName
            ErrorAction   = $SCT
            WarningAction = $SCT
         }
         $null = (Get-ScheduledTask @paramGetScheduledTask | Unregister-ScheduledTask -Confirm:$false -ErrorAction $SCT)

         # What to execute
         $paramNewScheduledTaskAction = @{
            Execute     = $chocoCmd
            Argument    = 'upgrade all -y >NUL 2>&1'
            ErrorAction = $STP
         }
         $taskAction = (New-ScheduledTaskAction @paramNewScheduledTaskAction)

         # Trigegr when someone login
         $paramNewScheduledTaskTrigger = @{
            AtLogOn     = $true
            ErrorAction = $STP
         }
         $taskTrigger = (New-ScheduledTaskTrigger @paramNewScheduledTaskTrigger)

         # Delay the Task for one (1) minute
         $taskTrigger.Delay = 'PT1M'

         # Who run the task and what run level to use (System and Highest
         $paramNewScheduledTaskPrincipal = @{
            UserId      = 'SYSTEM'
            RunLevel    = 'Highest'
            ErrorAction = $STP
         }
         $taskUserPrincipal = (New-ScheduledTaskPrincipal @paramNewScheduledTaskPrincipal)

         # Win8 is the latest
         $paramNewScheduledTaskSettingsSet = @{
            Compatibility = 'Win8'
            ErrorAction   = $STP
         }
         $taskSettings = (New-ScheduledTaskSettingsSet @paramNewScheduledTaskSettingsSet)

         # Set up the new task
         $paramNewScheduledTask = @{
            Action      = $taskAction
            Principal   = $taskUserPrincipal
            Trigger     = $taskTrigger
            Settings    = $taskSettings
            Description = $ScheduledTaskDescription
            ErrorAction = $STP
         }
         $task = (New-ScheduledTask @paramNewScheduledTask)

         # Register the new task
         $paramRegisterScheduledTask = @{
            TaskName    = $ScheduledTaskName
            InputObject = $task
            Force       = $true
            TaskPath    = '\'
            ErrorAction = $STP
         }
         $null = (Register-ScheduledTask @paramRegisterScheduledTask)
      }
   }
   catch
   {
      Write-Error -Message 'Whoopsie' -ErrorAction $STP
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
