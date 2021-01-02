#requires -Version 3.0 -Modules DnsClient

<#
      .SYNOPSIS
      Update CloudFlare DNS A Record if needed

      .DESCRIPTION
      Update CloudFlare DNS A Record if needed

      The prevent to much API calls, we use a regular DNS query first.
      Only if this query spot a difference, we ensure if an update is needed by ask the Cloudflare API for the latest published info.
      If there is stiff a difference, the cmdlet will update the entry for you.

      If you use a new/unknown hostname in the CF_HOSTNAME parameter, the cmdlet will create a new entry for the given host!

      .PARAMETER CF_TOKEN
      CloudFlare API Token

      Hint: You can find your API key at: https://dash.cloudflare.com/profile/api-tokens

      Create a dedicated Token just for this cmdlet and give it a name that indicate the purpose of it

      The Token needs a least the following permission: Zone.Zone, Zone.DNS
      The token needs access to at least the Zone you want to update (Resources), or use 'All zones'

      .PARAMETER CF_DOMAIN
      The CloudFlare DNS zone you want to modify

      Example: contoso.com (this is also the default)

      .PARAMETER CF_HOSTNAME
      This is the A record you'd like to update or add

      Example: homelab (this is also the default)

      Please Note: We support A Records only at this time!

      .PARAMETER DNSServer
      Resolves hostname using DNS instead of checking CloudFlare.
      It is recommended to use the CloudFlare DNS Servers, e.g. 1.1.1.1
      You can use any other server, but mind that you might not see the changed IP until the Cache TTL expired on this Server!

      .EXAMPLE
      PS C:\> .\Invoke-CloudFlareDDNSUpdate.ps1 -CF_TOKEN '<TOKEN>' -CF_DOMAIN 'contoso.com' -CF_HOSTNAME 'homelab'

      Check and updates the host 'homelab' in the DNS Zone 'contoso.com'

      .EXAMPLE
      PS C:\> .\Invoke-CloudFlareDDNSUpdate.ps1 -CF_TOKEN '<TOKEN>' -CF_DOMAIN 'contoso.com' -CF_HOSTNAME 'homelab' -Verbose

      Check and updates the host 'homelab' in the DNS Zone 'contoso.com', but run in verbose mode

      .EXAMPLE
      PS C:\> .\Invoke-CloudFlareDDNSUpdate.ps1 -CF_TOKEN '<TOKEN>' -CF_DOMAIN 'contoso.com' -CF_HOSTNAME 'homelab' -DNSServer 1.0.0.1

      Check and updates the host 'homelab' in the DNS Zone 'contoso.com', uses the backup CloudFlare DNS to get the published info

      .LINK
      https://1.1.1.1/dns/

      .NOTES
      We use a regular (cheap) DNS call to reduce the number of calls to CloudFlare (they allow 200 reqs/minute but why ask an API first?)

      There is no output by the cmdlet, makes it easier if run a a service or schedules task. use the -Verbose switch to see what the cmdlet is doing

      Please Note: We support A Records only at this time! We are already testing IPv6 (AAAA) and a few others.
