function Get-LocalGroupMembership
{
   <#
         .SYNOPSIS
         Get all local Groups a given User is a Member of

         .DESCRIPTION
         The the the membership of all local Groups for a given User.
         The Given User could be a local User (COMPUTER\USER) or a Domain User (DOMAIN\USER).

         .PARAMETER UserName
         Given User could be a local User (COMPUTER\USER) or a Domain User (DOMAIN\USER).
         Default is the user that executes the function.

         .EXAMPLE
         PS C:\> Get-LocalGroupMembership

         Dump the Group Membership for the User that executes the function

         .EXAMPLE
         PS C:\> Get-LocalGroupMembership -UserName 'CONTOSO\John.Doe'

         Dump the Group Membership for the User John.Doe in the Domain CONTOSO

         .EXAMPLE
         PS C:\> Get-LocalGroupMembership -UserName "$env:COMPUTERNAME\John.Doe"

         Dump the Group Membership for the User John.Doe on the local computer

         .EXAMPLE
         PS C:\> Get-LocalGroupMembership -UserName 'CONTOSO\John.Doe' | Foreach-Object { Add-LocalGroupMember -Group $_ -Member "$env:COMPUTERNAME\John.Doe" -ErrorAction SilentlyContinue }

         Clone the Group Membership from User John.Doe in the Domain CONTOSO to User John.Doe on the local computer

         .NOTES
         This is just a quick and dirty solution for a problem I faced. (See last example)
   #>

   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([psobject])]
   param
   (
      [Parameter(ValueFromPipeline,
         ValueFromPipelineByPropertyName)]
      [ValidateNotNullOrEmpty()]
      [Alias('User')]
      [string]
      $UserName = ("$env:USERDOMAIN" + '\' + "$env:USERNAME")
   )

   begin
   {
      # Create a new Object
      $LocalGroupMembership = @()
   }

   process
   {
      $AllGroups = (Get-LocalGroup -Name *)

      foreach ($LocalGroup in $AllGroups)
      {
         if (Get-LocalGroupMember -Group $LocalGroup.Name -ErrorAction SilentlyContinue | Where-Object -FilterScript {
               $PSItem.name -eq $UserName
            })
         {
            $LocalGroupMembership += $LocalGroup.Name
         }
      }
   }
   end
   {
      # Dump the object to the console
      $LocalGroupMembership
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
