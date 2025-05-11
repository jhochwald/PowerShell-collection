#requires -Version 3.0 -Modules AzureAD, Microsoft.Online.SharePoint.PowerShell
<#
      .SYNOPSIS
      Provision new Users personal SharePoint site

      .DESCRIPTION
      Provision new Users personal SharePoint site, Will also trigger the OneDrive provisioning.

      .PARAMETER TenantName
      Microsoft 365 Tenant name (e.g. contoso for contoso.onmicrosoft.com)
      Do not use any of the vanity domains of your tenant here!

      .EXAMPLE
      PS C:\> .\FixPersonalSPOSite.ps1
      Provision new Users personal SharePoint site

      .EXAMPLE
      PS C:\> .\FixPersonalSPOSite.ps1 -TenantName 'contoso'
      Provision new Users personal SharePoint site for the Microsoft 365 tenant with the name 'contoso' (for contoso.onmicrosoft.com)

      .NOTES
      I had issues where newly created users where unable to access there personal site/OneDrive via portal.office.com
      We found this issue in at least two different tenants, therefore we decided to figure out a workaround.

      Want to know how the magic workaround works?
      See the last command of this script, Get-SPOSite does all the magic. Don't ask!

      Author: Joerg Hochwald - https://hochwald.net
      Contributor: Christopher Pope - https://hope-this-helps.de
#>
[CmdletBinding(ConfirmImpact = 'Low')]
param
(
   [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName,
      Position = 0)]
   [ValidateNotNullOrEmpty()]
   [Alias('Tenant')]
   [string]
   $TenantName = ' contoso'
)

begin
{
   # Set the URL main part
   $AdminUrl = ('https://' + $TenantName + '-admin.sharepoint.com')

   # Connect to AzureAD
   Connect-AzureAD -ErrorAction Stop

   # Connect to SharePoint Online
   Connect-SPOService -Url $AdminUrl -ErrorAction Stop
}

process
{
   # Get all User from the AzureAD
   # Mind the Gap: -All is not a switch, it IS a Boolean <- WTF?
   $paramGetAzureADUser = @{
      All         = $true
      ErrorAction = 'SilentlyContinue'
   }
   $NewODFBUsers = (Get-AzureADUser @paramGetAzureADUser | Select-Object)

   # Filter licensed users
   $NewODFBUsers = ($NewODFBUsers | Where-Object -FilterScript {
         <#
               You can Filter much more, if you like
               We Filter:
               1. User with an assigned License
               2. All external users (based on the '#EXT#' in the UserPrincipalName)
               3. All users without a vanity domain (e.g. everyone within @NAME.onmicrosoft.com) <- Review this before using it!!!
         #>
         (($PSItem.AssignedLicenses -ne $null) -and ($PSItem.UserPrincipalName -notlike ('*#EXT#@*')) -and ($PSItem.UserPrincipalName -notlike ('*@' + $TenantName + '.onmicrosoft.com')))
      } | Select-Object -ExpandProperty UserPrincipalName -ErrorAction SilentlyContinue)

   # The Limit of Request-SPOPersonalSite is 200
   $SliceSize = 150

   # Create a new Index
   $SliceIndex = 0

   # Slice the big array into smaller chunks
   while ($($SliceSize * $SliceIndex) -lt $NewODFBUsers.Length)
   {
      # Cleanup
      $NewODFBUsersSlice = $null

      # Put the number of peaces into the new chunk (e.g. the new object)
      $NewODFBUsersSlice = ($NewODFBUsers | Select-Object -First $SliceSize -Skip ($SliceSize * $SliceIndex) -ErrorAction SilentlyContinue)

      # Just fire the Request, the hard limit is 200 per call
      $paramRequestSPOPersonalSite = @{
         UserEmails    = $NewODFBUsersSlice
         NoWait        = $true
         ErrorAction   = 'SilentlyContinue'
         WarningAction = 'SilentlyContinue'
      }
      $null = (Request-SPOPersonalSite @paramRequestSPOPersonalSite)

      # Count the slice
      $SliceIndex++
   }

   # Cool down and let Azure (SPO in this case) do the provisioning job in the background
   Start-Sleep -Seconds 60

   <#
         Reference is Case #:23027858 (One Drive is not accessible via portal.office.com)
         Solution: This get will do the magic! You have to do a Select on the "Owner" object to make the magic work.
         Looks like the get will trigger something in the background!
   #>
   $paramGetSPOSite = @{
      IncludePersonalSite = $true
      Limit               = 'all'
      Filter              = "Url -like '-my.sharepoint.com/personal/'"
      ErrorAction         = 'SilentlyContinue'
      WarningAction       = 'SilentlyContinue'
   }
   $null = (Get-SPOSite @paramGetSPOSite | Select-Object -Property Url, Owner)
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
