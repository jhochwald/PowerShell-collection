#requires -Version 3.0

function Disable-AzAccountLinkingExperience
{
   <#
         .SYNOPSIS
         Disable AAD/MSA Account Linking Experience

         .DESCRIPTION
         Disable AAD/MSA Account Linking Experience (MC466201)

         .EXAMPLE
         PS C:\> Disable-AzAccountLinkingExperience

         .LINK
         https://download.microsoft.com/download/2/4/5/245c3b59-a897-4ee1-a24d-e0ead9007603/AccountLinkingDisable.ps1

         .LINK
         https://go.microsoft.com/fwlink/?linkid=2214142

         .LINK
         https://go.microsoft.com/fwlink/?linkid=2214321

         .LINK
         https://learn.microsoft.com/microsoftsearch/security-for-search

         .LINK
         https://www.microsoft.com/rewards?rtc=1

         .NOTES
         With account linking enabled, employees with an Azure Active Directory (AAD) and Microsoft (MSA) account can opt into account linking through entry points such as Microsoft Edge and Microsoft Bing

         This script is based on the Microsoft Roadmap entry MC466201:
         https://download.microsoft.com/download/2/4/5/245c3b59-a897-4ee1-a24d-e0ead9007603/AccountLinkingDisable.ps1

         Q: Why did we rewrite the?
         A: Mostly because we want to have it within a function. On the other hand, the origial script used the AzureAD module in addition... Why should we? We can do that all with the Az.Accounts module

         Q: Can I do that within the Admin Center?
         A: Yep: https://admin.microsoft.com/#/Settings/Services/:/Settings/L1/EnterpriseMicrosoftRewards
   #>
   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([string])]
   param ()

   begin
   {
      # Create a new object, hope we never need that afterwards
      $err = @()

      #region Functions
      function Invoke-CleanupProcess
      {
         <#
               .SYNOPSIS
               Internal Cleanup process

               .DESCRIPTION
               Internal Cleanup process

               .EXAMPLE
               PS C:\> Invoke-CleanupProcess

               Internal Cleanup process

               .NOTES
               Just an internal Helper to avoid to much redundanz within the code
         #>
         [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Justification = 'Because we just clean them here')]
         [CmdletBinding(ConfirmImpact = 'None')]
         [OutputType([string])]
         param ()

         process
         {
            $AzAccountInfo = $null
            $AzTenantInfo = $null
            $AzAccessToken = $null
            $RequestHeaders = $null
            $RequestBody = $null

            # Now we close the connection
            $null = (Disconnect-AzAccount -Confirm:$false -ErrorAction SilentlyContinue)
         }
      }
      #endregion Functions

      #region ModuleCheck
      try
      {
         if (-not (Get-Module -ListAvailable -Name Az.Accounts -ErrorAction SilentlyContinue))
         {
            $null = (Install-Module -Name Az.Accounts -AllowClobber -Force -Confirm:$false -ErrorAction Stop -ErrorVariable +err)
         }
      }
      catch
      {
         # Re-Throw
         Write-Error -Message $_ -ErrorAction Stop -ErrorVariable +err
         exit 1
      }
      finally
      {
         $null = (Invoke-CleanupProcess -ErrorAction SilentlyContinue)
      }
      #endregion ModuleCheck
   }

   process
   {
      #region LoginAzAccount
      try
      {
         # Interactive login
         $AzAccountInfo = (Connect-AzAccount -Force -Confirm:$false -ErrorAction Stop -ErrorVariable +err)

         # Get the Tenant Infos we need
         $AzTenantInfo = (Get-AzTenant -TenantId $AzAccountInfo.Context.Tenant.Id -ErrorAction Stop -ErrorVariable +err)
      }
      catch
      {
         # Re-Throw
         Write-Error -Message $_ -ErrorAction Stop -ErrorVariable +err
         exit 1
      }
      finally
      {
         if ($err)
         {
            $null = (Invoke-CleanupProcess -ErrorAction SilentlyContinue)
         }
      }
      #endregion LoginAzAccount

      #region GetAzAccessToken
      try
      {
         # Get an access token
         $AzAccessToken = (Get-AzAccessToken -TenantId $AzAccountInfo.Context.Tenant.Id -ErrorAction Stop -ErrorVariable +err)
      }
      catch
      {
         # Re-Throw
         Write-Error -Message $_ -ErrorAction Stop -ErrorVariable +err
         exit 1
      }
      finally
      {
         if ($err)
         {
            $null = (Invoke-CleanupProcess -ErrorAction SilentlyContinue)
         }
      }
      #endregion GetAzAccessToken

      #region CallAccountLinkingManagementWebService
      try
      {
         $RequestHeaders = @{
            Authorization = $AzAccessToken
            'X-Executor'  = $AzAccountInfo.Context.Account.Id
         }

         $RequestBody = (@{
               TenantName   = $AzTenantInfo.Name
               TenantId     = $AzTenantInfo.Id
               Executor     = $AzAccountInfo.Context.Account.Id
               TenantDomain = $AzTenantInfo.DefaultDomain
         } | ConvertTo-Json -Compress:$true -ErrorAction Stop -ErrorVariable +err)

         $paramInvokeRestMethod = @{
            Uri           = 'https://accountlinkingmanagement.azurewebsites.net/api/Disablelinking?code=DjA9zo8eSiXgCjZfz8wBq_A8njKsy0DOEN6C0fC-qqsVAzFufMRIEQ=='
            Method        = 'POST'
            Headers       = $RequestHeaders
            Body          = $RequestBody
            ErrorAction   = 'Stop'
            ErrorVariable = '+err'
         }
         $RequestResponse = (Invoke-RestMethod @paramInvokeRestMethod)
      }
      catch
      {
         # Re-Throw
         Write-Error -Message $_ -ErrorAction Stop -ErrorVariable +err
         exit 1
      }
      finally
      {
         if ($err)
         {
            $null = (Invoke-CleanupProcess -ErrorAction SilentlyContinue)
         }
      }
      #endregion CallAccountLinkingManagementWebService
   }

   end
   {
      # Dump the info
      $RequestResponse

      # Cleanup anyway
      $null = (Invoke-CleanupProcess -ErrorAction SilentlyContinue)
   }
}
