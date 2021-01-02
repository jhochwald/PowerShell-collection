function Get-enADGPOReplication
{
   <#
         .SYNOPSIS
         Retrieve one or all the GPO and report their DSVersions and SysVolVersions

         .DESCRIPTION
         Retrieve one or all the GPO and report their DSVersions and SysVolVersions (Users and Computers)

         .PARAMETER GPOName
         Specify the name of the GPO

         .PARAMETER All
         Specify that you want to retrieve all the GPO (slow if you have a lot of Domain Controllers)

         .EXAMPLE
         Get-enADGPOReplication -GPOName "Default Domain Policy"

         Retrieve one GPO and report their DSVersions and SysVolVersions (Users and Computers)

         .EXAMPLE
         Get-enADGPOReplication -All

         Retrieve all the GPO and report their DSVersions and SysVolVersions (Users and Computers)

         .NOTES
         Releasenotes:
         1.0.1 2019-07-26 Refactored, License change to BSD 3-Clause
         1.0.0 2019-01-01 Initial Version

         THIS CODE IS MADE AVAILABLE AS IS, WITHOUT WARRANTY OF ANY KIND. THE ENTIRE RISK OF THE USE OR THE RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.

         Dependencies:
         Active Directory PowerShell Module

         .LINK
         https://www.enatec.io

         .LINK
         Get-ADDomainController

         .LINK
         Get-GPO
   #>

   [CmdletBinding(DefaultParameterSetName = 'All',
      ConfirmImpact = 'None')]
   param
   (
      [Parameter(ParameterSetName = 'One', HelpMessage = 'Specify the name of the GPO',
         Mandatory,
         ValueFromPipeline,
         ValueFromPipelineByPropertyName)]
      [ValidateNotNullOrEmpty()]
      [Alias('GPO')]
      [String[]]
      $GPOName,
      [Parameter(ParameterSetName = 'All',
         ValueFromPipeline,
         ValueFromPipelineByPropertyName)]
      [Switch]
      $All
   )

   process
   {
      foreach ($DomainController in ((Get-ADDomainController -ErrorAction Stop -ErrorVariable ErrorProcessGetDC -Filter *).hostname))
      {
         try
         {
            if ($psBoundParameters['GPOName'])
            {
               foreach ($GPOItem in $GPOName)
               {
                  $GPO = (Get-GPO -Name $GPOItem -Server $DomainController -ErrorAction Stop -ErrorVariable ErrorProcessGetGPO)

                  [pscustomobject][ordered] @{
                     GroupPolicyName       = $GPOItem
                     DomainController      = $DomainController
                     UserVersion           = $GPO.User.DSVersion
                     UserSysVolVersion     = $GPO.User.SysvolVersion
                     ComputerVersion       = $GPO.Computer.DSVersion
                     ComputerSysVolVersion = $GPO.Computer.SysvolVersion
                  }
               }
            }

            if ($psBoundParameters['All'])
            {
               $GPOList = (Get-GPO -All -Server $DomainController -ErrorAction Stop -ErrorVariable ErrorProcessGetGPOAll)

               foreach ($GPO in $GPOList)
               {
                  [pscustomobject][ordered] @{
                     GroupPolicyName       = $GPO.DisplayName
                     DomainController      = $DomainController
                     UserVersion           = $GPO.User.DSVersion
                     UserSysVolVersion     = $GPO.User.SysvolVersion
                     ComputerVersion       = $GPO.Computer.DSVersion
                     ComputerSysVolVersion = $GPO.Computer.SysvolVersion
                  }
               }
            }
         }
         catch
         {
            Write-Warning -Message '[PROCESS] Something wrong happened'

            if ($ErrorProcessGetDC)
            {
               Write-Warning -Message '[PROCESS] Error while running retrieving Domain Controllers with Get-ADDomainController'
            }

            if ($ErrorProcessGetGPO)
            {
               Write-Warning -Message '[PROCESS] Error while running Get-GPO'
            }

            if ($ErrorProcessGetGPOAll)
            {
               Write-Warning -Message '[PROCESS] Error while running Get-GPO -All'
            }

            Write-Warning -Message "[PROCESS] $($Error[0].exception.message)"
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
