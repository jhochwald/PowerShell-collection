function ConvertTo-UnixTimeStamp
{
   <#
         .SYNOPSIS
         Converts a Datetime into a Unix Timestamp (Epochdate)

         .DESCRIPTION
         Converts a Datetime into a Unix Timestamp (Epochdate)

         .PARAMETER Date
         The Date String that shoul be converted, default is now (if none is given)

         .PARAMETER Milliseconds
         Should the Timestamp (Epochdate) in Miliseconds instead of Seconds?

         .EXAMPLE
         PS C:\> ConvertTo-UnixTimeStamp

         Converts the actual time into a Unix Timestamp (Epochdate)

         .EXAMPLE
         PS C:\> ConvertTo-UnixTimeStamp -Milliseconds

         Converts the actual time into a Unix Timestamp (Epochdate), in milliseconds

         .EXAMPLE
         PS C:\> ConvertTo-UnixTimeStamp -Date ((Get-Date).AddDays(-1))

         Covert the same time yesterday into a Unix Timestamp (Epochdate)

         .EXAMPLE
         PS C:\> ConvertTo-UnixTimeStamp -Date ((Get-Date).AddDays(-1)) -Milliseconds

         Covert the same time yesterday into a Unix Timestamp (Epochdate), in milliseconds

         .NOTES
         Added the 'UniFi' (Alias for the switch 'Milliseconds') because the API returns miliseconds instead of seconds
   #>

   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([long])]
   param
   (
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 0)]
      [ValidateNotNullOrEmpty()]
      [Alias('TimeStamp', 'DateTimeStamp')]
      [datetime]
      $Date = (Get-Date),
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 1)]
      [Alias('UniFi')]
      [switch]
      $Milliseconds = $false
   )

   begin
   {
      Write-Verbose -Message 'Start ConvertTo-UnixTimeStamp'

      # Call meta function
      $null = (Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState -ErrorAction SilentlyContinue -WarningAction SilentlyContinue)

      # Set some defaults (Never change this!!!)
      $UnixStartTime = '1/1/1970'

      # Cleanup
      $Result = $null
   }

   process
   {
      try
      {
         if ($Milliseconds)
         {
            $Result = ([long]((New-TimeSpan -Start (Get-Date -Date $UnixStartTime -ErrorAction Stop -WarningAction SilentlyContinue) -End (Get-Date -Date $Date -ErrorAction Stop -WarningAction SilentlyContinue) -ErrorAction Stop -WarningAction SilentlyContinue).TotalMilliseconds))
         }
         else
         {
            $Result = ([long]((New-TimeSpan -Start (Get-Date -Date $UnixStartTime -ErrorAction Stop -WarningAction SilentlyContinue) -End (Get-Date -Date $Date -ErrorAction Stop -WarningAction SilentlyContinue) -ErrorAction Stop -WarningAction SilentlyContinue).TotalSeconds))
         }
      }
      catch
      {
         #region ErrorHandler
         # get error record
         [Management.Automation.ErrorRecord]$e = $_

         # retrieve information about runtime error
         $info = [PSCustomObject]@{
            Exception = $e.Exception.Message
            Reason    = $e.CategoryInfo.Reason
            Target    = $e.CategoryInfo.TargetName
            Script    = $e.InvocationInfo.ScriptName
            Line	  = $e.InvocationInfo.ScriptLineNumber
            Column    = $e.InvocationInfo.OffsetInLine
         }

         Write-Verbose -Message $info

         Write-Error -Message ($info.Exception) -ErrorAction Stop

         # Only here to catch a global ErrorAction overwrite
         break
         #endregion ErrorHandler
      }
   }

   end
   {
      # Dump to the Console
      $Result

      Write-Verbose -Message 'Done ConvertTo-UnixTimeStamp'
   }
}
