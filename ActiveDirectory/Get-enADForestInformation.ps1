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

         Retrieve als Global Catalog Servers from the current Active Directory Forest. More details then the above example, cause it will show all the details for each Global Catalog Servers.

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
