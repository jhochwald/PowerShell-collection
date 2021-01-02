#requires -Version 3.0 -Modules ActiveDirectory

function Set-ADServerUsage
{
   <#
      .SYNOPSIS
      Set all Active Directory related commands to use a special kind of server

      .DESCRIPTION
      By default the Active Directory related commands search for a DC. By default I want to make
      use of the closest one. When I make BULK operations, I would like to use the Server with
      the PDC role. This becomes handy often!

      .PARAMETER pdc
      Use the Active Directory Server who holds the PDC role.

      .EXAMPLE
      # Use the closest Server
      PS> Set-ADServerUsage

      .EXAMPLE
      # Use the Server with the PDC role
      PS> Set-ADServerUsage -pdc

      .EXAMPLE
      # When it comes to scripts that do bulk operations, especially bulk loads and manipulation,
      # I use the following within the Script:
      if (Get-Command Set-ADServerUsage -ErrorAction SilentlyContinue)
      {
      Set-ADServerUsage -pdc
      }

      .NOTES
      I use this helper function in my PROFILE. Therefore, some things a bit special.
      Who want's an error message every time a window opens under normal circumstances?
   #>
   param
   (
      [Parameter(ValueFromPipeline,
         ValueFromPipelineByPropertyName,
         Position = 1)]
      [switch]
      $pdc
   )

   begin
   {
      # Defaults
      $SC = 'SilentlyContinue'

      # Cleanup
      $dc = $null
   }

   process
   {
      <#
         The following would do the trick:
         #requires -Modules ActiveDirectory
         But I don't want any error messages, so I decided to use this old-school way to figure
         out if we are capable do what I want.
      #>
      if ((Get-Command -Name Get-ADDomain -ErrorAction $SC) -and (Get-Command -Name Get-ADDomainController -ErrorAction $SC) )
      {
         if ($pdc)
         {
            # Use the PDC instead
            $dc = ((Get-ADDomain -ErrorAction $SC -WarningAction $SC).PDCEmulator)
         }
         else
         {
            # Use the closest DC
            $dc = (Get-ADDomainController -Discover -NextClosestSite -ErrorAction $SC -WarningAction $SC)
         }

         # Skip everything if we do NOT have the proper information.
         <#
            Under normal circumstances this is pretty useless, but I use some virtual machines that have the RSAT tools installed, but they are not domain joined.
            The fore I make this check. If all the systems that have the RSAT installed are domain joined, this test is obsolete.
         #>
         if ($dc)
         {
            # Make use of the Server from above
            $PSDefaultParameterValues.add('*-AD*:Server', "$dc")
         }
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
