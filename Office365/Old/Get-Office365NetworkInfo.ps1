function Get-Office365NetworkInfo
{
	<#
			.SYNOPSIS
			The function gets the Office 365 URLs and IP address ranges.
	
			.DESCRIPTION
			Office 365 URLs and IP address ranges via the Microsoft published XML format.
			You can filter what product (e.g. O365, SPO, etc.) and type (IPV4, IPV6, or URL) and select the Environment to use.
	
			.PARAMETER Type
			Service Types to get, default is All for everything
			Multiple values are allowd

			Possible values are:
			All = Everything (the default)
			URL = Only URLs
			IPv4 = Only IPv4 Information
			IPv6 = Only IPv6 Information
	
			.PARAMETER Product
			Products to get, default is All for everthing
			Multiple values are allowd

			Possible values are:
			All = Everything (the default)
			o365 = Office 365 portal and shared
			LYO = Skype for Business Online
			Planner = Microsoft Planner
			Teams = Microsoft Teams
			ProPlus = Office Clients
			OneNote = Microsoft OneNote
			Yammer = Microsoft Yammer
			EXO = Exchange Online
			Identity = Office 365 authentication and identity
			Office365Video = Office 365 Video and Microsoft Stream
			WAC = Office Online
			SPO = SharePoint Online and OneDrive
			RCA = Office 365 remote analyzer tools
			Sway = Microsoft Sway
			EX-Fed = Exchange Federation
			OfficeMobile = 
			CRLs = Certificate revocation list
			OfficeiPad = Office for iOS
			EOP = Exchange Online Protection
			SfB = Skype for Business Online - USDefense & USDoD only
			OfficeOnline = Office Onlien CDN - USDefense & USDoD only
			Portal = Office 365 Portal - USDefense & USDoD only

			.PARAMETER Environment
			The Office365/Azure Environment to use, Default is Office 365 Worldwide (+GCC)
			Multiple values are not allowd

			Possible values are:
			Default = Office 365 Worldwide (+GCC)
			USDefense = Office 365 U.S. Government GCC High
			USDoD = Office 365 U.S. Government DoD
			Telekom = Office 365 Germany
			21Vianet = Office 365 operated by 21 Vianet

			.LINK
			https://aka.ms/o365endpoints

			.LINK
			http://aka.ms/o365ip

			.LINK
			https://support.content.office.net/en-us/static/Office365IPAddresses.xml

			.LINK
			http://iprange.omartin2010.com
			https://azurerange.azurewebsites.net

			.EXAMPLE
			PS C:\> Get-Office365NetworkInfo

			It gets the Office 365 URLs and IP address ranges.

			.EXAMPLE
			PS C:\> Get-Office365NetworkInfo -Type url

			It gets the Office 365 URLs only.

			.EXAMPLE
			PS C:\> Get-Office365NetworkInfo -Type url -Environment USDefense

			It gets the Office 365 U.S. Government GCC High URLs only for the.


			.EXAMPLE
			PS C:\> Get-Office365NetworkInfo -Product 'LYO'

			It gets the Office 365 URLs and IP address ranges for Skype for Business.

			.EXAMPLE
			PS C:\> Get-Office365NetworkInfo -Product 'Teams' -Type 'IPv4'

			It gets the Office 365 IPv6 address ranges for Microsoft Teams.

			.EXAMPLE
			PS C:\> Get-Office365NetworkInfo -Product 'Teams' -Type 'IPv4','IPv6'

			It gets the Office 365 IP (IPv4 and IPv6) address ranges for Microsoft Teams.

			.EXAMPLE
			PS C:\> (Get-Office365NetworkInfo -Product 'EXO' -Type url).Addresses | Sort-Object | Get-Unique

			It gets the Office 365 URLs for Exchange Online, sort them, and make them unique.

			.EXAMPLE
			PS C:\> Get-Office365NetworkInfo -Product 'Yammer','WAC' | Format-List

			It gets the Office 365 URLs and IP address ranges as formatted list.

			.EXAMPLE
			PS C:\> (Get-Office365NetworkInfo -Type url).Addresses | Select-String -Pattern '(Facebook)|(youtube)|(hockey)|(dropbox)|(google)' -NotMatch | Sort-Object | Get-Unique

			It gets the Office 365 URLs, sorts them, and makes them unique. And in this example, we remove the crappy (non Microsoft) URLs.

			.EXAMPLE
			PS C:\> (Get-Office365NetworkInfo -Type url).Addresses |Select-String -Pattern '(Facebook)|(youtube)|(hockey)|(dropbox)|(google)' | Sort-Object | Get-Unique

			In this example we filter all the non Microsoft URLs. We use this to implement es negative list :-)

			.NOTES
			Changelog:
			[Add] Multivalue for products
			[Add] Multivalue for types
			[Add] ExpressRoute Information (Still need some love)
			[Add] Environment support for the regional Office 365 instances (taken from our Office 365 module)
			[Changed] Splat some stuff
			[Changed] Refactored some older code
			[Removed] Removed extensive comments (Great job Josh)
			[Removed] Cisco Config Output (Has an own Filter-Function now)
			[Fix] Add missing products for USDefense & USDoD 
	#>
	
	[CmdletBinding()]
	[OutputType([psobject])]
	param
	(
		
		[Parameter(ValueFromPipeline,
				ValueFromPipelineByPropertyName,
		Position = 1)]
		[ValidateNotNullOrEmpty()]
		[ValidateSet('All', 'o365', 'Portal', 'OfficeOnline', 'SfB', 'LYO', 'Planner', 'Teams', 'ProPlus', 'OneNote', 'Yammer', 'EXO', 'Identity', 'Office365Video', 'WAC', 'SPO', 'RCA', 'Sway', 'EX-Fed', 'OfficeMobile', 'CRLs', 'OfficeiPad', 'EOP', IgnoreCase)]
		[string[]]
		$Product = 'All',
		[Parameter(ValueFromPipeline,
				ValueFromPipelineByPropertyName,
		Position = 2)]
		[ValidateNotNullOrEmpty()]
		[ValidateSet('All', 'URL', 'IPv4', 'IPv6', IgnoreCase)]
		[string[]]
		$Type = 'All',
		[Parameter(ValueFromPipeline,
				ValueFromPipelineByPropertyName,
		Position = 3)]
		[ValidateSet('USDefense', 'USDoD', 'Telekom', '21Vianet', 'Default')]
		[Alias('AzureEnvironment' ,'Office365Environment' ,'O365Environment')]
		[string]
		$Environment = 'Default'
	)

	begin
	{
		# Cleanup
		$Office365IPAddresses = $null

		switch ($Environment)
		{
			'USDefense'
			{
				$Office365IPAddresses = 'https://support.content.office.net/en-us/static/O365IPAddresses_USDefense.xml'
			}
			'USDoD'
			{
				$Office365IPAddresses = 'https://support.content.office.net/en-us/static/O365IPAddresses_USDoD.xml'
			}
			'Telekom'
			{
				# Download only: https://www.microsoft.com/en-us/download/confirmation.aspx?id=54770
				Write-Warning -Message 'There is no dedicated List for Germany avalible, yet!'
				Write-Warning -Message  'Ask Microsoft to publish them'
				$Office365IPAddresses = $null
			}
			'21Vianet'
			{
				# Download only: https://www.microsoft.com/en-ca/download/confirmation.aspx?id=42064
				Write-Warning -Message 'There is no dedicated List for Chine avalible, yet!'
				Write-Warning -Message  'Ask Microsoft to publish them'
				$Office365IPAddresses = $null
			}
			
			default
			{
				$Office365IPAddresses = 'https://support.content.office.net/en-us/static/O365IPAddresses.xml'
			}
		}

		if (-not ($Office365IPAddresses)) 
		{
			exit 1
		}

		Write-Verbose -Message ('Get the Office 365 URLs and IP address ranges from {0}.' -f $Office365IPAddresses)

		# Cleanup
		$Office365IPAddressObj = @()
		$Office365ObjectInfoProduct = @()
		$Office365ObjectInfoType = @()

		# ExpressRoute Information (Both list are not finished yet)
		$ExpressRouteEnabled = @(
			'EXO', 
			'EOP', 
			'LYO', 
			'Teams', 
			'o365', 
			'SPO'
		)

		$ExpressRouteDisabled = @(
			'Office365Video', 
			'Yammer', 
			'Sway', 
			'Planner', 
			'ProPlus', 
			'CRLs'
		)
	}
	
	process
	{
		try
		{
			$paramInvokeWebRequest = @{
				Uri              = $Office365IPAddresses
				DisableKeepAlive = $true
				ErrorAction      = 'Stop'
			}
			[XML]$Office365XMLData = (Invoke-WebRequest @paramInvokeWebRequest)
		}
		catch
		{
			Write-Error -Message ('Failed to get the Office 365 IP address & URL information from {0}.' -f $Office365IPAddresses) -ErrorAction Stop
			
			exit 1
		}

		ForEach($Office365Product in $Office365XMLData.Products.Product)
		{
			ForEach($AddressList in $Office365Product.AddressList)
			{
				if ($AddressList.Address) 
				{
					# Try to figure out if ExpressRoute is enabled for this product
					if ($ExpressRouteEnabled -contains $Office365Product.Name) 
					{
						$ExpressRoute = 'Yes'
					}
					elseif ($ExpressRouteDisabled -contains $Office365Product.Name) 
					{
						$ExpressRoute = 'No'
					}
					else 
					{
						# Everything else
						$ExpressRoute = 'Unknown'
					}

					# Ordered is slower, but we like it this way
					$Office365IPAddressParams = [ordered]@{
						Product      = $Office365Product.Name
						Type         = $AddressList.Type
						Addresses    = $AddressList.Address
						ExpressRoute = $ExpressRoute
					}

					# Append to our Object
					$Office365IPAddressObj += (New-Object -TypeName PSObject -Property $Office365IPAddressParams)
				}
			}
		}

		# Do we Filter?
		if ($Product -ne 'All') 
		{
			Write-Verbose -Message ('Display only the {0}' -f $Product)

			foreach ($SingleProduct in $Product) 
			{
				$Office365ObjectInfoProduct += $Office365IPAddressObj | Where-Object -FilterScript {
					$_.Product -eq $SingleProduct
				}
			}
		}
		else 
		{
			$Office365ObjectInfoProduct += $Office365IPAddressObj
		}


		if ($Type -ne 'All') 
		{
			Write-Verbose -Message ('Display only {0}' -f $Type)

			foreach ($SingleType in $Type) 
			{
				$Office365ObjectInfoType += $Office365ObjectInfoProduct | Where-Object -FilterScript {
					$_.Type -eq $SingleType
				}
			}
		}
		else 
		{
			$Office365ObjectInfoType += $Office365ObjectInfoProduct
		}
	}
	
	end
	{
		$Office365ObjectInfoType | Sort-Object -Property Product
		
	}

	<#
			Original Notes from the Author:

			I created this function a while ago. Basically, it was built to create several lists for equipment is used.
			For example: A HAProxy, a SquiD Proxy and my old Cisco Firewall and my pfSense Firewall.
			It started as something I created just for myself, to tweak my own stuff.
	#>

	<#
			Original License from the Author:

			Copyright 2015-2017 by Joerg Hochwald

			Redistribution and use in source and binary forms, with or without modification, are
			permitted provided that the following conditions are met:

			1. Redistributions of source code must retain the above copyright notice, this list of
			conditions and the following disclaimer.

			2. Redistributions in binary form must reproduce the above copyright notice, this list of
			conditions and the following disclaimer in the documentation and/or other materials
			provided with the distribution.

			3. Neither the name of the copyright holder nor the names of its contributors may be
			used to endorse or promote products derived from this software without specific prior
			written permission.

			THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
			EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
			MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
			COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
			EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
			SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
			HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
			OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
			SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

			By using the Software, you agree to the License, Terms and Conditions above!
	#>
}
