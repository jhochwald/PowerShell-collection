function Get-UnifiHourlyGatewayStats
{
   <#
         .SYNOPSIS
         Get hourly statistics for the USG

         .DESCRIPTION
         Get hourly statistics for the USG (UniFi Secure Gateway)

         For convenience, we return the a bit more then the API, e.g. everything in KB, MB, GB, and TB instead of just bytes
         We also return real timestamps instead of the unix timestaps in miliseconds that the UniFi returns

         Sample output:
         Time           : 2/1/2019 6:00:00 PM
         mem            : 33.29
         cpu            : 3.07
         lan-rx_errors  : 0
         lan-rx_bytes   : 50242070.25
         lan-rx_kb      : 49064.52
         lan-rx_mb      : 47.91
         lan-rx_gb      : 0.05
         lan-rx_packets : 298575.0
         lan-rx_dropped : 0
         wan-rx_errors  : 0
         wan-rx_packets : 64705.74999999999
         wan-rx_dropped : 0
         lan-tx_errors  : 0
         lan-tx_bytes   : 82506381.25
         lan-tx_kb      : 80572.64
         lan-tx_mb      : 78.68
         lan-tx_gb      : 0.08
         lan-tx_packets : 310632.50000000006
         lan-tx_dropped : 0
         wan-tx_errors  : 0
         wan-tx_bytes   : 16211129
         wan-tx_kb      : 15831.18
         wan-tx_mb      : 15.46
         wan-tx_gb      : 0.02
         wan-tx_packets : 42872.99999999999
         wan-tx_dropped : 0

         You might filter out all the 0 values, we keep them to prevent any null pointer expetions!

         You can Filter for whatever parameter you like (e.g. with Select-Object)

         BUG: The loadavg_ attributes are not working at the moment. The UniFi SDN Controller does not return any values for them!

         .PARAMETER UnifiSite
         ID of the client-device to be modified

         .PARAMETER Start
         Startpoint in UniFi Unix timestamp in milliseconds

         .PARAMETER End
         Endpoint in UniFi Unix timestamp in milliseconds

         .PARAMETER Attributes
         array containing attributes (strings) to be returned, defaults to mem, cpu, and zime (Time is mandatory)

         .EXAMPLE
         PS C:\> Get-UnifiHourlyGatewayStats

         Get hourly statistics for the USG (UniFi Secure Gateway) in the default site

         .EXAMPLE
         (Get-UnifiHourlyGatewayStats -Start '1548971935421' -End '1548975579019')

         Get hourly statistics for the USG (UniFi Secure Gateway) in the default site for a given time period.

         .EXAMPLE
         (Get-UnifiHourlyGatewayStats -Start '1548980058135')

         Get hourly statistics for the USG (UniFi Secure Gateway) in the default site for the last 60 minutes (was the timestamp while the sample was created)

         .EXAMPLE
         PS C:\> (Get-UnifiHourlyGatewayStats -UnifiSite 'contoso')[-1]

         Get hourly statistics for the USG (UniFi Secure Gateway) in the site 'contoso'

         .EXAMPLE
         PS C:\> Get-UnifiHourlyGatewayStats -Attributes 'mem','cpu','loadavg_5','lan-rx_errors','wan-rx_errors','lan-tx_errors','wan-tx_errors','lan-rx_bytes','wan-rx_bytes','lan-tx_bytes','wan-tx_bytes','lan-rx_packets','wan-rx_packets','lan-tx_packets','wan-tx_packets','lan-rx_dropped','wan-rx_dropped','lan-tx_dropped','wan-tx_dropped')

         Get all Values from the API

         .NOTES
         Defaults to the past week (7*24 hours)

         A USG (UniFi Secure Gateway) is required on the site you querry!

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
      [Alias('Startpoint', 'StartTime')]
      [String]
      $Start,
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 2)]
      [Alias('EndPoint', 'EndTime')]
      [string]
      $End,
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 3)]
      [ValidateSet('mem','cpu','loadavg_5','lan-rx_errors','wan-rx_errors','lan-tx_errors','wan-tx_errors','lan-rx_bytes','wan-rx_bytes','lan-tx_bytes','wan-tx_bytes','lan-rx_packets','wan-rx_packets','lan-tx_packets','wan-tx_packets','lan-rx_dropped','wan-rx_dropped','lan-tx_dropped','wan-tx_dropped', IgnoreCase = $true)]
      [Alias('attribs', 'UniFiAttributes')]
      [string[]]
      $Attributes
   )

   begin
   {
      Write-Verbose -Message 'Start Get-UnifiHourlyGatewayStats'

      # Set the defaults, if needed
      if (-not ($Attributes))
      {
         [string[]]$Attributes = 'mem', 'cpu', 'loadavg_5'
      }
      # ensure the attributes are lowercase (we ignore the case on the input for the user covinience)
      [string[]]$Attributes = ($Attributes).ToLower()

      # Save Datestring to keep everything consitant
      $now = (Get-Date)

      if (-not ($Start))
      {
         $Start = (ConvertTo-UnixTimeStamp -Date ($now.AddDays(-7)) -Milliseconds)
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
         $ApiRequestUri = $ApiUri + 's/' + $UnifiSite + '/stat/report/hourly.gw'
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
               Time    = ((ConvertFrom-UnixTimeStamp -TimeStamp ($item.time) -Milliseconds).ToLocalTime())
               gateway = $item.gw
            }

            #region Default
            if ($item.mem)
            {
               $outputAppend | Add-Member -NotePropertyName mem -NotePropertyValue ('{0:N2}' -f ([math]::Round($item.mem,2,'AwayFromZero')))
            }

            if ($item.cpu)
            {
               $outputAppend | Add-Member -NotePropertyName cpu -NotePropertyValue ('{0:N2}' -f ([math]::Round($item.cpu,2,'AwayFromZero')))
            }

            if ($item.loadavg_5)
            {
               $outputAppend | Add-Member -NotePropertyName loadavg_5 -NotePropertyValue ([INT]$item.loadavg_5)
            }
            #endregion Default

            #region RX
            if (($item.'lan-rx_errors') -or ($item.'lan-rx_errors' -eq '0.0'))
            {
               $outputAppend | Add-Member -NotePropertyName 'lan-rx_errors' -NotePropertyValue ([int]($item.'lan-rx_errors'))
            }

            if (($item.'lan-rx_bytes') -or ($item.'lan-rx_bytes' -eq '0.0'))
            {
               $outputAppend | Add-Member -NotePropertyName 'lan-rx_bytes' -NotePropertyValue $item.'lan-rx_bytes'

               if ((([math]::round($item.'lan-rx_bytes' / 1KB, 2)) -ne '0.0') -or (([math]::round($item.'lan-rx_bytes' / 1KB, 2)) -ne '0.00'))
               {
                  $outputAppend | Add-Member -NotePropertyName 'lan-rx_kb' -NotePropertyValue ([math]::round($item.'lan-rx_bytes' / 1KB, 2))

                  if ((([math]::round($item.'lan-rx_bytes' / 1MB, 2)) -ne '0.0') -or (([math]::round($item.'lan-rx_bytes' / 1MB, 2)) -ne '0.00'))
                  {
                     $outputAppend | Add-Member -NotePropertyName 'lan-rx_mb' -NotePropertyValue ([math]::round($item.'lan-rx_bytes' / 1MB, 2))

                     if ((([math]::round($item.'lan-rx_bytes' / 1GB, 2)) -ne '0.0') -or (([math]::round($item.'lan-rx_bytes' / 1GB, 2)) -ne '0.00'))
                     {
                        $outputAppend | Add-Member -NotePropertyName 'lan-rx_gb' -NotePropertyValue ([math]::round($item.'lan-rx_bytes' / 1GB, 2))

                        if ((([math]::round($item.'lan-rx_bytes' / 1TB, 2)) -ne '0.0') -or (([math]::round($item.'lan-rx_bytes' / 1TB, 2)) -ne '0.00'))
                        {
                           $outputAppend | Add-Member -NotePropertyName 'lan-rx_tb' -NotePropertyValue ([math]::round($item.'lan-rx_bytes' / 1TB, 2))
                        }
                     }
                  }
               }
            }

            if (($item.'lan-rx_packets') -or ($item.'lan-rx_packets' -eq '0.0'))
            {
               $outputAppend | Add-Member -NotePropertyName 'lan-rx_packets' -NotePropertyValue $item.'lan-rx_packets'
            }

            if (($item.'lan-rx_dropped') -or ($item.'lan-rx_dropped' -eq '0.0'))
            {
               $outputAppend | Add-Member -NotePropertyName 'lan-rx_dropped' -NotePropertyValue ([int]($item.'lan-rx_dropped'))
            }

            if (($item.'wan-rx_errors') -or ($item.'wan-rx_errors' -eq '0.0'))
            {
               $outputAppend | Add-Member -NotePropertyName 'wan-rx_errors' -NotePropertyValue ([int]($item.'wan-rx_errors'))
            }

            if (($item.'wan-rx_byte') -or ($item.'wan-rx_byte' -eq '0.0'))
            {
               $outputAppend | Add-Member -NotePropertyName 'wan-rx_bytes' -NotePropertyValue $item.'wan-rx_bytes'

               if ((([math]::round($item.'wan-rx_bytes' / 1KB, 2)) -ne '0.0') -or (([math]::round($item.'wan-rx_bytes' / 1KB, 2)) -ne '0.00'))
               {
                  $outputAppend | Add-Member -NotePropertyName 'wan-rx_kb' -NotePropertyValue ([math]::round($item.'wan-rx_bytes' / 1KB, 2))

                  if ((([math]::round($item.'wan-rx_bytes' / 1MB, 2)) -ne '0.0') -or (([math]::round($item.'wan-rx_bytes' / 1MB, 2)) -ne '0.00'))
                  {
                     $outputAppend | Add-Member -NotePropertyName 'wan-rx_mb' -NotePropertyValue ([math]::round($item.'wan-rx_bytes' / 1MB, 2))

                     if ((([math]::round($item.'wan-rx_bytes' / 1GB, 2)) -ne '0.0') -or (([math]::round($item.'wan-rx_bytes' / 1GB, 2)) -ne '0.00'))
                     {
                        $outputAppend | Add-Member -NotePropertyName 'wan-rx_gb' -NotePropertyValue ([math]::round($item.'wan-rx_bytes' / 1GB, 2))

                        if ((([math]::round($item.'wan-rx_bytes' / 1TB, 2)) -ne '0.0') -or (([math]::round($item.'wan-rx_bytes' / 1TB, 2)) -ne '0.00'))
                        {
                           $outputAppend | Add-Member -NotePropertyName 'wan-rx_tb' -NotePropertyValue ([math]::round($item.'wan-rx_bytes' / 1TB, 2))
                        }
                     }
                  }
               }
            }

            if (($item.'wan-rx_packets') -or ($item.'wan-rx_packets' -eq '0.0'))
            {
               $outputAppend | Add-Member -NotePropertyName 'wan-rx_packets' -NotePropertyValue $item.'wan-rx_packets'
            }

            if (($item.'wan-rx_dropped') -or ($item.'wan-rx_dropped' -eq '0.0'))
            {
               $outputAppend | Add-Member -NotePropertyName 'wan-rx_dropped' -NotePropertyValue ([int]($item.'wan-rx_dropped'))
            }
            #endregion RX

            #region TX
            if (($item.'lan-tx_errors') -or ($item.'lan-tx_errors' -eq '0.0'))
            {
               $outputAppend | Add-Member -NotePropertyName 'lan-tx_errors' -NotePropertyValue ([int]($item.'lan-tx_errors'))
            }

            if (($item.'lan-tx_bytes') -or ($item.'lan-tx_bytes' -eq '0.0'))
            {
               $outputAppend | Add-Member -NotePropertyName 'lan-tx_bytes' -NotePropertyValue $item.'lan-tx_bytes'

               if ((([math]::round($item.'lan-tx_bytes' / 1KB, 2)) -ne '0.0') -or (([math]::round($item.'lan-tx_bytes' / 1KB, 2)) -ne '0.00'))
               {
                  $outputAppend | Add-Member -NotePropertyName 'lan-tx_kb' -NotePropertyValue ([math]::round($item.'lan-tx_bytes' / 1KB, 2))

                  if ((([math]::round($item.'lan-tx_bytes' / 1MB, 2)) -ne '0.0') -or (([math]::round($item.'lan-tx_bytes' / 1MB, 2)) -ne '0.00'))
                  {
                     $outputAppend | Add-Member -NotePropertyName 'lan-tx_mb' -NotePropertyValue ([math]::round($item.'lan-tx_bytes' / 1MB, 2))

                     if ((([math]::round($item.'lan-tx_bytes' / 1GB, 2)) -ne '0.0') -or (([math]::round($item.'lan-tx_bytes' / 1GB, 2)) -ne '0.00'))
                     {
                        $outputAppend | Add-Member -NotePropertyName 'lan-tx_gb' -NotePropertyValue ([math]::round($item.'lan-tx_bytes' / 1GB, 2))

                        if ((([math]::round($item.'lan-tx_bytes' / 1TB, 2)) -ne '0.0') -or (([math]::round($item.'lan-tx_bytes' / 1TB, 2)) -ne '0.00'))
                        {
                           $outputAppend | Add-Member -NotePropertyName 'lan-tx_tb' -NotePropertyValue ([math]::round($item.'lan-tx_bytes' / 1TB, 2))
                        }
                     }
                  }
               }
            }

            if (($item.'lan-tx_packets') -or ($item.'lan-tx_packets' -eq '0.0'))
            {
               $outputAppend | Add-Member -NotePropertyName 'lan-tx_packets' -NotePropertyValue $item.'lan-tx_packets'
            }

            if (($item.'lan-tx_dropped') -or ($item.'lan-tx_dropped' -eq '0.0'))
            {
               $outputAppend | Add-Member -NotePropertyName 'lan-tx_dropped' -NotePropertyValue ([int]($item.'lan-tx_dropped'))
            }

            if (($item.'wan-tx_errors') -or ($item.'wan-tx_errors' -eq '0.0'))
            {
               $outputAppend | Add-Member -NotePropertyName 'wan-tx_errors' -NotePropertyValue ([int]($item.'wan-tx_errors'))
            }

            if (($item.'wan-tx_bytes') -or ($item.'wan-tx_bytes' -eq '0.0'))
            {
               $outputAppend | Add-Member -NotePropertyName 'wan-tx_bytes' -NotePropertyValue $item.'wan-tx_bytes'

               if ((([math]::round($item.'wan-tx_bytes' / 1KB, 2)) -ne '0.0') -or (([math]::round($item.'wan-tx_bytes' / 1KB, 2)) -ne '0.00'))
               {
                  $outputAppend | Add-Member -NotePropertyName 'wan-tx_kb' -NotePropertyValue ([math]::round($item.'wan-tx_bytes' / 1KB, 2))

                  if ((([math]::round($item.'wan-tx_bytes' / 1MB, 2)) -ne '0.0') -or (([math]::round($item.'wan-tx_bytes' / 1MB, 2)) -ne '0.00'))
                  {
                     $outputAppend | Add-Member -NotePropertyName 'wan-tx_mb' -NotePropertyValue ([math]::round($item.'wan-tx_bytes' / 1MB, 2))

                     if ((([math]::round($item.'wan-tx_bytes' / 1GB, 2)) -ne '0.0') -or (([math]::round($item.'wan-tx_bytes' / 1GB, 2)) -ne '0.00'))
                     {
                        $outputAppend | Add-Member -NotePropertyName 'wan-tx_gb' -NotePropertyValue ([math]::round($item.'wan-tx_bytes' / 1GB, 2))

                        if ((([math]::round($item.'wan-tx_bytes' / 1TB, 2)) -ne '0.0') -or (([math]::round($item.'wan-tx_bytes' / 1TB, 2)) -ne '0.00'))
                        {
                           $outputAppend | Add-Member -NotePropertyName 'wan-tx_tb' -NotePropertyValue ([math]::round($item.'wan-tx_bytes' / 1TB, 2))
                        }
                     }
                  }
               }
            }

            if (($item.'wan-tx_packets') -or ($item.'wan-tx_packets' -eq '0.0'))
            {
               $outputAppend | Add-Member -NotePropertyName 'wan-tx_packets' -NotePropertyValue $item.'wan-tx_packets'
            }

            if (($item.'wan-tx_dropped') -or ($item.'wan-tx_dropped' -eq '0.0'))
            {
               $outputAppend | Add-Member -NotePropertyName 'wan-tx_dropped' -NotePropertyValue ([int]($item.'wan-tx_dropped'))
            }
            #endregion TX


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

      Write-Verbose -Message 'Done Get-UnifiHourlyGatewayStats'
   }
}
