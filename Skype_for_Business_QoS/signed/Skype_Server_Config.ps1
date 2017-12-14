<#
		.SYNOPSIS
		Setup the S4B server for QoS
	
		.DESCRIPTION
		Setup the Skype for Business 2015 Server for Quality of Services
	
		.PARAMETER FrontEndPool
		Skype for Business Front End Pool
	
		.PARAMETER EdgePool
		Skype for Business Edge Pool
	
		.EXAMPLE
		PS C:\> .\Skype_Server_Config.ps1
	
		.EXAMPLE
		PS C:\> .\Skype_Server_Config.ps1 -verbose
	
		.NOTES
		Check that the ports and port ranges fit your requirements!
		
		The ports and ranges we use here should fit the Skype for Business Online setup
#>
[CmdletBinding()]
param
(
	[Parameter(ValueFromPipeline,
	Position = 1)]
	[string]
	$FrontEndPool = 's4bfe.fra.hicts.net',
	[Parameter(ValueFromPipeline,
	Position = 2)]
	[string]
	$EdgePool = 's4bedge.dmz.hicts.net'
)

#Requires -RunAsAdministrator

BEGIN
{
	#region Variables

	# QoS marking for Audio
	[string]$AudioMark = '46'

	# Audio Start Port
	[string]$AudioPortStart = '50000'

	# Number of Ports to use
	[string]$AudioPortCount = '20'

	# Video Start Port
	[string]$VideoPortStart = ([int]$AudioPortStart + [int]$AudioPortCount)
	# Legacy variante of the above (without calculating)
	#[string]$VideoPortStart = '50020'

	# Number of Ports to use
	[string]$VideoPortCount = '20'

	# App Sharing Start Port
	[string]$AppSharingPortStart = ([int]$VideoPortStart + [int]$VideoPortCount)
	# Legacy variante of the above (without calculating)
	#[string]$AppSharingPortStart = '50040'

	# Number of Ports to use
	[string]$AppSharingPortCount = '20'

	# Start File Transfer Port
	[string]$ClientFileTransferPort = '5350'

	# Number of Ports to use
	[string]$ClientFileTransferPortRange = '20'

	# Start Legacy Media Port
	[string]$ClientMediaPort = '5370'

	# Number of Ports to use (Legacy)
	[string]$ClientMediaPortRange = '20'

	# Number of Ports to use (Legacy)
	[string]$MediaCommunicationPortCount = '10000'
	
	<#
	
			# Legacy variables
	
			# Skype for Business Front End Pool
			[string]$FrontEndPool = 's4bfe.fra.hicts.net'

			# Skype for Business Edge Pool
			[string]$EdgePool = 's4bedge.dmz.hicts.net'
	#>
	
	#endregion Variables

	#region Defaults

	# Define some Defaults
	[string]$SC = 'SilentlyContinue'
	[string]$STP = 'Stop'
	[string]$Global = 'global'
	[string]$Voice8021p = '0'

	#endregion Defaults

	#region CheckCmd

	# All Skype for Business Server related commands
	$AllCommands = 'Set-CsConferencingConfiguration', 'Set-CsUCPhoneConfiguration', 'Set-CsMediaConfiguration', 'Set-CsConferenceServer', 'Set-CsApplicationServer', 'Set-CsMediationServer', 'Set-CsWebServer', 'Set-CsEdgeServer'

	# Loop over the list of commands
	foreach ($TheCommand in $AllCommands)
	{
		try
		{
			Write-Verbose -Message ('Check for {0}' -f $TheCommand)

			# Cleanup
			$paramGetCommand = $null

			# Splat reusable parameters
			$paramGetCommand = @{
				Name          = $TheCommand
				ErrorAction   = $STP
				WarningAction = $SC
			}
			$null = (Get-Command @paramGetCommand)

			Write-Verbose -Message ('Found {0}' -f $TheCommand)
		}
		catch
		{
			# Whoops
			$paramWriteError = @{
				Message     = ('Unable to find {0} - Please check your Setup!' -f $TheCommand)
				ErrorAction = $STP
			}
			Write-Error @paramWriteError

			# We are done here...
			break
		}
	}

	#endregion CheckCmd
}

