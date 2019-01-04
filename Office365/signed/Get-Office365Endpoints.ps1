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
# MIIjzQYJKoZIhvcNAQcCoIIjvjCCI7oCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU4CsQdgywQ4QoC+gHqnqN2zSg
# dpaggh8rMIIFLzCCBBegAwIBAgIVAJ0OATHCEQYLKXlMtSRrPmYvJ3aiMA0GCSqG
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
# X8APvLfCqwdFuIe9ehI5O0ZMkJO4WsDthgSw6mtqm1y5Ihz7Gu1u8dQwggWPMIIE
# d6ADAgECAgIA5TANBgkqhkiG9w0BAQUFADA9MQswCQYDVQQGEwJHQjERMA8GA1UE
# ChMIQXNjZXJ0aWExGzAZBgNVBAMTEkFzY2VydGlhIFJvb3QgQ0EgMjAeFw0wOTA0
# MTcxMzIyMzVaFw0yOTAzMTUxMjU5NTlaMD0xCzAJBgNVBAYTAkdCMREwDwYDVQQK
# EwhBc2NlcnRpYTEbMBkGA1UEAxMSQXNjZXJ0aWEgUm9vdCBDQSAyMIIBIjANBgkq
# hkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAlje+nuDZPqaGExf2SvOpB/MWaNV/RBZH
# 8yGfffzk/6T0C77N9MIGA+LsoUQUxZChn9HR9x4ys9TfUhSbndHqm8bR92D6/K1I
# x5MY619+C8QhVgTaI+E9xcNyxp06RnjusRGhAwHb3SJ5twSb6RuFVhEt2e0ibXmi
# G5DZqg59A4UaTBV4jSoGSjViHCTNWRlvfjmTu78VGazjwX3HqZVoO9E6K3PEwWC+
# z79f4OpLmQjuw8dZxemoIvRgiB0ZDK3I4LiKpIPKki/ilscFriovGBwRuIu7yILx
# zii9pZ5naHut1kQBvcFB2+vHbsAXNbSAD6mpvdDEKzMoUxs4cCO2gwIDAQABo4IC
# lzCCApMwDgYDVR0PAQH/BAQDAgEGMA8GA1UdEwEB/wQFMAMBAf8wggEzBgNVHQ4E
# ggEqBIIBJjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAJY3vp7g2T6m
# hhMX9krzqQfzFmjVf0QWR/Mhn3385P+k9Au+zfTCBgPi7KFEFMWQoZ/R0fceMrPU
# 31IUm53R6pvG0fdg+vytSMeTGOtffgvEIVYE2iPhPcXDcsadOkZ47rERoQMB290i
# ebcEm+kbhVYRLdntIm15ohuQ2aoOfQOFGkwVeI0qBko1YhwkzVkZb345k7u/FRms
# 48F9x6mVaDvROitzxMFgvs+/X+DqS5kI7sPHWcXpqCL0YIgdGQytyOC4iqSDypIv
# 4pbHBa4qLxgcEbiLu8iC8c4ovaWeZ2h7rdZEAb3BQdvrx27AFzW0gA+pqb3QxCsz
# KFMbOHAjtoMCAwEAATCCATcGA1UdIwSCAS4wggEqgIIBJjCCASIwDQYJKoZIhvcN
# AQEBBQADggEPADCCAQoCggEBAJY3vp7g2T6mhhMX9krzqQfzFmjVf0QWR/Mhn338
# 5P+k9Au+zfTCBgPi7KFEFMWQoZ/R0fceMrPU31IUm53R6pvG0fdg+vytSMeTGOtf
# fgvEIVYE2iPhPcXDcsadOkZ47rERoQMB290iebcEm+kbhVYRLdntIm15ohuQ2aoO
# fQOFGkwVeI0qBko1YhwkzVkZb345k7u/FRms48F9x6mVaDvROitzxMFgvs+/X+Dq
# S5kI7sPHWcXpqCL0YIgdGQytyOC4iqSDypIv4pbHBa4qLxgcEbiLu8iC8c4ovaWe
# Z2h7rdZEAb3BQdvrx27AFzW0gA+pqb3QxCszKFMbOHAjtoMCAwEAATANBgkqhkiG
# 9w0BAQUFAAOCAQEAAVsprh7rRtV3De9pJytO4jlHvWlPXEtAtOsUZf60zEPPn2xx
# PkCn5bv/M+nM/I5lNl54gOT0FNbZK7dowkEvy83zn2fo1N5IK/OkNmmuDFITQMls
# 7Pt0ODRcLDlb/u0YTPRMhOG1bnisazG7oDMTZOEtUfFaCRCN4ZvjrqmWOJrESoWu
# xALt41CLGLIq1q8m4lKrcKo1mNq10gjVnNlpzzLNYDm6WtJUoTNU1wAOBCxqBd5l
# S6qyf56d6cqZD/S9rWTtiXXza+F+F+Ukbq+dvbiaspHXOauRw0oizYmHC68rDtEv
# x99cm/EGUkjgWLBZVUo/f0ilKq4bFAuaBHP4KzCCBmowggVSoAMCAQICEAMBmgI6
# /1ixa9bV6uYX8GYwDQYJKoZIhvcNAQEFBQAwYjELMAkGA1UEBhMCVVMxFTATBgNV
# BAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEhMB8G
# A1UEAxMYRGlnaUNlcnQgQXNzdXJlZCBJRCBDQS0xMB4XDTE0MTAyMjAwMDAwMFoX
# DTI0MTAyMjAwMDAwMFowRzELMAkGA1UEBhMCVVMxETAPBgNVBAoTCERpZ2lDZXJ0
# MSUwIwYDVQQDExxEaWdpQ2VydCBUaW1lc3RhbXAgUmVzcG9uZGVyMIIBIjANBgkq
# hkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAo2Rd/Hyz4II14OD2xirmSXU7zG7gU6mf
# H2RZ5nxrf2uMnVX4kuOe1VpjWwJJUNmDzm9m7t3LhelfpfnUh3SIRDsZyeX1kZ/G
# FDmsJOqoSyyRicxeKPRktlC39RKzc5YKZ6O+YZ+u8/0SeHUOplsU/UUjjoZEVX0Y
# hgWMVYd5SEb3yg6Np95OX+Koti1ZAmGIYXIYaLm4fO7m5zQvMXeBMB+7NgGN7yfj
# 95rwTDFkjePr+hmHqH7P7IwMNlt6wXq4eMfJBi5GEMiN6ARg27xzdPpO2P6qQPGy
# znBGg+naQKFZOtkVCVeZVjCT88lhzNAIzGvsYkKRrALA76TwiRGPdwIDAQABo4ID
# NTCCAzEwDgYDVR0PAQH/BAQDAgeAMAwGA1UdEwEB/wQCMAAwFgYDVR0lAQH/BAww
# CgYIKwYBBQUHAwgwggG/BgNVHSAEggG2MIIBsjCCAaEGCWCGSAGG/WwHATCCAZIw
# KAYIKwYBBQUHAgEWHGh0dHBzOi8vd3d3LmRpZ2ljZXJ0LmNvbS9DUFMwggFkBggr
# BgEFBQcCAjCCAVYeggFSAEEAbgB5ACAAdQBzAGUAIABvAGYAIAB0AGgAaQBzACAA
# QwBlAHIAdABpAGYAaQBjAGEAdABlACAAYwBvAG4AcwB0AGkAdAB1AHQAZQBzACAA
# YQBjAGMAZQBwAHQAYQBuAGMAZQAgAG8AZgAgAHQAaABlACAARABpAGcAaQBDAGUA
# cgB0ACAAQwBQAC8AQwBQAFMAIABhAG4AZAAgAHQAaABlACAAUgBlAGwAeQBpAG4A
# ZwAgAFAAYQByAHQAeQAgAEEAZwByAGUAZQBtAGUAbgB0ACAAdwBoAGkAYwBoACAA
# bABpAG0AaQB0ACAAbABpAGEAYgBpAGwAaQB0AHkAIABhAG4AZAAgAGEAcgBlACAA
# aQBuAGMAbwByAHAAbwByAGEAdABlAGQAIABoAGUAcgBlAGkAbgAgAGIAeQAgAHIA
# ZQBmAGUAcgBlAG4AYwBlAC4wCwYJYIZIAYb9bAMVMB8GA1UdIwQYMBaAFBUAEisT
# mLKZB+0e36K+Vw0rZwLNMB0GA1UdDgQWBBRhWk0ktkkynUoqeRqDS/QeicHKfTB9
# BgNVHR8EdjB0MDigNqA0hjJodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNl
# cnRBc3N1cmVkSURDQS0xLmNybDA4oDagNIYyaHR0cDovL2NybDQuZGlnaWNlcnQu
# Y29tL0RpZ2lDZXJ0QXNzdXJlZElEQ0EtMS5jcmwwdwYIKwYBBQUHAQEEazBpMCQG
# CCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wQQYIKwYBBQUHMAKG
# NWh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRENB
# LTEuY3J0MA0GCSqGSIb3DQEBBQUAA4IBAQCdJX4bM02yJoFcm4bOIyAPgIfliP//
# sdRqLDHtOhcZcRfNqRu8WhY5AJ3jbITkWkD73gYBjDf6m7GdJH7+IKRXrVu3mrBg
# JuppVyFdNC8fcbCDlBkFazWQEKB7l8f2P+fiEUGmvWLZ8Cc9OB0obzpSCfDscGLT
# Ykuw4HOmksDTjjHYL+NtFxMG7uQDthSr849Dp3GdId0UyhVdkkHa+Q+B0Zl0DSbE
# Dn8btfWg8cZ3BigV6diT5VUW8LsKqxzbXEgnZsijiwoc5ZXarsQuWaBh3drzbaJh
# 6YoLbewSGL33VVRAA5Ira8JRwgpIr7DUbuD0FAo6G+OPPcqvao173NhEMIIGzTCC
# BbWgAwIBAgIQBv35A5YDreoACus/J7u6GzANBgkqhkiG9w0BAQUFADBlMQswCQYD
# VQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGln
# aWNlcnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBBc3N1cmVkIElEIFJvb3QgQ0Ew
# HhcNMDYxMTEwMDAwMDAwWhcNMjExMTEwMDAwMDAwWjBiMQswCQYDVQQGEwJVUzEV
# MBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29t
# MSEwHwYDVQQDExhEaWdpQ2VydCBBc3N1cmVkIElEIENBLTEwggEiMA0GCSqGSIb3
# DQEBAQUAA4IBDwAwggEKAoIBAQDogi2Z+crCQpWlgHNAcNKeVlRcqcTSQQaPyTP8
# TUWRXIGf7Syc+BZZ3561JBXCmLm0d0ncicQK2q/LXmvtrbBxMevPOkAMRk2T7It6
# NggDqww0/hhJgv7HxzFIgHweog+SDlDJxofrNj/YMMP/pvf7os1vcyP+rFYFkPAy
# IRaJxnCI+QWXfaPHQ90C6Ds97bFBo+0/vtuVSMTuHrPyvAwrmdDGXRJCgeGDboJz
# PyZLFJCuWWYKxI2+0s4Grq2Eb0iEm09AufFM8q+Y+/bOQF1c9qjxL6/siSLyaxhl
# scFzrdfx2M8eCnRcQrhofrfVdwonVnwPYqQ/MhRglf0HBKIJAgMBAAGjggN6MIID
# djAOBgNVHQ8BAf8EBAMCAYYwOwYDVR0lBDQwMgYIKwYBBQUHAwEGCCsGAQUFBwMC
# BggrBgEFBQcDAwYIKwYBBQUHAwQGCCsGAQUFBwMIMIIB0gYDVR0gBIIByTCCAcUw
# ggG0BgpghkgBhv1sAAEEMIIBpDA6BggrBgEFBQcCARYuaHR0cDovL3d3dy5kaWdp
# Y2VydC5jb20vc3NsLWNwcy1yZXBvc2l0b3J5Lmh0bTCCAWQGCCsGAQUFBwICMIIB
# Vh6CAVIAQQBuAHkAIAB1AHMAZQAgAG8AZgAgAHQAaABpAHMAIABDAGUAcgB0AGkA
# ZgBpAGMAYQB0AGUAIABjAG8AbgBzAHQAaQB0AHUAdABlAHMAIABhAGMAYwBlAHAA
# dABhAG4AYwBlACAAbwBmACAAdABoAGUAIABEAGkAZwBpAEMAZQByAHQAIABDAFAA
# LwBDAFAAUwAgAGEAbgBkACAAdABoAGUAIABSAGUAbAB5AGkAbgBnACAAUABhAHIA
# dAB5ACAAQQBnAHIAZQBlAG0AZQBuAHQAIAB3AGgAaQBjAGgAIABsAGkAbQBpAHQA
# IABsAGkAYQBiAGkAbABpAHQAeQAgAGEAbgBkACAAYQByAGUAIABpAG4AYwBvAHIA
# cABvAHIAYQB0AGUAZAAgAGgAZQByAGUAaQBuACAAYgB5ACAAcgBlAGYAZQByAGUA
# bgBjAGUALjALBglghkgBhv1sAxUwEgYDVR0TAQH/BAgwBgEB/wIBADB5BggrBgEF
# BQcBAQRtMGswJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBD
# BggrBgEFBQcwAoY3aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0
# QXNzdXJlZElEUm9vdENBLmNydDCBgQYDVR0fBHoweDA6oDigNoY0aHR0cDovL2Ny
# bDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNybDA6oDig
# NoY0aHR0cDovL2NybDQuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9v
# dENBLmNybDAdBgNVHQ4EFgQUFQASKxOYspkH7R7for5XDStnAs0wHwYDVR0jBBgw
# FoAUReuir/SSy4IxLVGLp6chnfNtyA8wDQYJKoZIhvcNAQEFBQADggEBAEZQPsm3
# KCSnOB22WymvUs9S6TFHq1Zce9UNC0Gz7+x1H3Q48rJcYaKclcNQ5IK5I9G6OoZy
# rTh4rHVdFxc0ckeFlFbR67s2hHfMJKXzBBlVqefj56tizfuLLZDCwNK1lL1eT7EF
# 0g49GqkUW6aGMWKoqDPkmzmnxPXOHXh2lCVz5Cqrz5x2S+1fwksW5EtwTACJHvzF
# ebxMElf+X+EevAJdqP77BzhPDcZdkbkPZ0XN1oPt55INjbFpjE/7WeAjD9KqrgB8
# 7pxCDs+R1ye3Fu4Pw718CqDuLAhVhSK46xgaTfwqIa1JMYNHlXdx3LEbS0scEJx3
# FMGdTy9alQgpECYwggciMIIGCqADAgECAgIA5jANBgkqhkiG9w0BAQUFADA9MQsw
# CQYDVQQGEwJHQjERMA8GA1UEChMIQXNjZXJ0aWExGzAZBgNVBAMTEkFzY2VydGlh
# IFJvb3QgQ0EgMjAeFw0wOTA0MjExMjE1MTdaFw0yODA0MTQyMzU5NTlaMD8xCzAJ
# BgNVBAYTAkdCMREwDwYDVQQKEwhBc2NlcnRpYTEdMBsGA1UEAxMUQXNjZXJ0aWEg
# UHVibGljIENBIDEwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDPWPIz
# xLPZHflPEdu447bWvKchN1cue6kMlLPLEvBHWs4hcF4Tg5w+zKP+nr1T1tgwZD+K
# bl3EG1KwEfXZCNBO9gRP/v8kcl8NrLSqfDT42wpYJms0u6xpNCjM8YVrkheQld6f
# i/Hfo4rVEEhWeHE5XjSdaLuaswnz/WQOJ12InjrOxOdu8fvyHVHt64fW07nBMI+N
# p8nNXQ/rfn8Em19GxgezP826lbFX9Jtv5rSKGGUq4A9AAA5EcMB++AZ6tWozF/Sb
# MRk1RL0bBjn6lmnnolWUad8hjcHRCfae65imcyCh1Zl3CCK5/Okds+hZ8NIQcJop
# Di3O7EQ4cxdyQTdlAgMBAAGjggQoMIIEJDAOBgNVHQ8BAf8EBAMCAQYwEgYDVR0T
# AQH/BAgwBgEB/wIBAjCB8AYDVR0gBIHoMIHlMIHiBgorBgEEAfxJAQEBMIHTMIHQ
# BggrBgEFBQcCAjCBwxqBwFdhcm5pbmc6IENlcnRpZmljYXRlcyBhcmUgaXNzdWVk
# IHVuZGVyIHRoaXMgcG9saWN5IHRvIGluZGl2aWR1YWxzIHRoYXQgaGF2ZSBub3Qg
# aGFkIHRoZWlyIGlkZW50aXR5IGNvbmZpcm1lZC4gRG8gbm90IHVzZSB0aGVzZSBj
# ZXJ0aWZpY2F0ZXMgZm9yIHZhbHVhYmxlIHRyYW5zYWN0aW9ucy4gTk8gTElBQklM
# SVRZIElTIEFDQ0VQVEVELjCCATMGA1UdDgSCASoEggEmMIIBIjANBgkqhkiG9w0B
# AQEFAAOCAQ8AMIIBCgKCAQEAz1jyM8Sz2R35TxHbuOO21rynITdXLnupDJSzyxLw
# R1rOIXBeE4OcPsyj/p69U9bYMGQ/im5dxBtSsBH12QjQTvYET/7/JHJfDay0qnw0
# +NsKWCZrNLusaTQozPGFa5IXkJXen4vx36OK1RBIVnhxOV40nWi7mrMJ8/1kDidd
# iJ46zsTnbvH78h1R7euH1tO5wTCPjafJzV0P635/BJtfRsYHsz/NupWxV/Sbb+a0
# ihhlKuAPQAAORHDAfvgGerVqMxf0mzEZNUS9GwY5+pZp56JVlGnfIY3B0Qn2nuuY
# pnMgodWZdwgiufzpHbPoWfDSEHCaKQ4tzuxEOHMXckE3ZQIDAQABMFoGA1UdHwRT
# MFEwT6BNoEuGSWh0dHA6Ly93d3cuYXNjZXJ0aWEuY29tL09ubGluZUNBL2NybHMv
# QXNjZXJ0aWFSb290Q0EyL0FzY2VydGlhUm9vdENBMi5jcmwwPQYIKwYBBQUHAQEE
# MTAvMC0GCCsGAQUFBzABhiFodHRwOi8vb2NzcC5nbG9iYWx0cnVzdGZpbmRlci5j
# b20wggE3BgNVHSMEggEuMIIBKoCCASYwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAw
# ggEKAoIBAQCWN76e4Nk+poYTF/ZK86kH8xZo1X9EFkfzIZ99/OT/pPQLvs30wgYD
# 4uyhRBTFkKGf0dH3HjKz1N9SFJud0eqbxtH3YPr8rUjHkxjrX34LxCFWBNoj4T3F
# w3LGnTpGeO6xEaEDAdvdInm3BJvpG4VWES3Z7SJteaIbkNmqDn0DhRpMFXiNKgZK
# NWIcJM1ZGW9+OZO7vxUZrOPBfceplWg70Torc8TBYL7Pv1/g6kuZCO7Dx1nF6agi
# 9GCIHRkMrcjguIqkg8qSL+KWxwWuKi8YHBG4i7vIgvHOKL2lnmdoe63WRAG9wUHb
# 68duwBc1tIAPqam90MQrMyhTGzhwI7aDAgMBAAEwDQYJKoZIhvcNAQEFBQADggEB
# AJSUl6GjE5m6hkpci2WLPoJMrG90TALbigGZS1zTYLsIwUxfx0VndhR/YU7dUQf5
# vFPhzQf9mwm9vidT9Wwd6Wg0hmDiT8Lh5y7T4XyqjuMKN3cp7eDFkrSCUhvT8Lg2
# n/qxeeJMD3ghtFhoyXtI5A/6CmPHBkcNMtQZAhORKjpJ41wSa+vH6v1TzC8otw+x
# uxgyAkO/hRmmmBIgGDuwxKfLrdBQRZWeBRmWqH7grQlE0gYYpBFS4FlorwBqjiID
# p6FH52OrLS9gLV2f1emxMQAlwh3LMBmwvUtTQs++8M8oX2EpXZCIHeoOEFEMbzmE
# v4I88yooHJxcTL026vcl/1IxggQMMIIECAIBATBYMD8xCzAJBgNVBAYTAkdCMREw
# DwYDVQQKEwhBc2NlcnRpYTEdMBsGA1UEAxMUQXNjZXJ0aWEgUHVibGljIENBIDEC
# FQCdDgExwhEGCyl5TLUkaz5mLyd2ojAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIB
# DDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEE
# AYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQU9Ekh502ymcqJ
# DvfFnsJdqAnpMmYwDQYJKoZIhvcNAQEBBQAEggEAqkNsnCJSp8dFnmqbiHgGBHTc
# w2wAFy9UOlzFtz6m27VA6a785cldPISRbplQVUlCUk1JPgYHSMvzXO7IanCrHEJv
# Q3z1ljyAPdGxduGH6uTHAHsaFgjChey9Ja9WtI7DNZRhQvGKyoB/pYqjM02hH553
# lCq24WYcCXwsjv3vfqV93eI/ENnR9MiDncWr/l+JcwFf+4Mr3FEBiQjdj8SYoVWk
# hzvqgvMyOmoKdnknTkBJBCA7exusSJVk73Q7Usj9ixlF8A7mp7/xggx4JDC3+ReA
# QQ2WuIfAYfkJ7ZanvYQr8JdTeXz8YsUbqD+Cs4Xrpny8dPABYnbJAQg4hJ9L5aGC
# Ag8wggILBgkqhkiG9w0BCQYxggH8MIIB+AIBATB2MGIxCzAJBgNVBAYTAlVTMRUw
# EwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20x
# ITAfBgNVBAMTGERpZ2lDZXJ0IEFzc3VyZWQgSUQgQ0EtMQIQAwGaAjr/WLFr1tXq
# 5hfwZjAJBgUrDgMCGgUAoF0wGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkq
# hkiG9w0BCQUxDxcNMTkwMTA0MjAzMDQ1WjAjBgkqhkiG9w0BCQQxFgQUNbgxhW+D
# CtLhN+zIHwkPfu4xeeAwDQYJKoZIhvcNAQEBBQAEggEAAYJlrYKFXWsoTkJsV9lc
# d7JLF0+CnhjEyPI0036g88QLyigmKGqtXbRffeAYUCpeTCj1hk7D6CouM6D7sqZV
# z45B/lhTsAb/xqzlaV5vsUICD2sX2XxmmS9LwkPLuVvOxzJi/b+s792j3e1v2ry2
# 7ywK/g8HOETRZK6AsOdq4232p74rKFDMY5GQK/VhjqGkK/UYG2T4WWmltLvL5KDo
# HvASAgbK0nHpHjdpZAfpGzTN5Xl/eBE5TWxm8rWPTpQBSQgDog8dN+D7jM5UfOGN
# LmBG9tRNuAivhLzUYvt8BS+C5bsip0AfNqeREgQ1xzGN9/630JGRI/rduM4/6WAp
# og==
# SIG # End signature block
