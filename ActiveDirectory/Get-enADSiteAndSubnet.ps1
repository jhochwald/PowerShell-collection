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
         Version: 1.0.1

         GUID: a0a633ca-6fd1-4806-a160-05bf1f76342b

         Author: Joerg Hochwald

         Companyname: enabling Technology

         Copyright: Copyright (c) 2ß18-2019, enabling Technology - All rights reserved.

         License: https://opensource.org/licenses/BSD-3-Clause

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
               $SubnetAdditionalInfo = $SubnetsContainerchildren.Where({
                     $_.name -match $i
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
