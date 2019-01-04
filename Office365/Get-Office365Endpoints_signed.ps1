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
# MIIO6AYJKoZIhvcNAQcCoIIO2TCCDtUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU4CsQdgywQ4QoC+gHqnqN2zSg
# dpagggxZMIIFLzCCBBegAwIBAgIVAJ0OATHCEQYLKXlMtSRrPmYvJ3aiMA0GCSqG
# SIb3DQEBCwUAMD8xCzAJBgNVBAYTAkdCMREwDwYDVQQKEwhBc2NlcnRpYTEdMBsG
# A1UEAxMUQXNjZXJ0aWEgUHVibGljIENBIDEwHhcNMTkwMTA0MTUzMjA3WhcNMTkw
# MjA0MTUzMjA3WjCBpzELMAkGA1UEBhMCREUxITAfBgkqhkiG9w0BCQEWEmpvZXJn
# QGhvY2h3YWxkLm5ldDEPMA0GA1UECBMGSGVzc2VuMRAwDgYDVQQHEwdNYWludGFs
# MRcwFQYDVQQKEw5Kb2VyZyBIb2Nod2FsZDEgMB4GA1UECxMXT3BlbiBTb3VyY2Ug
# RGV2ZWxvcG1lbnQxFzAVBgNVBAMTDkpvZXJnIEhvY2h3YWxkMIIBIjANBgkqhkiG
# 9w0BAQEFAAOCAQ8AMIIBCgKCAQEAy+erEpBAhw0epCs5yobwm9/nDvCufmCXVxu5
# Gc5CnJ7DoqPNN/mtz5Dv8xTR/QrqvjnP9cEZHqHj2mi75PVa10ODQY8cevWTv0WP
# hB0jmes93ghW/JoMyzX9WeKsIFlfdRhdSD2uFZ4pQ0sLFvfGsUPpZDl6i7tfKoU9
# Ujz/MWaf+ZhtnLQ9xwO6eposgl5BQQSJYOh3Zz5/wHMavU+7/RqWFePo857dgK3v
# mCVfSekpd6inIY5TSHpLRDTiVep5JnmSfTyY+rDowBbQD5RSYKBtRcNfvhqKDcgt
# +57qljipQir6fG69BdosVo7NktTrp/8PtOiZ1+P9GWYU3e3UnwIDAQABo4IBtzCC
# AbMwDgYDVR0PAQH/BAQDAgbAMAwGA1UdEwEB/wQCMAAwPQYIKwYBBQUHAQEEMTAv
# MC0GCCsGAQUFBzABhiFodHRwOi8vb2NzcC5nbG9iYWx0cnVzdGZpbmRlci5jb20w
# gfAGA1UdIASB6DCB5TCB4gYKKwYBBAH8SQEBATCB0zCB0AYIKwYBBQUHAgIwgcMM
# gcBXYXJuaW5nOiBDZXJ0aWZpY2F0ZXMgYXJlIGlzc3VlZCB1bmRlciB0aGlzIHBv
# bGljeSB0byBpbmRpdmlkdWFscyB0aGF0IGhhdmUgbm90IGhhZCB0aGVpciBpZGVu
# dGl0eSBjb25maXJtZWQuIERvIG5vdCB1c2UgdGhlc2UgY2VydGlmaWNhdGVzIGZv
# ciB2YWx1YWJsZSB0cmFuc2FjdGlvbnMuIE5PIExJQUJJTElUWSBJUyBBQ0NFUFRF
# RC4wTAYDVR0fBEUwQzBBoD+gPYY7aHR0cDovL3d3dy5nbG9iYWx0cnVzdGZpbmRl
# ci5jb20vY3Jscy9Bc2NlcnRpYVB1YmxpY0NBMS5jcmwwEwYDVR0lBAwwCgYIKwYB
# BQUHAwMwDQYJKoZIhvcNAQELBQADggEBAIxGRztqVffdY91xmUr4P41HdSRX9lAJ
# wnlu7MSLyJOwFT7OspypFCHSecguJKoDV5LN6vOKcGgpo8T1W5oOsGVfxLVSG21+
# M6DVu1FQVJdyMngqisWj05wk6FZ2W6HdEvfasFeTmCjxRpj7rp6kkOhuLpUxbx6G
# Oax3eYyO+VZnpjdZVuhZYnSY6IR+m4jPjjN6dS8HGLb4rT1kj+HL7Bb7RSoad67y
# lIojwchPqpsfbTbktcqYMUX7Z3QsJmqp14823mUaDaQ9Ru0a3IeFnqVehYSte96g
# X8APvLfCqwdFuIe9ehI5O0ZMkJO4WsDthgSw6mtqm1y5Ihz7Gu1u8dQwggciMIIG
# CqADAgECAgIA5jANBgkqhkiG9w0BAQUFADA9MQswCQYDVQQGEwJHQjERMA8GA1UE
# ChMIQXNjZXJ0aWExGzAZBgNVBAMTEkFzY2VydGlhIFJvb3QgQ0EgMjAeFw0wOTA0
# MjExMjE1MTdaFw0yODA0MTQyMzU5NTlaMD8xCzAJBgNVBAYTAkdCMREwDwYDVQQK
# EwhBc2NlcnRpYTEdMBsGA1UEAxMUQXNjZXJ0aWEgUHVibGljIENBIDEwggEiMA0G
# CSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDPWPIzxLPZHflPEdu447bWvKchN1cu
# e6kMlLPLEvBHWs4hcF4Tg5w+zKP+nr1T1tgwZD+Kbl3EG1KwEfXZCNBO9gRP/v8k
# cl8NrLSqfDT42wpYJms0u6xpNCjM8YVrkheQld6fi/Hfo4rVEEhWeHE5XjSdaLua
# swnz/WQOJ12InjrOxOdu8fvyHVHt64fW07nBMI+Np8nNXQ/rfn8Em19GxgezP826
# lbFX9Jtv5rSKGGUq4A9AAA5EcMB++AZ6tWozF/SbMRk1RL0bBjn6lmnnolWUad8h
# jcHRCfae65imcyCh1Zl3CCK5/Okds+hZ8NIQcJopDi3O7EQ4cxdyQTdlAgMBAAGj
# ggQoMIIEJDAOBgNVHQ8BAf8EBAMCAQYwEgYDVR0TAQH/BAgwBgEB/wIBAjCB8AYD
# VR0gBIHoMIHlMIHiBgorBgEEAfxJAQEBMIHTMIHQBggrBgEFBQcCAjCBwxqBwFdh
# cm5pbmc6IENlcnRpZmljYXRlcyBhcmUgaXNzdWVkIHVuZGVyIHRoaXMgcG9saWN5
# IHRvIGluZGl2aWR1YWxzIHRoYXQgaGF2ZSBub3QgaGFkIHRoZWlyIGlkZW50aXR5
# IGNvbmZpcm1lZC4gRG8gbm90IHVzZSB0aGVzZSBjZXJ0aWZpY2F0ZXMgZm9yIHZh
# bHVhYmxlIHRyYW5zYWN0aW9ucy4gTk8gTElBQklMSVRZIElTIEFDQ0VQVEVELjCC
# ATMGA1UdDgSCASoEggEmMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA
# z1jyM8Sz2R35TxHbuOO21rynITdXLnupDJSzyxLwR1rOIXBeE4OcPsyj/p69U9bY
# MGQ/im5dxBtSsBH12QjQTvYET/7/JHJfDay0qnw0+NsKWCZrNLusaTQozPGFa5IX
# kJXen4vx36OK1RBIVnhxOV40nWi7mrMJ8/1kDiddiJ46zsTnbvH78h1R7euH1tO5
# wTCPjafJzV0P635/BJtfRsYHsz/NupWxV/Sbb+a0ihhlKuAPQAAORHDAfvgGerVq
# Mxf0mzEZNUS9GwY5+pZp56JVlGnfIY3B0Qn2nuuYpnMgodWZdwgiufzpHbPoWfDS
# EHCaKQ4tzuxEOHMXckE3ZQIDAQABMFoGA1UdHwRTMFEwT6BNoEuGSWh0dHA6Ly93
# d3cuYXNjZXJ0aWEuY29tL09ubGluZUNBL2NybHMvQXNjZXJ0aWFSb290Q0EyL0Fz
# Y2VydGlhUm9vdENBMi5jcmwwPQYIKwYBBQUHAQEEMTAvMC0GCCsGAQUFBzABhiFo
# dHRwOi8vb2NzcC5nbG9iYWx0cnVzdGZpbmRlci5jb20wggE3BgNVHSMEggEuMIIB
# KoCCASYwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCWN76e4Nk+poYT
# F/ZK86kH8xZo1X9EFkfzIZ99/OT/pPQLvs30wgYD4uyhRBTFkKGf0dH3HjKz1N9S
# FJud0eqbxtH3YPr8rUjHkxjrX34LxCFWBNoj4T3Fw3LGnTpGeO6xEaEDAdvdInm3
# BJvpG4VWES3Z7SJteaIbkNmqDn0DhRpMFXiNKgZKNWIcJM1ZGW9+OZO7vxUZrOPB
# fceplWg70Torc8TBYL7Pv1/g6kuZCO7Dx1nF6agi9GCIHRkMrcjguIqkg8qSL+KW
# xwWuKi8YHBG4i7vIgvHOKL2lnmdoe63WRAG9wUHb68duwBc1tIAPqam90MQrMyhT
# GzhwI7aDAgMBAAEwDQYJKoZIhvcNAQEFBQADggEBAJSUl6GjE5m6hkpci2WLPoJM
# rG90TALbigGZS1zTYLsIwUxfx0VndhR/YU7dUQf5vFPhzQf9mwm9vidT9Wwd6Wg0
# hmDiT8Lh5y7T4XyqjuMKN3cp7eDFkrSCUhvT8Lg2n/qxeeJMD3ghtFhoyXtI5A/6
# CmPHBkcNMtQZAhORKjpJ41wSa+vH6v1TzC8otw+xuxgyAkO/hRmmmBIgGDuwxKfL
# rdBQRZWeBRmWqH7grQlE0gYYpBFS4FlorwBqjiIDp6FH52OrLS9gLV2f1emxMQAl
# wh3LMBmwvUtTQs++8M8oX2EpXZCIHeoOEFEMbzmEv4I88yooHJxcTL026vcl/1Ix
# ggH5MIIB9QIBATBYMD8xCzAJBgNVBAYTAkdCMREwDwYDVQQKEwhBc2NlcnRpYTEd
# MBsGA1UEAxMUQXNjZXJ0aWEgUHVibGljIENBIDECFQCdDgExwhEGCyl5TLUkaz5m
# Lyd2ojAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkq
# hkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGC
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU9Ekh502ymcqJDvfFnsJdqAnpMmYwDQYJKoZI
# hvcNAQEBBQAEggEAqkNsnCJSp8dFnmqbiHgGBHTcw2wAFy9UOlzFtz6m27VA6a78
# 5cldPISRbplQVUlCUk1JPgYHSMvzXO7IanCrHEJvQ3z1ljyAPdGxduGH6uTHAHsa
# FgjChey9Ja9WtI7DNZRhQvGKyoB/pYqjM02hH553lCq24WYcCXwsjv3vfqV93eI/
# ENnR9MiDncWr/l+JcwFf+4Mr3FEBiQjdj8SYoVWkhzvqgvMyOmoKdnknTkBJBCA7
# exusSJVk73Q7Usj9ixlF8A7mp7/xggx4JDC3+ReAQQ2WuIfAYfkJ7ZanvYQr8JdT
# eXz8YsUbqD+Cs4Xrpny8dPABYnbJAQg4hJ9L5Q==
# SIG # End signature block
