function Set-UniFiDefaultRequestHeader
{
   <#
         .SYNOPSIS
         Set the default Header for all UniFi Requests

         .DESCRIPTION
         Set the default Header for all UniFi Requests

         .EXAMPLE
         PS C:\> Set-UniFiDefaultRequestHeader

         Set the default Header for all UniFi Requests

         .NOTES
         This is an internal helper function only
   #>
   [CmdletBinding(ConfirmImpact = 'None')]
   param ()

   begin
   {
      Write-Verbose -Message 'Start Set-UniFiDefaultRequestHeader'

      # Call meta function
      $null = (Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState -ErrorAction SilentlyContinue -WarningAction SilentlyContinue)

      # Cleanup
      $RestHeader = $null
   }

   process
   {
      Write-Verbose -Message 'Create the Default Request Header'

      $Global:RestHeader = @{
         'charset'    = 'utf-8'
         'Content-Type' = 'application/json'
      }

      Write-Verbose -Message ('Default Request Header is {0}' -f $RestHeader)
   }

   end {
      Write-Verbose -Message 'Done Set-UniFiDefaultRequestHeader'
   }
}
