#requires -Version 1.0

function Get-DsRegStatusInfo
{
   <#
      .SYNOPSIS
         Wrapper function for the dsregcmd command

      .DESCRIPTION
         Wrapper function for the dsregcmd command
         Nothing fancy, but it should convert the plain text output of dsregcmd to a PSObject

      .EXAMPLE
         PS C:\> Get-DsRegStatusInfo

         Returns a PSObject with the values of dsregcmd

      .EXAMPLE
         PS C:\> $AADInfo = (Get-DsRegStatusInfo | Select-Object -Property AzureAdJoined,WorkplaceJoined)
         PS C:\> if ( ($AADInfo.AzureAdJoined -ne 'YES') -and ($AADInfo.WorkplaceJoined -ne 'YES') ) {throw 'Not AzureAD bound'}

         Check if the system is joined to the AzureAD (fully or just WorkplaceJoined)

      .EXAMPLE
         PS C:\> $AADInfo = (Get-DsRegStatusInfo | Select-Object -Property AzureAdJoined, WorkplaceJoined)
         PS C:\> if ($AADInfo.AzureAdJoined -eq 'YES') {'AzureAd Joined'} elseif ($AADInfo.WorkplaceJoined -eq 'YES') {'Workplace Joined'} else {'Unknown'}

         Check if the system is joined to the AzureAD (fully or just WorkplaceJoined)

      .NOTES
         Replaced my old ConvertFrom-String based wrapper implementation, this is more flexible

      .LINK
         http://hochwald.net
   #>
   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([psobject])]
   param ()

   begin
   {
      $DsRegCmdPlain = (& "$env:windir\system32\dsregcmd.exe" /status)
      $DsRegStatusInfo = (New-Object -TypeName PSObject)
   }

   process
   {
      $DsRegCmdPlain | Select-String -Pattern ' *[A-z]+ : [A-z]+ *' | ForEach-Object -Process {
         $null = (Add-Member -InputObject $DsRegStatusInfo -MemberType NoteProperty -Name (([String]$_).Trim() -split ' : ')[0] -Value (([String]$_).Trim() -split ' : ')[1] -ErrorAction SilentlyContinue)
      }
   }

   end
   {
      $DsRegStatusInfo
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
