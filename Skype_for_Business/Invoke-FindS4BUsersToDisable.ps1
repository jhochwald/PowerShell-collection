#requires -Version 1.0

<#
   .SYNOPSIS
   Find AD disabled Skype for Business Users

   .DESCRIPTION
   Find accounts that are disabled in the Active Directory but are still Skype for Business enabled

   .PARAMETER disable
   Should all users that are disbled in the Active Directory also be disabled in Skype for Business

   .EXAMPLE
   PS C:\> Invoke-FindS4BUsersToDisable

   # Find AD disabled Skype for Business Users

   .EXAMPLE
   PS C:\> Invoke-FindS4BUsersToDisable -disable

   # Find and disable AD disabled Skype for Business Users

   .NOTES
   Be carfull with the -disable switch
   It might disable monitoring users and/or Skype enabled resource accounts
#>
param
(
   [Parameter(Position = 1)]
   [Alias('d')]
   [switch]
   $disable
)

begin
{
   # Define the defaults
   $SC = 'SilentlyContinue'

   # Cleanup
   $S4BUsersToDisable = $null
}

process
{
   # Splat
   $paramGetCsAdUser = @{
      ResultSize    = 'Unlimited'
      ErrorAction   = $SC
      WarningAction = $SC
   }
   $S4BUsersToDisable = (Get-CsAdUser @paramGetCsAdUser | Where-Object -FilterScript {
         $_.UserAccountControl -match 'AccountDisabled' -and $_.Enabled -eq $true
      } | Select-Object -Property Name, Enabled, SipAddress)
}

end
{
   if ($disable)
   {
      # Disable all user found
      foreach ($S4BUserToDisable in $S4BUsersToDisable)
      {
         Write-Verbose -Message ('We try to disable {0} now' -f $S4BUserToDisable.SipAddress)
         try
         {
            # Splat
            $paramDisableCsUser = @{
               ErrorAction   = 'Stop'
               WarningAction = $SC
            }
            $null = ($S4BUserToDisable.SipAddress | Disable-CsUser @paramDisableCsUser)

            Write-Verbose -Message ('The user {0} is now disabled' -f $S4BUserToDisable.SipAddress)
         }
         catch
         {
            Write-Warning -Message ('We where unable to disable {0}' -f $S4BUserToDisable.SipAddress)
         }
      }
   }
   else
   {
      # Dump all Users
      $S4BUsersToDisable
   }

   # Cleanup
   $S4BUsersToDisable = $null
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
