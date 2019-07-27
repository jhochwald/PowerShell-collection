function Get-enADGroupChange
{
   <#
         .SYNOPSIS
         Retrieve information about changed Active Directory groups

         .DESCRIPTION
         Retrieve information about one, or more, changed Active Directory groups

         .PARAMETER Server
         Active DirectoryDomain Controller to querry.
         Default is the logon server

         .PARAMETER MonitorGroup
         Group to monitor, multi value is supported.
         Defaults to all Groups with admins.

         Specifies an Active Directory object by providing one of the following property values. The identifier in
         parentheses is the LDAP display name for the attribute.

         Distinguished Name

         Example: CN=DOM-ADM,OU=groups,OU=asia,DC=corp,DC=contoso,DC=com

         GUID (objectGUID)

         Example: 599c3d2e-f72d-4d20-8a88-030d99495f20

         The cmdlet searches the default naming context or partition to find the object. If two or more objects are
         found, the cmdlet returns a non-terminating error.

         .PARAMETER Hour
         Period to querry, value in hours

         .EXAMPLE
         Get-enADGroupChange

         Retrieve information about changed Active Directory groups

         .EXAMPLE
         Get-enADGroupChange -MonitorGroup 'DOM-ADM'

         Retrieve information about changes to theActive Directory group DOM-ADM

         .EXAMPLE
         Get-enADGroupChange -Server DC03

         Retrieve information about changed Active Directory groups on DC03

         .EXAMPLE
         Get-enADGroupChange -Hour 72

         Retrieve information about Active Directory groups that have been changed within the last 72 hours

         .EXAMPLE
         Get-enADGroupChange -Server DC02 -Hour 96

         Retrieve information about Active Directory groups that have been changed within the last 96 hours on DC02

         .OUTPUTS
         psobject

         .NOTES
         Version: 1.0.1

         GUID: 6289fe30-3292-45ba-b587-de1eac067dc6

         Author: Joerg Hochwald

         Companyname: enabling Technology

         Copyright: Copyright (c) 2ß18-2019, enabling Technology - All rights reserved.

         License: https://opensource.org/licenses/BSD-3-Clause

         Releasenotes:
         1.0.1 2019-07-26 Refactored, License change to BSD 3-Clause
         1.0.0 2019-01-01 Initial Version

         THIS CODE IS MADE AVAILABLE AS IS, WITHOUT WARRANTY OF ANY KIND. THE ENTIRE RISK OF THE USE OR THE RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.

         .INPUTS
         String
         Int

         .LINK
         https://www.enatec.io

         .LINK
         Get-ADDomainController

         .LINK
         Get-ADGroup

         .LINK
         Get-ADReplicationAttributeMetadata

         .LINK
         Get-Date
   #>

   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([psobject])]
   param
   (
      [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
      [ValidateNotNullOrEmpty()]
      [Alias('DomainController')]
      [string]
      $Server = (Get-ADDomainController -Discover | Select-Object -ExpandProperty HostName),
      [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
      [ValidateNotNullOrEmpty()]
      [Alias('Group')]
      [string[]]
      $MonitorGroup = (Get-ADGroup -Filter ' AdminCount -eq 1 ' -Server $Server | Select-Object -ExpandProperty ObjectGUID),
      [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
      [Alias('Period')]
      [int]
      $Hour = 24
   )

   begin
   {
      # Create a new object
      $Members = @()

      Write-Verbose -Message ('Processing group {0} via Server {1}' -f $MonitorGroup, $Server)
   }

   process
   {
      try
      {
         foreach ($SingleGroup in $MonitorGroup)
         {
            Write-Verbose -Message ('Processing group {0}' -f $SingleGroup)

            # Querry the info and add to the Object
            $Members += (Get-ADReplicationAttributeMetadata -Server $Server -Object $SingleGroup -ShowAllLinkedValues | Where-Object -FilterScript {
                  $_.IsLinkValue
               } | Select-Object -Property @{
                  name       = 'GroupDN'
                  expression = {
                     $SingleGroup.DistinguishedName
                  }
               }, @{
                  name       = 'GroupName'
                  expression = {
                     $SingleGroup.Name
                  }
            }, *)
         }

         # Filter
         $Members | Where-Object -FilterScript {
            $_.LastOriginatingChangeTime -gt (Get-Date).AddHours(-1 * $Hour)
         }
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
      $Members = $null
   }
}
