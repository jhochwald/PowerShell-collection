#requires -Version 2.0 -Modules MSCommerce
<#
      .SYNOPSIS
      Configure "self-service trial of Viva Goals" within a tenant

      .DESCRIPTION
      Configure "self-service trial of Viva Goals" within a Microsoft 365 tenant

      .EXAMPLE
      PS C:\> .\Setup-MSCommerceProductPolicies.ps1

      Configure "Self-Service Purchase" within a Microsoft 365 tenant

      .LINK
      https://learn.microsoft.com/en-us/microsoft-365/commerce/subscriptions/allowselfservicepurchase-powershell?view=o365-worldwide

      .LINK
      https://learn.microsoft.com/microsoft-365/commerce/subscriptions/manage-self-service-purchases-admins?view=o365-worldwide

      .LINK
      https://petri.com/m365-changelog-self-service-trial-experience-available-for-viva-goals/

      .LINK
      https://m365admin.handsontek.net/self-service-trial-experience-available-for-viva-goals/

      .NOTES
      Just add a kind of logic, with a list of allowed services, related to MC516356

      And here we go again: There is a "Connect-MSCommerce" within the MSCommerce,
      but there is no "Disconnect-MSCommerce" provided!
#>
[CmdletBinding(ConfirmImpact = 'Low')]
[OutputType([string])]
param ()

process
{
   # Connect to the MSCommerce services
   Connect-MSCommerce
   
   # Get the existing list of services
   $MSCommerceProductPolicies = (Get-MSCommerceProductPolicies -PolicyId AllowSelfServicePurchase)
   
   # Only this is allowd
   $AllowedProducts = @(
      'Viva Learning'
      'Viva Goals'
      'Teams Exploratory'
   )
   
   foreach ($MSCommerceProductPolicy in $MSCommerceProductPolicies)
   {
      $paramUpdateMSCommerceProductPolicy = $null
      
      if (($MSCommerceProductPolicy.PolicyId -eq 'AllowSelfServicePurchase') -and ($AllowedProducts -contains $MSCommerceProductPolicy.ProductName) -and ($MSCommerceProductPolicy.PolicyValue -ne 'Enabled'))
      {
         $paramUpdateMSCommerceProductPolicy = @{
            PolicyId      = $MSCommerceProductPolicy.PolicyId
            ProductId     = $MSCommerceProductPolicy.ProductId
            Enabled       = $true
            ErrorAction   = 'Continue'
            WarningAction = 'SilentlyContinue'
         }
         $null = (Update-MSCommerceProductPolicy @paramUpdateMSCommerceProductPolicy)
      }
      elseif (($MSCommerceProductPolicy.PolicyId -eq 'AllowSelfServicePurchase') -and (-not ($AllowedProducts -contains $MSCommerceProductPolicy.ProductName)) -and ($MSCommerceProductPolicy.PolicyValue -ne 'Disabled'))
      {
         $paramUpdateMSCommerceProductPolicy = @{
            PolicyId      = $MSCommerceProductPolicy.PolicyId
            ProductId     = $MSCommerceProductPolicy.ProductId
            Enabled       = $false
            ErrorAction   = 'Continue'
            WarningAction = 'SilentlyContinue'
         }
         $null = (Update-MSCommerceProductPolicy @paramUpdateMSCommerceProductPolicy)
      }
      
      $paramUpdateMSCommerceProductPolicy = $null
   }
}

end
{
   $MSCommerceProductPolicies = $null
   $AllowedProducts = $null
   
   #region GarbageCollection
   [GC]::Collect()
   [GC]::WaitForPendingFinalizers()
   #endregion GarbageCollection
}