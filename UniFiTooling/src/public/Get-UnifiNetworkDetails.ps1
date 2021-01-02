function Get-UnifiNetworkDetails
{
   <#
         .SYNOPSIS
         Get the details about one network via the API of the UniFi Controller

         .DESCRIPTION
         Get the details about one network via the API of the UniFi Controller

         .PARAMETER Id
         The ID (network_id) of the network you would like to get detaild information about. Multiple values are supported.

         .PARAMETER Name
         The Name (not the ID/network_id) of the network you would like to get detaild information about. Multiple values are supported.

         .PARAMETER UnifiSite
         UniFi Site as configured. The default is: default

         .EXAMPLE
         PS C:\> Get-UnifiNetworkDetails -id 'ba7e58be13574ef4881a79c3'

         Get the details about the network with ID ba7e58be13574ef4881a79c3 via the API of the UniFi Controller

         .EXAMPLE
         Get-UnifiNetworkDetails -UnifiNetwork 'ba7e58be13574ef4881a79c3'

         Same as above, with the legacy parameter alias used.

         .EXAMPLE
         PS C:\> Get-UnifiNetworkDetails -name 'JoshHome'

         Get the details about the network JoshHome via the API of the UniFi Controller

         .EXAMPLE
         PS C:\> Get-UnifiNetworkDetails -name 'JoshHome', 'JohnHome'

         Get the details about the networks JoshHome and JohnHome via the API of the UniFi Controller

         .EXAMPLE
         PS C:\> Get-UnifiNetworkDetails -id 'ba7e58be13574ef4881a79c3', '2437bdf7fdf04f1a96c0fd32'

         Get the details about the networks with IDs ba7e58be13574ef4881a79c3 and 2437bdf7fdf04f1a96c0fd32 via the API of the UniFi Controller

         .EXAMPLE
         PS C:\> Get-UnifiNetworkDetails -id 'ba7e58be13574ef4881a79c3' -UnifiSite 'Contoso'

         Get the details about the network with ID ba7e58be13574ef4881a79c3 on Site 'Contoso' via the API of the UniFi Controller

         .EXAMPLE
         PS C:\> Get-UnifiNetworkDetails -name 'JoshHome' -UnifiSite 'Contoso'

         Get the details about the network JoshHome on Site 'Contoso' via the API of the UniFi Controller

         .NOTES
         The parameter UnifiNetwork is now an Alias.
         If the UnifiNetwork parameter is used, it must(!) be the ID (network_id). This was necessary to make it a non breaking change.

         .LINK
         Get-UnifiNetworkList

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
   [OutputType([psobject])]
   param
   (
      [Parameter(ParameterSetName = 'Request by Id',Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 0,
      HelpMessage = 'The ID (network_id) of the network you would like to get detaild information about.')]
      [ValidateNotNullOrEmpty()]
      [Alias('UnifiNetwork', 'UnifiNetworkId', 'NetworkId')]
      [string[]]
      $Id,
      [Parameter(ParameterSetName = 'Request by Name', Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 0,
      HelpMessage = 'The Name (not the ID/network_id) of the network you would like to get detaild information about.')]
      [ValidateNotNullOrEmpty()]
      [Alias('UnifiNetworkName', 'NetworkName')]
      [string[]]
      $Name,
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 1)]
      [ValidateNotNullOrEmpty()]
      [Alias('Site')]
      [string]
      $UnifiSite = 'default'
   )

   begin
   {
      Write-Verbose -Message 'Start Get-UnifiNetworkDetails'

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
                  if (-not (Get-UniFiIsAlive)) { Throw }
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

      # Create a new Object
      $SessionData = @()
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

         switch ($PsCmdlet.ParameterSetName)
         {
            'Request by Name'
            {
               foreach ($SingleName in $Name)
               {
                  # Cleanup
                  $Session = $null

                  Write-Verbose -Message 'Create the Request URI'

                  $ApiRequestUri = $ApiUri + 's/' + $UnifiSite + '/rest/networkconf/'

                  Write-Verbose -Message ('URI: {0}' -f $ApiRequestUri)

                  Write-Verbose -Message 'Send the Request'

                  $paramInvokeRestMethod = @{
                     Method        = 'Get'
                     Uri           = $ApiRequestUri
                     Headers       = $RestHeader
                     ErrorAction   = 'SilentlyContinue'
                     WarningAction = 'SilentlyContinue'
                     WebSession    = $RestSession
                  }
                  $Session = (Invoke-RestMethod @paramInvokeRestMethod)

                  Write-Verbose -Message "Session Meta: $(($Session.meta.rc | Out-String).Trim())"
                  Write-Verbose -Message "Session Data: $("`n" + ($Session.data | Out-String).Trim())"

                  # check result
                  if ($Session.meta.rc -ne 'ok')
                  {
                     # Error Message
                     Write-Error -Message 'Unable to Login' -ErrorAction Stop

                     # Only here to catch a global ErrorAction overwrite
                     break
                  }
                  elseif (-not ($Session.data))
                  {
                     # Error Message for a possible Not found
                     Write-Error -Message 'No Data - Possible Reason: Not found' -Category ObjectNotFound -ErrorAction Stop

                     # Only here to catch a global ErrorAction overwrite
                     break
                  }
                  $Session = $Session.data | Where-Object {
                     $_.name -eq $SingleName
                  }
                  $SessionData = $SessionData + $Session
               }
            }
            'Request by Id'
            {
               foreach ($SingleId in $Id)
               {
                  # Cleanup
                  $Session = $null

                  Write-Verbose -Message 'Create the Request URI'

                  $ApiRequestUri = $ApiUri + 's/' + $UnifiSite + '/rest/networkconf/' + $SingleId

                  Write-Verbose -Message ('URI: {0}' -f $ApiRequestUri)

                  Write-Verbose -Message 'Send the Request'

                  $paramInvokeRestMethod = @{
                     Method        = 'Get'
                     Uri           = $ApiRequestUri
                     Headers       = $RestHeader
                     ErrorAction   = 'SilentlyContinue'
                     WarningAction = 'SilentlyContinue'
                     WebSession    = $RestSession
                  }
                  $Session = (Invoke-RestMethod @paramInvokeRestMethod)

                  Write-Verbose -Message ('Session Info: {0}' -f $Session)

                  # check result
                  if ($Session.meta.rc -ne 'ok')
                  {
                     # Error Message
                     Write-Error -Message 'Unable to Login' -ErrorAction Stop

                     # Only here to catch a global ErrorAction overwrite
                     break
                  }
                  elseif (-not ($Session.data))
                  {
                     # Error Message for a possible Not found
                     Write-Error -Message 'No Data - Possible Reason: Not found' -Category ObjectNotFound -ErrorAction Stop

                     # Only here to catch a global ErrorAction overwrite
                     break
                  }
                  $SessionData = $SessionData + $Session.data
               }
            }
         }
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

         #region RestoreProgressPreference
         $ProgressPreference = $ExistingProgressPreference
         #endregion RestoreProgressPreference
      }
   }

   end
   {
      # Dump the Result
      $SessionData

      # Cleanup
      $SessionData = $null

      #region RestoreProgressPreference
      $ProgressPreference = $ExistingProgressPreference
      #endregion RestoreProgressPreference

      Write-Verbose -Message 'Start Get-UnifiNetworkDetails'
   }
}
