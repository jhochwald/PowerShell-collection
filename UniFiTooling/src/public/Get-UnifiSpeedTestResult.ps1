function Get-UnifiSpeedTestResult
{
   <#
         .SYNOPSIS
         Get the UniFi Security Gateway (USG) Speed Test results

         .DESCRIPTION
         Get the UniFi Security Gateway (USG) Speed Test results

         .PARAMETER Timeframe
         Timeframe in hours, default is 24

         .PARAMETER StartDate
         Start date (valid Date String)
         Default is now

         .PARAMETER EndDate
         End date (valid Date String), default is now minus 24 hours

         .PARAMETER UnifiSite
         UniFi Site as configured. The default is: default

         .PARAMETER all
         Get all existing Speed Test Results

         .PARAMETER UniFiValues
         Show results without modifications, like the UniFi Controller creates them

         .PARAMETER last
         Only test latest Speed Test Result will be displayed

         .EXAMPLE
         PS C:\> Get-UnifiSpeedTestResult -last

         Only test latest Speed Test Result will be displayed

         .EXAMPLE
         PS C:\> Get-UnifiSpeedTestResult -all

         Get all the UniFi Security Gateway (USG) Speed Test results

         .EXAMPLE
         PS C:\> Get-UnifiSpeedTestResult -all | Sort-Object -Property time

         Get all the UniFi Security Gateway (USG) Speed Test results, sorted by date

         .EXAMPLE
         PS C:\> Get-UnifiSpeedTestResult | Select-Object -Property *

         Get the UniFi Security Gateway (USG) Speed Test results from the last 24 hours (default), returns all values

         .EXAMPLE
         PS C:\> Get-UnifiSpeedTestResult -UnifiSite 'Contoso'

         Get the UniFi Security Gateway (USG) Speed Test results from the last 24 hours (default)

         .EXAMPLE
         PS C:\> Get-UnifiSpeedTestResult -Timeframe 48

         Get the UniFi Security Gateway (USG) Speed Test results of the last 48 hours

         .EXAMPLE
         PS C:\> Get-UnifiSpeedTestResult -StartDate '1/16/2019 12:00 AM' -EndDate '1/16/2019 11:59:59 PM'

         Get the UniFi Security Gateway (USG) Speed Test results for a given time/date
         In the example, all results from 1/16/2019 (all day) will be returned

         .NOTES
         Initial version that makes it more human readable.
         The filetring needs a few more tests

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
   [CmdletBinding(DefaultParameterSetName = 'DateSet',ConfirmImpact = 'None')]
   [OutputType([psobject])]
   param
   (
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 0)]
      [Alias('Start')]
      [datetime]
      $StartDate,
      [Parameter(ParameterSetName = 'TimeFrameSet',
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 1)]
      [Alias('hours')]
      [int]
      $Timeframe,
      [Parameter(ParameterSetName = 'DateSet',
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 1)]
      [ValidateNotNullOrEmpty()]
      [datetime]
      $EndDate = (Get-Date),
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 2)]
      [ValidateNotNullOrEmpty()]
      [Alias('Site')]
      [string]
      $UnifiSite = 'default',
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 3)]
      [switch]
      $all = $false,
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 4)]
      [switch]
      $UniFiValues = $false,
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 4)]
      [switch]
      $last = $false
   )

   begin
   {
      Write-Verbose -Message 'Start Get-UnifiSpeedTestResult'

      # Call meta function
      $null = (Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState -ErrorAction SilentlyContinue -WarningAction SilentlyContinue)

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

      #region ConfigureDefaultDisplaySet
      $defaultDisplaySet = 'time', 'download', 'upload', 'latency'

      # Create the default property display set
      $defaultDisplayPropertySet = (New-Object -TypeName System.Management.Automation.PSPropertySet -ArgumentList ('DefaultDisplayPropertySet', [string[]]$defaultDisplaySet))
      $PSStandardMembers = [Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
      #endregion ConfigureDefaultDisplaySet

      #region Filtering
      switch ($PsCmdlet.ParameterSetName)
      {
         'TimeFrameSet'
         {
            Write-Verbose -Message 'TimeFrameSet'
            if (-not ($StartDate))
            {
               if ($Timeframe)
               {
                  $StartDate = ((Get-Date).AddHours(-$Timeframe))
               }
               else
               {
                  $StartDate = ((Get-Date).AddDays(-1))
               }
            }

            if (-not ($EndDate))
            {
               $EndDate = (Get-Date)
            }
         }
         'DateSet'
         {
            Write-Verbose -Message 'DateSet'
            if (-not ($StartDate))
            {
               $StartDate = ((Get-Date).AddDays(-1))
            }

            if (-not ($EndDate))
            {
               $EndDate = (Get-Date)
            }
         }
      }

      [string]$FilterStartDate = (ConvertTo-UnixTimestamp -Date $StartDate -Milliseconds)
      [string]$FilterEndDate = (ConvertTo-UnixTimestamp -Date $EndDate -Milliseconds)

      if (($all) -or ($last))
      {
         $FilterStartDate = $null
         $FilterEndDate = $null
      }
      #endregion Filtering
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

         $ApiRequestUri = $ApiUri + 's/' + $UnifiSite + '/stat/report/archive.speedtest'

         Write-Verbose -Message ('URI: {0}' -f $ApiRequestUri)
         #endregion SetRequestURI

         #region ApiRequestBodyInput
         $Script:ApiRequestBodyInput = [PSCustomObject][ordered]@{
            attrs = @(
               'xput_download',
               'xput_upload',
               'latency',
               'time'
            )
            start = $FilterStartDate
            end   = $FilterEndDate
         }
         #endregion ApiRequestBodyInput

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
            Line	  = $e.InvocationInfo.ScriptLineNumber
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

      $Result = @()

      foreach ($item in $Session.data)
      {
         $Object = $null
         $Object = [PSCustomObject][ordered]@{
            id       = $item._id
            latency  = $item.latency
            oid      = $item.oid
            time     = if ($UniFiValues)
            {
               $item.time
            }
            else
            {
               ConvertFrom-UnixTimeStamp -TimeStamp ($item.time) -Milliseconds
            }
            download = if ($UniFiValues)
            {
               $item.xput_download
            }
            else
            {
               [math]::Round($item.xput_download,1)
            }
            upload   = if ($UniFiValues)
            {
               $item.xput_upload
            }
            else
            {
               [math]::Round($item.xput_upload,1)
            }
         }
         $Result = ($Result + $Object)
      }

      # Give this object a unique typename
      $null = ($Result.PSObject.TypeNames.Insert(0,'Speedtest.Result'))
      $null = ($Result | Add-Member MemberSet PSStandardMembers $PSStandardMembers)

      #region IfLast
      if ($last)
      {
         $Result = ($Result | Sort-Object -Property time | Select-Object -Last 1)
      }
      #endregion IfLast

   }

   end
   {
      # Dump the Result
      $Result

      # Cleanup
      $Session = $null

      #region RestoreProgressPreference
      $ProgressPreference = $ExistingProgressPreference
      #endregion RestoreProgressPreference

      Write-Verbose -Message 'Start Get-UnifiSpeedTestResult'
   }
}
