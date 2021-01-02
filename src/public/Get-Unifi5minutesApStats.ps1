function Get-Unifi5minutesApStats
{
   <#
         .SYNOPSIS
         Get Access Point stats in 5 minute segments

         .DESCRIPTION
         Get the stats in 5 minute segments for all or just one access points in a given UniFi site
         For convenience, we return the traffic Megabytes and not in bytes (as the UniFi does it).
         We also return real timestamps instead of the unix timestaps that the UniFi returns

         .PARAMETER UnifiSite
         ID of the client-device to be modified

         .PARAMETER Mac
         Client MAC address

         .PARAMETER Start
         Startpoint in UniFi Unix timestamp in milliseconds

         .PARAMETER End
         Endpoint in UniFi Unix timestamp in milliseconds

         .EXAMPLE
         PS C:\> Get-Unifi5minutesApStats

         Get the stats in 5 minute segments for all access points in the default site

         .EXAMPLE
         PS C:\> Get-Unifi5minutesApStats -Mac '78:8a:20:59:e6:88'

         Get the stats in 5 minute segments for a given (78:8a:20:59:e6:88) access point in the default site

         .EXAMPLE
         (Get-Unifi5minutesApStats -Start '1548971935421' -End '1548975579019')

         Get the statistics for a given time period.

         .EXAMPLE
         (Get-Unifi5minutesApStats -Start '1548971935421')

         Get the statistics for the last 60 minutes (was the timestamp while the sample was created)

         .EXAMPLE
         PS C:\> Get-Unifi5minutesApStats -UnifiSite 'contoso' | Where-Object { $_.Traffic -ne '0.00' }

         Get the stats in 5 minute segments for all access points in the site 'contoso', if traffic is generated.

         .EXAMPLE
         PS C:\> (Get-Unifi5minutesApStats -UnifiSite 'contoso')[-1]

         Get the last stats in 5 minute segments for all access points in the site 'contoso'

         .NOTES
         Defaults to the past 12 hours.
         Make sure that the retention policy for 5 minutes stats is set to the correct value in the controller settings
         Ubiquiti announced this with the Controller version 5.5 - It will not work on older versions!

         .LINK
         Get-UniFiConfig

         .LINK
         Set-UniFiDefaultRequestHeader

         .LINK
         Invoke-UniFiApiLogin

         .LINK
         Invoke-RestMethod

         .LINK
         ConvertFrom-UnixTimeStamp

         .LINK
         ConvertTo-UnixTimeStamp
   #>

   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([psobject])]
   param
   (
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 0)]
      [ValidateNotNullOrEmpty()]
      [Alias('Site')]
      [string]
      $UnifiSite = 'default',
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 1)]
      [ValidateNotNullOrEmpty()]
      [Alias('UniFiMac', 'MacAddress')]
      [string]
      $Mac,
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 2)]
      [Alias('Startpoint', 'StartTime')]
      [String]
      $Start,
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 3)]
      [Alias('EndPoint', 'EndTime')]
      [string]
      $End
   )

   begin
   {
      Write-Verbose -Message 'Start Get-Unifi5minutesApStats'

      # Save Datestring to keep everything consitant
      $now = (Get-Date)

      if (-not ($Start))
      {
         $Start = (ConvertTo-UnixTimeStamp -Date ($now.AddHours(-12)) -Milliseconds)
      }

      if (-not ($End))
      {
         $End = (ConvertTo-UnixTimeStamp -Date $now -Milliseconds)
      }

      # Cleanup
      $Session = $null

      #region SafeProgressPreference
      # Safe ProgressPreference and Setup SilentlyContinue for the function
      $ExistingProgressPreference = ($ProgressPreference)
      $ProgressPreference = 'SilentlyContinue'
      #endregion SafeProgressPreference

      #region CheckSession
      if (-not (Get-UniFiIsAlive))
      {
         #region LoginCheckLoop
         # TODO: Move to config
         [int]$NumberOfRetries = '3'
         [int]$RetryTimer = '5'
         # Setup the Loop itself
         $RetryLoop = $false
         [int]$RetryCounter = '0'
         # Original code/idea was by Thomas Maurer
         do
         {
            try
            {
               # Try to Logout
               try
               {
                  if (-not (Get-UniFiIsAlive))
                  {
                     Throw
                  }
               }
               catch
               {
                  # We don't care about that
                  Write-Verbose -Message 'Logout failed'
               }

               # Try a Session check (login is inherited here within the helper function)
               if (-not (Get-UniFiIsAlive -ErrorAction Stop -WarningAction SilentlyContinue))
               {
                  Write-Error -Message 'Login failed' -ErrorAction Stop -Category AuthenticationError
               }

               # End the Loop
               $RetryLoop = $true
            }
            catch
            {
               if ($RetryCounter -gt $NumberOfRetries)
               {
                  Write-Warning -Message ('Could still not login, after {0} retries.' -f $NumberOfRetries)

                  # Stay in the Loop
                  $RetryLoop = $true
               }
               else
               {
                  if ($RetryCounter -eq 0)
                  {
                     Write-Warning -Message ('Could not login! Retrying in {0} seconds.' -f $RetryTimer)
                  }
                  else
                  {
                     Write-Warning -Message ('Retry {0} of {1} failed. Retrying in {2} seconds.' -f $RetryCounter, $NumberOfRetries, $RetryTimer)
                  }

                  $null = (Start-Sleep -Seconds $RetryTimer)

                  $RetryCounter = $RetryCounter + 1
               }
            }
         }
         While ($RetryLoop -eq $false)
         #endregion LoginCheckLoop
      }
      #endregion CheckSession

      #region ReCheckSession
      if (-not ($RestSession))
      {
         # Restore ProgressPreference
         $ProgressPreference = $ExistingProgressPreference

         Write-Error -Message 'Unable to login! Check the connection to the controller, SSL certificates, and your credentials!' -ErrorAction Stop -Category AuthenticationError

         # Only here to catch a global ErrorAction overwrite
         break
      }
      #endregion ReCheckSession

      #region MacHandler
      if ($Mac)
      {
         [string]$Mac = (ConvertTo-UniFiValidMacAddress -Mac $Mac)
      }
      #endregion MacHandler

      #region ApiRequestBodyInput
      $Script:ApiRequestBodyInput = [PSCustomObject][ordered]@{
         attrs = 'bytes', 'num_sta', 'time'
         start = $Start
         end   = $End
      }

      if ($Mac)
      {
         $ApiRequestBodyInput | Add-Member -MemberType NoteProperty -Name mac -Value $Mac
      }
      #endregion ApiRequestBodyInput

      # Call meta function
      $paramGetCallerPreference = @{
         Cmdlet        = $PSCmdlet
         SessionState  = $ExecutionContext.SessionState
         ErrorAction   = 'SilentlyContinue'
         WarningAction = 'SilentlyContinue'
      }
      $null = (Get-CallerPreference @paramGetCallerPreference)
   }

   process
   {
      try
      {
         #region ReadConfig
         Write-Verbose -Message 'Read the Config'

         $null = (Get-UniFiConfig)
         #endregion ReadConfig

         #region CertificateHandler
         Write-Verbose -Message ('Certificate check - Should be {0}' -f $ApiSelfSignedCert)

         [Net.ServicePointManager]::ServerCertificateValidationCallback = {
            $ApiSelfSignedCert
         }
         #endregion CertificateHandler

         #region SetRequestHeader
         Write-Verbose -Message 'Set the API Call default Header'

         $null = (Set-UniFiDefaultRequestHeader)
         #endregion SetRequestHeader

         #region SetRequestURI
         Write-Verbose -Message 'Create the Request URI'
         $ApiRequestUri = $ApiUri + 's/' + $UnifiSite + '/stat/report/5minutes.ap'
         Write-Verbose -Message ('URI: {0}' -f $ApiRequestUri)
         #endregion SetRequestURI

         #region ApiRequestBody
         $paramConvertToJson = @{
            InputObject   = $ApiRequestBodyInput
            Depth         = 5
            ErrorAction   = 'Stop'
            WarningAction = 'SilentlyContinue'
         }

         $ApiRequestBodyInput = $null

         $Script:ApiRequestBody = (ConvertTo-Json @paramConvertToJson)
         #endregion ApiRequestBody

         #region Request
         Write-Verbose -Message 'Send the Request'

         $paramInvokeRestMethod = @{
            Method        = 'Post'
            Uri           = $ApiRequestUri
            Headers       = $RestHeader
            Body          = $ApiRequestBody
            ErrorAction   = 'SilentlyContinue'
            WarningAction = 'SilentlyContinue'
            WebSession    = $RestSession
         }
         $Session = (Invoke-RestMethod @paramInvokeRestMethod)

         Write-Verbose -Message "Session Meta: $(($Session.meta.rc | Out-String).Trim())"

         Write-Verbose -Message "Session Data: $("`n" + ($Session.data | Out-String).Trim())"
         #endregion Request

         #region CreateOutput
         $output = @()

         foreach($item in $Session.data)
         {
            $outputAppend = [PSCustomObject][ordered]@{
               AccesPoint = $item.ap
               Time       = ((ConvertFrom-UnixTimeStamp -TimeStamp ($item.time) -Milliseconds).ToLocalTime())
               Clients    = $item.num_sta
               Traffic    = ([math]::round($item.bytes / 1MB, 2))
            }
            # Sppend to the output
            $output += $outputAppend

            # Cleanup
            $outputAppend = $null
         }

         # Resort to make sure everything is in the right order :)
         $output = $output | Sort-Object Time
         #endregion CreateOutput
      }
      catch
      {
         # Try to Logout
         try
         {
            $null = (Invoke-UniFiApiLogout -ErrorAction SilentlyContinue -WarningAction SilentlyContinue)
         }
         catch
         {
            # We don't care about that
            Write-Verbose -Message 'Logout failed'
         }

         #region ErrorHandler
         # get error record
         [Management.Automation.ErrorRecord]$e = $_

         # retrieve information about runtime error
         $info = [PSCustomObject]@{
            Exception = $e.Exception.Message
            Reason    = $e.CategoryInfo.Reason
            Target    = $e.CategoryInfo.TargetName
            Script    = $e.InvocationInfo.ScriptName
            Line      = $e.InvocationInfo.ScriptLineNumber
            Column    = $e.InvocationInfo.OffsetInLine
         }

         Write-Verbose -Message $info

         Write-Error -Message ($info.Exception) -ErrorAction Stop

         # Only here to catch a global ErrorAction overwrite
         break
         #endregion ErrorHandler
      }
      finally
      {
         #region ResetSslTrust
         # Reset the SSL Trust (make sure everything is back to default)
         [Net.ServicePointManager]::ServerCertificateValidationCallback = $null
         #endregion ResetSslTrust

         #region RestoreProgressPreference
         $ProgressPreference = $ExistingProgressPreference
         #endregion RestoreProgressPreference
      }

      # check result
      if ($Session.meta.rc -ne 'ok')
      {
         # Verbose stuff
         $Script:line = $_.InvocationInfo.ScriptLineNumber
         Write-Verbose -Message ('Error was in Line {0}' -f $line)
         Write-Verbose -Message ('Error was {0}' -f $Session.meta.rc)

         # Error Message
         Write-Error -Message 'Unable to Login' -ErrorAction Stop

         # Only here to catch a global ErrorAction overwrite
         break
      }
   }

   end
   {
      # Dump the Result
      $output

      # Cleanup
      $Session = $null
      $output = $null

      #region RestoreProgressPreference
      $ProgressPreference = $ExistingProgressPreference
      #endregion RestoreProgressPreference

      Write-Verbose -Message 'Done Get-Unifi5minutesApStats'
   }
}
