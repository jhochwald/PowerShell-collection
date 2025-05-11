function Set-Office365GroupMailAddress
{
   <#
         .SYNOPSIS
         Add or change Office 365 Group or Team Email Address

         .DESCRIPTION
         Add or change Office 365 Group or Team Email Address

         .PARAMETER OldDomain
         Old Domain Name, Format is: DOMAIN.TLD
         e.g. contoso.com

         .PARAMETER NewDomain
         NEW Domain Name, Format is: DOMAIN.TLD
         e.g. contoso.net

         .PARAMETER MakeNewPrimary
         Will the new Mail address be the new Primary SMTP Address?

         .PARAMETER RemoveOld
         Should the old Primary SMTP Address be removed?
         Please note: You must make another one to your Primary SMTP Address before you do this!

         .EXAMPLE
         PS C:\> Set-Office365GroupMailAddress -OldDomain 'contoso.onmicrosoft.com' -NewDomain 'contoso.com'

         If the existing Primary SMTP Address is 'dummy@contoso.onmicrosoft.com', this will add 'dummy@contoso.com' as alias.

         .EXAMPLE
         PS C:\> Set-Office365GroupMailAddress -OldDomain 'contoso.com' -NewDomain 'contoso.net' -MakeNewPrimary

         If the existing Primary SMTP Address is 'dummy@contoso.com', this will add 'dummy@contoso.com' as alias,
         and make it the new Primary SMTP Address

         .EXAMPLE
         PS C:\> Set-Office365GroupMailAddress -OldDomain 'contoso.com' -NewDomain 'contoso.net' -MakeNewPrimary -RemoveOld

         If the existing Primary SMTP Address is 'dummy@contoso.com', this will add 'dummy@contoso.com' as alias,
         and make it the new Primary SMTP Address and removes the old address

         .EXAMPLE
         PS C:\> Set-Office365GroupMailAddress -OldDomain 'contoso.com' -NewDomain 'contoso.net' -MakeNewPrimary -RemoveOld -WhatIf

         If the existing Primary SMTP Address is 'dummy@contoso.com', this will add 'dummy@contoso.com' as alias,
         and make it the new Primary SMTP Address and removes the old address

         Will simulate the execution (WhatIf is present)

         .EXAMPLE
         PS C:\> Set-Office365GroupMailAddress -OldDomain 'contoso.com' -NewDomain 'contoso.net' -MakeNewPrimary -RemoveOld -Verbose

         If the existing Primary SMTP Address is 'dummy@contoso.com', this will add 'dummy@contoso.com' as alias,
         and make it the new Primary SMTP Address and removes the old address.

         The Process will be verbose (Verbose is present)

         .NOTES
         Initial public Release!

         Might become handy if you like to convert all DOMAIN.onmicrosoft.com addresses to your own domain,
         or if you decide to go with a new external mail domain.
   #>
   [CmdletBinding(ConfirmImpact = 'Low',
      SupportsShouldProcess)]
   param
   (
      [Parameter(ValueFromPipeline,
         ValueFromPipelineByPropertyName)]
      [ValidateNotNullOrEmpty()]
      [string]
      $OldDomain = 'contoso.com',
      [Parameter(ValueFromPipeline,
         ValueFromPipelineByPropertyName)]
      [ValidateNotNullOrEmpty()]
      [string]
      $NewDomain = 'contoso.net',
      [Parameter(ValueFromPipeline,
         ValueFromPipelineByPropertyName)]
      [Alias('MakePrimary')]
      [switch]
      $MakeNewPrimary = $null,
      [Parameter(ValueFromPipeline,
         ValueFromPipelineByPropertyName)]
      [Alias('RemoveOldDomain', 'Remove', 'Cleanup')]
      [switch]
      $RemoveOld = $null
   )

   begin
   {
      # Save the infos from the switches
      $IsVerbose = (($PSCmdlet.MyInvocation.BoundParameters['Verbose']).IsPresent)
      $IsWhatIf = (($PSCmdlet.MyInvocation.BoundParameters['WhatIf']).IsPresent)

      # Build the filter strings
      $OldDomainString = ('@' + $OldDomain)
      $NewDomainString = ('@' + $NewDomain)

      # Cleanup
      $WrongGroups = $null

      # Get all matching Groups
      $WrongGroups = (Get-UnifiedGroup -ErrorAction Stop -Verbose:$IsVerbose | Where-Object -FilterScript {
            $PSItem.PrimarySmtpAddress -like ('*' + $OldDomainString)
         })
   }

   process
   {
      foreach ($item in $WrongGroups)
      {
         # Replace within the string
         $NewPrimarySmtpAddress = ($item.PrimarySmtpAddress).Replace($OldDomainString, $NewDomainString)

         #region AddEmailAddresses
         $paramSetUnifiedGroup = @{
            Identity       = ($item.Name)
            EmailAddresses = @{
               Add = $NewPrimarySmtpAddress
            }
            ErrorAction    = 'Continue'
            WhatIf         = $IsWhatIf
            Verbose        = $IsVerbose
            Confirm        = $false
         }
         $null = (Set-UnifiedGroup @paramSetUnifiedGroup)
         #endregion AddEmailAddresses

         #region SetPrimarySmtpAddress
         if ($MakeNewPrimary)
         {
            $paramSetUnifiedGroup = @{
               Identity           = ($item.Name)
               PrimarySmtpAddress = $NewPrimarySmtpAddress
               ErrorAction        = 'Continue'
               WhatIf             = $IsWhatIf
               Verbose            = $IsVerbose
               Confirm            = $false
            }
            $null = (Set-UnifiedGroup @paramSetUnifiedGroup)
         }
         #endregion SetPrimarySmtpAddress

         #region RemoveOldAddress
         if ($RemoveOld)
         {
            $paramSetUnifiedGroup = @{
               Identity       = ($item.Name)
               EmailAddresses = @{
                  Remove = ($item.PrimarySmtpAddress)
               }
               ErrorAction    = 'Continue'
               WhatIf         = $IsWhatIf
               Verbose        = $IsVerbose
               Confirm        = $false
            }
            $null = (Set-UnifiedGroup @paramSetUnifiedGroup)
         }
         #endregion RemoveOldAddress
      }
   }

   end
   {
      # Cleanup
      $WrongGroups = $null
   }
}

#region LICENSE
<#
   BSD 3-Clause License

   Copyright (c) 2022, enabling Technology
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
