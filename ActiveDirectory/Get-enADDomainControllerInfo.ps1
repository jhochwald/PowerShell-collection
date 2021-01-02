Function Get-enDomainControllerInfo
{
   <#
         .SYNOPSIS
         Get a list of domain controllers

         .DESCRIPTION
         Will provide a list of domain controllers in your current domain.
         Optionally you can also request a discovery of the "closest" one.

         .PARAMETER ComputerName
         Retrieve information about the specified domain controller.
         This is a RegEx match so you can match multiple domain controllers with your pattern.

         .PARAMETER Discover
         Use Discover to return the information of the closest domain controller.

         .EXAMPLE
         Get-enDomainControllerInfo

         Retrieve a list of all domain controllers in your domain.

         .EXAMPLE
         Get-enDomainControllerInfo -Computer 01

         Retrieve a list of all domain controllers with "01" in their name.

         .EXAMPLE
         Get-enDomainControllerInfo -Discover

         Retrieve the name of the closest domain controller.

         .NOTES
   #>
   [CmdletBinding(DefaultParameterSetName = 'all')]
   Param (
      [Parameter(Position = 0, ParameterSetName = 'dc')]
      [string]$ComputerName,
      [Parameter(ParameterSetName = 'all')]
      [switch]$Discover
   )

   begin
   {
      $DirectoryContext = [DirectoryServices.ActiveDirectory.DirectoryContext]::New('Domain')
      $SelectProperties = 'Name', 'Forest', 'Domain', 'SiteName', 'Roles', 'CurrentTime', 'HighestCommittedUsn', 'OSVersion'
   }

   process
   {
      If ($Discover)
      {
         $LocatorFlag = [DirectoryServices.ActiveDirectory.LocatorOptions]::ForceRediscovery
         $Info = ([DirectoryServices.ActiveDirectory.DomainController]::FindOne($DirectoryContext, $LocatorFlag) | Select-Object -Property $SelectProperties)
      }
      elseif ($ComputerName)
      {
         $Info = ([DirectoryServices.ActiveDirectory.DomainController]::FindAll($DirectoryContext) | Where-Object -Property Name -Match -Value $ComputerName | Select-Object -Property $SelectProperties)
      }
      else
      {
         $Info = ([DirectoryServices.ActiveDirectory.DomainController]::FindAll($DirectoryContext) | Select-Object -Property $SelectProperties)
      }
   }

   end
   {
      $Info
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
