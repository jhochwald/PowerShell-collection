#requires -Version 3.0 -Modules ActiveDirectory
function Get-enADFSMORole
{
   <#
         .SYNOPSIS
         Retrieve the FSMO Role in the Forest/Domain

         .DESCRIPTION
         Retrieve the FSMO Role in the Forest/Domain of Active Directory

         .PARAMETER Credential
         Specify the alternative credential to use

         .EXAMPLE
         Get-enADFSMORole

         Retrieve the FSMO Role in the Forest/Domain of Active Directory

         .EXAMPLE
         Get-enADFSMORole -Credential (Get-Credential)

         Retrieve the FSMO Role in the Forest/Domain of Active Directory

         .NOTES
         Version: 1.0.1

         GUID: b5713556-2ede-420a-9104-f9c85e0cdb27

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
         Get-ADForest

         .LINK
         Get-ADDomain
   #>

   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([psobject])]
   param
   (
      [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
      [System.Management.Automation.Credential()]
      [Alias('RunAs')]
      [pscredential]
      $Credential = [pscredential]::Empty
   )

   begin
   {
      $Properties = $null
   }

   process
   {
      try
      {
         if ($PSBoundParameters['Credential'])
         {
            # Query with the credentials specified
            $ForestRoles = (Get-ADForest -Credential $Credential -ErrorAction 'Stop' -ErrorVariable ErrorGetADForest)
            $DomainRoles = (Get-ADDomain -Credential $Credential -ErrorAction 'Stop' -ErrorVariable ErrorGetADDomain)
         }
         else
         {
            # Query with the current credentials
            $ForestRoles = (Get-ADForest)
            $DomainRoles = (Get-ADDomain)
         }

         # Define Properties
         $Properties = @{
            SchemaMaster         = $ForestRoles.SchemaMaster
            DomainNamingMaster   = $ForestRoles.DomainNamingMaster
            InfraStructureMaster = $DomainRoles.InfraStructureMaster
            RIDMaster            = $DomainRoles.RIDMaster
            PDCEmulator          = $DomainRoles.PDCEmulator
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
      $Properties
   }
}

Get-enADFSMORole
