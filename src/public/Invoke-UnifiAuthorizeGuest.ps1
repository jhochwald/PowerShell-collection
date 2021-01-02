function Invoke-UnifiAuthorizeGuest
{
   <#
         .SYNOPSIS
         Authorize a client device via the API of the UniFi Controller

         .DESCRIPTION
         Authorize a client device via the API of the Ubiquiti UniFi Controller

         .PARAMETER UnifiSite
         UniFi Site as configured. The default is: default

         .PARAMETER Mac
         Client MAC address

         .PARAMETER Minutes
         Minutes (from now) until authorization expires, the default is 60 (1 hour)

         .PARAMETER Up
         Upload speed limit in Kilobit per second (kbit/s)

         .PARAMETER Down
         Download speed limit in Kilobit per second (kbit/s)

         .PARAMETER Limit
         Data transfer limit in megabytes (MB), upload and download will be combined.
         The default is unlimited

         .PARAMETER AccessPoint
         MAC address of the Access Point to which client is connected, should result in a much faster authorization

         .EXAMPLE
         PS C:\> Invoke-UnifiAuthorizeGuest -Mac '84:3a:4b:cd:88:2D'

         Authorize a client device via the API of the UniFi Controller

         .EXAMPLE
         PS C:\> Invoke-UnifiAuthorizeGuest -Mac '84:3a:4b:cd:88:2D' -AccessPoint '788a2059c699'

         Authorize a client device via the API of the UniFi Controller, it used the AccessPoint with the Mac address 78:8a:20:59:c6:99 directly for a faster authorization

         .EXAMPLE
         PS C:\> Invoke-UnifiAuthorizeGuest -Mac '843a4bcd882D' -Minutes 180

         Authorize a client device for 180 minutes via the API of the UniFi Controller

         .EXAMPLE
         PS C:\> Invoke-UnifiAuthorizeGuest -Mac '843a4bcd882D' -Up 1024 -Down 2048

         Authorize a client device with a restriction of 1024 kbit/s upload rate and 2048 kbit/s download rate via the API of the UniFi Controller

         .EXAMPLE
         PS C:\> Invoke-UnifiAuthorizeGuest -Mac '843a4bcd882D' -Limit 102400

         Authorize a client device with a limitation of  via 102400 megabytes of traffic (combined) the API of the UniFi Controller

         .EXAMPLE
         PS C:\> Invoke-UnifiAuthorizeGuest '84-3a-4b-cd-88-2D' -UnifiSite 'Contoso'

         Authorize a client device on site 'Contoso' via the API of the UniFi Controller (The function will normalize the MAC Address for us)

         .NOTES
         Initial version of the Ubiquiti UniFi Controller automation function

         .LINK
         Get-UniFiConfig

         .LINK
         Set-UniFiDefaultRequestHeader

         .LINK
         Invoke-UniFiApiLogin

         .LINK
         Invoke-RestMethod
   #>

   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([bool])]
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
            Position = 1,
      HelpMessage = 'Client MAC address')]
      [ValidateNotNullOrEmpty()]
      [Alias('UniFiMac', 'MacAddress')]
      [string]
      $Mac,
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 2)]
      [Alias('UniFiMinutes')]
      [int]
      $Minutes = 60,
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 3)]
      [Alias('UniFiUp')]
      [int]
      $Up = $null,
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 4)]
      [int]
      $Down = $null,
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 5)]
      [Alias('MBytes', 'UniFiLimit', 'UniFiMBytes')]
      [int]
      $Limit = $null,
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 6)]
      [Alias('UniFiAccessPoint', 'ApMac', 'UniFiApMac', 'ap_mac')]
      [string]
      $AccessPoint = $null
   )

   begin
   {
      Write-Verbose -Message 'Start Invoke-UnifiAuthorizeGuest'

      # Cleanup
      $Session = $null

      #region MacHandler
      [string]$Mac = (ConvertTo-UniFiValidMacAddress -Mac $Mac)
      #endregion MacHandler

      #region AccessPointMacHandler
      <#
            Make sure we have the right format
      #>
      if ($AccessPoint)
      {
         $regex = '((\d|([a-f]|[A-F])){2}){6}'
         [string]$AccessPoint = $AccessPoint.Trim().Replace(':', '').Replace('.', '').Replace('-', '')
         if (($AccessPoint.Length -eq 12) -and ($AccessPoint -match $regex))
         {
            [string]$AccessPoint = ($AccessPoint -replace '..(?!$)', '$&:')
         }
         else
         {
            # Verbose stuff
            $Script:line = $_.InvocationInfo.ScriptLineNumber

            Write-Verbose -Message ('Error was in Line {0}' -f $line)

            # Error Message
            Write-Error -Message ('Sorry, but {0} is a format that the UniFi Controller will nor understand' -f $AccessPoint) -ErrorAction Stop

            # Only here to catch a global ErrorAction overwrite
            break
         }
      }
      #endregion AccessPointMacHandler

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

      #region ApiRequestBodyInput
      $Script:ApiRequestBodyInput = [PSCustomObject][ordered]@{
         cmd     = 'authorize-guest'
         mac     = $Mac
         minutes = $Minutes
      }

      if ($Up)
      {
         Write-Verbose -Message ('Add upload speed limit: {0}' -f $Up)
         $ApiRequestBodyInput | Add-Member -MemberType NoteProperty -Name up -Value $Up -Force
      }

      if ($Down)
      {
         Write-Verbose -Message ('Add download speed limit: {0}' -f $Down)
         $ApiRequestBodyInput | Add-Member -MemberType NoteProperty -Name down -Value $Down -Force
      }

      if ($Limit)
      {
         Write-Verbose -Message ('Add data transfer limit: {0}' -f $Limit)
         $ApiRequestBodyInput | Add-Member -MemberType NoteProperty -Name bytes -Value $Limit -Force
      }

      if ($AccessPoint)
      {
         Write-Verbose -Message ('Use AP MAC address: {0}' -f $AccessPoint)
         $ApiRequestBodyInput | Add-Member -MemberType NoteProperty -Name ap_mac -Value $AccessPoint -Force
      }
      #endregion ApiRequestBodyInput

      # Call meta function
		$paramGetCallerPreference = @{
			Cmdlet	     = $PSCmdlet
			SessionState = $ExecutionContext.SessionState
			ErrorAction  = 'SilentlyContinue'
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

         $ApiRequestUri = $ApiUri + 's/' + $UnifiSite + '/cmd/stamgr'

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

         if ($Session.data)
         {
            Write-Verbose -Message "Session Data: $("`n" + ($Session.data | Out-String).Trim())"
            $Result = $true
         }
         else
         {
            $Result = $false
         }
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
         Write-Error -Message 'Unable to get the network list' -ErrorAction Stop

         # Only here to catch a global ErrorAction overwrite
         break
      }
   }

   end
   {
      # Dump the Result
      Write-Output -InputObject $true

      # Cleanup
      $Session = $null

      #region RestoreProgressPreference
      $ProgressPreference = $ExistingProgressPreference
      #endregion RestoreProgressPreference

      Write-Verbose -Message 'Start Invoke-UnifiAuthorizeGuest'
   }
}
