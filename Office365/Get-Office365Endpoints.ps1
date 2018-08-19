#requires -Version 3.0
<#
    .SYNOPSIS
    Get the Office 365 Endpoint Information from Microsoft via the new RestFull Webservice (JSON)

    .DESCRIPTION
    Microsoft updates the Office 365 IP address and FQDN entries at the end of each month and occasionally out of the cycle for operational or support requirements.
    This function uses the new JSON based Webserice instead of the old XML based one; the XML based service will be retired soon by Microsoft.

    .PARAMETER Instance
    The short name of the Office 365 service instance.
    Valid: Worldwide, USGovDoD, USGovGCCHigh, China, Germany
    The default is: Worldwide

    .PARAMETER Services
    Valid items are All, Common, Exchange, SharePoint, Skype.
    The default is: All
    Because Common service area items are a prerequisite for all other service areas

    .PARAMETER Tenant
    Your Office 365 tenant name.
    The web service takes your provided name and inserts it in parts of URLs that include the tenant name.
    If you don't provide a tenant name, those parts of URLs have the wildcard character (*).

    .PARAMETER NoIPv6
    Query string parameter. Set this to true to exclude IPv6 addresses from the output, for example, if you don't use IPv6 in your network.
    The default is FALSE
    TODO: Not iomplemented yet! - Might be dropped in the near future, but it could speed up things by not getting IPv6 info if we do not need them.

    .PARAMETER ExpressRoute
    Only display endpoints that could be routed over ExpressRoute.
    Default is: FALSE - All endpoints will be exported

    .PARAMETER Category
    The connectivity category for the endpoint set.
    Valid values are: All, Optimize, Allow, and Default.
    Default is: 'All'

    .PARAMETER Required
    This endpoint set is required to have connectivity for Office 365 to be supported. 
    Default is: FALSE

    .PARAMETER Output
    What to return?
    Values are: All, IPv4, IPv6, URLs
    Default is: All

    .EXAMPLE
    PS C:\> .\Get-Office365Endpoints.ps1

    It gets the International (Worldwide) Office 365 URLs, IPv4, and IPv6 address ranges.

    .EXAMPLE
    PS C:\> .\Get-Office365Endpoints.ps1 -Instance Germany

    It gets the Office 365 Germany URLs, IPv4 address ranges. It would also return IPv6, but IPv6 is not supported, at least not yet.

    .EXAMPLE
    PS C:\> .\Get-Office365Endpoints.ps1 -Instance Germany -Category Optimize

    It gets the Office 365 Germany URLs, IPv4 address ranges. Only in the category 'Optimize'. It would also return IPv6, but IPv6 is not supported, at least not yet.

    .EXAMPLE
    PS C:\> .\Get-Office365Endpoints.ps1 -Instance Worldwide -Services Exchange -Required

    It gets the International (Worldwide) Office 365 URLs, IPv4, and IPv6 address ranges for Exchange and everything to be supported (includes CDNs and other, even external, services).

    .EXAMPLE
    PS C:\> .\Get-Office365Endpoints.ps1 -Instance Worldwide -Services Exchange -Required -Tenant 'contoso'

    It gets the International (Worldwide) Office 365 URLs, IPv4, and IPv6 address ranges for Exchange and everything to be supported (includes CDNs and other, even external, services); this example includes URLs for the tenant with the Name 'contoso'.
    The Tenant based URLs are generated and not checked, so please make sure you use the correct name!

    .EXAMPLE
    PS C:\> ((.\Get-Office365Endpoints.ps1 -Instance Worldwide -Services Exchange -Tenant 'kreativsign' -Output URLs -Required).url | Sort-Object -Unique) -join "," | Out-String

    It gets the International (Worldwide) Office 365 URLs, IPv4, and IPv6 address ranges for Exchange and everything to be supported (includes CDNs and other, even external, services); this example includes URLs for the tenant with the Name 'contoso'.
    The Tenant based URLs are generated and not checked, so please make sure you use the correct name! !
    It just dumps the URLs in a comma separated (CSV) format. Useful for Proxy Servers.

    .EXAMPLE
    PS C:\> (((.\Get-Office365Endpoints.ps1 -Instance Worldwide -Services Exchange -Output IPv4) | Where-Object -FilterScript {$_.tcpPorts -eq '587'}).ip | Sort-Object -Unique) -join "," | Out-String

    It gets the International (Worldwide) Office 365 IPv4 addresses for Exchange Submission (SMTP) Servers who use Port 587. It dumps a comma separated (CSV) format. Useful for Firewalls.

    .EXAMPLE
    PS C:\> (((.\Get-Office365Endpoints.ps1 -Instance Worldwide -Services Exchange -Output IPv6) | Where-Object -FilterScript {$_.tcpPorts -eq '25'}).ip | Sort-Object -Unique) -join "," | Out-String

    It gets the International (Worldwide) Office 365 IPv4 addresses for Exchange SMTP Servers who use Port 25. It dumps a comma separated (CSV) format. Useful for Firewalls.

    .EXAMPLE
    PS C:\> (((.\Get-Office365Endpoints.ps1 -Instance Worldwide -Services Exchange -Output URLs) | Where-Object -FilterScript {$_.notes -like '*Exchange Hybrid Configuration Wizard*' }).url | Sort-Object -Unique) -join "," | Out-String

    Get a List of Exchange Online URLs that you might need if you want to run the Exchange Hybrid Configuration Wizard.

    .EXAMPLE
    PS C:\> ((.\Get-Office365Endpoints.ps1 -Instance Worldwide -Output 'IPv4' -ExpressRoute).ip | Sort-Object -Unique) -join "," | Out-String

    Get a List of IPv4 addresses for ExpressRoute configuration.

    .EXAMPLE
    PS C:\> ((.\Get-Office365Endpoints.ps1 -Instance Worldwide -Output 'IPv6' -ExpressRoute).ip | Sort-Object -Unique) -join "," | Out-String

    Get a List of IPv6 addresses for ExpressRoute configuration. Please note: IPv6 is not supported with ExpressRoute in every Instance, (example: Germany)

    .NOTES
    Initial Version that uses the new Microsoft Service. A few things are still missing or not rock solid. 
    However, we needed a solution to configure ExpressRoute now, so we started with some rework to use the new Webservice.

    This function is part of the commercial en.Office365 PowerShell Module - Distributed separately as OpenSouce with a very flexible license (See below)

    Some parts of the script are based upon the example that Microsoft published on the info page of the new Webservice!

    .LINK
    https://github.com/jhochwald/PowerShell-collection/blob/master/Office365/Get-Office365Endpoints.ps1

    .LINK
    https://hochwald.net/powershell-get-the-office-365-endpoint-information-from-microsoft/

    .LINK
    https://hochwald.net/powershell-function-to-get-the-office-365-urls-and-ip-address-ranges/

    .LINK
    https://support.office.com/en-us/article/managing-office-365-endpoints-99cab9d4-ef59-4207-9f2b-3728eb46bf9a#webservice

    .LINK
    https://techcommunity.microsoft.com/t5/Office-365-Blog/Announcing-Office-365-endpoint-categories-and-Office-365-IP/ba-p/177638
