#requires -Version 3.0

<#
      .SYNOPSIS
      Remove the access to Outlook for all Mailboxes in an Microsoft Office 365 Tenant

      .DESCRIPTION
      Remove the access to Outlook for all Mailboxes in an Microsoft Office 365 Tenant
      It will remove access to OWA (Outlook Web Application), Exchange Active Sync (EAS), Outlook App and Outlook (part of the Office Suite).

      .PARAMETER CredentialUser
      The UPN of the admin user

      .PARAMETER CredentialFile
      File where the credential will be stored

      Make sure that this is secured!

      .PARAMETER ProxyAccessType
      Determines which mechanism is used to resolve the host name. The acceptable values for this parameter are:
      - IEConfig
      - WinHttpConfig
      - AutoDetect
      - NoProxyServer
      - None

      The default value is None.

      For information about the values of this parameter, see the description of the System.Management.Automation.Remoting.ProxyAccessTypehttp://go.microsoft.com/fwlink/?LinkId=144756 (http://go.microsoft.com/fwlink/?LinkId=144756) enumeration in the Microsoft Developer Network (MSDN) library.

      .EXAMPLE
      PS C:\> .\Approve-CASMailboxSettings.ps1

      .EXAMPLE
      PS C:\> .\Approve-CASMailboxSettings.ps1 -verbose

      .NOTES
      I created the script to run automated (via Windows scheduler) and it will save the password in a plain text file.
      You might want to use another option to gain access to Exchaneg Online

      Please check all values before using the script!

      TODO: Run the script once before using it as scheduled task! This will create and save the credentials.
#>
[CmdletBinding(ConfirmImpact = 'None')]
param
(
   [Parameter(ValueFromPipeline,
   ValueFromPipelineByPropertyName)]
   [ValidateNotNullOrEmpty()]
   [Alias('Username', 'AdminUser')]
   [string]
   $CredentialUser = 'youradmin.user@contoso.com',
   [Parameter(ValueFromPipeline,
   ValueFromPipelineByPropertyName)]
   [ValidateNotNullOrEmpty()]
   [Alias('CredFile', 'SecretFile')]
   [string]
   $CredentialFile = ($env:LOCALAPPDATA + '\exocreds.txt'),
   [Parameter(ValueFromPipeline,
   ValueFromPipelineByPropertyName)]
   [ValidateSet('IEConfig', 'WinHttpConfig', 'AutoDetect', 'NoProxyServer', 'None', IgnoreCase = $true)]
   [ValidateNotNullOrEmpty()]
   [Alias('PSSessionOptionProxy')]
   [string]
   $ProxyAccessType = 'None'
)

begin
{
   # Admin User (Global Admin or min. Exchange Online Admin role)
   if (-not ($CredentialUser))
   {
      $CredentialUser = 'youradmin.user@contoso.com'
   }

   # Where to store the password?
   if (-not ($CredentialFile))
   {
      $CredentialFile = ($env:LOCALAPPDATA + '\exocreds.txt')
   }
}

