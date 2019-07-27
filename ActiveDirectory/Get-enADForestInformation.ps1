function Get-enADForestInformation
{
   <#
         .SYNOPSIS
         Retrieve information about an Active Directory Forest

         .DESCRIPTION
         Retrieve information about an Active Directory Forest

         .PARAMETER ForestName
         Forest name to retrieve information about

         .PARAMETER Credential
         Credential to use for retrieval

         .EXAMPLE
         PS ~> Get-enADForestInformation

         Retrieve information about the current Active Directory Forest

         .EXAMPLE
         PS ~> Get-enADForestInformation | Select-Object ApplicationPartitions

         Retrieve information about Application Partitions from the current Active Directory Forest

         .EXAMPLE
         PS ~> Get-enADForestInformation | Select-Object GlobalCatalogs

         Retrieve als Global Catalog Servers from the current Active Directory Forest

         .EXAMPLE
         PS ~> (Get-enADForestInformation) | Select-Object -ExpandProperty GlobalCatalogs

         Retrieve als Global Catalog Servers from the current Active Directory Forest. More detaild then the above example, cause it will show all the details for each Global Catalog Servers.

         .EXAMPLE
         PS ~> Get-enADForestInformation | Select-Object NamingRoleOwner

         Retrieve information about the Naming master Roles holder from the current Active Directory Forest

         .EXAMPLE
         PS ~> (Get-enADForestInformation).Sites

         Retrieve information about Active Directory Sites from the current Active Directory Forest

         .EXAMPLE
         PS ~> Get-enADForestInformation -Credential (Get-Credential)

         Retrieve information about the current Active Directory Forest, with special credentials (e.g. RunAs)

         .EXAMPLE
         PS ~> Get-enADForestInformation -ForestName Value

         Retrieve information about Active Directory Forest specified in Value

         .EXAMPLE
         PS ~> Get-enADForestInformation -ForestName Value -Credential Value

         Retrieve information about Active Directory Forest specified in Value, with special credentials (e.g. RunAs)

         .OUTPUTS
         psobject

         .INPUTS
         String
         pscredential

         .NOTES
         Version: 1.0.1

         GUID: fbbedbec-834a-4f91-bb52-e5fd94770534

         Author: Joerg Hochwald

         Companyname: enabling Technology

         Copyright: Copyright (c) 2ß18-2019, enabling Technology - All rights reserved.

         License: https://opensource.org/licenses/BSD-3-Clause

         Releasenotes:
         1.0.1 2019-07-26 Refactored, License change to BSD 3-Clause
         1.0.0 2019-01-01 Initial Version

         THIS CODE IS MADE AVAILABLE AS IS, WITHOUT WARRANTY OF ANY KIND. THE ENTIRE RISK OF THE USE OR THE RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.

         .LINK
         https://www.enatec.io

         .LINK
         Get-ADForest
   #>

   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([psobject])]
   param
   (
      [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
      [Alias('Forest')]
      [string]
      $ForestName = ([DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().Name.ToString()),
      [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
      [System.Management.Automation.Credential()]
      [pscredential]
      $Credential
   )

   begin
   {
      # Cleanup
      $output = $null
      $ActiveDirectoryContext = $null
   }

   process
   {
      try
      {
         if ($Credential)
         {
            $credentialUser = ($Credential.UserName.ToString())
            $credentialPassword = ($Credential.GetNetworkCredential().Password.ToString())
            $ActiveDirectoryContext = (New-Object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList ('forest', $ForestName, $credentialUser, $credentialPassword))

            # Cleanup
            $credentialUser = $null
            $credentialPassword = $null
         }
         else
         {
            $ActiveDirectoryContext = (New-Object -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext -ArgumentList ('forest', $ForestName))
         }

         $output = ([DirectoryServices.ActiveDirectory.Forest]::GetForest($ActiveDirectoryContext))
      }
      catch
      {
         #region ErrorHandler
         # get error record
         [Management.Automation.ErrorRecord]$e = $_

         # retrieve information about runtime error
         $info = [PSCustomObject]@{
            Exception = $e.Exception.Message
            Reason    = $e.CategoryInfo.Reason
            Target    = $e.CategoryInfo.TargetName
            Script    = $e.InvocationInfo.ScriptName
            Line      = $e.InvocationInfo.ScriptLineNumber
            Column    = $e.InvocationInfo.OffsetInLine
         }

         $info | Out-String | Write-Verbose

         Write-Error -Message ($info.Exception) -ErrorAction Stop

         # Only here to catch a global ErrorAction overwrite
         break
         #endregion ErrorHandler
      }
   }

   end
   {
      $output

      # Cleanup
      $output = $null
      $ActiveDirectoryContext = $null
   }
}
