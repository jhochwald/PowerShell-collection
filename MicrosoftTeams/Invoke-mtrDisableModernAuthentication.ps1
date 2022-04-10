function Invoke-mtrDisableModernAuthentication
{
   <#
         .SYNOPSIS
         Disable Modern Authentication for a Microsoft Teams Room Device Account

         .DESCRIPTION
         Disable Modern Authentication for a Microsoft Teams Room Device Account
         It dsables it in Exchange Online and Skype for Business Online. It also configures the tenant to do so, if needed.

         .PARAMETER Identity
         The Microsoft Teams Rooms (MTR) Account Search String

         .EXAMPLE
         PS C:\> .\Invoke-mtrDisableModernAuthentication.ps1 -Identity 'MyTeamRoom'

         .EXAMPLE
         PS C:\> .\Invoke-mtrDisableModernAuthentication.ps1 -Identity 'TeamRoom@contoso.com'

         .NOTES
         Just a quick and dirty tool to do the job, nothing fancy and without a real error handling!
         -> Use at your own risk!

         You need to be a tenant admin to configure all the things
   #>
   [CmdletBinding(ConfirmImpact = 'Low')]
   param
   (
      [Parameter(Mandatory, HelpMessage = 'The Microsoft Teams Rooms (MTR) Account Search String',
         ValueFromPipeline,
         ValueFromPipelineByPropertyName,
         Position = 0)]
      [ValidateNotNullOrEmpty()]
      [Alias('SearchString', 'mtrAccount')]
      [string]
      $Identity
   )

   begin
   {
      #region Defaults
      $STP = 'Stop'
      $SCT = 'SilentlyContinue'
      #endregion Defaults

      #region GeneralParameters
      $RemovePSSessionDefaultParams = @{
         Confirm     = $false
         ErrorAction = $SCT
      }

      $RemoveModuleDefaultParams = @{
         Force       = $true
         Confirm     = $false
         ErrorAction = $SCT
      }
      #endregion GeneralParameters

      Write-Verbose -Message 'Message'
   }

   process
   {
      #region ConnectAzureAD
      $null = (Connect-AzureAD)
      #endregion ConnectAzureAD

      #region ConnectSkypeForBusinessOnline
      # We use a crappy workaround, because the Modern Auth window never shows up to querry the admin UPN, and I do NOT trust the command to querry it
      $SkypeForBusinessSession = (New-CsOnlineSession -UserName (Read-Host -Prompt 'Please enter the admin principal name (ex. admin@contoso.com)'))
      $paramImportPSSession = @{
         Session             = $SkypeForBusinessSession
         DisableNameChecking = $true
         AllowClobber        = $true
      }
      $null = (Import-PSSession @paramImportPSSession)
      #endregion ConnectSkypeForBusinessOnline

      #region ConnectExchangeOnline
      # We use the ExchangeOnlineShell Module from the Gallery
      if (-not (Get-Command -Name Get-Mailbox -ErrorAction $SCT))
      {
         $paramConnectExchangeOnlineShell = @{
            Confirm       = $false
            WarningAction = $SCT
            ErrorAction   = $STP
         }
         $null = (Connect-ExchangeOnlineShell @paramConnectExchangeOnlineShell)
      }
      #endregion ConnectExchangeOnline

      #region CheckModernAuth
      # Do we have Modern Auth enabled Global?
      if ((Get-OrganizationConfig | Select-Object -ExpandProperty OAuth2ClientProfileEnabled) -eq $true)
      {
         # Disconnect Modern Authentication (For a single user) - In this case the MTR
         $paramRevokeAzureADUserAllRefreshToken = @{
            ObjectId    = (Get-AzureADUser -SearchString $Identity | Select-Object -ExpandProperty objectId)
            ErrorAction = $SCT
         }
         $null = (Revoke-AzureADUserAllRefreshToken @paramRevokeAzureADUserAllRefreshToken)
         $null = (Revoke-AzureADUserAllRefreshToken @paramRevokeAzureADUserAllRefreshToken)

         # Allow non Modern Auth in Skype for Business
         if ((Get-CsOAuthConfiguration -ErrorAction $SCT | Select-Object -ExpandProperty ClientAdalAuthOverride) -ne 'Allowed')
         {
            $paramSetCsOAuthConfiguration = @{
               ClientAdalAuthOverride = 'Allowed'
               Confirm                = $false
               ErrorAction            = $SCT
            }
            $null = (Set-CsOAuthConfiguration @paramSetCsOAuthConfiguration)
         }
      }
      else
      {
         # Shame on you!
         Write-Warning -Message 'Looks like Modern Auth is not enabled for this tenant!' -WarningAction $STP
      }
      #endregion CheckModernAuth

      #region DisconnectAzureAD
      $null = (Disconnect-AzureAD -Confirm:$false -ErrorAction $SCT)
      #endregion DisconnectAzureAD

      #region DisconnectSkypeForBusiness
      $paramRemoveModule = @{
         Name        = (Get-Command -Name Set-CsOAuthConfiguration -ErrorAction $SCT | Select-Object -ExpandProperty Source)
         Force       = $true
         ErrorAction = $SCT
      }

      $null = (Remove-Module @paramRemoveModule)
      $null = ($SkypeForBusinessSession.Id | Remove-PSSession @RemovePSSessionDefaultParams)
      #endregion DisconnectSkypeForBusiness

      #region DisconnectExchangeOnline
      $ExchangeSessionID = (Get-PSSession | Where-Object {
            $PSItem.ComputerName -eq 'outlook.office365.com'
         } | Select-Object -ExpandProperty Id)

      if ($ExchangeSessionID)
      {
         $paramDisconnectExchangeOnlineShell = @{
            SessionID = $ExchangeSessionID
            Confirm   = $false
         }
         $null = (Disconnect-ExchangeOnlineShell @paramDisconnectExchangeOnlineShell)
      }

      # Will be removed soon (Disconnect-ExchangeOnlineShell will handle this for us!)
      $RemoveModuleName = (Get-Command -Name Get-OrganizationConfig -ErrorAction $SCT | Select-Object -ExpandProperty Source)

      if ($RemoveModuleName)
      {
         $paramRemoveModule = @{
            Name        = $RemoveModuleName
            Force       = $true
            ErrorAction = $SCT
         }
         $null = (Remove-Module @RemoveModuleDefaultParams)
      }
      #endregion DisconnectExchangeOnline
   }

   end
   {
      #region FinalCleanup
      # Just in case: We remove all sessions that might still be around
      $null = ((Get-PSSession -ErrorAction $SCT | Where-Object {
               $PSItem.ComputerName -eq 'outlook.office365.com'
            }) | Remove-PSSession @RemovePSSessionDefaultParams)

      $null = ((Get-PSSession -ErrorAction $SCT | Where-Object {
               $PSItem.ComputerName -like 'admin*.online.lync.com'
            }) | Remove-PSSession @RemovePSSessionDefaultParams)

      # Remove the Modules (Here just in case we missed something above)
      $null = (Remove-Module -Name (Get-Command -Name Connect-ExchangeOnlineShell -ErrorAction $SCT | Select-Object -ExpandProperty Source) @RemoveModuleDefaultParams)
      $null = (Remove-Module -Name (Get-Command -Name Disconnect-AzureAD -ErrorAction $SCT | Select-Object -ExpandProperty Source) @RemoveModuleDefaultParams)
      $null = (Remove-Module -Name (Get-Command -Name New-CsOnlineSession -ErrorAction $SCT | Select-Object -ExpandProperty Source) @RemoveModuleDefaultParams)
      #endregion FinalCleanup
   }
}
