function Get-enADSiteAndSubnetInfo
{
   <#
         .SYNOPSIS
         Retrieve Site names, subnets names and descriptions.

         .DESCRIPTION
         Retrieve Site names, subnets names and descriptions from the Active Directory

         .EXAMPLE
         PS ~> Get-enADSiteAndSubnetInfo

         Retrieve Site names, subnets names and descriptions from the Active Directory

         .EXAMPLE
         PS ~> Get-enADSiteAndSubnetInfo | Export-Csv -Path C:\scripts\PowerShell\Reports\ADSiteInventory.csv

         Retrieve Site names, subnets names and descriptions from the Active Directory

         .OUTPUTS
         PSObject

         .NOTES
          Releasenotes:
         1.0.1 2019-07-26 Refactored, License change to BSD 3-Clause
         1.0.0 2019-01-01 Initial Version

         THIS CODE IS MADE AVAILABLE AS IS, WITHOUT WARRANTY OF ANY KIND. THE ENTIRE RISK OF THE USE OR THE RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.

         Dependencies:
         Active Directory PowerShell Module

         .LINK
         https://www.enatec.io
   #>
   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([psobject])]
   param ()

   begin
   {
      Write-Verbose -Message '[BEGIN] Starting Script...'
   }

   process
   {
      try
      {
         # Domain and Sites Information
         $Forest = ([DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest())
         $SiteInfo = ([DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().Sites)

         # Forest Context
         $ForestType = ([DirectoryServices.ActiveDirectory.DirectoryContexttype]'forest')
         $ForestContext = (New-Object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList $ForestType, $Forest)

         # Distinguished Name of the Configuration Partition
         $Configuration = ([ADSI]'LDAP://RootDSE').configurationNamingContext

         # Get the Subnet Container
         $SubnetsContainer = ([ADSI]('LDAP://CN=Subnets,CN=Sites,{0}' -f $Configuration))
         $SubnetsContainerchildren = ($SubnetsContainer.Children)

         foreach ($item in $SiteInfo)
         {
            Write-Verbose -Message ('[PROCESS] SITE: {0}' -f $item.name)

            $output = @{
               Name = $item.name
            }

            foreach ($i in $item.Subnets.name)
            {
               Write-Verbose -Message ('[PROCESS] SUBNET: {0}' -f $i)

               $output.Subnet = $i
               $SubnetAdditionalInfo = $SubnetsContainerchildren.Where( {
                     $PSItem.name -match $i
                  })

               Write-Verbose -Message ('[PROCESS] SUBNET: {0} - DESCRIPTION: {1}' -f $i, $SubnetAdditionalInfo.Description)

               $output.Description = $($SubnetAdditionalInfo.Description)

               Write-Verbose -Message '[PROCESS] OUTPUT INFO'

               New-Object -TypeName PSObject -Property $output
            }
         }
      }
      catch
      {
         Write-Warning -Message '[PROCESS] Something Wrong Happened'
         Write-Warning -Message $Error[0]
      }
   }

   end
   {
      Write-Verbose -Message '[END] Script Completed!'
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
