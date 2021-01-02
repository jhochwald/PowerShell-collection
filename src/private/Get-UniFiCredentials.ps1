function Get-UniFiCredentials
{
   <#
         .SYNOPSIS
         Read the API Credentials from the UniFi config file

         .DESCRIPTION
         Read the API Credentials from the UniFi config file

         .EXAMPLE
         PS C:\> Get-UniFiCredentials

         Read the API Credentials from the UniFi config file

         .NOTES
         Only import/read the username and password

         .LINK
         Get-UniFiConfig
   #>
   [CmdletBinding(ConfirmImpact = 'None')]
   param
   (
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 0)]
      [ValidateNotNullOrEmpty()]
      [Alias('UnifiConfig')]
      [string]
      $Path = '.\UniFiConfig.json'
   )

   begin
   {
      Write-Verbose -Message 'Start Get-UniFiCredentials'

      # Call meta function
      $null = (Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState -ErrorAction SilentlyContinue -WarningAction SilentlyContinue)

      # Cleanup
      $RawJson = $null
      $UnifiConfig = $null
   }

   process
   {
      try
      {
         Write-Verbose -Message 'Read the Config File'
         $RawJson = (Get-Content -Path $Path -Force -ErrorAction Stop -WarningAction SilentlyContinue)

         Write-Verbose -Message 'Convert the JSON config File to a PSObject'
         $UnifiConfig = ($RawJson | ConvertFrom-Json -ErrorAction Stop -WarningAction SilentlyContinue)
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

      # Cleanup
      $RawJson = $null

      Write-Verbose -Message 'Try to setup the API Credentials'

      if ((-not $UnifiConfig.Login.Username) -or (-not $UnifiConfig.Login.Password))
      {
         # Verbose stuff
         $Script:line = $_.InvocationInfo.ScriptLineNumber
         Write-Verbose -Message ('Error was in Line {0}' -f $line)

         # Bad news!
         Write-Error -Message 'Unable to setup the API Credentials, please check your config file!' -ErrorAction Stop

         # Only here to catch a global ErrorAction overwrite
         break
      }

      $ApiUsername = $null
      $ApiPassword = $null
      $Global:ApiUsername = $UnifiConfig.Login.Username
      $Global:ApiPassword = $UnifiConfig.Login.Password

      Write-Verbose -Message 'API Credentials set'
   }

   end
   {
      # Cleanup
      $RawJson = $null
      $UnifiConfig = $null

      Write-Verbose -Message 'Start Get-UniFiCredentials'
   }
}
