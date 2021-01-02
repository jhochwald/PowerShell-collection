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