PROCESS
{
	#region ConferencingConfiguration

	try
	{
		Write-Verbose -Message 'Change Conferencing Configuration'

		# Cleanup
		$paramSetCsConferencingConfiguration = $null

		# Splat reusable parameters
		$paramSetCsConferencingConfiguration = @{
			Identity                    = $Global
			ClientAudioPort             = $AudioPortStart
			ClientAudioPortRange        = $AudioPortCount
			ClientVideoPort             = $VideoPortStart
			ClientVideoPortRange        = $VideoPortCount
			ClientAppSharingPort        = $AppSharingPortStart
			ClientAppSharingPortRange   = $AppSharingPortCount
			ClientFileTransferPort      = $ClientFileTransferPort
			ClientFileTransferPortRange = $ClientFileTransferPortRange
			ClientMediaPortRangeEnabled = $true
			ClientMediaPort             = $ClientMediaPort
			ClientMediaPortRange        = $ClientMediaPortRange
			ErrorAction                 = $STP
			WarningAction               = $SC
		}

		$null = (Set-CsConferencingConfiguration @paramSetCsConferencingConfiguration)

		Write-Verbose -Message 'Changed Conferencing Configuration'
	}
	catch
	{
		Write-Warning -Message 'Unable to Set Conferencing Configuration'
	}

	#endregion ConferencingConfiguration

	#region ChangeUCPhoneConfiguration

	try
	{
		Write-Verbose -Message 'Change UC Phone Configuration'

		# Cleanup
		$paramSetCsUCPhoneConfiguration = $null

		# Splat reusable parameters
		$paramSetCsUCPhoneConfiguration = @{
			Identity         = $Global
			VoiceDiffServTag = $AudioMark
			Voice8021p       = $Voice8021p
			ErrorAction      = $STP
			WarningAction    = $SC
		}

		$null = (Set-CsUCPhoneConfiguration @paramSetCsUCPhoneConfiguration)

		Write-Verbose -Message 'Changed UC Phone Configuration'
	}
	catch
	{
		Write-Warning -Message 'Unable to Set UC Phone Configuration'
	}

	#endregion ChangeUCPhoneConfiguration

	#region ChangeMediaConfiguration

	try
	{
		Write-Verbose -Message 'Change Media Configuration'

		# Cleanup
		$paramSetCsMediaConfiguration = $null

		# Splat reusable parameters
		$paramSetCsMediaConfiguration = @{
			Identity      = $Global
			EnableQoS     = $true
			ErrorAction   = $STP
			WarningAction = $SC
		}

		$null = (Set-CsMediaConfiguration @paramSetCsMediaConfiguration)

		Write-Verbose -Message 'Changed Media Configuration'
	}
	catch
	{
		Write-Warning -Message 'Unable to Set Media Configuration'
	}

	#endregion ChangeMediaConfiguration

	#region ChangeConferenceServerConfiguration

	try
	{
		Write-Verbose -Message 'Change Conference Server Configuration'

		# Cleanup
		$paramSetCsConferenceServer = $null

		# Splat reusable parameters
		$paramSetCsConferenceServer = @{
			Identity            = $FrontEndPool
			AppSharingPortStart = $AppSharingPortStart
			AppSharingPortCount = $AppSharingPortCount
			AudioPortStart      = $AudioPortStart
			AudioPortCount      = $AudioPortCount
			VideoPortStart      = $VideoPortStart
			VideoPortCount      = $VideoPortCount
			ErrorAction         = $STP
			WarningAction       = $SC
		}

		$null = (Set-CsConferenceServer @paramSetCsConferenceServer)

		Write-Verbose -Message 'Changed Conference Server Configuration'
	}
	catch
	{
		Write-Warning -Message 'Unable to Set Conference Server Configuration'
	}

	#endregion ChangeConferenceServerConfiguration

	#region ChangeApplicationServerConfiguration

	try
	{
		Write-Verbose -Message 'Change Application Server Configuration'

		# Cleanup
		$paramSetCsApplicationServer = $null

		# Splat reusable parameters
		$paramSetCsApplicationServer = @{
			Identity            = $FrontEndPool
			AppSharingPortStart = $AppSharingPortStart
			AppSharingPortCount = $AppSharingPortCount
			AudioPortStart      = $AudioPortStart
			AudioPortCount      = $AudioPortCount
			VideoPortStart      = $VideoPortStart
			VideoPortCount      = $VideoPortCount
			ErrorAction         = $STP
			WarningAction       = $SC
		}

		$null = (Set-CsApplicationServer @paramSetCsApplicationServer)

		Write-Verbose -Message 'Changed Application Server Configuration'
	}
	catch
	{
		Write-Warning -Message 'Unable to Set Application Server Configuration'
	}

	#endregion ChangeApplicationServerConfiguration

	#region ChangeMediationServerConfiguration

	try
	{
		Write-Verbose -Message 'Change Mediation Server Configuration'

		#Cleanup
		$paramSetCsMediationServer = $null


		# Splat reusable parameters
		$paramSetCsMediationServer = @{
			Identity       = $FrontEndPool
			AudioPortStart = $AudioPortStart
			AudioPortCount = $AudioPortCount
			ErrorAction    = $STP
			WarningAction  = $SC
		}

		$null = (Set-CsMediationServer @paramSetCsMediationServer)

		Write-Verbose -Message 'Changed Mediation Server Configuration'
	}
	catch
	{
		Write-Warning -Message 'Unable to Set Mediation Server Configuration'
	}

	#endregion ChangeMediationServerConfiguration

	#region ChangeWebServerConfiguration

	try
	{
		Write-Verbose -Message 'Change Web Server Configuration'

		#Cleanup
		$paramSetCsWebServer = $null

		# Splat reusable parameters
		$paramSetCsWebServer = @{
			Identity            = $FrontEndPool
			AppSharingPortStart = $AppSharingPortStart
			AppSharingPortCount = $AppSharingPortCount
			ErrorAction         = $STP
			WarningAction       = $SC
		}

		$null = (Set-CsWebServer @paramSetCsWebServer)

		Write-Verbose -Message 'Changed Web Server Configuration'
	}
	catch
	{
		Write-Warning -Message 'Unable to Set Web Server Configuration'
	}

	#endregion ChangeWebServerConfiguration

	#region ChangeEdgeServerConfiguration

	try
	{
		Write-Verbose -Message 'Change Edge Server Configuration'

		# Cleanup
		$paramSetCsEdgeServer = $null

		# Splat reusable parameters
		$paramSetCsEdgeServer = @{
			Identity                    = $EdgePool
			MediaCommunicationPortStart = $AudioPortStart
			MediaCommunicationPortCount = $MediaCommunicationPortCount
			ErrorAction                 = $STP
			WarningAction               = $SC
		}

		$null = (Set-CsEdgeServer @paramSetCsEdgeServer)

		Write-Verbose -Message 'Changed Edge Server Configuration'
	}
	catch
	{
		Write-Warning -Message 'Unable to Set Edge Server Configuration'
	}

	#endregion ChangeEdgeServerConfiguration
}