#>
[CmdletBinding()]
[OutputType([psobject])]
param
(
  [Parameter(ValueFromPipeline = $true,
  ValueFromPipelineByPropertyName = $true)]
  [ValidateNotNullOrEmpty()]
  [ValidateSet('Worldwide', 'USGovDoD', 'USGovGCCHigh', 'China', 'Germany', IgnoreCase = $true)]
  [string]
  $Instance = 'Worldwide',
  [Parameter(ValueFromPipeline = $true)]
  [ValidateNotNullOrEmpty()]
  [ValidateSet('All', 'Common', 'Exchange', 'SharePoint', 'Skype', IgnoreCase = $true)]
  [Alias('ServiceAreas')]
  [string]
  $Services = 'All',
  [Parameter(ValueFromPipeline = $true)]
  [Alias('TenantName')]
  [string]
  $Tenant = $null,
  [Parameter(ValueFromPipeline = $true)]
  [switch]
  $NoIPv6,
  [Parameter(ValueFromPipeline = $true)]
  [switch]
  $ExpressRoute,
  [ValidateSet('All', 'Optimize', 'Allow', 'Default', IgnoreCase = $true)]
  [string[]]
  $Category,
  [Parameter(ValueFromPipeline = $true)]
  [switch]
  $Required,
  [Parameter(ValueFromPipeline = $true)]
  [ValidateSet('All', 'IPv4', 'IPv6', 'URLs', IgnoreCase = $true)]
  [string]
  $Output = 'All'
)

