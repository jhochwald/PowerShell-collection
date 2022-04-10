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
         Period to query, value in hours

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
                  $PSItem.IsLinkValue
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
            $PSItem.LastOriginatingChangeTime -gt (Get-Date).AddHours(-1 * $Hour)
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
