function Get-enADDNSServerInformation
{
   <#
         .SYNOPSIS
         Retrieve information about the Active Directory Domain Name Servers

         .DESCRIPTION
         Retrieve information about the Active Directory Domain Name Servers

         .PARAMETER Domain
         A description of the Domain parameter.

         .EXAMPLE
         PS ~> Get-enADDNSServerInformation

         Retrieve information about the Active Directory Domain Name Servers, use the current domain

         .EXAMPLE
         PS ~> Get-enADDNSServerInformation | Export-CSV -Path C:\scripts\PowerShell\Reports\DNS_Zones.csv -NoTypeInformation -Force -Confirm:$false
         Retrieve information about the Active Directory Domain Name Servers, use the current domain and exports it to CSV

         .EXAMPLE
         PS ~> Get-enADDNSServerInformation | ConvertTo-Json -Depth 10 | Set-Content -Path C:\scripts\PowerShell\Reports\DNS_Zones.json -Force -Confirm:$false
         Retrieve information about the Active Directory Domain Name Servers, use the current domain and exports it to a JSON File

         .EXAMPLE
         PS ~> Get-enADDNSServerInformation -Domain 'contoso.com'

         Retrieve information about the Active Directory Domain Name Servers in the Domain contoso.com

         .EXAMPLE
         PS ~> Get-enADDNSServerInformation -Domain 'contoso.com', 'corp.contoso.net'

         Retrieve information about the Active Directory Domain Name Servers in the Domain contoso.com and corp.contoso.net

         .OUTPUTS
         psobject

         .INPUTS
         String

         .NOTES
         TODO: Need refactoring: Object handler sucks
         TODO: Find a non WMI based Solution for this

         Version: 1.0.1

         GUID: 4404141a-1731-4786-8bbf-ee6706765050

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
         http://msdn.microsoft.com/en-us/library/windows/desktop/aa393295(v=vs.85).aspx

         .LINK
         Get-ADDomainController

         .LINK
         Get-WmiObject
   #>

   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([psobject])]
   param
   (
      [Parameter(ValueFromPipeline,
         ValueFromPipelineByPropertyName)]
      [string[]]
      $Domain = ([DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().Name.ToString())
   )

   begin
   {
      $DNSReport = @()
   }

   process
   {
      foreach ($DomainEach in $Domain)
      {
         $AllDomainControllers = (Get-ADDomainController -Filter {
               Site -like '*' -and Domain -eq $DomainEach
            } | Select-Object -ExpandProperty Name)

         foreach ($SingleDomainController in $AllDomainControllers)
         {
            # Prevent Null Pointer Exceptions
            if ($SingleDomainController)
            {
               # TODO: Find a non WMI based Solution for this
               $Forwarders = (Get-WmiObject -ComputerName $SingleDomainController -Namespace root\MicrosoftDNS -Class MicrosoftDNS_Server -ErrorAction SilentlyContinue)

               # TODO: Find a non WMI based Solution for this
               $NetworkInterface = (Get-WmiObject -ComputerName $SingleDomainController -Query 'Select * From Win32_NetworkAdapterConfiguration Where IPEnabled=TRUE' -ErrorAction SilentlyContinue)

               $DNSReport += 1 | Select-Object -Property @{
                  name       = 'DC'
                  expression = {
                     $SingleDomainController
                  }
               }, @{
                  name       = 'Domain'
                  expression = {
                     $DomainEach
                  }
               }, @{
                  name       = 'DNSHostName'
                  expression = {
                     $NetworkInterface.DNSHostName
                  }
               }, @{
                  name       = 'IPAddress'
                  expression = {
                     $NetworkInterface.IPAddress
                  }
               }, @{
                  name       = 'DNSServerAddresses'
                  expression = {
                     $Forwarders.ServerAddresses
                  }
               }, @{
                  name       = 'DNSServerSearchOrder'
                  expression = {
                     $NetworkInterface.DNSServerSearchOrder
                  }
               }, @{
                  name       = 'Forwarders'
                  expression = {
                     $Forwarders.Forwarders
                  }
               }, @{
                  name       = 'BootMethod'
                  expression = {
                     $Forwarders.BootMethod
                  }
               }, @{
                  name       = 'ScavengingInterval'
                  expression = {
                     $Forwarders.ScavengingInterval
                  }
               }
            }
         }
      }
   }

   end
   {
      $DNSReport
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
