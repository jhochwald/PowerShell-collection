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
      A friend asked me for a solution after a merger to replace all Primary SMTP Addresses and get rid of the old domain (legal requirement in this case)

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