begin
{
  if (! $Category -or $Category -eq 'All') 
  {
    # Set to all
    $Category += 'Optimize', 'Allow', 'Default'
  }

  # Tweak our Output
  # TODO: Make a simpler solution for that!
  switch ($Output)
  {
    'All'
    {
      $outIPv4 = $true
      $outIPv6 = $true
      $outURLs = $true
    }
    'IPv4'
    {
      $outIPv4 = $true
      $outIPv6 = $false
      $outURLs = $false
    }
    'IPv6'
    {
      $outIPv4 = $false
      $outIPv6 = $true
      $outURLs = $false
    }
    'URLs'
    {
      $outIPv4 = $false
      $outIPv6 = $false
      $outURLs = $true
    }
  }
	
  # Webservice root URL
  $BaseURI = 'https://endpoints.office.com'
	
  # Path where client ID and latest version number will be stored
  $datapath = $Env:TEMP + '\endpoints_clientid_' + $Instance + '_latestversion.txt'
	
  # fetch client ID and version if data file exists; otherwise create new file
  if (Test-Path -Path $datapath)
  {
    # Read the File
    $content = (Get-Content -Path $datapath)
		
    # Get the Info
    $clientRequestId = $content[0]
    $lastVersion = $content[1]
		
    # Cleanup
    $content = $null
  }
  else
  {
    # Create a GUID
    $clientRequestId = [GUID]::NewGuid().Guid
		
    # Dummy Data
    $lastVersion = '0000000000'
		
    # Save the local info
    try
    {
      @($clientRequestId, $lastVersion) | Out-File -FilePath $datapath -ErrorAction Stop
    }
    catch
    {
      # Write the complete error if we have verbose turned on
      Write-Verbose -Message $_

      # Our Error test
      Write-Error -Message ('Unable to write Datafile: {0}' -f $datapath) -ErrorAction Stop

      # We should never reach this point!
      Break
    }
  }
	
  # Call version method to check the latest version, and pull new data if version number is different
  try
  {
    $GetVersionParams = @{
      Uri           = ($BaseURI + '/version/' + $Instance + '?clientRequestId=' + $clientRequestId)
      Method        = 'Get'
      ErrorAction   = 'Stop'
      WarningAction = 'SilentlyContinue'
    }
    $version = (Invoke-RestMethod @GetVersionParams)
  }
  catch
  {
    # Write the complete error if we have verbose turned on
    Write-Verbose -Message $_

    # Our Error test
    Write-Error -Message 'Unable to get the new Office 365 Endpoint Information' -ErrorAction Stop

    # We should never reach this point!
    break
  }
}

