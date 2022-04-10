function Get-LocalIpAddresses
{
   <#
         .SYNOPSIS
         Print a string with all IP addresses

         .DESCRIPTION
         Print a string with all IP addresses. Supports IPv4 and IPv6.
         It filters IPv6 Link Local only addresses by default.

         .PARAMETER TargetName
         Specifies the computers to test. Type the computer names or type IP addresses in IPv4 or IPv6 format. Wildcard characters are not permitted. The default is localhost.

         .PARAMETER IPv6LinkLocal
         Retuns IPv6 Link Local only addresses? Off by default.

         .EXAMPLE
         PS C:\> Get-LocalIpAddresses
         Print a string with all local IP addresses

         .EXAMPLE
         PS C:\> Get-LocalIpAddresses -TargetName 'mycomputer'
         Print a string with all IP addresses for the computer 'mycomputer'

         .NOTES
         TODO: Remove the -TargetName in the next release! Makes no sense (only IPv4 is returned)
   #>
   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([string])]
   param
   (
      [Parameter(ValueFromPipeline,
         ValueFromPipelineByPropertyName,
         Position = 1)]
      [ValidateNotNullOrEmpty()]
      [string]
      $TargetName = $env:COMPUTERNAME,
      [Parameter(ValueFromPipeline,
         ValueFromPipelineByPropertyName,
         Position = 2)]
      [Alias('IsIPv6LinkLocal')]
      [switch]
      $IPv6LinkLocal
   )

   begin
   {
      $IpInfo = $null
   }

   process
   {
      $IpInfo = ($TargetName | ForEach-Object -Process {
            (([Net.DNS]::GetHostAddresses([Net.Dns]::GetHostByName($_).HostName) | Where-Object -FilterScript {
                  $PSItem.IsIPv6LinkLocal -eq $IPv6LinkLocal
               }).IPAddressToString)
         })
   }

   end
   {
      # Dump to the Console
      $IpInfo
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