#>
[CmdletBinding(ConfirmImpact = 'None')]
param
(
   [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
   [ValidateNotNullOrEmpty()]
   [Alias('CLOUDFLARE_TOKEN', 'CFAPIKey', 'Token')]
   [string]
   $CF_TOKEN = '<Your_Super_Secret_Token_Here>',
   [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
   [ValidateNotNullOrEmpty()]
   [Alias('CLOUDFLARE_Domain', 'CLOUDFLARE_DomainName', 'CFDomainName', 'Zone')]
   [string]
   $CF_DOMAIN = 'contoso.com',
   [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
   [ValidateNotNullOrEmpty()]
   [Alias('CFARecord', 'CLOUDFLARE_HOST', 'CLOUDFLARE_HOSTNAME')]
   [string]
   $CF_HOSTNAME = 'homelab',
   [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
   [ValidateNotNullOrEmpty()]
   [Alias('DNSToUse')]
   [string]
   $DNSServer = '1.1.1.1'
)

begin
{
   #region Cleanup
   $CF_KnownIP = $null
   $CF_ExternalIP = $null
   #endregion Cleanup

   #region CheapRequests
   if (Get-Command -Name Resolve-DnsName -ErrorAction SilentlyContinue)
   {
      # Get the A record from the CloudFlare DNS (cheap request)
      $paramResolveDnsName = @{
         Name          = ($CF_HOSTNAME + '.' + $CF_DOMAIN)
         Type          = 'A'
         Server        = $DNSServer
         ErrorAction   = 'SilentlyContinue'
         WarningAction = 'Continue'
      }
      [string]$CF_KnownIP = (((Resolve-DnsName @paramResolveDnsName) | Select-Object -ExpandProperty IPAddress).Trim())
   }
   elseif (Get-Command -Name dig -ErrorAction SilentlyContinue)
   {
      # This is the Fallback on macOS, due to the missing DnsClient module on PowerShell core here
      [string]$CF_KnownIP = (((dig A ($CF_HOSTNAME + '.' + $CF_DOMAIN) ('@' + $DNSServer) +short)).Trim())
   }
   else
   {
      Write-Warning -Message 'Unable to lookup the DNS entry, we try to use the CloudFlare API' -WarningAction Continue

      # Set a dummy (to prevent any null pointer exception during the compare)
      [string]$CF_KnownIP = '0.0.0.0'
   }

   # Get the external IP via Web Request from our own service (cheap request)
   $paramInvokeRestMethod = @{
      Method          = 'Get'
      UseBasicParsing = $true
      Uri             = 'https://ip.enatec.net'
      ErrorAction     = 'Stop'
      WarningAction   = 'Continue'
   }
   [string]$CF_ExternalIP = ((Invoke-RestMethod @paramInvokeRestMethod).Trim())
   #endregion CheapRequests
}

process
{
   # Compare the two values
   if ($CF_ExternalIP -ne $CF_KnownIP)
   {
      # Looks like there is a Difference

      # Only the V4 API is supported by the cmdlet yet!
      $CF_API_ENDPOINT = $null
      $CF_API_ENDPOINT = 'https://api.cloudflare.com/client/v4'

      $CF_Headers = $null
      $CF_Headers = @{
         'Authorization' = ('Bearer ' + $CF_TOKEN)
         'Content-Type'  = 'application/json'
      }

      $CF_ZoneURI = $null
      $CF_ZoneURI = ($CF_API_ENDPOINT + '/zones?name=' + $CF_DOMAIN)

      Write-Verbose -Message ('Getting DNS-Zone ID for ' + $($CF_DOMAIN) + ' via ' + $CF_ZoneURI)

      # Let us get the Zone Info directly from CloudFlare (API Request)
      $CF_ZoneId = $null
      $paramInvokeRestMethod = @{
         Uri           = $CF_ZoneURI
         ContentType   = 'application/json'
         Headers       = $CF_Headers
         ErrorAction   = 'Stop'
         WarningAction = 'Continue'
      }
      $CF_ZoneId = (((Invoke-RestMethod @paramInvokeRestMethod).result).id)

      $CF_DNSURI = $null
      $CF_DNSURI = ($CF_API_ENDPOINT + '/zones/' + $CF_ZoneId + '/dns_records?type=A&name=' + $CF_HOSTNAME + '.' + $CF_DOMAIN)

      Write-Verbose -Message ('Getting DNS data for ' + $($CF_HOSTNAME).$($CF_DOMAIN) + ' via ' + $CF_DNSURI)

      # Let us get the host Info directly from CloudFlare (API Request)
      $CF_DNSData = $null
      $paramInvokeRestMethod = @{
         Uri           = $CF_DNSURI
         ContentType   = 'application/json'
         Headers       = $CF_Headers
         ErrorAction   = 'Stop'
         WarningAction = 'Continue'
      }
      $CF_DNSData = ((Invoke-RestMethod @paramInvokeRestMethod).result)

      #  Compare again (Double check)
      if ($CF_ExternalIP -ne $CF_DNSData.content)
      {
         # OK, we are sure that there is a new IP!
         Write-Verbose -Message 'IP address change detected, we will try to update the CloudFlare DNS'

         try
         {
            $CF_Body = $null
            $CF_Body = @{
               'type'    = 'A'
               'name'    = ($CF_HOSTNAME + '.' + $CF_DOMAIN)
               'content' = $CF_ExternalIP
               'ttl'     = '1'
            }

            $URI_Update = $null
            $URI_Update = ($CF_API_ENDPOINT + '/zones/' + $CF_ZoneId + '/dns_records/' + $($CF_DNSData.id))

            # Apply the new IP address to the CloudFlare DNS
            $CF_Result = $null
            $paramInvokeRestMethod = @{
               Uri           = $URI_Update
               Method        = 'Put'
               ContentType   = 'application/json'
               Headers       = $CF_Headers
               Body          = $
               WebSession    = ($CF_Body | ConvertTo-Json)
               ErrorAction   = 'Stop'
               WarningAction = 'Continue'
            }
            $CF_Result = ((Invoke-RestMethod @paramInvokeRestMethod).result)

            if ($CF_Result.content -eq $CF_ExternalIP)
            {
               Write-Verbose -Message 'SUCCESS: CloudFlare DNS was successfully updated'
            }
            else
            {
               Write-Verbose -Message 'FAILED: CloudFlare DNS was not successfully updated'
            }
         }
         catch
         {
            # Get error record
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

            # output information. Post-process collected info, and log info (optional)
            $info | Out-String | Write-Verbose

            $paramWriteError = @{
               Message      = $e.Exception.Message
               ErrorAction  = 'Stop'
               Exception    = $e.Exception
               TargetObject = $e.CategoryInfo.TargetName
            }
            Write-Error @paramWriteError

            # Just in case
            exit 1
         }
      }
      else
      {
         Write-Verbose -Message 'CloudFlare: No update is needed'
      }
   }
   else
   {
      Write-Verbose -Message 'DNS: No update is needed'
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
