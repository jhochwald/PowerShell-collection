function Test-IsAdmin
{
   <#
         .SYNOPSIS
         Check if PowerShell run elevated (e.g. as admin or not)

         .DESCRIPTION
         This is a complete new approach to check if the Shell runs elevated or not.
         It runs on PowerShell and PowerShell Core, and it supports macOS or Linux as well.

         .EXAMPLE
         PS C:\> Test-IsAdmin

         .NOTES
         Rewritten function to support PowerShell Desktop and Core on Windows, macOS, and Linux
         Mostly used within other functions and in the personal PowerShell profiles.

         Releasenotes:
         1.0.1 2019-05-09: Add some comments to the code
         1.0.0 2019-05-09: Initial Release of the rewritten function

         THIS CODE IS MADE AVAILABLE AS IS, WITHOUT WARRANTY OF ANY KIND. THE ENTIRE RISK OF THE USE OR THE RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.
   #>
   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([bool])]
   param ()

   process
   {
      if ($PSVersionTable.PSEdition -eq 'Desktop')
      {
         # Fastest way on Windows
         ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')
      }
      elseif (($PSVersionTable.PSEdition -eq 'Core') -and ($PSVersionTable.Platform -eq 'Unix'))
      {
         # Ok, on macOS and Linux we use ID to figure out if we run elevated (0 means superuser rights)
         if ((id -u) -eq 0)
         {
            return $true
         }
         else
         {
            return $false
         }
      }
      elseif (($PSVersionTable.PSEdition -eq 'Core') -and ($PSVersionTable.Platform -eq 'Win32NT'))
      {
         # For PowerShell Core on Windows the same approach as with the Desktop work just fine
         # This is for future improvements :-)
         ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')
      }
      else
      {
         # Unable to figure it out!
         Write-Warning -Message 'Unknown'

         return
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
   - If you disagree with any of the terms, and any conditions declared: Just delete it and build your own solution
#>
#endregion DISCLAIMER
