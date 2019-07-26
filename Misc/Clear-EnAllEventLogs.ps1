function Clear-EnAllEventLogs
{
   <#
         .SYNOPSIS
         AllEventLlogs

         .DESCRIPTION
         AllEventLlogs

         .PARAMETER ComputerName
         Computer Name

         .EXAMPLE
         PS C:\> Clear-EnAllEventLogs

         .NOTES
         Additional information about the function.
   #>
   [CmdletBinding(ConfirmImpact = 'Medium',
   SupportsShouldProcess)]
   param
   (
      [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
      [string[]]
      $ComputerName = "$env:COMPUTERNAME"
   )

   process
   {

      foreach ($SingleComputerName in $ComputerName)
      {
         if ($pscmdlet.ShouldProcess($SingleComputerName, 'Cleanup All EventLogs'))
         {
            $paramGetEventLog = @{
               ComputerName = $SingleComputerName
               List         = $true
            }
            $null = (Get-EventLog @paramGetEventLog | ForEach-Object -Process {
                  if ($_.Entries)
                  {
                     $paramClearEventLog = @{
                        LogName     = $_.Log
                        Confirm     = $false
                        ErrorAction = 'SilentlyContinue'
                     }
                     $null = (Clear-EventLog @paramClearEventLog)
                  }
            })
         }
      }
   }
}
Clear-EnAllEventLogs
