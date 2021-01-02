#requires -Version 3.0 -Modules CimCmdlets

<#
      .SYNOPSIS
      Simple script to generate a lot of CPU load

      .DESCRIPTION
      Generate a lot of CPU load based on the number logical processors

      .PARAMETER Overload
      Double the number of jobs.
      Normally the script will start one job per logical Processors,
      this switch will double the number. This will overload the server.

      Hint: If your server supports Hyper-threading,
      the number of logical Processors is the doubled amount of cores!

      WARNING: The system might become unstable!

      .EXAMPLE
      PS C:\> .\invoke-CPUWorkload.ps1

      .NOTES
      Nothing fancy, just a plain and easy script to generate a lot of load.
      Created to do a stress test on new servers.
#>
[CmdletBinding(ConfirmImpact = 'Medium')]
param
(
   [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
   [Alias('Double')]
   [switch]
   $Overload
)

#region ClearRunningCPUWorkloadJobs
function Clear-RunningCPUWorkloadJobs
{
   <#
         .SYNOPSIS
         Get, stop, and remove all running CPUWorkloadJobs

         .DESCRIPTION
         Get, stop, and remove all running CPUWorkloadJobs

         .EXAMPLE
         PS C:\> Clear-RunningCPUWorkloadJobs

         .NOTES
         Internal Helper for the "Generate a log of CPU load" script
   #>

   [CmdletBinding(ConfirmImpact = 'Low')]
   param ()

   # Get a list of running jobs
   $CPUWorkloadJobList = (Get-Job -Name 'CPUWorkload_*' -ErrorAction SilentlyContinue)

   # Cleanup
   if ($CPUWorkloadJobList)
   {
      $null = ($CPUWorkloadJobList | Stop-Job -ErrorAction SilentlyContinue)
      $null = ($CPUWorkloadJobList | Receive-Job -AutoRemoveJob -Wait -ErrorAction SilentlyContinue)
   }
}
#endregion ClearRunningCPUWorkloadJobs

# Get the number of logical processors
[int]$NumThreads = (Get-CimInstance -ClassName Win32_Processor | Select-Object -ExpandProperty NumberOfLogicalProcessors)

if (($PSCmdlet.MyInvocation.BoundParameters['Overload']).IsPresent)
{
   $NumThreads = ($NumThreads * 2)

   Write-Warning -Message 'You decide to overload the system! This may cause the system to become unstable.'
}

# Stop and cleanup, if needed
$null = (Clear-RunningCPUWorkloadJobs)

# Start to generate load, based on the system capabilities
foreach ($loop in 1 .. $NumThreads)
{
   $null = (Start-Job -Name ('CPUWorkload_' + $loop) -ScriptBlock {
         [float]$result = 1

         while ($true)
         {
            [float]$x = Get-Random -Minimum 1 -Maximum 999999999

            $result = $result * $x
         }
      })
}

<#
      We start the work with Start-Job (in the background)
      If this can cause an overload, the system might become unstable and it might take very long to respond.

      CTRL+C will not end background execution of worker threads, it will just kill this script
#>
Read-Host -Prompt 'Press any key to exit the test.'

# Stop and cleanup, if needed
$null = (Clear-RunningCPUWorkloadJobs)

# Ensure all jobs are gone
$null = (Clear-RunningCPUWorkloadJobs)

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
