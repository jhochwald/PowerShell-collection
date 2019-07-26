#requires -Version 4.0
function Clear-EnAllEventLogsv2
{
   <#
         .SYNOPSIS
         AllEventLlogs
	
         .DESCRIPTION
         AllEventLlogs
	
         .PARAMETER ComputerName
         Computer Name
	
         .EXAMPLE
         PS C:\> Clear-EnAllEventLogsv2
	
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
            $null = ((Get-EventLog @paramGetEventLog).Where({
                     if ($_.Entries) 
                     {
                        $_
                     }
               }).ForEach({
                     $paramClearEventLog = @{
                        LogName     = $_.Log
                        Confirm     = $false
                        ErrorAction = 'SilentlyContinue'
                     }
                     $null = (Clear-EventLog @paramClearEventLog)
            }))
         }
      }
   }
}
Clear-EnAllEventLogsv2