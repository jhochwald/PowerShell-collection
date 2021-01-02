#requires -Version 3.0 -RunAsAdministrator

<#
   .SYNOPSIS
   Enable DNS-over-HTTPS (DoH) if device is not domain-joined

   .DESCRIPTION
   Enable DNS-over-HTTPS (DoH) if device is not domain-joined

   It enables the Cloudflare DNS Servers, even if DoH is not working yet.

   IPv6 Support is optional.

   .PARAMETER IPv6
   Enable IPv6 Support, IPv6 Servers will be added to the server list

   .EXAMPLE
   PS C:\> .\Enable-DNSOverHTTPS.ps1

   Enable DNS-over-HTTPS (DoH) if device is not domain-joined for IPv4 only

   .EXAMPLE
   PS C:\> .\Enable-DNSOverHTTPS.ps1 -IPv6

   Enable DNS-over-HTTPS (DoH) if device is not domain-joined for IPv4 and IPv6

   .NOTES
   Only the Insider Build of Windows 10 supports DoH!
   But we configure it anyway!

   The Cloudflare servers are used for regular DNS resolution and as soon as DoH is supported,
   we can configure and use it anyway.

   A future version of this script might support additional parameters, like DohFlags

   You can also change the servers below to any service you like, e.g. Google DNS or Quad9 from IBM.

   The Bool as return was requested by a customer, and the exit code (0 or 1) is implemented for our bootstrap setup

   .LINK
   https://1.1.1.1/dns/

   .LINK
   https://techcommunity.microsoft.com/t5/networking-blog/windows-insiders-can-now-test-dns-over-https/ba-p/1381282
#>
[CmdletBinding(ConfirmImpact = 'None')]
[OutputType([bool])]
param
(
   [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
   [Alias('IP6', '6')]
   [switch]
   $IPv6
)

begin
{
   #region Defaults
   $SCT = 'SilentlyContinue'
   $STP = 'Stop'
   $CNT = 'Continue'

   # Save the infos from the switches
   if (($PSCmdlet.MyInvocation.BoundParameters['Verbose']).IsPresent)
   {
      $IsVerbose = $true
   }
   else
   {
      $IsVerbose = $false
   }

   if (($PSCmdlet.MyInvocation.BoundParameters['Debug']).IsPresent)
   {
      $IsDebug = $true
   }
   else
   {
      $IsDebug = $false
   }

   if (($PSCmdlet.MyInvocation.BoundParameters['WhatIf']).IsPresent)
   {
      $IsWhatIf = $true
   }
   else
   {
      $IsWhatIf = $false
   }
   #endregion Defaults

   #region ServerAddresses
   # Create an Empty Object
   $ServerAddresses = @()

   # IPv4 DNS Servers to use
   $ServerAddressesIPv4 = @(
      '1.1.1.1'
      '1.0.0.1'
   )

   # Add the IPv4 Servers to the Object
   $ServerAddresses += $ServerAddressesIPv4

   if ((($PSCmdlet.MyInvocation.BoundParameters['IPv6']).IsPresent) -eq $true)
   {
      Write-Verbose -Message 'IPv6 Servers will be added to the serverlist'
      # IPv6 DNS Servers to use
      $ServerAddressesIPv6 = @(
         '2606:4700:4700::1111'
         '2606:4700:4700::1001'
      )

      # Add the IPv6 Servers to the Object
      $ServerAddresses += $ServerAddressesIPv6
   }
   #endregion ServerAddresses
}

process
{
   #region DoH
   # Enable DNS-over-HTTPS for IPv4 if device is not domain-joined
   $paramGetCimInstance = @{
      ClassName   = 'CIM_ComputerSystem'
      Verbose     = $IsVerbose
      Debug       = $IsDebug
      ErrorAction = $STP
   }
   if (((Get-CimInstance @paramGetCimInstance).PartOfDomain) -eq $false)
   {
      try
      {
         # Temporarily key
         $paramNewItemProperty = @{
            Path         = 'HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters'
            Name         = 'EnableAutoDoh'
            Value        = 2
            PropertyType = 'DWord'
            Force        = $true
            WhatIf       = $IsWhatIf
            Verbose      = $IsVerbose
            Debug        = $IsDebug
            ErrorAction  = $CNT
         }
         $null = (New-ItemProperty @paramNewItemProperty)

         $paramGetNetAdapter = @{
            Verbose     = $IsVerbose
            Debug       = $IsDebug
            Physical    = $true
            ErrorAction = $SCT
         }
         $MACAddress = ((Get-NetAdapter @paramGetNetAdapter).MacAddress)

         $paramGetNetIPConfiguration = @{
            Verbose     = $IsVerbose
            Debug       = $IsDebug
            ErrorAction = $SCT
         }
         $IpConfig = (Get-NetIPConfiguration @paramGetNetIPConfiguration | Where-Object -FilterScript {
               $MACAddress -eq $_.NetAdapter.MacAddress
            })

         $paramSetDnsClientServerAddress = @{
            ServerAddresses = $ServerAddresses
            Verbose         = $IsVerbose
            Debug           = $IsDebug
            ErrorAction     = $CNT
         }
         $null = ($IpConfig | Set-DnsClientServerAddress @paramSetDnsClientServerAddress)

         $paramClearDnsClientCache = @{
            Verbose     = $IsVerbose
            Debug       = $IsDebug
            ErrorAction = $SCT
         }
         $null = (Clear-DnsClientCache @paramClearDnsClientCache)

         $paramRegisterDnsClient = @{
            Verbose     = $IsVerbose
            Debug       = $IsDebug
            ErrorAction = $SCT
         }
         $null = (Register-DnsClient @paramRegisterDnsClient)
      }
      catch
      {
         # Get error record
         [Management.Automation.ErrorRecord]$e = $_

         # retrieve information about runtime error
         $info = [PSCustomObject]@{
            Exception = $e.Exception.Message
            Reason    = $e.CategoryInfo.Reason
            Target    = $e.CategoryInfo.TargetName
            Script    = $e.InvocationInfo.ScriptName
            Line      = $e.InvocationInfo.ScriptLineNumber
            Column    = $e.InvocationInfo.OffsetInLine
         }

         # output information. Post-process collected info, and log info (optional)
         $info | Out-String | Write-Verbose

         $paramWriteError = @{
            Message      = $e.Exception.Message
            ErrorAction  = $CNT
            Exception    = $e.Exception
            TargetObject = $e.CategoryInfo.TargetName
         }
         Write-Error @paramWriteError
      }
   }
   else
   {
      $paramWriteError = @{
         Message      = 'Sorry, this computer seems to be part of a Active Directory domain!'
         Exception    = 'Active Directory Domain Members are not supported'
         Category     = 'NotEnabled'
         TargetObject = $env:COMPUTERNAME
         ErrorAction  = $CNT
      }
      Write-Error @paramWriteError

      # Return the Bool
      Write-Output -InputObject $false

      # Unclean exit
      exit 1
   }
   #endregion DoH
}

end
{
   # Return the Bool
   Write-Output -InputObject $true

   # Clean exit
   exit 0
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
