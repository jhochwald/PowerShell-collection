#requires -Version 3.0 -RunAsAdministrator

<#
.SYNOPSIS
Enable inbound ICMP (Ping) and Remote Desktop (RDP)

.DESCRIPTION
Enable inbound ICMP (Ping) and Remote Desktop (RDP).
Ping will be enabled for IPv4 and IPv6.

.PARAMETER RDPGroup
Enable the complete RDP Groups in the Windows Firewall?
This will enable more then just the basic requirements, use with care!!!

.EXAMPLE
PS C:\> .\Set-AllowPingAndRemoteDesktop.ps1

Enable inbound ICMP (Ping) and Remote Desktop (RDP)

.EXAMPLE
PS C:\> .\Set-AllowPingAndRemoteDesktop.ps1 -verbose

Enable inbound ICMP (Ping) and Remote Desktop (RDP) - verbose run

.EXAMPLE
PS C:\> .\Set-AllowPingAndRemoteDesktop.ps1 -WhatIf

Enable inbound ICMP (Ping) and Remote Desktop (RDP) - Dry run

.NOTES
Helper script I use to bootstrap servers
Run this elevated!!!

Version 1.0.4

.LINK
http://enatec.io
#>
[CmdletBinding(ConfirmImpact = 'Medium',
   SupportsShouldProcess)]
param
(
   [Parameter(ValueFromPipeline)]
   [switch]
   $RDPGroup
)

begin
{
   Write-Output -InputObject 'Enable inbound ICMP (Ping) and Remote Desktop (RDP)'

   $SCT = 'SilentlyContinue'
   $CNT = 'Continue'

   if (Get-Command -Name 'Set-MpPreference' -ErrorAction $SCT)
   {
      $null = (Set-MpPreference -EnableControlledFolderAccess Disabled -Force -ErrorAction $SCT)
   }

   # Splat the Set-ItemProperty parameters
   $paramSetItemProperty = @{
      Path        = 'HKLM:\System\CurrentControlSet\Control\Terminal Server'
      Name        = 'fDenyTSConnections'
      Value       = 0
      ErrorAction = $CNT
   }

   # Splat the Enable-NetFirewallRule parameters
   $paramEnableNetFirewallRule = @{
      Confirm     = $false
      ErrorAction = $CNT
   }
}

process
{
   # Support WhatIf (SupportsShouldProcess)
   if ($pscmdlet.ShouldProcess('Registry Terminal Server', 'Modify'))
   {
      # Tweak the Registry for Remote Desktop connections
      $null = (Set-ItemProperty @paramSetItemProperty)
   }

   # We avoid using $RDPGroup.IsPresent
   if ($PSBoundParameters.ContainsKey('RDPGroup'))
   {
      if ($pscmdlet.ShouldProcess('Firewall Group for Remote Desktop', 'Enable'))
      {
         # Allow Remote Desktop (The Group)
         $paramGetNetFirewallRule = @{
            DisplayGroup = 'Remote Desktop'
            ErrorAction  = $SCT
         }
         $null = (Get-NetFirewallRule @paramGetNetFirewallRule | Where-Object {
               $_.Enabled -ne $true
            } | Enable-NetFirewallRule @paramEnableNetFirewallRule)
      }
   }
   else
   {
      if ($pscmdlet.ShouldProcess('Firewall Rules for Remote Desktop', 'Enable'))
      {
         # Alternative Approach: Enable the minimum, not the Group
         $paramGetNetFirewallRule = @{
            Name        = 'RemoteDesktop-UserMode-In-TCP'
            ErrorAction = $SCT
         }
         $null = (Get-NetFirewallRule @paramGetNetFirewallRule | Where-Object {
               $_.Enabled -ne $true
            } | Enable-NetFirewallRule @paramEnableNetFirewallRule)

         $paramGetNetFirewallRule = @{
            DisplayName = 'Remote Desktop - User Mode (TCP-In)'
            ErrorAction = $SCT
         }
         $null = (Get-NetFirewallRule @paramGetNetFirewallRule | Where-Object {
               $_.Enabled -ne $true
            } | Enable-NetFirewallRule @paramEnableNetFirewallRule)
      }
   }

   if ($pscmdlet.ShouldProcess('Ping', 'Enable'))
   {
      # Allow Ping for IPv4 and IPv6
      # NOTE: The wildcard (ICMPv?) will select both. Replace it with 4 or 6 to use just one of them
      $paramGetNetFirewallRule = @{
         DisplayName = 'File and Printer Sharing (Echo Request - ICMPv?-In)'
         ErrorAction = $SCT
      }
      $null = (Get-NetFirewallRule @paramGetNetFirewallRule | Where-Object {
            $_.Enabled -ne $true
         } | Enable-NetFirewallRule @paramEnableNetFirewallRule)
   }
}

end
{
   if (Get-Command -Name 'Set-MpPreference' -ErrorAction $SCT)
   {
      $null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction $SCT)
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
