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