END
{
	Write-Output -InputObject 'Done with the Skype for Business QoS setup.'
}

#region License

<#
		Copyright (c) 2017, Joerg Hochwald. All rights reserved.

		Redistribution and use in source and binary forms, with or without
		modification, are permitted provided that the following conditions are met:
		* Redistributions of source code must retain the above copyright notice, this
		list of conditions and the following disclaimer.
		* Redistributions in binary form must reproduce the above copyright notice,
		this list of conditions and the following disclaimer in the documentation
		and/or other materials provided with the distribution.
		* Neither the name of the copyright holder nor the names of its
		contributors may be used to endorse or promote products derived from
		this software without specific prior written permission.

		THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
		AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
		IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
		DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
		FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
		DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
		SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
		CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
		OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
		OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

		By using the Software, you agree to the License, Terms and Conditions above!
#>

<#
		This is a third-party Software!

		The developer of this Software is NOT sponsored by or affiliated with Microsoft Corp (MSFT) or any of its subsidiaries in any way
		The Software is not supported by Microsoft Corp (MSFT)!
#>

#endregion License

# SIG # Begin signature block
# MIIYpQYJKoZIhvcNAQcCoIIYljCCGJICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUJKNj4zvcdSZMZZQ0T4B48+6g
# BkagghPNMIID7jCCA1egAwIBAgIQfpPr+3zGTlnqS5p31Ab8OzANBgkqhkiG9w0B
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
# ARUwIwYJKoZIhvcNAQkEMRYEFEtPEpVMsuxnBn6SBqEjxUFOe2JGMA0GCSqGSIb3
# DQEBAQUABIIBAGKd0qeKUjVCk78wSiwifdjFXTx+/JBvN+iWsFIV+z3nE1F+5xM2
# hJHegQ2LW4okd9ODYnOgi/kky677YAHZtp7/BQfiDhpoGSqWFO0lGYANdEHfniDL
# HnqDbTNg3bg+VdU9ywW1RcZyB05Ujo27gBYt6LQbRpzBT4mZSEHzNyAf1NXZX/C8
# DCMA+KwmKufaZfP598UD1s8m+IVpEERJEOsqCATBTpvaaiNczazNsVMoEShg3UVi
# XuhrG+pzCXws4ljAGxIbYkSkfZ74Bsh4j2a/vKuW6mOOSDaARlntE8eCX76JZMOW
# JvEBo57W8s7YPTJVlCWOKEFzpz16xIBcD+ShggILMIICBwYJKoZIhvcNAQkGMYIB
# +DCCAfQCAQEwcjBeMQswCQYDVQQGEwJVUzEdMBsGA1UEChMUU3ltYW50ZWMgQ29y
# cG9yYXRpb24xMDAuBgNVBAMTJ1N5bWFudGVjIFRpbWUgU3RhbXBpbmcgU2Vydmlj
# ZXMgQ0EgLSBHMgIQDs/0OMj+vzVuBNhqmBsaUDAJBgUrDgMCGgUAoF0wGAYJKoZI
# hvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTcxMjE0MDk0NDQ2
# WjAjBgkqhkiG9w0BCQQxFgQUoKDdaIkVu7j3Aci8NDkrazTRyUgwDQYJKoZIhvcN
# AQEBBQAEggEAG7tFmRjfZHncL/BGl4+fWms8gpll9XLpE6cGeQnaFAVEbdJFjGE8
# ETxgV72R88tH/27oSIHfuRp/moug2AZx3ccUV4eAgLJ6rTXxe1qbjD0BNvt45PuJ
# OsRL9387cZY1jdUNZeFA0k86kmUdxU7Jl5PEadUX2LNuv+sJoZf2dp6+0RA5QNvj
# 6/IRbMO51Hh16IIY4kyMJiFe+ne/8jKsnUeu2xEQnAmgqrq0rASt6EfzwZp6fQvz
# 2FQWq7Tkd0X5s6WSsDPqqp2mIINKGsC5V9K9HKF8hVJ2TU7DEzTEgWl6fSp010dw
# nYHIvNM2tkdzOnHnOTGYE+k66Ldq1Zsilg==
# SIG # End signature block