process
{
  if ($version.latest -gt $lastVersion)
  {
    Write-Verbose -Message ('New version of Office 365 {0} endpoints detected' -f $Instance)
		
    # Write the new version number to the data file
    try
    {
      @($clientRequestId, $version.latest) | Out-File -FilePath $datapath -ErrorAction Stop
    }
    catch
    {
      # Write the complete error if we have verbose turned on
      Write-Verbose -Message $_

      # Our Error test
      Write-Error -Message ('Unable to write Datafile: {0}' -f $datapath) -ErrorAction Stop

      # We should never reach this point!
      Break
    }
		
		
    # Invoke endpoints method to get the new data
    try
    {
      # Set the default URI
      $requestURI = ($BaseURI + '/endpoints/' + $Instance + '?clientRequestId=' + $clientRequestId)
			
      switch ($Services)
      {
        'All'
        {
          # We get all
        }
        'Common'
        {
          # Append to the URI
          $requestURI = ($requestURI + '&ServiceAreas=Common')
        }
        'Exchange'
        {
          # Append to the URI
          $requestURI = ($requestURI + '&ServiceAreas=Exchange')
        }
        'SharePoint'
        {
          # Append to the URI
          $requestURI = ($requestURI + '&ServiceAreas=SharePoint')
        }
        'Skype'
        {
          # Append to the URI
          $requestURI = ($requestURI + '&ServiceAreas=Skype')
        }
      }

      if ($Tenant)
      {
        # Append to the URI - Build URL for the Tenant
        $requestURI = ($requestURI + '&TenantName=' + $Tenant)
      }

      # Do our job and get the data via Rest Request
      Write-Verbose -Message ('We request the following URI: {0}' -f $requestURI)

      $endpointSetsParams = @{
        Uri           = $requestURI
        Method        = 'Get'
        ErrorAction   = 'Stop'
        WarningAction = 'SilentlyContinue'
      }
      $endpointSets = (Invoke-RestMethod @endpointSetsParams)
    }
    catch
    {
      # Write the complete error if we have verbose turned on
      Write-Verbose -Message $_

      # Our Error test
      Write-Error -Message 'Unable to get the new Office 365 Endpoint Information' -ErrorAction Stop

      # We should never reach this point!
      break
    }

    # Filter results for Allow and Optimize endpoints, and transform these into custom objects with port and category
    if ($outURLs)
    {
      $flatUrls = $endpointSets | ForEach-Object -Process {
        $endpointSet = $_
        $urls = $(if ($endpointSet.urls.Count -gt 0)
          {
            $endpointSet.urls
          }
          else
          {
            @()
          }
        )

        # Cleanup
        $urlCustomObjects = @()
				
        if ($endpointSet.category -in ($Category))
        {
          $urlCustomObjects = $urls | ForEach-Object -Process {
            # Ordered is slower, but we like it this way
            [PSCustomObject][ordered]@{
              id           = $endpointSet.id
              serviceArea  = $endpointSet.serviceArea
              DisplayName  = $endpointSet.serviceAreaDisplayName
              url          = $_
              tcpPorts     = $endpointSet.tcpPorts
              udpPorts     = $endpointSet.udpPorts
              expressRoute = $endpointSet.expressRoute
              category     = $endpointSet.category
              required     = $endpointSet.required
              notes        = $endpointSet.notes
            }
          }
        }

        # Only ExpressRoute enabled Objects?
        if ($ExpressRoute) 
        {
          $urlCustomObjects = $urlCustomObjects | Where-Object -FilterScript {
            $urlCustomObjects.expressRoute -eq $true
          }
        }

        # Only required to have connectivity for Office 365 to be supported
        if ($Required) 
        {
          $urlCustomObjects = $urlCustomObjects | Where-Object -FilterScript {
            $urlCustomObjects.required -eq $true
          }
        }

        # Dump
        $urlCustomObjects
      }
    }
		
    if ($outIPv4)
    {
      $flatIpv4 = $endpointSets | ForEach-Object -Process {
        $endpointSet = $_
        $ips = $(if ($endpointSet.ips.Count -gt 0)
          {
            $endpointSet.ips
          }
          else
          {
            @()
          }
        )
				
        # IPv4 strings have dots while IPv6 strings have colons
        $IPv4 = $ips | Where-Object -FilterScript {
          $_ -like '*.*'
        }
				
        # Cleanup
        $ipCustomObjects = @()
				
        if ($endpointSet.category -in ($Category))
        {
          $ipCustomObjects = $IPv4 | ForEach-Object -Process {
            # Ordered is slower, but we like it this way
            [PSCustomObject][ordered]@{
              id           = $endpointSet.id
              serviceArea  = $endpointSet.serviceArea
              DisplayName  = $endpointSet.serviceAreaDisplayName
              ip           = $_
              tcpPorts     = $endpointSet.tcpPorts
              udpPorts     = $endpointSet.udpPorts
              expressRoute = $endpointSet.expressRoute
              category     = $endpointSet.category
              required     = $endpointSet.required
              notes        = $endpointSet.notes
            }
          }
        }
				
        # Dump
        $ipCustomObjects
      }
    }
		
    if ($outIPv6)
    {
      $flatIpv6 = $endpointSets | ForEach-Object -Process {
        $endpointSet = $_
        $ips = $(if ($endpointSet.ips.Count -gt 0)
          {
            $endpointSet.ips
          }
          else
          {
            @()
          }
        )
				
        # IPv4 strings have dots while IPv6 strings have colons
        $IPv6 = $ips | Where-Object -FilterScript {
          $_ -like '*:*'
        }
				
        # Cleanup
        $ipCustomObjects = @()
				
        if ($endpointSet.category -in ($Category))
        {
          $ipCustomObjects = $IPv6 | ForEach-Object -Process {
            # Ordered is slower, but we like it this way
            [PSCustomObject][ordered]@{
              id           = $endpointSet.id
              serviceArea  = $endpointSet.serviceArea
              DisplayName  = $endpointSet.serviceAreaDisplayName
              ip           = $_
              tcpPorts     = $endpointSet.tcpPorts
              udpPorts     = $endpointSet.udpPorts
              expressRoute = $endpointSet.expressRoute
              category     = $endpointSet.category
              required     = $endpointSet.required
              notes        = $endpointSet.notes
            }
          }
        }
				
        # Dump
        $ipCustomObjects
      }
    }
  }
}

end
{
  if ($version.latest -gt $lastVersion)
  {
    if ($outIPv4)
    {
      Write-Verbose -Message 'Office 365 IPv4 IP Address Ranges'
      ($flatIpv4 | Sort-Object -Property id)
    }
		
    if ($outIPv6)
    {
      Write-Verbose -Message 'Office 365 IPv6 IP Address Ranges'
      ($flatIpv6 | Sort-Object -Property id)
    }
		
    if ($outURLs)
    {
      Write-Verbose -Message 'Office 365 URLs'
      ($flatUrls | Sort-Object -Property id)
    }
  }
  else
  {
    Write-Output -InputObject 'Office 365 worldwide commercial service instance endpoints are up-to-date'
  }
}

<#
    CHANGELOG:

    0.8.1 - 2018-08-19: [FIX] Add missing OutputType
    0.8.0 - 2018-08-18: Intitial 
#>

<#
    LICENSE:

    Copyright 2018 by enabling Technology - http://enatec.io

    Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

    2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

    3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

    By using the Software, you agree to the License, Terms and Conditions above!
#>