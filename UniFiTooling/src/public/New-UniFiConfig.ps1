function New-UniFiConfig
{
   <#
         .SYNOPSIS
         Creates the UniFi config JSON file

         .DESCRIPTION
         Creates the UniFi config JSON file. If no input is given it creates one with all the defaults.

         .PARAMETER UniFiUsername
         The login of a UniFi User with admin rights

         .PARAMETER UniFiPassword
         The password for the user given above. It is clear text for now. I know... But the Ubiquiti UniFi Controller seems to understand plain text only.

         .PARAMETER UniFiProtocol
         Valid is http and https. default is https
         Please note: http is untested and it might not even work!

         .PARAMETER UniFiSelfSignedCert
         If you use a self signed certificate and/or a certificate from an untrusted CA, you might want to use true here.
         Default is FALSE

         .PARAMETER UniFiHostname
         The Ubiquiti UniFi Controller you want to use. You can use a Fully-Qualified Host Name (FQHN) or an IP address.

         .PARAMETER UniFiPort
         The port number that you have configured on your Ubiquiti UniFi Controller.
         The default is 8443

         .PARAMETER Path
         Where to safe the JSON config. Default is the directory where you call the function.
         e.g. .\UniFiConfig.json

         .PARAMETER force
         Replaces the contents of a file, even if the file is read-only. Without this parameter, read-only files are not changed.

         .EXAMPLE
         PS C:\> New-UniFiConfig

         .EXAMPLE
         PS C:\> New-UniFiConfig -UniFiUsername 'unfi.admin.user' -UniFiPassword 'mySuperSecretPassworHere' -UniFiProtocol 'https' -UniFiSelfSignedCert $true -UniFiHostname 'unifi.contoso.com' -UniFiPort '8443' -Path '.\UniFiConfig.json'

         .EXAMPLE
         PS C:\> New-UniFiConfig -UniFiUsername 'unfi.admin.user' -UniFiPassword 'mySuperSecretPassworHere' -UniFiProtocol 'https' -UniFiSelfSignedCert $true -UniFiHostname 'unifi.contoso.com' -UniFiPort '8443' -Path '.\UniFiConfig.json' -force

         .NOTES
         Just an helper function to create a JSON config

         .LINK
         Get-UniFiConfig

         .LINK
         Get-UniFiCredentials
   #>

   [CmdletBinding(ConfirmImpact = 'None',
   SupportsShouldProcess)]
   param
   (
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 0)]
      [ValidateNotNullOrEmpty()]
      [Alias('enUniFiUsername')]
      [string]
      $UniFiUsername = 'unfi.admin.user',
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 1)]
      [ValidateNotNullOrEmpty()]
      [Alias('enUniFiPassword')]
      [string]
      $UniFiPassword = 'mySuperSecretPassworHere',
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 2)]
      [ValidateSet('http', 'https', IgnoreCase = $true)]
      [ValidateNotNullOrEmpty()]
      [Alias('enUniFiProtocol')]
      [string]
      $UniFiProtocol = 'https',
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 3)]
      [ValidateNotNullOrEmpty()]
      [Alias('enUniFiSelfSignedCert')]
      [bool]
      $UniFiSelfSignedCert = $false,
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 4)]
      [ValidateNotNullOrEmpty()]
      [Alias('enUniFiHostname')]
      [string]
      $UniFiHostname = 'unifi.contoso.com',
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 5)]
      [ValidateNotNullOrEmpty()]
      [Alias('enUniFiPort')]
      [int]
      $UniFiPort = 8443,
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 6)]
      [ValidateNotNullOrEmpty()]
      [Alias('enConfigPath', 'ConfigPath')]
      [string]
      $Path = '.\UniFiConfig.json',
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 7)]
      [switch]
      $force = $false
   )

   begin
   {
      Write-Verbose -Message 'Start New-UniFiConfig'

      # Call meta function
      $null = (Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState -ErrorAction SilentlyContinue -WarningAction SilentlyContinue)

      #region JsonInputData
      $JsonInputData = [PSCustomObject][ordered]@{
         Login          = [PSCustomObject][ordered]@{
            Username = $UniFiUsername
            Password = $UniFiPassword
         }
         protocol       = $UniFiProtocol
         SelfSignedCert = $UniFiSelfSignedCert
         Hostname       = $UniFiHostname
         Port           = $UniFiPort
      }
      #endregion JsonInputData
   }

   process
   {
      try
      {
         #region JsonData
         $paramConvertToJson = @{
            InputObject   = $JsonInputData
            Depth         = 2
            ErrorAction   = 'Stop'
            WarningAction = 'SilentlyContinue'
         }
         $JsonData = (ConvertTo-Json @paramConvertToJson)

         $paramSetContent = @{
            Value         = $JsonData
            Path          = $Path
            PassThru      = $true
            Force         = $force
            Confirm       = $false
            ErrorAction   = 'Stop'
            WarningAction = 'SilentlyContinue'
         }
         if ($pscmdlet.ShouldProcess($Path, 'Create'))
         {
            $null = (Set-Content @paramSetContent)
         }
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
            Line      = $e.InvocationInfo.ScriptLineNumber
            Column    = $e.InvocationInfo.OffsetInLine
         }

         Write-Verbose -Message $info

         Write-Error -Message ($info.Exception) -ErrorAction Stop

         # Only here to catch a global ErrorAction overwrite
         break
         #endregion ErrorHandler
      }
   }

   end
   {
      # Cleanup
      $JsonInputData = $null
      $paramConvertToJson = $null

      Write-Verbose -Message 'Done New-UniFiConfig'
   }
}
