function Get-AzureADTeantIdForDomain
{
   <#
         .SYNOPSIS
         Get the Azure Active Directory Teant ID for a given Domain
   
         .DESCRIPTION
         Get the Azure Active Directory Teant ID for a given Domain
   
         .PARAMETER Domain
         TLD Name (Vanity and onmicrosoft.com domains will work)
         e.g., contoso.com or contoso.onmicrosoft.com
   
         .EXAMPLE
         PS C:\> Get-AzureADTeantIdForDomain -Domain 'contoso.com'

         Get the Azure Active Directory Teant ID for a given Domain

         .EXAMPLE
         PS C:\> 'contoso.onmicrosoft.com' | Get-AzureADTeantIdForDomain

         Get the Azure Active Directory Teant ID for a given Domain, via pipeline
   
         .NOTES
         Do not abuse!

         Vanity and onmicrosoft.com domains will work
   #>
   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([string])]
   param
   (
      [Parameter(ValueFromPipeline,
                 ValueFromPipelineByPropertyName)]
      [ValidateNotNullOrEmpty()]
      [string]
      $Domain = 'contoso.com'
   )
   
   process
   {
      $TeantId = $null
      $TeantId = ((Invoke-RestMethod -Uri ('https://login.windows.net/{0}/.well-known/openid-configuration' -f $Domain) -Method Get).token_endpoint.Split('/')[3])
   }
   
   end
   {
      $TeantId
      
      # Cleanup-Up
      $TeantId = $null
   }
}
