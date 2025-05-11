<#
      .SYNOPSIS
      Replace the Domain for all UnifiedGroups (and Microsoft Teams) Primary SMTP Address

      .DESCRIPTION
      Replace the Domain for all UnifiedGroups (and Microsoft Teams) Primary SMTP Address

      .PARAMETER OldDomain
      The old Domain (e.g. contoso.com)

      .PARAMETER NewDomain
      The new Domain (e.g. contoso.net)

      .EXAMPLE
      PS C:\> .\ReplaceDomainForAllUnifiedGroups.ps1 -OldDomain 'contoso.com' -NewDomain 'contoso.net'

      Replace the Primary SMTP Addresses for all UnifiedGroups (and Microsoft Teams) that are in the domain 'contoso.com' with the someone in the Domain 'contoso.net'
      e.g. if an old address was myTeam@contoso.com would end up as myTeam@contoso.new

      .LINK
      https://docs.microsoft.com/en-us/powershell/exchange/exchange-online/connect-to-exchange-online-powershell/connect-to-exchange-online-powershell?view=exchange-ps

      .LINK
      http://hochwald.net

      .NOTES
      Quick and dirty approach, without any real Error handling.
      A friend asked me for a solution after a merger to replace all Primary SMTP Addresses and get rif of the old domain (legal requirement in this case)

      You need be be connected to an Exchange Online Session (NOT part of this script).
#>
[CmdletBinding(ConfirmImpact = 'Low',
   SupportsShouldProcess = $true)]
param
(
   [Parameter(Mandatory = $true,
      ValueFromPipeline = $true,
      ValueFromPipelineByPropertyName = $true)]
   [ValidateNotNullOrEmpty()]
   [Alias('DomainToReplace')]
   [string]
   $OldDomain,
   [Parameter(Mandatory = $true,
      ValueFromPipeline = $true,
      ValueFromPipelineByPropertyName = $true)]
   [ValidateNotNullOrEmpty()]
   [string]
   $NewDomain
)

begin
{
   $OldMailFilter = ('@' + $OldDomain)

   # Cleanup
   $AllUnifiedGroups = $null
}

process
{
   $AllUnifiedGroups = (Get-UnifiedGroup | Where-Object -FilterScript {
         $PSItem.PrimarySmtpAddress -like ('*' + $OldMailFilter)
      } | Select-Object -Property Identity, DisplayName, PrimarySmtpAddress)

   if ($AllUnifiedGroups)
   {
      foreach ($item in $AllUnifiedGroups)
      {
         if ($item.PrimarySmtpAddress -like ('*' + $OldMailFilter))
         {
            $OldMailAddress = $null
            $OldMailAddress = (($item).PrimarySmtpAddress)

            $NewMailAddress = $null
            $NewMailAddress = ($OldMailAddress.Replace($OldMailFilter, ('@' + $NewDomain)))
            Write-Verbose -Message ('Replace: {0} with: {1}' -f $OldMailAddress, $NewMailAddress)

            # Add the new Address
            $null = (Set-UnifiedGroup -Identity (($item).Identity) -EmailAddresses: @{
                  Add = $NewMailAddress
               } -Confirm:$false)

            # Make new Address the primary SMTP address
            $null = (Set-UnifiedGroup -Identity (($item).Identity) -PrimarySmtpAddress $NewMailAddress -Confirm:$false)

            # Remove the old SMTP Address
            $null = (Set-UnifiedGroup -Identity (($item).Identity) -EmailAddresses: @{
                  Remove = $OldMailAddress
               } -Confirm:$false)
         }
         else
         {
            Write-Warning -Message ('Sorry, the PrimarySmtpAddress of {0} is not in {1}' -f $item.DisplayName, $OldDomain)
         }
      }
   }
   else
   {
      Write-Output -InputObject 'Nothing to do!!!'
   }
}
