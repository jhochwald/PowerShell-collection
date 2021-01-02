function Resolve-DNSHost
{
   <#
      .SYNOPSIS
      Resolve DNS hostname to IP and reverse

      .DESCRIPTION
      This function resolves DNS hostname to IP and  the other way around (reverse)

      .PARAMETER HostEntry
      Hostname (Single, or multiple) to test.

      .EXAMPLE
      PS C:\> Resolve-DNSHost -HostEntry www.hochwald.net

      HostName         IPAddress
      --------         ---------
      www.hochwald.net {104.28.0.64, 104.28.1.64, 2606:4700:30::681c:140, 2606:4700:30::681c:40}

      This function resolves DNS hostname to IP and  the other way around (reverse)

      .EXAMPLE
      PS C:\> Resolve-DNSHost -HostEntry 'www.hochwald.net','autodiscover.hochwald.net'

      HostName                  IPAddress
      --------                  ---------
      www.hochwald.net          {104.28.0.64, 104.28.1.64, 2606:4700:30::681c:140, 2606:4700:30::681c:40}
      autodiscover.hochwald.net {40.101.88.8, 40.101.88.184, 52.97.151.104, 40.101.60.24...}

      This function resolves DNS hostname to IP and  the other way around (reverse)

      .OUTPUTS
      psobject

      .NOTES
      Refactored of Resolve-Host.Ps1 by @PrateekKumarSingh

      .LINK
      Original:
      https://gist.github.com/PrateekKumarSingh/586f2d3d43f7e8cb07ce

      .LINK
      Dns Class (system.net.dns):
      https://docs.microsoft.com/de-de/dotnet/api/system.net.dns

      .INPUTS
      String
   #>
   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([psobject])]
   param
   (
      [Parameter(Mandatory,
         ValueFromPipeline,
         ValueFromPipelineByPropertyName,
         Position = 0,
         HelpMessage = 'Hostname (Single, or multiple) to test.')]
      [ValidateNotNullOrEmpty()]
      [String[]]
      $HostEntry
   )

   begin
   {
      # Cleanup
      $Obj = @()
      $Object = @()
   }

   process
   {
      $HostEntry | ForEach-Object -Process {
         $Obj += New-Object -TypeName psobject -Property @{
            HostName  = $_
            IPAddress = $([Net.Dns]::gethostentry($_).AddressList.IPAddressToString)
         }
      }

      # Append
      $Object = ($Obj | Select-Object -Property Hostname, IPAddress)
   }

   end
   {
      # Dump to the console
      $Object
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
   - If you disagree with any of the terms, and any conditions declared: Just delete it and build your own solution
#>
#endregion DISCLAIMER
