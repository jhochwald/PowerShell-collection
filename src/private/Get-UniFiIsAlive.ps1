function Get-UniFiIsAlive
{
   <#
         .SYNOPSIS
         Use a simple API call to see if the session is alive

         .DESCRIPTION
         Use a simple API call to see if the session is alive

         .PARAMETER UnifiSite
         UniFi Site as configured. The default is: default

         .EXAMPLE
         PS C:\> Get-UniFiIsAlive

         Use a simple API call to see if the session is alive

         .EXAMPLE
         PS C:\> Get-UniFiIsAlive -UnifiSite 'Contoso'

         Use a simple API call to see if the session is alive on Site 'Contoso'

         .NOTES
         Internal Helper Function

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
      $UnifiSite = 'default'
   )

   begin
   {
      Write-Verbose -Message 'Start Get-UniFiIsAlive'

      # Call meta function
      $null = (Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState -ErrorAction SilentlyContinue -WarningAction SilentlyContinue)

      # Cleanup
      $Session = $null

      #region SafeProgressPreference
      # Safe ProgressPreference and Setup SilentlyContinue for the function
      $ExistingProgressPreference = ($ProgressPreference)
      $ProgressPreference = 'SilentlyContinue'
      #endregion SafeProgressPreference

      # Set the default to FALSE
      $SessionStatus = $false
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

         #region UniFiApiLogin
         $null = (Invoke-UniFiApiLogin -ErrorAction SilentlyContinue)
         #endregion UniFiApiLogin

         #region SetRequestHeader
         Write-Verbose -Message 'Set the API Call default Header'

         $null = (Set-UniFiDefaultRequestHeader)
         #endregion SetRequestHeader

         #region SetRequestURI
         Write-Verbose -Message 'Create the Request URI'

         $ApiRequestUri = $ApiUri + 's/' + $UnifiSite + '/self'

         Write-Verbose -Message ('URI: {0}' -f $ApiRequestUri)
         #endregion SetRequestURI

         #region Request
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

         $SessionStatus = $true
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

         # Restore ProgressPreference
         $ProgressPreference = $ExistingProgressPreference

         # Reset the SSL Trust (make sure everything is back to default)
         [Net.ServicePointManager]::ServerCertificateValidationCallback = $null

         # That was it!
         $SessionStatus = $false
      }

      # check result
      if ($Session.meta.rc -ne 'ok')
      {
         # Restore ProgressPreference
         $ProgressPreference = $ExistingProgressPreference

         # Reset the SSL Trust (make sure everything is back to default)
         [Net.ServicePointManager]::ServerCertificateValidationCallback = $null

         # That was it!
         $SessionStatus = $false
      } else {
         $SessionStatus = $true
      }
   }

   end
   {
      # Cleanup
      $Session = $null

      #region ResetSslTrust
      # Reset the SSL Trust (make sure everything is back to default)
      [Net.ServicePointManager]::ServerCertificateValidationCallback = $null
      #endregion ResetSslTrust

      #region RestoreProgressPreference
      $ProgressPreference = $ExistingProgressPreference
      #endregion RestoreProgressPreference

      # Dump the Result
      $SessionStatus

      Write-Verbose -Message 'Start Get-UniFiIsAlive'
   }
}
