#requires -Version 3.0 -Modules CimCmdlets, Microsoft.PowerShell.LocalAccounts -RunAsAdministrator

<#
   .SYNOPSIS
   Remove given user and the matching profile

   .DESCRIPTION
   Remove given user and the matching profile.
   Created to remove all inactive guest users on a shared device

   .PARAMETER User
   You can specify the Username or use wildcards

   .EXAMPLE
   PS C:\> .\Remove-GuestUserAccounts.ps1 -User 'JohnDoe'

   Remove the user named 'JohnDoe', it also removes the Profile of the User.

   .EXAMPLE
   PS C:\> .\Remove-GuestUserAccounts.ps1 -User 'enguest*'

   Remove all users that starts with 'enguest', it also removes all Profiles of these Users.

   .NOTES
   Created to cleanup a shared device in aa conference room.
   We run this script every day to save some diskspace and to delete all unneeded accounts.
   All guest accounts on this system are one time users, so they are disabled after each use anyway.

   .LINK
   http://enatec.io
#>
[CmdletBinding(ConfirmImpact = 'Low',
   SupportsShouldProcess)]
param
(
   [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
   [ValidateNotNullOrEmpty()]
   [Alias('UserAlias')]
   [string]
   $User = 'shpctac*'
)

begin
{
   # Defaults
   $SCT = 'SilentlyContinue'

   # Cleanup
   $ExpiredGuests = $null
}

process
{
   if ($pscmdlet.ShouldProcess($User, 'Delete'))
   {
      # Get all matching users
      $paramGetLocalUser = @{
         Name          = $User
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $ExpiredGuests = (Get-LocalUser @paramGetLocalUser | Where-Object -FilterScript {
            $_.Enabled -eq $false
         })

      # Delete matching users, if we have some
      if ($ExpiredGuests)
      {
         # Remove the User Account
         $ExpiredGuests | ForEach-Object -Process {
            $paramRemoveLocalUser = @{
               Name          = ($_.Name)
               Confirm       = $false
               ErrorAction   = $SCT
               WarningAction = $SCT
            }
            $null = (Remove-LocalUser @paramRemoveLocalUser)
         }

         # Remove the Profile
         $ExpiredGuests | ForEach-Object -Process {
            $paramGetCimInstance = @{
               ClassName     = 'Win32_UserProfile'
               ErrorAction   = $SCT
               WarningAction = $SCT
            }
            $paramRemoveCimInstance = @{
               Confirm       = $false
               ErrorAction   = $SCT
               WarningAction = $SCT
            }
            $null = (Get-CimInstance @paramGetCimInstance | Where-Object -FilterScript {
                  $_.LocalPath.split('\') -eq $_.Name
               } | Remove-CimInstance @paramRemoveCimInstance)
         }
      }
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
   - If you disagree with any of the Terms, and any Conditions declared: Just delete it and build your own solution
#>
#endregion DISCLAIMER
