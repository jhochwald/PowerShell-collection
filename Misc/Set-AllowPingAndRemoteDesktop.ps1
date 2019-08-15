#requires -Version 3.0 -Modules NetSecurity -RunAsAdministrator

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
   # Splat the Set-ItemProperty parameters
   $paramSetItemProperty = @{
      Path        = 'HKLM:\System\CurrentControlSet\Control\Terminal Server'
      Name        = 'fDenyTSConnections'
      Value       = 0
      ErrorAction = 'Continue'
   }

   # Splat the Enable-NetFirewallRule parameters
   $paramEnableNetFirewallRule = @{
      Confirm     = $false
      ErrorAction = 'Continue'
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
         $null = (Get-NetFirewallRule -DisplayGroup 'Remote Desktop' -ErrorAction SilentlyContinue | Where-Object {
               $_.Enabled -ne $true
         } | Enable-NetFirewallRule @paramEnableNetFirewallRule)
      }
   }
   else
   {
      if ($pscmdlet.ShouldProcess('Firewall Rules for Remote Desktop', 'Enable'))
      {
         # Alternative Approach: Enable the minimum, not the Group
         Get-NetFirewallRule -Name 'RemoteDesktop-UserMode-In-TCP' -ErrorAction SilentlyContinue | Where-Object {
            $_.Enabled -ne $true
         } | Enable-NetFirewallRule @paramEnableNetFirewallRule

         Get-NetFirewallRule -DisplayName 'Remote Desktop - User Mode (TCP-In)' -ErrorAction SilentlyContinue | Where-Object {
            $_.Enabled -ne $true
         } | Enable-NetFirewallRule @paramEnableNetFirewallRule
      }
   }

   if ($pscmdlet.ShouldProcess('Ping', 'Enable'))
   {
      # Allow Ping for IPv4 and IPv6
      # NOTE: The wildcard (ICMPv?) will select both. Replace it with 4 or 6 to use just one of them
      Get-NetFirewallRule -DisplayName 'File and Printer Sharing (Echo Request - ICMPv?-In)' -ErrorAction SilentlyContinue | Where-Object {
         $_.Enabled -ne $true
      } | Enable-NetFirewallRule @paramEnableNetFirewallRule
   }
}