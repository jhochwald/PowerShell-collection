#requires -Version 3.0 -Modules MSOnline
function Set-bdcMsolMFAState
{
   <#
         .SYNOPSIS
         Convert users from per-user MFA to Conditional Access based MFA
	
         .DESCRIPTION
         Convert users from per-user MFA to Conditional Access based MFA
	
         .PARAMETER ObjectId
         ObjectId of the Office 365 User
	
         .PARAMETER UserPrincipalName
         User Principal Name of the Office 365 User
	
         .PARAMETER State
         MFA State ('Disabled','Enabled', or 'Enforced')
         Default is Disabled
	
         .EXAMPLE
         Set-bdcMsolMFAState -ObjectId Value -UserPrincipalName john.doe@contoso.com -State Enabled
         Enabled MFA for john.doe@contoso.com
	
         .EXAMPLE
         Set-bdcMsolMFAState -ObjectId Value -UserPrincipalName john.doe@contoso.com -State Enabled
         Enforces MFA for john.doe@contoso.com
	
         .EXAMPLE
         Set-bdcMsolMFAState -ObjectId Value -UserPrincipalName john.doe@contoso.com -State Enabled
         Disables MFA for john.doe@contoso.com
	
         .EXAMPLE
         Get-MsolUser -All | Set-bdcMsolMFAState -State Disabled
         Disable MFA for all users
	
         .EXAMPLE
         (Get-MsolUser -UserPrincipalName john.doe@contoso.com | Select-Object -Property UserPrincipalName,StrongAuthenticationRequirements)
		
         Check the MFA state for john.doe@contoso.com
	
         .EXAMPLE
         (Get-MsolUser -UserPrincipalName john.doe@contoso.com | Select-Object -Property UserPrincipalName,StrongAuthenticationRequirements).StrongAuthenticationRequirements
		
         Check the MFA details for john.doe@contoso.com
	
         .OUTPUTS
         None
	
         .NOTES
         Just a minor tweaked version of the original Microsoft version (See link below)
	
         .LINK
         https://docs.microsoft.com/en-us/azure/active-directory/authentication/howto-mfa-userstates
	
         .INPUTS
         String
   #>
   [CmdletBinding(ConfirmImpact = 'medium',
   SupportsShouldProcess)]
   param
   (
      [Parameter(ValueFromPipelineByPropertyName)]
      [string]
      $ObjectId = $null,
      [Parameter(ValueFromPipelineByPropertyName)]
      [string]
      $UserPrincipalName = $null,
      [ValidateSet('Disabled', 'Enabled', 'Enforced')]
      [string]
      $State = 'Disabled'
   )
	
   begin
   {
      # Load the Assembly
      $null = (Add-Type -AssemblyName Microsoft.Online.Administration.Automation.PSModule)
   }
	
   process
   {
      Write-Verbose -Message ('Setting MFA state for user ' + $UserPrincipalName + ' (' + $ObjectId + ') to ' + $State)
		
      # Create a new Object
      $Requirements = @()
		
      # Create the settings and add them to the new object
      if ($State -ne 'Disabled')
      {
         $Requirement = [Microsoft.Online.Administration.StrongAuthenticationRequirement]::new()
         $Requirement.RelyingParty = '*'
         $Requirement.State = $State
         $Requirements += $Requirement
      }
		
      # Apply the new settings, based on the Object
      $null = (Set-MsolUser -ObjectId $ObjectId -UserPrincipalName $UserPrincipalName -StrongAuthenticationRequirements $Requirements)
   }
	
   end
   {
      # Cleanup
      $Requirements = $null
   }
}
