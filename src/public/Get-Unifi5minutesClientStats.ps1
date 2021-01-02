function Get-Unifi5minutesClientStats
{
   <#
         .SYNOPSIS
         Get user/client statistics in 5 minute segments

         .DESCRIPTION
         Get user/client statistics in 5 minute segments for a given client

         For convenience, we return the a bit more then the API, e.g. everything in KB, MB, GB, and TB instead of just bytes
         We also return real timestamps instead of the unix timestaps in miliseconds that the UniFi returns

         Sample output:
         Time          : 2/1/2019 3:45:00 PM
         rx_bytes      : 105.0
         rx_kb         : 0.10
         rx_mb         : 0.00
         rx_gb         : 0.00
         rx_tb         : 0.00
         rx_rate       : 650000.0
         rx_rate_mbps  : 634.77
         rx_retries    : 0
         rx_packets    : 2.5
         tx_bytes      : 213.0
         tx_kb         : 0.21
         tx_mb         : 0.00
         tx_gb         : 0.00
         tx_tb         : 0.00
         tx_rate       : 650000.0
         tx_rate_mbps  : 634.77
         tx_retries    : 1
         tx_packets    : 4.5
         Traffic_bytes : 318
         Traffic_kb    : 0.31
         Traffic_mb    : 0.00
         Traffic_gb    : 0.00
         Traffic_tb    : 0.00
         Signal        : -65
         Signal_plain  : -65.0

         In reality, we filter out all 0.00 values (e.g. tx_mb above)
         You can Filter for whatever parameter you like (e.g. with Select-Object)

         .PARAMETER UnifiSite
         ID of the client-device to be modified

         .PARAMETER Mac
         Client MAC address (required)

         .PARAMETER Start
         Startpoint in UniFi Unix timestamp in milliseconds

         .PARAMETER End
         Endpoint in UniFi Unix timestamp in milliseconds

         .PARAMETER Attributes
         array containing attributes (strings) to be returned, defaults to rx_bytes and tx_bytes

         .EXAMPLE
         PS C:\> Get-Unifi5minutesClientStats -Mac '78:8a:20:59:e6:88'

         Get user/client statistics in 5 minute segments for a given (78:8a:20:59:e6:88) user/client in the default site

         .EXAMPLE
         (Get-Unifi5minutesClientStats -Mac '78:8a:20:59:e6:88' -Start '1548971935421' -End '1548975579019')

         Get user/client statistics in 5 minute segments for a given (78:8a:20:59:e6:88) user/client in the default site for a given time period.

         .EXAMPLE
         (Get-Unifi5minutesClientStats -Mac '78:8a:20:59:e6:88' -Start '1548980058135')

         Get user/client statistics in 5 minute segments for a given (78:8a:20:59:e6:88) user/client in the default site for the last 60 minutes (was the timestamp while the sample was created)

         .EXAMPLE
         PS C:\> (Get-Unifi5minutesClientStats -Mac '78:8a:20:59:e6:88' -UnifiSite 'contoso')[-1]

         Get user/client statistics in 5 minute segments for a given (78:8a:20:59:e6:88) user/client in the site 'contoso'

         .EXAMPLE
         PS C:\> Get-Unifi5minutesClientStats -Mac '78:8a:20:59:e6:88' -Attributes 'rx_bytes', 'tx_bytes', 'signal', 'rx_rate', 'tx_rate', 'rx_retries', 'tx_retries', 'rx_packets', 'tx_packets')

         Get all Values from the API

         .NOTES
         Defaults to the past 12 hours.
         Make sure that the retention policy for 5 minutes stats is set to the correct value in the controller settings
         Ubiquiti announced this with the Controller version 5.8 - It will not work on older versions!
         Make sure that "Clients Historical Data" (Collect clients' historical data) has been enabled in the UniFi controller in "Settings/Maintenance"

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
      [Parameter(Mandatory,
            ValueFromPipeline,
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
      $End,
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 4)]
      [ValidateSet('rx_bytes', 'tx_bytes', 'signal', 'rx_rate', 'tx_rate', 'rx_retries', 'tx_retries', 'rx_packets', 'tx_packets', IgnoreCase = $true)]
      [Alias('attribs', 'UniFiAttributes')]
      [string[]]
      $Attributes
   )

   begin
   {
      Write-Verbose -Message 'Start Get-Unifi5minutesClientStats'

      # Set the defaults, if needed
      if (-not ($Attributes))
      {
         [string[]]$Attributes = 'rx_bytes', 'tx_bytes'
      }
      # ensure the attributes are lowercase (we ignore the case on the input for the user covinience)
      [string[]]$Attributes = ($Attributes).ToLower()

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
                     throw
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
         while ($RetryLoop -eq $false)
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
         attrs = ($Attributes + 'time')
         start = $Start
         end   = $End
         mac   = $Mac
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
         $ApiRequestUri = $ApiUri + 's/' + $UnifiSite + '/stat/report/5minutes.user'
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

         foreach ($item in $Session.data)
         {
            $outputAppend = [PSCustomObject][ordered]@{
               Time = ((ConvertFrom-UnixTimeStamp -TimeStamp ($item.time) -Milliseconds).ToLocalTime())
            }

            #region RX
            if ($item.rx_bytes)
            {
               $outputAppend | Add-Member -NotePropertyName rx_bytes -NotePropertyValue $item.rx_bytes

               if ((([math]::round($item.rx_bytes / 1KB, 2)) -ne '0.0') -or (([math]::round($item.rx_bytes / 1KB, 2)) -ne '0.00'))
               {
                  $outputAppend | Add-Member -NotePropertyName rx_kb -NotePropertyValue ([math]::round($item.rx_bytes / 1KB, 2))

                  if ((([math]::round($item.rx_bytes / 1MB, 2)) -ne '0.0') -or (([math]::round($item.rx_bytes / 1MB, 2)) -ne '0.00'))
                  {
                     $outputAppend | Add-Member -NotePropertyName rx_mb -NotePropertyValue ([math]::round($item.rx_bytes / 1MB, 2))

                     if ((([math]::round($item.rx_bytes / 1GB, 2)) -ne '0.0') -or (([math]::round($item.rx_bytes / 1GB, 2)) -ne '0.00'))
                     {
                        $outputAppend | Add-Member -NotePropertyName rx_gb -NotePropertyValue ([math]::round($item.rx_bytes / 1GB, 2))

                        if ((([math]::round($item.rx_bytes / 1TB, 2)) -ne '0.0') -or (([math]::round($item.rx_bytes / 1TB, 2)) -ne '0.00'))
                        {
                           $outputAppend | Add-Member -NotePropertyName rx_tb -NotePropertyValue ([math]::round($item.rx_bytes / 1TB, 2))
                        }
                     }
                  }
               }
            }

            if ($item.rx_rate)
            {
               $outputAppend | Add-Member -NotePropertyName rx_rate -NotePropertyValue $item.rx_rate

               if ((([math]::round($item.rx_rate / 1KB, 2)) -ne '0.0') -or (([math]::round($item.rx_rate / 1KB, 2)) -ne '0.00'))
               {
                  $outputAppend | Add-Member -NotePropertyName rx_rate_mbps -NotePropertyValue ([math]::round($item.rx_rate / 1KB, 2))
               }
            }

            # If 0.0 handler added
            if (($item.rx_retries) -or ($item.rx_retries -eq '0.0'))
            {
               $outputAppend | Add-Member -NotePropertyName rx_retries -NotePropertyValue ([INT]$item.rx_retries)
            }

            if ($item.rx_packets)
            {
               $outputAppend | Add-Member -NotePropertyName rx_packets -NotePropertyValue $item.rx_packets
            }
            #endregion RX

            #region TX
            if ($item.tx_bytes)
            {
               $outputAppend | Add-Member -NotePropertyName tx_bytes -NotePropertyValue $item.tx_bytes

               if ((([math]::round($item.tx_bytes / 1KB, 2)) -ne '0.0') -or (([math]::round($item.tx_bytes / 1KB, 2)) -ne '0.00'))
               {
                  $outputAppend | Add-Member -NotePropertyName tx_kb -NotePropertyValue ([math]::round($item.tx_bytes / 1KB, 2))

                  if ((([math]::round($item.tx_bytes / 1MB, 2)) -ne '0.0') -or (([math]::round($item.tx_bytes / 1MB, 2)) -ne '0.00'))
                  {
                     $outputAppend | Add-Member -NotePropertyName tx_mb -NotePropertyValue ([math]::round($item.tx_bytes / 1MB, 2))

                     if ((([math]::round($item.tx_bytes / 1GB, 2)) -ne '0.0') -or (([math]::round($item.tx_bytes / 1GB, 2)) -ne '0.00'))
                     {
                        $outputAppend | Add-Member -NotePropertyName tx_gb -NotePropertyValue ([math]::round($item.tx_bytes / 1GB, 2))

                        if ((([math]::round($item.tx_bytes / 1TB, 2)) -ne '0.0') -or (([math]::round($item.tx_bytes / 1TB, 2)) -ne '0.00'))
                        {
                           $outputAppend | Add-Member -NotePropertyName tx_tb -NotePropertyValue ([math]::round($item.tx_bytes / 1TB, 2))
                        }
                     }
                  }
               }
            }

            if ($item.tx_rate)
            {
               $outputAppend | Add-Member -NotePropertyName tx_rate -NotePropertyValue $item.tx_rate
               if ((([math]::round($item.tx_rate / 1KB, 2)) -ne '0.0') -or (([math]::round($item.tx_rate / 1KB, 2)) -ne '0.00'))
               {
                  $outputAppend | Add-Member -NotePropertyName tx_rate_mbps -NotePropertyValue ([math]::round($item.tx_rate / 1KB, 2))
               }
            }

            # If 0.0 handler added
            if (($item.tx_retries) -or ($item.tx_retries -eq '0.0'))
            {
               $outputAppend | Add-Member -NotePropertyName tx_retries -NotePropertyValue ([INT]$item.tx_retries)
            }

            if ($item.tx_packets)
            {
               $outputAppend | Add-Member -NotePropertyName tx_packets -NotePropertyValue $item.tx_packets
            }
            #endregion TX

            #region Traffic
            if (($item.rx_bytes) -and ($item.tx_bytes))
            {
               $outputAppend | Add-Member -NotePropertyName Traffic_bytes -NotePropertyValue ([math]::round(($item.rx_bytes + $item.tx_bytes)))

               if ((([math]::round(($item.rx_bytes + $item.tx_bytes) / 1KB, 2)) -ne '0.0') -or (([math]::round(($item.rx_bytes + $item.tx_bytes) / 1KB, 2)) -ne '0.00'))
               {
                  $outputAppend | Add-Member -NotePropertyName Traffic_kb -NotePropertyValue ([math]::round(($item.rx_bytes + $item.tx_bytes) / 1KB, 2))

                  if ((([math]::round(($item.rx_bytes + $item.tx_bytes) / 1MB, 2)) -ne '0.0') -or (([math]::round(($item.rx_bytes + $item.tx_bytes) / 1MB, 2)) -ne '0.00'))
                  {
                     $outputAppend | Add-Member -NotePropertyName Traffic_mb -NotePropertyValue ([math]::round(($item.rx_bytes + $item.tx_bytes) / 1MB, 2))

                     if ((([math]::round(($item.rx_bytes + $item.tx_bytes) / 1GB, 2)) -ne '0.0') -or (([math]::round(($item.rx_bytes + $item.tx_bytes) / 1GB, 2)) -ne '0.00'))
                     {
                        $outputAppend | Add-Member -NotePropertyName Traffic_gb -NotePropertyValue ([math]::round(($item.rx_bytes + $item.tx_bytes) / 1GB, 2))

                        if ((([math]::round(($item.rx_bytes + $item.tx_bytes) / 1TB, 2)) -ne '0.0') -or (([math]::round(($item.rx_bytes + $item.tx_bytes) / 1TB, 2)) -ne '0.00'))
                        {
                           $outputAppend | Add-Member -NotePropertyName Traffic_tb -NotePropertyValue ([math]::round(($item.rx_bytes + $item.tx_bytes) / 1TB, 2))
                        }
                     }
                  }
               }
            }
            #endregion Traffic

            #region Signal
            if ($item.signal)
            {
               $outputAppend | Add-Member -NotePropertyName Signal -NotePropertyValue ([math]::Truncate($item.signal))
               $outputAppend | Add-Member -NotePropertyName Signal_plain -NotePropertyValue $item.signal
            }
            #endregion Signal

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

      Write-Verbose -Message 'Done Get-Unifi5minutesClientStats'
   }
}
