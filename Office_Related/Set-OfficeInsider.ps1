#requires -Version 1.0

<#
   .SYNOPSIS
   This script will set the Office Channel info in the Registry

   .DESCRIPTION
   This script will add the Office Insider Channel Information in the Registry.
   It is a Quick and Dirty Solution.

   .PARAMETER Channel
   The Office Release Channel

   Possible Values for the Channel Variable are:
   Insiderfast - With weekly builds, not generally supported
   FirstReleaseCurrent - Office Insider Slow aka First Release Channel
   Current - Current Channel (Default)
   Validation - First Release for Deferred Channel
   Business - Also known as Current Branch for Business

   .EXAMPLE
   # Set the Distribution Channel to Insiderfast - Weekly builds
   PS> .\Set-OfficeInsider.ps1 -Channel 'Insiderfast'

   .EXAMPLE
   # Set the Distribution Channel to Business - Slow updates
   PS> .\Set-OfficeInsider.ps1 -Channel 'Business'

   .NOTES
   This will work with Windows based Office 365 (Click to Run) installations only!

   Change the Release Channel might cause issues! Do this at your own risk.
   Not all Channels are supported by Microsoft.

   Author: Joerg Hochwald - http://hochwald.net
#>
param
(
   [Parameter(ValueFromPipeline = $true,
      Position = 1)]
   [ValidateSet('Insiderfast', 'FirstReleaseCurrent', 'Current', 'Validation', 'Business', IgnoreCase = $true)]
   [ValidateNotNullOrEmpty()]
   [string]
   $Channel = 'Current'
)

begin
{
   # Constants
   $SC = 'SilentlyContinue'

   try
   {
      $paramNewItem = @{
         Path          = 'HKLM:\SOFTWARE\Policies\Microsoft\office\16.0\common\'
         Name          = 'officeupdate'
         Force         = $true
         ErrorAction   = $SC
         WarningAction = $SC
         Confirm       = $false
      }
      $null = (New-Item @paramNewItem)

      Write-Verbose -Message 'The Registry Structure was created.'
   }
   catch
   {
      Write-Verbose -Message 'The Registry Structure exists...'
   }
}

process
{
   try
   {
      $paramNewItemProperty = @{
         Path          = 'HKLM:\SOFTWARE\Policies\Microsoft\office\16.0\common\officeupdate'
         Name          = 'updatebranch'
         PropertyType  = 'String'
         Value         = $Channel
         Force         = $true
         ErrorAction   = $SC
         WarningAction = $SC
         Confirm       = $false
      }
      $null = (New-ItemProperty @paramNewItemProperty)

      Write-Verbose -Message 'Registry Entry was created.'
   }
   catch
   {
      $paramSetItem = @{
         Path          = 'HKLM:\SOFTWARE\Policies\Microsoft\office\16.0\common\officeupdate\updatebranch'
         Value         = $Channel
         Force         = $true
         ErrorAction   = $SC
         WarningAction = $SC
         Confirm       = $false
      }
      $null = (Set-Item @paramSetItem)

      Write-Verbose -Message 'Registry Entry was changed.'
   }
}

end
{
   Write-Output -InputObject "Office Release Channel Set to $Channel"
}

#region LICENSE
<#
      BSD 3-Clause License

      Copyright (c) 2020, enabling Technology
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
      - If you disagree with any of the Terms, and any Conditions declared: Just delete it and build your own solution
#>
#endregion DISCLAIMER
