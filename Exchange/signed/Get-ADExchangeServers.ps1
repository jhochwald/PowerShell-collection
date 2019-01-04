#requires -Version 1.0

function Get-ADExchangeServers
{
	<#
			.SYNOPSIS
			Get all Exchange Servers from Active Directory
	
			.DESCRIPTION
			This function gets a list with info of all Exchange Servers from the Active Directory.
			The Exchange tools (or a PowerShell Connection) is not needed.
			That is the major difference to Get-ExchangeServer
	
			.EXAMPLE
			# Get all Exchange Servers from Active Directory
			PS> Get-ADExchangeServers

			path    : http://nycexch01.contoso.com/powershell
			server  : NYCEXCH01
			Fullver : Version 15.1 (Build 31034.26)
			version : 15.1
			Site    : HQ

			path    : http://nycexch02.contoso.com/powershell
			server  : NYCEXCH02
			Fullver : Version 15.1 (Build 31034.26)
			version : 15.1
			Site    : HQ

			.EXAMPLE
			# No Exchange Server found! (Error)
			PS> Get-ADExchangeServers

			Get-ADExchangeServers : Unable to get the Exchange Information from the Active Directory!

			.NOTES
			Only Exchange Servers with a configured PowerShell URI will be dumped
	#>
	
	[CmdletBinding()]
	[OutputType([psobject])]
	param ()
	
	begin
	{
		# Define some defaults
		$ErrorMessage = 'Unable to get the Exchange Information from the Active Directory!'
		$SC = 'SilentlyContinue'
		$STP = 'Stop'
		
		# Search configuration partition for Exchange Servers where the powershell virtual directory is enabled
		try
		{
			$ActiveDirectoryInfo = (New-Object -TypeName adsisearcher -ArgumentList ([adsi]"LDAP://$(([adsi]'LDAP://rootdse').configurationNamingContext)"), '(&(objectclass=msExchPowerShellVirtualDirectory)(msexchinternalhostname=*))')
		}
		catch
		{
			$paramWriteError = @{
				Message		  = $ErrorMessage
				ErrorAction   = $STP
				WarningAction = $SC
			}
			
			Write-Error @paramWriteError
			break
		}
		
		if (-not ($ActiveDirectoryInfo))
		{
			$paramWriteError = @{
				Message		  = $ErrorMessage
				ErrorAction   = $STP
				WarningAction = $SC
			}
			
			Write-Error @paramWriteError
			break
		}
		
		# Create a new Object
		$ADExchangeInfo = @()
	}
	
	process
	{
		try
		{
			$ActiveDirectoryInfo.findall() | Sort-Object -Descending -Property {
				$_.properties.msexchversion[0]
			} | ForEach-Object -Process {
				# Define some defauts
				$NONE = ' '
				$COM = ','
				
				if ($_.properties.msexchinternalhostname[0])
				{
					if ($_.properties.distinguishedname[0])
					{
						$SrvLdapPath = ($_.properties.distinguishedname[0] -split $COM)[3 .. 100] -join $COM
						
						try
						{
							$SingleServerObject = [adsi]"LDAP://$SrvLdapPath"
						}
						catch
						{
							$SingleServerObject = $null
						}
						
						if ($SingleServerObject)
						{
							if ($SingleServerObject.serialnumber[0])
							{
								$SingleFullVersion = $SingleServerObject.serialnumber[0]
							}
							else
							{
								$SingleFullVersion = $null
							}
							
							if (($SingleServerObject.serialNumber -split $NONE)[1])
							{
								$SingleShortVersion = ($SingleServerObject.serialNumber -split $NONE)[1]
							}
							else
							{
								$SingleShortVersion = $null
							}
							
							if ($SingleServerObject.name[0])
							{
								$SingleServer = $SingleServerObject.name[0]
							}
							else
							{
								$SingleServer = $null
							}
							
							if ($SingleServerObject.msExchServerSite[0])
							{
								$SingleActiveDirectorySite = $SingleServerObject.msExchServerSite[0] -replace '^CN=|,.*$', ''
							}
							else
							{
								$SingleActiveDirectorySite = $null
							}
						}
						
						if ($_.properties.msexchinternalhostname[0])
						{
							# With each virtual directory create an object to represent its details,
							# if List Version or site is included, also find the server object
							$paramNewObject = @{
								TypeName = 'psobject'
								Property = @{
									path = $_.properties.msexchinternalhostname[0]
									server = $SingleServer
									Site = $SingleActiveDirectorySite
									version = $SingleShortVersion
									Fullver = $SingleFullVersion
								}
							}
							
							$SingleExchangeInfo = (New-Object @paramNewObject)
							
							# Append the Info to the Object
							$ADExchangeInfo += $SingleExchangeInfo
						}
					}
				}
			}
		}
		catch
		{
			# Do nothing
			Write-Verbose -Message 'Something went wrong...'
		}
	}
	
	end
	{
		# Just dump the plain object
		if ($ADExchangeInfo)
		{
			$ADExchangeInfo
		}
		else
		{
			$paramWriteError = @{
				Message		  = $ErrorMessage
				ErrorAction   = $STP
				WarningAction = $SC
			}
			
			Write-Error @paramWriteError
			break
		}
	}
}
Get-ADExchangeServers

#region CHANGELOG
<#
  Soon
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

# SIG # Begin signature block
# MIIO6AYJKoZIhvcNAQcCoIIO2TCCDtUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU6u42ap45B7E3ieX4v5uAEMdz
# vASgggxZMIIFLzCCBBegAwIBAgIVAJ0OATHCEQYLKXlMtSRrPmYvJ3aiMA0GCSqG
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQULLCZD1Cnq4vSD5qgtUBFhVEvqLcwDQYJKoZI
# hvcNAQEBBQAEggEAxAy4wcRCpG9ck2+9tQ4HMmwFAlEPhqPO7R3K8+EcXx7Wz61K
# nox6hiETWkAhQ4uWa4tMXuRf30vS4DJo8GJSRNCTw5VmtsYcpxUOLOSL6aNGyNKq
# e8RwegI2rx8qUsqa4sUtZz4ow1N7QMBrebcUlfQ0rqvGvglk+YJCUGWNqEmQ3fS0
# V9meSuhCSj9yvSpViWayCq6uZ2ltB58iGHbWYOuHTjNTzCvkywdTTcOsqAUm4zeP
# jA1WdNmsmhER4vUphtefFFpYQnXgfUNF01Jf0wiU9hl0HnPPI00unX2q1AO97i4I
# 9CACoPu7bVjE2egDuqYFUDhJzhlgs3om6MWKJg==
# SIG # End signature block
