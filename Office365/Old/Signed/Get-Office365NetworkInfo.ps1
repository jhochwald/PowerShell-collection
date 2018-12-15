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

# SIG # Begin signature block
# MIIYpQYJKoZIhvcNAQcCoIIYljCCGJICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUkXeM3CXF9lwc8f7eXgnXYaKd
# vhygghPNMIID7jCCA1egAwIBAgIQfpPr+3zGTlnqS5p31Ab8OzANBgkqhkiG9w0B
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
# ggVMMIIENKADAgECAhAW1PdTHZsYJ0/yJnM0UYBcMA0GCSqGSIb3DQEBCwUAMH0x
# CzAJBgNVBAYTAkdCMRswGQYDVQQIExJHcmVhdGVyIE1hbmNoZXN0ZXIxEDAOBgNV
# BAcTB1NhbGZvcmQxGjAYBgNVBAoTEUNPTU9ETyBDQSBMaW1pdGVkMSMwIQYDVQQD
# ExpDT01PRE8gUlNBIENvZGUgU2lnbmluZyBDQTAeFw0xNTA3MTcwMDAwMDBaFw0x
# ODA3MTYyMzU5NTlaMIGQMQswCQYDVQQGEwJERTEOMAwGA1UEEQwFMzU1NzYxDzAN
# BgNVBAgMBkhlc3NlbjEQMA4GA1UEBwwHTGltYnVyZzEYMBYGA1UECQwPQmFobmhv
# ZnNwbGF0eiAxMRkwFwYDVQQKDBBLcmVhdGl2U2lnbiBHbWJIMRkwFwYDVQQDDBBL
# cmVhdGl2U2lnbiBHbWJIMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA
# ryMOYXRM7T2omd0n14YWqtrWV/Xg0OEzzAhPxwVxn8BfZfOsTrNv/yQTmwvj90yG
# 5M6n5Iy3S0j9I43oFjfbTy/82UMjt+jMCod+a8+Etfqn9O0OSZIfWwPwAjKtMf1v
# bvAM1fisL3XgprgQEjywa1nBk5CTBB2VXqAIGZp1qv7tiRWEBsgiRJrMT3LJFO59
# +J2a0dXj0Mc+v6qXiOI0n8rbtkVlvAzqQYGUMEFKAtQq+58xj5c9S6SnN0JoDRTP
# KAZR0N+DLSG1JKnwxH1GerhYwvS399PQhm+avEKuHs1eRBcAKTbG2eSrRtdQgLof
# RmiWd+Xh9qe9VjK8PzyogQIDAQABo4IBsjCCAa4wHwYDVR0jBBgwFoAUKZFg/4pN
# +uv5pmq4z/nmS71JzhIwHQYDVR0OBBYEFJ5Ubj/1S9WOa/xJPLh/uQYe5xKGMA4G
# A1UdDwEB/wQEAwIHgDAMBgNVHRMBAf8EAjAAMBMGA1UdJQQMMAoGCCsGAQUFBwMD
# MBEGCWCGSAGG+EIBAQQEAwIEEDBGBgNVHSAEPzA9MDsGDCsGAQQBsjEBAgEDAjAr
# MCkGCCsGAQUFBwIBFh1odHRwczovL3NlY3VyZS5jb21vZG8ubmV0L0NQUzBDBgNV
# HR8EPDA6MDigNqA0hjJodHRwOi8vY3JsLmNvbW9kb2NhLmNvbS9DT01PRE9SU0FD
# b2RlU2lnbmluZ0NBLmNybDB0BggrBgEFBQcBAQRoMGYwPgYIKwYBBQUHMAKGMmh0
# dHA6Ly9jcnQuY29tb2RvY2EuY29tL0NPTU9ET1JTQUNvZGVTaWduaW5nQ0EuY3J0
# MCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5jb21vZG9jYS5jb20wIwYDVR0RBBww
# GoEYaG9jaHdhbGRAa3JlYXRpdnNpZ24ubmV0MA0GCSqGSIb3DQEBCwUAA4IBAQBJ
# JmTEqjcTIST+pbRkKzsIMMcpPHdRyoTGKCxpjQNGj19taCpbKci2yp3AWS5BgnHO
# SeqbYky/AgroG19ZzrhZmHLQG0jdLeHHNgfEONUMEsHL3WSP+Z10+N6frRb4vrqg
# 0ReIG4iw5wn17u0fpWf14URSO6rl6ygkzoVX4wgq/+M8VYynkHoS1fgsMcSliktF
# VCe7GhzfyaZ341+NwPb+j/zVu7ouYEV6AcBoYOlOEZ/weTc1XLQZylDe2uqYfp7c
# KmbxS3lSShI41l2RhbCvOSbMWAnKgzaudMxOHh+JzEFCkHsiS/hUSesdFF6KFnTP
# A34eRc7VcSd3eGb7TyMvMIIF4DCCA8igAwIBAgIQLnyHzA6TSlL+lP0ct800rzAN
# BgkqhkiG9w0BAQwFADCBhTELMAkGA1UEBhMCR0IxGzAZBgNVBAgTEkdyZWF0ZXIg
# TWFuY2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9yZDEaMBgGA1UEChMRQ09NT0RPIENB
# IExpbWl0ZWQxKzApBgNVBAMTIkNPTU9ETyBSU0EgQ2VydGlmaWNhdGlvbiBBdXRo
# b3JpdHkwHhcNMTMwNTA5MDAwMDAwWhcNMjgwNTA4MjM1OTU5WjB9MQswCQYDVQQG
# EwJHQjEbMBkGA1UECBMSR3JlYXRlciBNYW5jaGVzdGVyMRAwDgYDVQQHEwdTYWxm
# b3JkMRowGAYDVQQKExFDT01PRE8gQ0EgTGltaXRlZDEjMCEGA1UEAxMaQ09NT0RP
# IFJTQSBDb2RlIFNpZ25pbmcgQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK
# AoIBAQCmmJBjd5E0f4rR3elnMRHrzB79MR2zuWJXP5O8W+OfHiQyESdrvFGRp8+e
# niWzX4GoGA8dHiAwDvthe4YJs+P9omidHCydv3Lj5HWg5TUjjsmK7hoMZMfYQqF7
# tVIDSzqwjiNLS2PgIpQ3e9V5kAoUGFEs5v7BEvAcP2FhCoyi3PbDMKrNKBh1SMF5
# WgjNu4xVjPfUdpA6M0ZQc5hc9IVKaw+A3V7Wvf2pL8Al9fl4141fEMJEVTyQPDFG
# y3CuB6kK46/BAW+QGiPiXzjbxghdR7ODQfAuADcUuRKqeZJSzYcPe9hiKaR+ML0b
# tYxytEjy4+gh+V5MYnmLAgaff9ULAgMBAAGjggFRMIIBTTAfBgNVHSMEGDAWgBS7
# r34CPfqm8TyEjq3uOJjs2TIy1DAdBgNVHQ4EFgQUKZFg/4pN+uv5pmq4z/nmS71J
# zhIwDgYDVR0PAQH/BAQDAgGGMBIGA1UdEwEB/wQIMAYBAf8CAQAwEwYDVR0lBAww
# CgYIKwYBBQUHAwMwEQYDVR0gBAowCDAGBgRVHSAAMEwGA1UdHwRFMEMwQaA/oD2G
# O2h0dHA6Ly9jcmwuY29tb2RvY2EuY29tL0NPTU9ET1JTQUNlcnRpZmljYXRpb25B
# dXRob3JpdHkuY3JsMHEGCCsGAQUFBwEBBGUwYzA7BggrBgEFBQcwAoYvaHR0cDov
# L2NydC5jb21vZG9jYS5jb20vQ09NT0RPUlNBQWRkVHJ1c3RDQS5jcnQwJAYIKwYB
# BQUHMAGGGGh0dHA6Ly9vY3NwLmNvbW9kb2NhLmNvbTANBgkqhkiG9w0BAQwFAAOC
# AgEAAj8COcPu+Mo7id4MbU2x8U6ST6/COCwEzMVjEasJY6+rotcCP8xvGcM91hoI
# lP8l2KmIpysQGuCbsQciGlEcOtTh6Qm/5iR0rx57FjFuI+9UUS1SAuJ1CAVM8bdR
# 4VEAxof2bO4QRHZXavHfWGshqknUfDdOvf+2dVRAGDZXZxHNTwLk/vPa/HUX2+y3
# 92UJI0kfQ1eD6n4gd2HITfK7ZU2o94VFB696aSdlkClAi997OlE5jKgfcHmtbUIg
# os8MbAOMTM1zB5TnWo46BLqioXwfy2M6FafUFRunUkcyqfS/ZEfRqh9TTjIwc8Jv
# t3iCnVz/RrtrIh2IC/gbqjSm/Iz13X9ljIwxVzHQNuxHoc/Li6jvHBhYxQZ3ykub
# Ua9MCEp6j+KjUuKOjswm5LLY5TjCqO3GgZw1a6lYYUoKl7RLQrZVnb6Z53BtWfht
# Kgx/GWBfDJqIbDCsUgmQFhv/K53b0CDKieoofjKOGd97SDMe12X4rsn4gxSTdn1k
# 0I7OvjV9/3IxTZ+evR5sL6iPDAZQ+4wns3bJ9ObXwzTijIchhmH+v1V04SF3Awpo
# bLvkyanmz1kl63zsRQ55ZmjoIs2475iFTZYRPAmK0H+8KCgT+2rKVI2SXM3CZZgG
# ns5IW9S1N5NGQXwH3c/6Q++6Z2H/fUnguzB9XIDj5hY5S6cxggRCMIIEPgIBATCB
# kTB9MQswCQYDVQQGEwJHQjEbMBkGA1UECBMSR3JlYXRlciBNYW5jaGVzdGVyMRAw
# DgYDVQQHEwdTYWxmb3JkMRowGAYDVQQKExFDT01PRE8gQ0EgTGltaXRlZDEjMCEG
# A1UEAxMaQ09NT0RPIFJTQSBDb2RlIFNpZ25pbmcgQ0ECEBbU91MdmxgnT/ImczRR
# gFwwCQYFKw4DAhoFAKB4MBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZI
# hvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcC
# ARUwIwYJKoZIhvcNAQkEMRYEFBX+pvN4Id5Atomd2h2aeVMXDNoQMA0GCSqGSIb3
# DQEBAQUABIIBAFy2O+HewhcHs0UxIQD9mY8cq5htxx/uNPo4vLKE4HYbDZ4KFQ85
# 9xqRUsDRnP2/BVP5BH9zeki0k2PrV2ulUAh4ikIqx9qKdNuBRuLI1Em0puQCG2NS
# +RZ+bNOVZ8Z6NW+95oS0vmWblSYxpk5TZmxx/NoAB8Qnujmk1z5lgqzPpWbj1Cfy
# jwcAd2bD80LK1MZgZOtUcSvUY8H+OvwMha3HbkrCEpeMk4bIjvGSZxlTrHNYpN5x
# 2Y29BvWvKtD8mMwreXt5nvb8hp5imj4nj8rpX6Xsbu1GHS2JCvqrlWDmJTMnknMt
# yTAl3oPg7yQEhNXGJvgecae3e4BYpPbZOemhggILMIICBwYJKoZIhvcNAQkGMYIB
# +DCCAfQCAQEwcjBeMQswCQYDVQQGEwJVUzEdMBsGA1UEChMUU3ltYW50ZWMgQ29y
# cG9yYXRpb24xMDAuBgNVBAMTJ1N5bWFudGVjIFRpbWUgU3RhbXBpbmcgU2Vydmlj
# ZXMgQ0EgLSBHMgIQDs/0OMj+vzVuBNhqmBsaUDAJBgUrDgMCGgUAoF0wGAYJKoZI
# hvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTgwMzA3MDEwMzE2
# WjAjBgkqhkiG9w0BCQQxFgQUqQ6vdvA44JAk2+DY0PH2y+iSxFIwDQYJKoZIhvcN
# AQEBBQAEggEANIuc3CUbQpsODgyoR1WJGDqSpjh9Oo2CY0vOsXThGv93jIm6B90E
# C0T8TC4XwPpcQZMYipdBd18UL+AEc7FfiWAuUp3iZ2owox2Y04XMBSU1rkztsZKP
# 8BKaaslvI8FqCdw8UAjpO2YOvgJ+IPPpi0TvKorF4Pw3vpmyYnVISHpnKJlNxiM2
# NNplr7n6GQSpAjLbvbTPcC/JFWk0hHEIjOqMSkAKAFhfsz4jq7UGSoMZeIFFRdxD
# 5EpdnndngyoQO/HmDU48fcdSVqHSeP3a8Pet2Y2SAsR916j5GZO2hrGiUeROjiHm
# d1R7l+Uasx9SFWTGdGAzSd+y9EKijfA16g==
# SIG # End signature block
