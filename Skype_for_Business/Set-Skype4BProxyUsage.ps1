#requires -Version 1.0

<#
   .SYNOPSIS
   Skype for Business should use Proxy Server

   .DESCRIPTION
   Skype for Business should use Proxy Server to sign in instead of trying a direct connection.
   Works with Skype for Business 2015 and 2016 and should work with Lync 1013 as well.

   .EXAMPLE
   PS C:\> .\Set-Skype4BProxyUsage.ps1

   .NOTES
   Please note: This is a per user setting!

   SIP is not used between Clients (aka P2P or Cleint to Client).
   It wil be used between Client and Server and/or Server and Server.
   Media Bypass will be used for RTP media between Clients (when possible)

   .LINK
   https://support.microsoft.com/en-us/help/3207112/skype-for-business-should-use-proxy-server-to-sign-in-instead-of-tryin

   .LINK
   https://blogs.technet.microsoft.com/uclobby/2016/12/08/enabling-lyncsfb-client-to-use-proxy-server-for-sip-traffic-instead-of-trying-direct-connection/
#>
[CmdletBinding()]
param ()

$parameters = @{
   Path          = 'HKCU:\Software\Microsoft\UCCPlatform\Lync'
   Name          = 'EnableDetectProxyForAllConnections'
   PropertyType  = 'DWORD'
   Value         = '1'
   Force         = $true
   ErrorAction   = 'Stop'
   WarningAction = 'SilentlyContinue'
}

try
{
   $null = (New-ItemProperty @parameters)
   Write-Verbose -Message 'New value set.'
}
catch
{
   try
   {
      $null = (Set-ItemProperty @parameters)
      Write-Verbose -Message 'Existing value modified.'
   }
   catch
   {
      Write-Warning -Message 'Unable to create/set the value.'
   }
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
