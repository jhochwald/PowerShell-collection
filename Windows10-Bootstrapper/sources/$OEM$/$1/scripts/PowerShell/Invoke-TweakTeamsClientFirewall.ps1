#requires -Version 3.0 -Modules NetSecurity -RunAsAdministrator

<#
   .SYNOPSIS
   Tweak the Firewall Rules for Microsoft Teams clients

   .DESCRIPTION
   Tweak the Firewall Rules for Microsoft Teams clients for all users that have it installed

   .NOTES
   Early testing release

   Changelog:
   1.0.1: Reformatted
   1.0.0: Initial Release

   Version 1.0.1

   .LINK
   http://enatec.io
#>
[CmdletBinding(ConfirmImpact = 'Low',
   SupportsShouldProcess)]
param ()

begin
{
   Write-Output -InputObject 'Tweak the Firewall Rules for Microsoft Teams clients for all users that have it installed'

   #region Defaults
   $SCT = 'SilentlyContinue'
   #endregion Defaults
}

process
{
   # Creates firewall rules for Microsoft Teams
   $AllUsers = $null

   $paramJoinPath = @{
      Path        = $env:SystemDrive
      ChildPath   = 'Users'
      ErrorAction = $SCT
   }
   $paramGetChildItem = @{
      Path        = (Join-Path @paramJoinPath)
      ErrorAction = $SCT
      Exclude     = 'Public', 'ADMINI~*'
   }
   $AllUsers = (Get-ChildItem @paramGetChildItem)

   if ($null -ne $AllUsers)
   {
      foreach ($SingleUser in $AllUsers)
      {
         # Cleanup
         $FullTeamsPath = $null

         # get the Executable
         $paramJoinPath = @{
            Path        = $SingleUser.FullName
            ChildPath   = 'AppData\Local\Microsoft\Teams\Current\Teams.exe'
            ErrorAction = $SCT
         }
         $FullTeamsPath = (Join-Path @paramJoinPath)

         $paramTestPath = @{
            Path        = $FullTeamsPath
            ErrorAction = $SCT
         }
         if (Test-Path @paramTestPath)
         {
            $paramGetNetFirewallApplicationFilter = @{
               Program     = $FullTeamsPath
               ErrorAction = $SCT
            }
            if (-not (Get-NetFirewallApplicationFilter @paramGetNetFirewallApplicationFilter))
            {
               # Cleanup
               $NetFirewallRuleName = $null

               # Apply the Rulename
               $NetFirewallRuleName = ('Teams.exe for user {0}' -f $SingleUser.Name)

               'UDP', 'TCP' | ForEach-Object -Process {
                  $paramNewNetFirewallRule = @{
                     DisplayName = $NetFirewallRuleName
                     Direction   = 'Inbound'
                     Profile     = 'Any'
                     Program     = $FullTeamsPath
                     Action      = 'Allow'
                     Protocol    = $_
                     Enabled     = 'True'
                     Confirm     = $false
                     ErrorAction = $SCT
                  }
                  $null = (New-NetFirewallRule @paramNewNetFirewallRule)
               }

               # Cleanup
               $NetFirewallRuleName = $null
            }
         }

         # Cleanup
         $FullTeamsPath = $null
      }
   }
}

#region LICENSE
<#
   BSD 3-Clause License

   Copyright (c) 2020, Beyond Datacenter
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
