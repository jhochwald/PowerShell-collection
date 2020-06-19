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
            $_.PrimarySmtpAddress -like ('*' + $OldDomainString)
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
