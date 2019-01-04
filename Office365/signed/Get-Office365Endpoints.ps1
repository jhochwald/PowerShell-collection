#requires -Version 3.0

function Get-Office365Endpoints
{
  <#
      .SYNOPSIS
      Get the Office 365 Endpoint Information from Microsoft via the new RestFull Webservice (JSON)
	
      .DESCRIPTION
      Microsoft updates the Office 365 IP address and FQDN entries at the end of each month and occasionally out of the cycle for operational or support requirements.
		
      This function uses the new JSON based Webserice instead of the old XML based one; the XML based service will be retired soon by Microsoft.
		
      The Function will compare the last downloaded version with the latest available online version, if there is no update available, the function does nothing.
      If there is an update, the function will do what you told it to. If you want to enforce the download, just delete the O365_endpoints_*_latestversion.txt in your $Env:TEMP Directory. The * is a placeholder, for the Instance name.
	
      .PARAMETER Instance
      The short name of the Office 365 service instance.
      Valid: Worldwide, USGovDoD, USGovGCCHigh, China, Germany
      The default is: Worldwide
	
      .PARAMETER Services
      Valid items are All, Common, Exchange, SharePoint, Skype.
      Because Common service area items are a prerequisite for all other service areas it is included every time - Adopted that from the Microsoft Statement; nevertheless, we disagree with the selection of Microsoft. There are way to many endpoints included here!
      The default is: All
	
      .PARAMETER Tenant
      Your Office 365 tenant name.
      The web service takes your provided name and inserts it in parts of URLs that include the tenant name.
      If you don't provide a tenant name, those parts of URLs have the wildcard character (*).
	
      .PARAMETER NoIPv6
      Query string parameter. Set this to true to exclude IPv6 addresses from the output, for example, if you don't use IPv6 in your network.
      The default is FALSE
	
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
	
      .PARAMETER SkipVersionCheck
      Force the download and ignore the existing version information
	
      .EXAMPLE
      PS C:\> Get-Office365Endpoints.ps1
		
      It gets the International (Worldwide) Office 365 URLs, IPv4, and IPv6 address ranges.
	
      .EXAMPLE
      PS C:\> Get-Office365Endpoints.ps1 -Instance Germany
		
      It gets the Office 365 Germany URLs, IPv4 address ranges. It would also return IPv6, but IPv6 is not supported, at least not yet.
	
      .EXAMPLE
      PS C:\> Get-Office365Endpoints.ps1 -Instance Germany -Category Optimize
		
      It gets the Office 365 Germany URLs, IPv4 address ranges. Only in the category 'Optimize'. It would also return IPv6, but IPv6 is not supported, at least not yet.
	
      .EXAMPLE
      PS C:\> Get-Office365Endpoints.ps1 -Instance Worldwide -Services Exchange -Required
		
      It gets the International (Worldwide) Office 365 URLs, IPv4, and IPv6 address ranges for Exchange and everything to be supported (includes CDNs and other, even external, services).
	
      .EXAMPLE
      PS C:\> Get-Office365Endpoints.ps1 -Instance Worldwide -Services Exchange -Required -Tenant 'contoso'
		
      It gets the International (Worldwide) Office 365 URLs, IPv4, and IPv6 address ranges for Exchange and everything to be supported (includes CDNs and other, even external, services); this example includes URLs for the tenant with the Name 'contoso'.
      The Tenant based URLs are generated and not checked, so please make sure you use the correct name!
	
      .EXAMPLE
      PS C:\> ((Get-Office365Endpoints.ps1 -Instance Worldwide -Services Exchange -Tenant 'contoso' -Output URLs -Required).url | Sort-Object -Unique) -join "," | Out-String
		
      It gets the International (Worldwide) Office 365 URLs, IPv4, and IPv6 address ranges for Exchange and everything to be supported (includes CDNs and other, even external, services); this example includes URLs for the tenant with the Name 'contoso'.
      The Tenant based URLs are generated and not checked, so please make sure you use the correct name! !
      It just dumps the URLs in a comma separated (CSV) format. Useful for Proxy Servers.

      .EXAMPLE
      PS C:\> ((Get-Office365Endpoints.ps1 -Instance Worldwide -Services Exchange -Tenant 'contoso' -Output URLs -Required -SkipVersionCheck).url | Sort-Object -Unique) -join "," | Out-String
		
      It gets the International (Worldwide) Office 365 URLs, IPv4, and IPv6 address ranges for Exchange and everything to be supported (includes CDNs and other, even external, services); this example includes URLs for the tenant with the Name 'contoso'.
      The Tenant based URLs are generated and not checked, so please make sure you use the correct name! !
      It just dumps the URLs in a comma separated (CSV) format. Useful for Proxy Servers.
      The SkipVersionCheck Switch enforce the Download, without checking the local version.

      .EXAMPLE
      PS C:\> (((Get-Office365Endpoints.ps1 -Instance Worldwide -Services Exchange -Output IPv4) | Where-Object -FilterScript {$PSItem.tcpPorts -eq '587'}).ip | Sort-Object -Unique) -join "," | Out-String
		
      It gets the International (Worldwide) Office 365 IPv4 addresses for Exchange Submission (SMTP) Servers who use Port 587. It dumps a comma separated (CSV) format. Useful for Firewalls.
	
      .EXAMPLE
      PS C:\> (((Get-Office365Endpoints.ps1 -Instance Worldwide -Services Exchange -Output IPv6) | Where-Object -FilterScript {$PSItem.tcpPorts -eq '25'}).ip | Sort-Object -Unique) -join "," | Out-String
		
      It gets the International (Worldwide) Office 365 IPv4 addresses for Exchange SMTP Servers who use Port 25. It dumps a comma separated (CSV) format. Useful for Firewalls.
	
      .EXAMPLE
      PS C:\> (((Get-Office365Endpoints.ps1 -Instance Worldwide -Services Exchange -Output URLs) | Where-Object -FilterScript {$PSItem.notes -like '*Exchange Hybrid Configuration Wizard*' }).url | Sort-Object -Unique) -join "," | Out-String
		
      Get a List of Exchange Online URLs that you might need if you want to run the Exchange Hybrid Configuration Wizard.
	
      .EXAMPLE
      PS C:\> ((Get-Office365Endpoints.ps1 -Instance Worldwide -Output 'IPv4' -ExpressRoute).ip | Sort-Object -Unique) -join "," | Out-String
		
      Get a List of IPv4 addresses for ExpressRoute configuration.
	
      .EXAMPLE
      PS C:\> ((Get-Office365Endpoints.ps1 -Instance Worldwide -Output 'IPv6' -ExpressRoute).ip | Sort-Object -Unique) -join "," | Out-String
		
      Get a List of IPv6 addresses for ExpressRoute configuration. Please note: IPv6 is not supported with ExpressRoute in every Instance, (example: Germany)
	
      .EXAMPLE
      PS C:\> ((Get-Office365Endpoints.ps1 -Instance Worldwide -NoIPv6).ip | Sort-Object -Unique) -join "," | Out-String
		
      Get a list of IP addreses and exclude IPv6. The benefit of this parameter is the NoIPv6 parameter: The call will exclude the IPv6 Data from the response, and that might be smarter than filter it. It might be handy if you do NOT use IPv6 within your network - If this is the case, you might miss the future of networking! Think about that, before ignoring IPv6.
	
      .EXAMPLE
      $ExchangeOnlineSMTPEndpoints = (Get-Office365Endpoints.ps1 -Services Exchange) | Where-Object -FilterScript {
      $PSItem.ip -and
      $PSItem.DisplayName -eq 'Exchange Online' -and
      $PSItem.tcpPorts -contains '25'
      }
      $ExchangeOnlineSMTPEndpoints.ip
		
      Retrieve endpoints for Exchange Online and filter on TCP port 25
      This is based on the following idea: http://www.powershell.no/exchange/online,office/365,powershell/2018/08/26/automate-office365-ip-address-handling.html
	
      .NOTES
      Function that uses the new Microsoft Service. A few things are still missing or not rock solid.
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
  [CmdletBinding(ConfirmImpact = 'None')]
  [OutputType([psobject])]
  param
  (
    [Parameter(ValueFromPipeline,
    ValueFromPipelineByPropertyName)]
    [ValidateSet('Worldwide', 'USGovDoD', 'USGovGCCHigh', 'China', 'Germany', IgnoreCase = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $Instance = 'Worldwide',
    [Parameter(ValueFromPipeline)]
    [ValidateSet('All', 'Common', 'Exchange', 'SharePoint', 'Skype', IgnoreCase = $true)]
    [ValidateNotNullOrEmpty()]
    [Alias('ServiceAreas')]
    [string]
    $Services = 'All',
    [Parameter(ValueFromPipeline)]
    [Alias('TenantName')]
    [string]
    $Tenant = $null,
    [Parameter(ValueFromPipeline)]
    [switch]
    $NoIPv6,
    [Parameter(ValueFromPipeline)]
    [switch]
    $ExpressRoute,
    [ValidateSet('All', 'Optimize', 'Allow', 'Default', IgnoreCase = $true)]
    [string[]]
    $Category,
    [Parameter(ValueFromPipeline)]
    [switch]
    $Required,
    [Parameter(ValueFromPipeline)]
    [ValidateSet('All', 'IPv4', 'IPv6', 'URLs', IgnoreCase = $true)]
    [string]
    $Output = 'All',
    [Parameter(ValueFromPipeline,
    ValueFromPipelineByPropertyName)]
    [Alias('ForceDownload')]
    [switch]
    $SkipVersionCheck = $false
  )

  begin
  {
    #region MakeIPv6Plausible
    if (($NoIPv6) -and ($Output -eq 'IPv6'))
    {
      # This makes no sense, and we totally ignore to do it!
      Write-Error -Message 'The selected parameters make no sense; we cannot continue!' -ErrorAction Stop
		
      # We should never reach this point!
      break
    }
    #endregion MakeIPv6Plausible
	
    #region CategoryTweaker
    if ((! $Category) -or ($Category -eq 'All'))
    {
      Write-Verbose -Message 'We get all categories.'
		
      # Set to all
      $Category += 'Optimize', 'Allow', 'Default'
    }
    #endregion CategoryTweaker
	
    #region TweakOutputHandler
	
    <#
        TODO: Make a simpler solution for that!
    #>
    switch ($Output)
    {
      'All'
      {
        Write-Verbose -Message 'Dump all Infos (IPv4, IPv6, and URLs)'
			
        $outIPv4 = $true
        $outIPv6 = $true
        $outURLs = $true
      }
      'IPv4'
      {
        Write-Verbose -Message 'Dump IPv4 Infos'
			
        $outIPv4 = $true
        $outIPv6 = $false
        $outURLs = $false
      }
      'IPv6'
      {
        Write-Verbose -Message 'Dump IPv6 Infos'
			
        $outIPv4 = $false
        $outIPv6 = $true
        $outURLs = $false
      }
      'URLs'
      {
        Write-Verbose -Message 'Dump URLs Infos'
			
        $outIPv4 = $false
        $outIPv6 = $false
        $outURLs = $true
      }
    }
    #endregion TweakOutputHandler
	
    #region ConfigurationVariables
    # Webservice root URL
    $BaseURI = 'https://endpoints.office.com'
    Write-Verbose -Message ('We use {0} as Base URL' -f $BaseURI)
	
    # Path where client ID and latest version number will be stored
    <#
        TODO: Move the Location to a parameter
    #>
    $datapath = $Env:TEMP + '\O365_endpoints_' + $Instance + '_latestversion.txt'
	
    Write-Verbose -Message ('We save the Endpoint Version Information to {0}' -f $datapath)
    #endregion ConfigurationVariables
	
    #region LocalVersionChecker
    # fetch client ID and version if data file exists; otherwise create new file
    if (Test-Path -Path $datapath)
    {
      Write-Verbose -Message 'We get the information from Microsoft...'
		
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
      Write-Verbose -Message 'Old version information file exists, start to gather the Info!'
		
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
        break
      }
    }
    #endregion LocalVersionChecker
	
    #region RemoteVersionChecker
    # Call version method to check the latest version, and pull new data if version number is different
    try
    {
      # Splat the parameters
      $GetVersionParams = @{
        Uri           = ($BaseURI + '/version/' + $Instance + '?clientRequestId=' + $clientRequestId)
        Method        = 'Get'
        ErrorAction   = 'Stop'
        WarningAction = 'SilentlyContinue'
      }
		
      Write-Verbose -Message ('We use {0} as request URI.' -f ($GetVersionParams.Uri))
		
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
    #endregion RemoteVersionChecker
  }

  process
  {
    #region VersionCompare
    if (($SkipVersionCheck -eq $true) -or ($version.latest -gt $lastVersion))
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
        break
      }
      #endregion VersionCompare
		
      #region GetTheEndpoints
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
			
        if ($NoIPv6)
        {
          # Append to the URI - Exclude IPv6 addresses from the output
          $requestURI = ($requestURI + '&NoIPv6')
				
          Write-Verbose -Message 'IPv6 addresses are excluded from the output! IPv6 is the future, think about an adoption soon.'
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
      #endregion GetTheEndpoints
		
      #region FilterURLs
		
      if ($outURLs)
      {
        $flatUrls = $endpointSets | ForEach-Object -Process {
          $endpointSet = $PSItem
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
                url          = $PSItem
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
      #endregion FilterURLs
		
      #region FilterIPv4
      if ($outIPv4)
      {
        $flatIpv4 = $endpointSets | ForEach-Object -Process {
          $endpointSet = $PSItem
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
            $PSItem -like '*.*'
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
                ip           = $PSItem
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
      #endregion FilterIPv4
		
      #region FilterIPv6
      if ($outIPv6)
      {
        $flatIpv6 = $endpointSets | ForEach-Object -Process {
          $endpointSet = $PSItem
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
            $PSItem -like '*:*'
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
                ip           = $PSItem
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
      #endregion FilterIPv4
    }
  }

  end
  {
    if (($SkipVersionCheck -eq $true) -or ($version.latest -gt $lastVersion))
    {
      #region DumpIPv4
      if ($outIPv4)
      {
        Write-Verbose -Message 'Office 365 IPv4 IP Address Ranges'

        ($flatIpv4 | Sort-Object -Property id)
      }
      #endregion DumpIPv4
		
      #region DumpIPv6
      if ($outIPv6)
      {
        Write-Verbose -Message 'Office 365 IPv6 IP Address Ranges'

        ($flatIpv6 | Sort-Object -Property id)
      }
      #endregion DumpIPv6
		
      #region DumpURLs
      if ($outURLs)
      {
        Write-Verbose -Message 'Office 365 URLs'

        ($flatUrls | Sort-Object -Property id)
      }
      #endregion DumpURLs
    }
    else
    {
      #region DumpInfoNothing
      <#
          This 'else' loop is here as a placeholder in this script!
          We use this in the comemrcial version (function within the commercial module) 
      #>
		
      Write-Output -InputObject ('The {0} Office 365 endpoints are up-to-date' -f $Instance)
      #endregion DumpInfoNothing
    }
  }

  #region CHANGELOG
  <#
      CHANGELOG:
      0.8.6 - 2019.01-04:
      [CHANGE] Converted back to a function to make it easier for me (no more need to adopt between my sources)
      [ADD] Start to add regions

      0.8.5 - 2018-10-04:
      [FIX] Fix the Output to reflect the correct Instance name (PSMO365-48)
      [ADD] Add -SkipVersionCheck Switch to force the download. As request by @mikes-gh in #4 in GitHub (PSMO365-49)
      [FIX] Fix a view typos and errors

      0.8.4 - 2018-08-29:
      [ADD] Exchange Online Example added (Source http://www.powershell.no/exchange/online,office/365,powershell/2018/08/26/automate-office365-ip-address-handling.html)
      [CHANGE] Tweaks (after internal code review and refactoring)

      0.8.3 - 2018-08-20 - Unreleased:
      [ADD] We added a few more verbose outputs. Verbose Implementation us based upon request. (PSMO365-43)
      [CHANGE] Region name change

      0.8.2 - 2018-08-19:
      [ADD] Regions added to make the code more readable within code editors (PSMO365-47)
      [FIX] A few typos in the descriptions where fixed - No change to any code or logic

      0.8.1 - 2018-08-19:
      [FIX] Add missing OutputType (PSMO365-41)
      [CHANGE] datafile name tweaked (PSMO365-42)
      [ADD] Missing NoIPv6 switch function implemented (PSMO365-44)
      [ADD] New Example for NoIPv6 switch (PSMO365-45)
      [ADD] A few more links
      [ADD] Info about the datafile (PSMO365-42)
      [ADD] Embed a few things as comment - Due to the separation from the Module
      [ADD] This changelog within the code - Reflect the changes within the dedicated function (PSMO365-46)

      0.8.0 - 2018-08-18:
      [INIT] Intitial public release
  #>
  #endregion CHANGELOG

  #region LICENSE
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
      - If you disagree with any of the Terms, and any Conditions declared: Just delete it and build your own solution
  #>
  #endregion DISCLAIMER
}

# SIG # Begin signature block
# MIIZkAYJKoZIhvcNAQcCoIIZgTCCGX0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU4CsQdgywQ4QoC+gHqnqN2zSg
# dpagghTyMIID7jCCA1egAwIBAgIQfpPr+3zGTlnqS5p31Ab8OzANBgkqhkiG9w0B
# AQUFADCBizELMAkGA1UEBhMCWkExFTATBgNVBAgTDFdlc3Rlcm4gQ2FwZTEUMBIG
# A1UEBxMLRHVyYmFudmlsbGUxDzANBgNVBAoTBlRoYXd0ZTEdMBsGA1UECxMUVGhh
# d3RlIENlcnRpZmljYXRpb24xHzAdBgNVBAMTFlRoYXd0ZSBUaW1lc3RhbXBpbmcg
# Q0EwHhcNMTIxMjIxMDAwMDAwWhcNMjAxMjMwMjM1OTU5WjBeMQswCQYDVQQGEwJV
# UzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xMDAuBgNVBAMTJ1N5bWFu
# dGVjIFRpbWUgU3RhbXBpbmcgU2VydmljZXMgQ0EgLSBHMjCCASIwDQYJKoZIhvcN
# AQEBBQADggEPADCCAQoCggEBALGss0lUS5ccEgrYJXmRIlcqb9y4JsRDc2vCvy5Q
# WvsUwnaOQwElQ7Sh4kX06Ld7w3TMIte0lAAC903tv7S3RCRrzV9FO9FEzkMScxeC
# i2m0K8uZHqxyGyZNcR+xMd37UWECU6aq9UksBXhFpS+JzueZ5/6M4lc/PcaS3Er4
# ezPkeQr78HWIQZz/xQNRmarXbJ+TaYdlKYOFwmAUxMjJOxTawIHwHw103pIiq8r3
# +3R8J+b3Sht/p8OeLa6K6qbmqicWfWH3mHERvOJQoUvlXfrlDqcsn6plINPYlujI
# fKVOSET/GeJEB5IL12iEgF1qeGRFzWBGflTBE3zFefHJwXECAwEAAaOB+jCB9zAd
# BgNVHQ4EFgQUX5r1blzMzHSa1N197z/b7EyALt0wMgYIKwYBBQUHAQEEJjAkMCIG
# CCsGAQUFBzABhhZodHRwOi8vb2NzcC50aGF3dGUuY29tMBIGA1UdEwEB/wQIMAYB
# Af8CAQAwPwYDVR0fBDgwNjA0oDKgMIYuaHR0cDovL2NybC50aGF3dGUuY29tL1Ro
# YXd0ZVRpbWVzdGFtcGluZ0NBLmNybDATBgNVHSUEDDAKBggrBgEFBQcDCDAOBgNV
# HQ8BAf8EBAMCAQYwKAYDVR0RBCEwH6QdMBsxGTAXBgNVBAMTEFRpbWVTdGFtcC0y
# MDQ4LTEwDQYJKoZIhvcNAQEFBQADgYEAAwmbj3nvf1kwqu9otfrjCR27T4IGXTdf
# plKfFo3qHJIJRG71betYfDDo+WmNI3MLEm9Hqa45EfgqsZuwGsOO61mWAK3ODE2y
# 0DGmCFwqevzieh1XTKhlGOl5QGIllm7HxzdqgyEIjkHq3dlXPx13SYcqFgZepjhq
# IhKjURmDfrYwggSjMIIDi6ADAgECAhAOz/Q4yP6/NW4E2GqYGxpQMA0GCSqGSIb3
# DQEBBQUAMF4xCzAJBgNVBAYTAlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jwb3Jh
# dGlvbjEwMC4GA1UEAxMnU3ltYW50ZWMgVGltZSBTdGFtcGluZyBTZXJ2aWNlcyBD
# QSAtIEcyMB4XDTEyMTAxODAwMDAwMFoXDTIwMTIyOTIzNTk1OVowYjELMAkGA1UE
# BhMCVVMxHTAbBgNVBAoTFFN5bWFudGVjIENvcnBvcmF0aW9uMTQwMgYDVQQDEytT
# eW1hbnRlYyBUaW1lIFN0YW1waW5nIFNlcnZpY2VzIFNpZ25lciAtIEc0MIIBIjAN
# BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAomMLOUS4uyOnREm7Dv+h8GEKU5Ow
# mNutLA9KxW7/hjxTVQ8VzgQ/K/2plpbZvmF5C1vJTIZ25eBDSyKV7sIrQ8Gf2Gi0
# jkBP7oU4uRHFI/JkWPAVMm9OV6GuiKQC1yoezUvh3WPVF4kyW7BemVqonShQDhfu
# ltthO0VRHc8SVguSR/yrrvZmPUescHLnkudfzRC5xINklBm9JYDh6NIipdC6Anqh
# d5NbZcPuF3S8QYYq3AhMjJKMkS2ed0QfaNaodHfbDlsyi1aLM73ZY8hJnTrFxeoz
# C9Lxoxv0i77Zs1eLO94Ep3oisiSuLsdwxb5OgyYI+wu9qU+ZCOEQKHKqzQIDAQAB
# o4IBVzCCAVMwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAO
# BgNVHQ8BAf8EBAMCB4AwcwYIKwYBBQUHAQEEZzBlMCoGCCsGAQUFBzABhh5odHRw
# Oi8vdHMtb2NzcC53cy5zeW1hbnRlYy5jb20wNwYIKwYBBQUHMAKGK2h0dHA6Ly90
# cy1haWEud3Muc3ltYW50ZWMuY29tL3Rzcy1jYS1nMi5jZXIwPAYDVR0fBDUwMzAx
# oC+gLYYraHR0cDovL3RzLWNybC53cy5zeW1hbnRlYy5jb20vdHNzLWNhLWcyLmNy
# bDAoBgNVHREEITAfpB0wGzEZMBcGA1UEAxMQVGltZVN0YW1wLTIwNDgtMjAdBgNV
# HQ4EFgQURsZpow5KFB7VTNpSYxc/Xja8DeYwHwYDVR0jBBgwFoAUX5r1blzMzHSa
# 1N197z/b7EyALt0wDQYJKoZIhvcNAQEFBQADggEBAHg7tJEqAEzwj2IwN3ijhCcH
# bxiy3iXcoNSUA6qGTiWfmkADHN3O43nLIWgG2rYytG2/9CwmYzPkSWRtDebDZw73
# BaQ1bHyJFsbpst+y6d0gxnEPzZV03LZc3r03H0N45ni1zSgEIKOq8UvEiCmRDoDR
# EfzdXHZuT14ORUZBbg2w6jiasTraCXEQ/Bx5tIB7rGn0/Zy2DBYr8X9bCT2bW+IW
# yhOBbQAuOA2oKY8s4bL0WqkBrxWcLC9JG9siu8P+eJRRw4axgohd8D20UaF5Mysu
# e7ncIAkTcetqGVvP6KUwVyyJST+5z3/Jvz4iaGNTmr1pdKzFHTx/kuDDvBzYBHUw
# ggUvMIIEF6ADAgECAhUAnQ4BMcIRBgspeUy1JGs+Zi8ndqIwDQYJKoZIhvcNAQEL
# BQAwPzELMAkGA1UEBhMCR0IxETAPBgNVBAoTCEFzY2VydGlhMR0wGwYDVQQDExRB
# c2NlcnRpYSBQdWJsaWMgQ0EgMTAeFw0xOTAxMDQxNTMyMDdaFw0xOTAyMDQxNTMy
# MDdaMIGnMQswCQYDVQQGEwJERTEhMB8GCSqGSIb3DQEJARYSam9lcmdAaG9jaHdh
# bGQubmV0MQ8wDQYDVQQIEwZIZXNzZW4xEDAOBgNVBAcTB01haW50YWwxFzAVBgNV
# BAoTDkpvZXJnIEhvY2h3YWxkMSAwHgYDVQQLExdPcGVuIFNvdXJjZSBEZXZlbG9w
# bWVudDEXMBUGA1UEAxMOSm9lcmcgSG9jaHdhbGQwggEiMA0GCSqGSIb3DQEBAQUA
# A4IBDwAwggEKAoIBAQDL56sSkECHDR6kKznKhvCb3+cO8K5+YJdXG7kZzkKcnsOi
# o803+a3PkO/zFNH9Cuq+Oc/1wRkeoePaaLvk9VrXQ4NBjxx69ZO/RY+EHSOZ6z3e
# CFb8mgzLNf1Z4qwgWV91GF1IPa4VnilDSwsW98axQ+lkOXqLu18qhT1SPP8xZp/5
# mG2ctD3HA7p6miyCXkFBBIlg6HdnPn/Acxq9T7v9GpYV4+jznt2Are+YJV9J6Sl3
# qKchjlNIektENOJV6nkmeZJ9PJj6sOjAFtAPlFJgoG1Fw1++GooNyC37nuqWOKlC
# Kvp8br0F2ixWjs2S1Oun/w+06JnX4/0ZZhTd7dSfAgMBAAGjggG3MIIBszAOBgNV
# HQ8BAf8EBAMCBsAwDAYDVR0TAQH/BAIwADA9BggrBgEFBQcBAQQxMC8wLQYIKwYB
# BQUHMAGGIWh0dHA6Ly9vY3NwLmdsb2JhbHRydXN0ZmluZGVyLmNvbTCB8AYDVR0g
# BIHoMIHlMIHiBgorBgEEAfxJAQEBMIHTMIHQBggrBgEFBQcCAjCBwwyBwFdhcm5p
# bmc6IENlcnRpZmljYXRlcyBhcmUgaXNzdWVkIHVuZGVyIHRoaXMgcG9saWN5IHRv
# IGluZGl2aWR1YWxzIHRoYXQgaGF2ZSBub3QgaGFkIHRoZWlyIGlkZW50aXR5IGNv
# bmZpcm1lZC4gRG8gbm90IHVzZSB0aGVzZSBjZXJ0aWZpY2F0ZXMgZm9yIHZhbHVh
# YmxlIHRyYW5zYWN0aW9ucy4gTk8gTElBQklMSVRZIElTIEFDQ0VQVEVELjBMBgNV
# HR8ERTBDMEGgP6A9hjtodHRwOi8vd3d3Lmdsb2JhbHRydXN0ZmluZGVyLmNvbS9j
# cmxzL0FzY2VydGlhUHVibGljQ0ExLmNybDATBgNVHSUEDDAKBggrBgEFBQcDAzAN
# BgkqhkiG9w0BAQsFAAOCAQEAjEZHO2pV991j3XGZSvg/jUd1JFf2UAnCeW7sxIvI
# k7AVPs6ynKkUIdJ5yC4kqgNXks3q84pwaCmjxPVbmg6wZV/EtVIbbX4zoNW7UVBU
# l3IyeCqKxaPTnCToVnZbod0S99qwV5OYKPFGmPuunqSQ6G4ulTFvHoY5rHd5jI75
# VmemN1lW6FlidJjohH6biM+OM3p1LwcYtvitPWSP4cvsFvtFKhp3rvKUiiPByE+q
# mx9tNuS1ypgxRftndCwmaqnXjzbeZRoNpD1G7Rrch4WepV6FhK173qBfwA+8t8Kr
# B0W4h716Ejk7RkyQk7hawO2GBLDqa2qbXLkiHPsa7W7x1DCCByIwggYKoAMCAQIC
# AgDmMA0GCSqGSIb3DQEBBQUAMD0xCzAJBgNVBAYTAkdCMREwDwYDVQQKEwhBc2Nl
# cnRpYTEbMBkGA1UEAxMSQXNjZXJ0aWEgUm9vdCBDQSAyMB4XDTA5MDQyMTEyMTUx
# N1oXDTI4MDQxNDIzNTk1OVowPzELMAkGA1UEBhMCR0IxETAPBgNVBAoTCEFzY2Vy
# dGlhMR0wGwYDVQQDExRBc2NlcnRpYSBQdWJsaWMgQ0EgMTCCASIwDQYJKoZIhvcN
# AQEBBQADggEPADCCAQoCggEBAM9Y8jPEs9kd+U8R27jjtta8pyE3Vy57qQyUs8sS
# 8EdaziFwXhODnD7Mo/6evVPW2DBkP4puXcQbUrAR9dkI0E72BE/+/yRyXw2stKp8
# NPjbClgmazS7rGk0KMzxhWuSF5CV3p+L8d+jitUQSFZ4cTleNJ1ou5qzCfP9ZA4n
# XYieOs7E527x+/IdUe3rh9bTucEwj42nyc1dD+t+fwSbX0bGB7M/zbqVsVf0m2/m
# tIoYZSrgD0AADkRwwH74Bnq1ajMX9JsxGTVEvRsGOfqWaeeiVZRp3yGNwdEJ9p7r
# mKZzIKHVmXcIIrn86R2z6Fnw0hBwmikOLc7sRDhzF3JBN2UCAwEAAaOCBCgwggQk
# MA4GA1UdDwEB/wQEAwIBBjASBgNVHRMBAf8ECDAGAQH/AgECMIHwBgNVHSAEgegw
# geUwgeIGCisGAQQB/EkBAQEwgdMwgdAGCCsGAQUFBwICMIHDGoHAV2FybmluZzog
# Q2VydGlmaWNhdGVzIGFyZSBpc3N1ZWQgdW5kZXIgdGhpcyBwb2xpY3kgdG8gaW5k
# aXZpZHVhbHMgdGhhdCBoYXZlIG5vdCBoYWQgdGhlaXIgaWRlbnRpdHkgY29uZmly
# bWVkLiBEbyBub3QgdXNlIHRoZXNlIGNlcnRpZmljYXRlcyBmb3IgdmFsdWFibGUg
# dHJhbnNhY3Rpb25zLiBOTyBMSUFCSUxJVFkgSVMgQUNDRVBURUQuMIIBMwYDVR0O
# BIIBKgSCASYwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDPWPIzxLPZ
# HflPEdu447bWvKchN1cue6kMlLPLEvBHWs4hcF4Tg5w+zKP+nr1T1tgwZD+Kbl3E
# G1KwEfXZCNBO9gRP/v8kcl8NrLSqfDT42wpYJms0u6xpNCjM8YVrkheQld6fi/Hf
# o4rVEEhWeHE5XjSdaLuaswnz/WQOJ12InjrOxOdu8fvyHVHt64fW07nBMI+Np8nN
# XQ/rfn8Em19GxgezP826lbFX9Jtv5rSKGGUq4A9AAA5EcMB++AZ6tWozF/SbMRk1
# RL0bBjn6lmnnolWUad8hjcHRCfae65imcyCh1Zl3CCK5/Okds+hZ8NIQcJopDi3O
# 7EQ4cxdyQTdlAgMBAAEwWgYDVR0fBFMwUTBPoE2gS4ZJaHR0cDovL3d3dy5hc2Nl
# cnRpYS5jb20vT25saW5lQ0EvY3Jscy9Bc2NlcnRpYVJvb3RDQTIvQXNjZXJ0aWFS
# b290Q0EyLmNybDA9BggrBgEFBQcBAQQxMC8wLQYIKwYBBQUHMAGGIWh0dHA6Ly9v
# Y3NwLmdsb2JhbHRydXN0ZmluZGVyLmNvbTCCATcGA1UdIwSCAS4wggEqgIIBJjCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAJY3vp7g2T6mhhMX9krzqQfz
# FmjVf0QWR/Mhn3385P+k9Au+zfTCBgPi7KFEFMWQoZ/R0fceMrPU31IUm53R6pvG
# 0fdg+vytSMeTGOtffgvEIVYE2iPhPcXDcsadOkZ47rERoQMB290iebcEm+kbhVYR
# LdntIm15ohuQ2aoOfQOFGkwVeI0qBko1YhwkzVkZb345k7u/FRms48F9x6mVaDvR
# OitzxMFgvs+/X+DqS5kI7sPHWcXpqCL0YIgdGQytyOC4iqSDypIv4pbHBa4qLxgc
# EbiLu8iC8c4ovaWeZ2h7rdZEAb3BQdvrx27AFzW0gA+pqb3QxCszKFMbOHAjtoMC
# AwEAATANBgkqhkiG9w0BAQUFAAOCAQEAlJSXoaMTmbqGSlyLZYs+gkysb3RMAtuK
# AZlLXNNguwjBTF/HRWd2FH9hTt1RB/m8U+HNB/2bCb2+J1P1bB3paDSGYOJPwuHn
# LtPhfKqO4wo3dynt4MWStIJSG9PwuDaf+rF54kwPeCG0WGjJe0jkD/oKY8cGRw0y
# 1BkCE5EqOknjXBJr68fq/VPMLyi3D7G7GDICQ7+FGaaYEiAYO7DEp8ut0FBFlZ4F
# GZaofuCtCUTSBhikEVLgWWivAGqOIgOnoUfnY6stL2AtXZ/V6bExACXCHcswGbC9
# S1NCz77wzyhfYSldkIgd6g4QUQxvOYS/gjzzKigcnFxMvTbq9yX/UjGCBAgwggQE
# AgEBMFgwPzELMAkGA1UEBhMCR0IxETAPBgNVBAoTCEFzY2VydGlhMR0wGwYDVQQD
# ExRBc2NlcnRpYSBQdWJsaWMgQ0EgMQIVAJ0OATHCEQYLKXlMtSRrPmYvJ3aiMAkG
# BSsOAwIaBQCgeDAYBgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJ
# AzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMG
# CSqGSIb3DQEJBDEWBBT0SSHnTbKZyokO98Wewl2oCekyZjANBgkqhkiG9w0BAQEF
# AASCAQCqQ2ycIlKnx0WeapuIeAYEdNzDbAAXL1Q6XMW3PqbbtUDprvzlyV08hJFu
# mVBVSUJSTUk+BgdIy/Nc7shqcKscQm9DfPWWPIA90bF24Yfq5McAexoWCMKF7L0l
# r1a0jsM1lGFC8YrKgH+liqMzTaEfnneUKrbhZhwJfCyO/e9+pX3d4j8Q2dH0yIOd
# xav+X4lzAV/7gyvcUQGJCN2PxJihVaSHO+qC8zI6agp2eSdOQEkEIDt7G6xIlWTv
# dDtSyP2LGUXwDuanv/GCDHgkMLf5F4BBDZa4h8Bh+Qntlqe9hCvwl1N5fPxixRuo
# P4KzheumfLx08AFidskBCDiEn0vloYICCzCCAgcGCSqGSIb3DQEJBjGCAfgwggH0
# AgEBMHIwXjELMAkGA1UEBhMCVVMxHTAbBgNVBAoTFFN5bWFudGVjIENvcnBvcmF0
# aW9uMTAwLgYDVQQDEydTeW1hbnRlYyBUaW1lIFN0YW1waW5nIFNlcnZpY2VzIENB
# IC0gRzICEA7P9DjI/r81bgTYapgbGlAwCQYFKw4DAhoFAKBdMBgGCSqGSIb3DQEJ
# AzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE5MDEwNDE2MDEzMFowIwYJ
# KoZIhvcNAQkEMRYEFDW4MYVvgwrS4TfsyB8JD37uMXngMA0GCSqGSIb3DQEBAQUA
# BIIBAHytWwh6Fb0vkO/oDQs3U/O9dEadlUtwAElRUV+UeDCaZkk3+qZf0fst4rVa
# 6WqRxwVdpQ+jkHnH3e8mFEmTpzaB1hJ4e5LUer/+nSOrlL4Vj4CXEaBp5MyiDkW4
# koVdE/Qs2fXCcasSLjwRRYlJph2V1s+dZ8GENG0iyyNs33y3HgO2+SRFqxtL1sWT
# sqA+NsXCm6FrkTTgm7W50HFdS6AdbKYEeYIPrWdUh5dmfoxPLA4yOJ0K3CFrx+hO
# BmcGeXaJ+8X0dGQooJX1uSJy9fIh0/78KR8F8vUq2q0O1GqQn/Y4LWf5knq/7jcO
# T8Z1YDkMLHVOhnWngnLEvqsDTJ4=
# SIG # End signature block
