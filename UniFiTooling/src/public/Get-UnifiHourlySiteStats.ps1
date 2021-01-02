function Get-UnifiHourlySiteStats
{
   <#
         .SYNOPSIS
         Get horly statistics for a complete Site

         .DESCRIPTION
         Get horly statistics for a complete UniFi Site

         For convenience, we return the a bit more then the API, e.g. everything in KB, MB, GB, and TB instead of just bytes

         We also return real timestamps instead of the unix timestaps in miliseconds that the UniFi returns

         Sample output:
         Time         : 1/28/2019 8:00:00 AM
         wan-tx_bytes : 15674710.4243137
         wan-tx_kb    : 15307.33
         wan-tx_mb    : 14.95
         wan-tx_gb    : 0.01
         wan-rx_bytes : 74608528.2870588
         wan-rx_kb    : 72859.89
         wan-rx_mb    : 71.15
         wan-rx_gb    : 0.07
         wan_bytes    : 90283238.7113726
         wan_kb       : 88167.23
         wan_mb       : 86.1
         wan_gb       : 0.08
         wlan_bytes   : 73033651.4499586
         wlan_kb      : 71321.93
         wlan_mb      : 69.65
         wlan_gb      : 0.07
         Clients      : 35
         LAN_Clients  : 30
         WLAN_Clients : 5

         You might filter out all the 0 values, we keep them to prevent any null pointer expetions!

         You can Filter for whatever parameter you like (e.g. with Select-Object)

         .PARAMETER UnifiSite
         ID of the client-device to be modified

         .PARAMETER Start
         Startpoint in UniFi Unix timestamp in milliseconds

         .PARAMETER End
         Endpoint in UniFi Unix timestamp in milliseconds

         .PARAMETER Attributes
         array containing attributes (strings) to be returned, defaults are all

         .EXAMPLE
         PS C:\> Get-UnifiHourlySiteStats

         Get horly statistics for a complete UniFi for the default site

         .EXAMPLE
         (Get-UnifiHourlySiteStats -Start '1548971935421' -End '1548975579019')

         Get horly statistics for a complete UniFi for the default site for a given time period.

         .EXAMPLE
         (Get-UnifiHourlySiteStats -Start '1548980058135')

         Get horly statistics for a complete UniFi for the default site for the last 60 minutes (was the timestamp while the sample was created)

         .EXAMPLE
         PS C:\> (Get-UnifiHourlySiteStats -UnifiSite 'contoso')[-1]

         Get horly statistics for a complete UniFi for the site 'contoso'

         .EXAMPLE
         PS C:\> Get-UnifiHourlySiteStats -Attributes 'bytes','wan-tx_bytes','wan-rx_bytes','wlan_bytes','num_sta','lan-num_sta','wlan-num_sta')

         Get all Values from the API

         .NOTES
         Defaults to the past day (24 hours)

         "bytes" are no longer returned with controller version 4.9.1 and later

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
      [ValidateSet('bytes','wan-tx_bytes','wan-rx_bytes','wlan_bytes','num_sta','lan-num_sta','wlan-num_sta', IgnoreCase = $true)]
      [Alias('attribs', 'UniFiAttributes')]
      [string[]]
      $Attributes
   )

   begin
   {
      Write-Verbose -Message 'Start Get-UnifiHourlySiteStats'

      # Set the defaults, if needed
      if (-not ($Attributes))
      {
         [string[]]$Attributes = 'bytes', 'wan-tx_bytes', 'wan-rx_bytes', 'wlan_bytes', 'num_sta', 'lan-num_sta', 'wlan-num_sta'
      }
      # ensure the attributes are lowercase (we ignore the case on the input for the user covinience)
      [string[]]$Attributes = ($Attributes).ToLower()

      # Save Datestring to keep everything consitant
      $now = (Get-Date)

      if (-not ($Start))
      {
         $Start = (ConvertTo-UnixTimeStamp -Date ($now.AddHours(-24)) -Milliseconds)
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
         $ApiRequestUri = $ApiUri + 's/' + $UnifiSite + '/stat/report/hourly.site'
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

            #region
            if (($item.'bytes') -or ($item.'bytes' -eq '0.0'))
            {
               $outputAppend | Add-Member -NotePropertyName 'bytes' -NotePropertyValue $item.'bytes'

               if ((([math]::round($item.'bytes' / 1KB, 2)) -ne '0.0') -or (([math]::round($item.'bytes' / 1KB, 2)) -ne '0.00'))
               {
                  $outputAppend | Add-Member -NotePropertyName 'kb' -NotePropertyValue ([math]::round($item.'bytes' / 1KB, 2))

                  if ((([math]::round($item.'bytes' / 1MB, 2)) -ne '0.0') -or (([math]::round($item.'bytes' / 1MB, 2)) -ne '0.00'))
                  {
                     $outputAppend | Add-Member -NotePropertyName 'mb' -NotePropertyValue ([math]::round($item.'bytes' / 1MB, 2))

                     if ((([math]::round($item.'bytes' / 1GB, 2)) -ne '0.0') -or (([math]::round($item.'bytes' / 1GB, 2)) -ne '0.00'))
                     {
                        $outputAppend | Add-Member -NotePropertyName 'gb' -NotePropertyValue ([math]::round($item.'bytes' / 1GB, 2))

                        if ((([math]::round($item.'bytes' / 1TB, 2)) -ne '0.0') -or (([math]::round($item.'bytes' / 1TB, 2)) -ne '0.00'))
                        {
                           $outputAppend | Add-Member -NotePropertyName 'tb' -NotePropertyValue ([math]::round($item.'bytes' / 1TB, 2))
                        }
                     }
                  }
               }
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

            if (($item.'wan-rx_bytes') -or ($item.'wan-rx_bytes' -eq '0.0'))
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

            if ((($item.'wan-tx_bytes') -or ($item.'wan-tx_bytes' -eq '0.0')) -and (($item.'wan-rx_bytes') -or ($item.'wan-rx_bytes' -eq '0.0')))
            {
               $WanbytesSummed = ($item.'wan-tx_bytes' + $item.'wan-rx_bytes')

               $outputAppend | Add-Member -NotePropertyName 'wan_bytes' -NotePropertyValue $WanbytesSummed

               if ((([math]::round($WanbytesSummed / 1KB, 2)) -ne '0.0') -or (([math]::round($WanbytesSummed / 1KB, 2)) -ne '0.00'))
               {
                  $outputAppend | Add-Member -NotePropertyName 'wan_kb' -NotePropertyValue ([math]::round($WanbytesSummed / 1KB, 2))

                  if ((([math]::round($WanbytesSummed / 1MB, 2)) -ne '0.0') -or (([math]::round($WanbytesSummed / 1MB, 2)) -ne '0.00'))
                  {
                     $outputAppend | Add-Member -NotePropertyName 'wan_mb' -NotePropertyValue ([math]::round($WanbytesSummed / 1MB, 2))

                     if ((([math]::round($WanbytesSummed / 1GB, 2)) -ne '0.0') -or (([math]::round($WanbytesSummed / 1GB, 2)) -ne '0.00'))
                     {
                        $outputAppend | Add-Member -NotePropertyName 'wan_gb' -NotePropertyValue ([math]::round($WanbytesSummed / 1GB, 2))

                        if ((([math]::round($WanbytesSummed / 1TB, 2)) -ne '0.0') -or (([math]::round($WanbytesSummed / 1TB, 2)) -ne '0.00'))
                        {
                           $outputAppend | Add-Member -NotePropertyName 'wan_tb' -NotePropertyValue ([math]::round($WanbytesSummed / 1TB, 2))
                        }
                     }
                  }
               }

               $WanbytesSummed = $null
            }

            if (($item.'wlan_bytes') -or ($item.'wlan_bytes' -eq '0.0'))
            {
               $outputAppend | Add-Member -NotePropertyName 'wlan_bytes' -NotePropertyValue $item.'wlan_bytes'

               if ((([math]::round($item.'wlan_bytes' / 1KB, 2)) -ne '0.0') -or (([math]::round($item.'wlan_bytes' / 1KB, 2)) -ne '0.00'))
               {
                  $outputAppend | Add-Member -NotePropertyName 'wlan_kb' -NotePropertyValue ([math]::round($item.'wlan_bytes' / 1KB, 2))

                  if ((([math]::round($item.'wlan_bytes' / 1MB, 2)) -ne '0.0') -or (([math]::round($item.'wlan_bytes' / 1MB, 2)) -ne '0.00'))
                  {
                     $outputAppend | Add-Member -NotePropertyName 'wlan_mb' -NotePropertyValue ([math]::round($item.'wlan_bytes' / 1MB, 2))

                     if ((([math]::round($item.'wlan_bytes' / 1GB, 2)) -ne '0.0') -or (([math]::round($item.'wlan_bytes' / 1GB, 2)) -ne '0.00'))
                     {
                        $outputAppend | Add-Member -NotePropertyName 'wlan_gb' -NotePropertyValue ([math]::round($item.'wlan_bytes' / 1GB, 2))

                        if ((([math]::round($item.'wlan_bytes' / 1TB, 2)) -ne '0.0') -or (([math]::round($item.'wlan_bytes' / 1TB, 2)) -ne '0.00'))
                        {
                           $outputAppend | Add-Member -NotePropertyName 'wlan_tb' -NotePropertyValue ([math]::round($item.'wlan_bytes' / 1TB, 2))
                        }
                     }
                  }
               }
            }

            if (($item.'num_sta') -or ($item.'num_sta' -eq '0.0'))
            {
               $outputAppend | Add-Member -NotePropertyName 'Clients' -NotePropertyValue $item.'num_sta'
            }

            if (($item.'lan-num_sta') -or ($item.'lan-num_sta' -eq '0.0'))
            {
               $outputAppend | Add-Member -NotePropertyName 'LAN_Clients' -NotePropertyValue $item.'lan-num_sta'
            }

            if (($item.'wlan-num_sta') -or ($item.'wlan-num_sta' -eq '0.0'))
            {
               $outputAppend | Add-Member -NotePropertyName 'WLAN_Clients' -NotePropertyValue $item.'wlan-num_sta'
            }
            #endregion

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

      Write-Verbose -Message 'Done Get-UnifiHourlySiteStats'
   }
}
