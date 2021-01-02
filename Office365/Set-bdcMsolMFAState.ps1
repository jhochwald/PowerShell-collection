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

#region LICENSE
<#
   BSD 3-Clause License

   Copyright (c) 2021, enabling Technology
   All rights reserved.

   Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

   1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
   2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
   3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>
#endregion LICENSE

#region DISCLAIMER
<#
   DISCLAIMER:
   - Use at your own risk, etc.
   - This is open-source software, if you find an issue try to fix it yourself. There is no support and/or warranty in any kind
   - This is a third-party Software
   - The developer of this Software is NOT sponsored by or affiliated with Microsoft Corp (MSFT) or any of its subsidiaries in any way
   - The Software is not supported by Microsoft Corp (MSFT)
   - By using the Software, you agree to the License, Terms, and any Conditions declared and described above
   - If you disagree with any of the terms, and any conditions declared: Just delete it and build your own solution
#>
#endregion DISCLAIMER