process
{
   #region CredentialHandler
   try
   {
      if (-not (Test-Path -Path $CredentialFile -ErrorAction SilentlyContinue))
      {
         # Do we have any credentials in memory (variable)
         if (-not ($ExoCreds))
         {
            #
            $paramGetCredential = @{
               Message     = 'Bitte mit einem Exchange Online Admin Benutzer anmelden'
               UserName    = $CredentialUser
               ErrorAction = 'Stop'
            }
            $ExoCreds = (Get-Credential @paramGetCredential)
         }

         # Splat the parameters
         $paramOutFile = @{
            FilePath    = $CredentialFile
            Force       = $true
            Encoding    = 'utf8'
            ErrorAction = 'Stop'
            Confirm     = $false
         }

         # Save the file
         $null = ($ExoCreds.Password | ConvertFrom-SecureString | Out-File @paramOutFile)
      }
      else
      {
         # Splat the parameters
         $paramGetContent = @{
            Path        = $CredentialFile
            Force       = $true
            ErrorAction = 'Stop'
         }
         $paramConvertToSecureString = @{
            ErrorAction = 'Stop'
         }

         # Read and convert the file wit the password
         $PwdSecureString = (Get-Content @paramGetContent | ConvertTo-SecureString @paramConvertToSecureString)

         # Splat the parameters
         $paramNewObject = @{
            TypeName     = 'System.Management.Automation.PSCredential'
            ArgumentList = $CredentialUser, $PwdSecureString
         }

         # Create the credential object
         $ExoCreds = (New-Object @paramNewObject)

         # Remove the password string from memory
         $PwdSecureString = $null
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

      $info | Out-String | Write-Verbose

      Write-Error -Message ($info.Exception) -ErrorAction Stop

      # Only here to catch a global ErrorAction overwrite
      break
      #endregion ErrorHandler
   }
   #endregion CredentialHandler

   #region ConnectExchangeOnline
   try
   {
      # Proxy Handling
      <#
            -ProxyAccessType <ProxyAccessType>
            Determines which mechanism is used to resolve the host name. The acceptable values for this parameter are:
            - IEConfig
            - WinHttpConfig
            - AutoDetect
            - NoProxyServer
            - None

            The default value is None.
            For information about the values of this parameter, see the description of the System.Management.Automation.Remoting.ProxyAccessTypehttp://go.microsoft.com/fwlink/?LinkId=144756 (http://go.microsoft.com/fwlink/?LinkId=144756) enumeration in the Microsoft Developer Network (MSDN) library.

            Source:
            Get-Help New-PSSessionOption -Detailed
      #>
      if ($ProxyAccessType)
      {
         # Splat the parameters
         $paramNewPSSessionOption = @{
            ProxyAccessType = $ProxyAccessType
            ErrorAction     = 'Stop'
         }

         # Do we need a proxy to access Office 365?
         $ProxyOptions = (New-PSSessionOption @paramNewPSSessionOption)
      }

      # Cleanup
      $ExoSession = $null

      # Splat the parameters
      $paramGetPSSession = @{
         ErrorAction = 'SilentlyContinue'
      }
      $paramRemovePSSession = @{
         ErrorAction = 'SilentlyContinue'
         Confirm     = $false
      }

      # Remove all existing Exchange Online Sessions
      $null = (Get-PSSession @paramGetPSSession | Where-Object {
            $_.ComputerName -eq 'outlook.office365.com'
      } | Remove-PSSession @paramRemovePSSession)

      # Splat the parameters
      $paramNewPSSession = @{
         ConfigurationName = 'Microsoft.Exchange'
         ConnectionUri     = 'https://outlook.office365.com/powershell-liveid/'
         Credential        = $ExoCreds
         Authentication    = 'Basic'
         AllowRedirection  = $true
         ErrorAction       = 'Stop'
      }

      # Proxy settings needed?
      if ($ProxyOptions)
      {
         $paramNewPSSession.SessionOption = $ProxyOptions
      }

      # Create the session
      $ExoSession = (New-PSSession @paramNewPSSession)

      # Splat the parameters
      $paramImportPSSession = @{
         Session             = $ExoSession
         DisableNameChecking = $true
         AllowClobber        = $true
         ErrorAction         = 'Stop'
         WarningAction       = 'Continue'
      }

      # Create the Session
      $null = (Import-PSSession @paramImportPSSession)
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

      $info | Out-String | Write-Verbose

      Write-Error -Message ($info.Exception) -ErrorAction Stop

      # Only here to catch a global ErrorAction overwrite
      break
      #endregion ErrorHandler
   }
   #endregion ConnectExchangeOnline

   #region SetCASMailbox
   try
   {
      # Check if the session is alive
      if (-not (Get-Command -Name Get-CASMailbox))
      {
         # Splat the parameters
         $paramWriteError = @{
            Exception   = 'Es scheint ein Problem mit der Exchange Online Verbindung zu geben!'
            Message     = 'Die erforderlichen Exchnage Online Befehle wurden nicht gefunden!'
            Category    = 'ResourceUnavailable'
            ErrorAction = 'Stop'
         }
         Write-Error @paramWriteError

         # Make sure we are done!
         throw
      }

      # Splat the parameters
      $paramGetCASMailbox = @{
         ResultSize    = 'unlimited'
         Filter        = {
            (name -notlike 'DiscoverysearchMailbox*')
         }
         ErrorAction   = 'Stop'
         WarningAction = 'Continue'
      }
      $paramSetCASMailbox = @{
         ActiveSyncEnabled                = $false
         ImapEnabled                      = $false
         MAPIEnabled                      = $false
         OutlookMobileEnabled             = $false
         OWAEnabled                       = $false
         OWAforDevicesEnabled             = $false
         PopEnabled                       = $false
         SmtpClientAuthenticationDisabled = $false
         UniversalOutlookEnabled          = $false
         Confirm                          = $false
         ErrorAction                      = 'Continue'
         WarningAction                    = 'Continue'
      }

      # Remove the outlook access from all mailboxes
      $null = (Get-CASMailbox @paramGetCASMailbox | Set-CASMailbox @paramSetCASMailbox)
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

      $info | Out-String | Write-Verbose

      Write-Error -Message ($info.Exception) -ErrorAction Stop

      # Only here to catch a global ErrorAction overwrite
      break
      #endregion ErrorHandler
   }
   #endregion SetCASMailbox
}

end
{
   # Cleanup
   $ExoSession = $null

   # Splat the parameters
   $paramGetPSSession = @{
      ErrorAction = 'SilentlyContinue'
   }
   $paramRemovePSSession = @{
      ErrorAction = 'SilentlyContinue'
      Confirm     = $false
   }

   # Remove all existing Exchange Online Sessions
   $null = (Get-PSSession @paramGetPSSession | Where-Object {
         $_.ComputerName -eq 'outlook.office365.com'
   } | Remove-PSSession @paramRemovePSSession)
}
