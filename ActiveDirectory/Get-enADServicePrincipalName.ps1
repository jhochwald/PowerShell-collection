function Get-enADServicePrincipalName
{
   <#
         .SYNOPSIS
         Retrieves all Service Principal Names (SPNs)

         .DESCRIPTION
         Retrieves all Service Principal Names (SPNs) from Active Directory

         .INPUTS
         NONE

         .OUTPUTS
         PSObject

         .EXAMPLE
         PS /> Get-enADServicePrincipalName

         Retrieves all Service Principal Names (SPNs) from Active Directory

         .EXAMPLE
         PS ~> Get-enADServicePrincipalName | Where-Object -FilterScript { $_.ObjectClass -eq 'user' }

         Retrieves all user class Service Principal Names (SPNs) from Active Directory

         .EXAMPLE
         PS ~> Get-enADServicePrincipalName | Where-Object -FilterScript { $_.DNSHostName -like 'server01.contoso.com' }

         Retrieves all Service Principal Names (SPNs) for the Server 'server01.contoso.com' from Active Directory

         .EXAMPLE
         PS ~> Get-enADServicePrincipalName | Where-Object -FilterScript { $_.Name -like '*Krb*' }

         Retrieves all Kerberos related Service Principal Names (SPNs) from Active Directory

         .EXAMPLE
         PS ~> Get-enADServicePrincipalName | Where-Object -FilterScript { $_.SPN -like '*Krb*' }

         Retrieves all Kerberos related Service Principal Names (SPNs) from Active Directory

         .EXAMPLE
         PS ~> Get-enADServicePrincipalName | Export-Csv -Path C:\scripts\PowerShell\Reports\ADServicePrincipalNames.csv

         Retrieves all Service Principal Names (SPNs) from Active Directory and export them to a CSV

         .NOTES
         Version: 1.0.1

         GUID: 807143d7-fa3e-4b71-affa-fab838b34a01

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

         .LINK
         Get-ADObject
   #>
   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([psobject])]
   param ()

   begin
   {
      # Create a new Object
      $AllObject = @()
   }

   process
   {
      try
      {
         # We use Get-ADObject because this seems to be fast enough
         $paramGetADObject = @{
	         Filter	  = "(objectClass -eq 'user') -or (objectClass -eq 'computer') -and (servicePrincipalName -like '*')"
	         Properties = 'Name', 'servicePrincipalName', 'DistinguishedName', 'ObjectClass', 'DNSHostName', 'whenCreated'
         }
         $AllServicePrincipalNames = (Get-ADObject @paramGetADObject)

         # Loop over the List we got from Get-ADObject
         foreach ($SingleServicePrincipalName in $AllServicePrincipalNames)
         {
            # Get the values for the Service Principal Name
            $ObjectClass = $SingleServicePrincipalName.ObjectClass
            $DistinguishedName = $SingleServicePrincipalName.DistinguishedName
            $Name = $SingleServicePrincipalName.Name
            $whenCreated = $SingleServicePrincipalName.whenCreated
            $DNSHostName = $SingleServicePrincipalName.DNSHostName

            # Loop over all Service Principal Names - Remeber, there could be more then one Service Principal Names value per record
            foreach ($ServicePrincipalName in $SingleServicePrincipalName.servicePrincipalName)
            {
               # Create a new Object
               $SingleObject = (New-Object -TypeName PSObject -Property @{
                     Name              = $Name
                     SPN               = $ServicePrincipalName
                     ObjectClass       = $ObjectClass
                     DistinguishedName = $DistinguishedName
                     WhenCreated       = $whenCreated
                     DNSHostName       = $DNSHostName
               })

               # Add the Values to the List
               $AllObject += $SingleObject

               # Cleanup
               $SingleObject = $null
            }
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
      # Dump
      $AllObject

      # Cleanup
      $AllObject = $null
   }
}

get-help Get-enADServicePrincipalName -Examples
