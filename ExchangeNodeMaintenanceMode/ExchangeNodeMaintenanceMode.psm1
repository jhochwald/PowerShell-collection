#requires -Version 3.0 -Modules DnsClient, FailoverClusters

function Invoke-Exchange2016Workaround
{
	<#
			.SYNOPSIS
			Workaround for Exchange 2016 on Windows Server 2016
	
			.DESCRIPTION
			Workaround for Exchange 2016 on Windows Server 2016
	
			.EXAMPLE
			PS C:\> Invoke-Exchange2016Workaround
	
			.NOTES
			This is a quick an dirty one :)

			. LINK
			Set-ExchangeNodeMaintenanceModeOn
			Set-ExchangeNodeMaintenanceModeOff
			Test-ExchangeNodeMaintenanceMode
			Invoke-ApplyExchangeCumulativeUpdate
	#>
	
	$paramGetCommand = @{
		Name          = 'Get-MailboxDatabaseCopyStatus'
		ErrorAction   = 'SilentlyContinue'
		WarningAction = 'SilentlyContinue'
	}
	if (-not (Get-Command @paramGetCommand )) 
	{
		try 
		{
			$paramAddPSSnapin = @{
				Name = 'Microsoft.Exchange.Management.PowerShell.SnapIn'
			}
			Add-PSSnapin @paramAddPSSnapin
		}
		catch 
		{
			$paramWriteError = @{
				Message       = 'Sure that this is a Exchange Server?'
				ErrorAction   = 'Stop'
				WarningAction = 'SilentlyContinue'
			}
			Write-Error @paramWriteError 
		}
	}
}

function Set-ExchangeNodeMaintenanceModeOn
{
	<#
			.SYNOPSIS
			Set the Exchange Node to Service
	
			.DESCRIPTION
			Set the Exchange Node to Service
	
			.PARAMETER ComputerName
			Name of the Exchange Node, default is local system
	
			.EXAMPLE
			# Node is in Maintenance Mode
			PS C:\> Set-ExchangeNodeMaintenanceModeOn
			$false

			.EXAMPLE
			# Node is not in Maintenance Mode
			PS C:\> Set-ExchangeNodeMaintenanceModeOn
			$true

			.NOTES
			TODO: Find a detection for the Workaround
			TODO: Find a better solution for the certificate check issue

			. LINK
			Invoke-Exchange2016Workaround
			Set-ExchangeNodeMaintenanceModeOff
			Test-ExchangeNodeMaintenanceMode
			Invoke-ApplyExchangeCumulativeUpdate
	#>
	
	param
	(
		[Parameter(ValueFromPipeline = $true,
				ValueFromPipelineByPropertyName = $true,
		Position = 1)]
		[ValidateNotNullOrEmpty()]
		[string]
		$ComputerName = $env:COMPUTERNAME
	)
	
	Begin
	{
		# Workaround for Exchange 2016 on Windows Server 2016
		Invoke-Exchange2016Workaround
	}
	
	Process
	{
		# Draining the server
		$paramSetServerComponentState = @{
			identity  = $ComputerName
			Component = 'ServerWideOffline'
			State     = 'Draining'
			Requester = 'Maintenance'
		}
		Set-ServerComponentState @paramSetServerComponentState
		
		# Restart of the Sertvices enforces the draining
		$paramRestartService = @{
			Name          = 'MSExchangeTransport'
			Force         = $true
			ErrorAction   = 'SilentlyContinue'
			WarningAction = 'SilentlyContinue'
			Confirm       = $false
		}
		$null = (Restart-Service @paramRestartService)
		
		$paramRestartService = @{
			Name          = 'MSExchangeFrontEndTransport'
			Force         = $true
			ErrorAction   = 'SilentlyContinue'
			WarningAction = 'SilentlyContinue'
			Confirm       = $false
		}
		$null = (Restart-Service @paramRestartService)
		
		# Suspend the cluster node
		$paramSuspendClusterNode = @{
			Name    = $ComputerName
			Confirm = $false
		}
		$null = (Suspend-ClusterNode @paramSuspendClusterNode)
		
		# Move all databases to the other servers
		$paramSetMailboxServer = @{
			identity                                 = $ComputerName
			DatabaseCopyActivationDisabledAndMoveNow = $true
		}
		$null = (Set-MailboxServer @paramSetMailboxServer)
		
		# Get the Cluster Twin
		$PartnerNode = (Get-ClusterNode | Where-Object -FilterScript {
				$_.Name -ne $ComputerName
		} | Select-Object -ExpandProperty name)
		
		$paramResolveDnsName = @{
			Name = $PartnerNode
			Type = 'A'
		}
		$PartnerNodeFQDN = ((Resolve-DnsName @paramResolveDnsName).name)
		
		$paramSetServerComponentState = @{
			identity  = $ComputerName
			Component = 'ServerWideOffline'
			State     = 'Inactive'
			Requester = 'Maintenance'
		}
		$null = (Set-ServerComponentState @paramSetServerComponentState)
		
		$paramRedirectMessage = @{
			Server  = $ComputerName
			Target  = $PartnerNodeFQDN
			Confirm = $false
		}
		$null = (Redirect-Message @paramRedirectMessage)
	}
}

function Set-ExchangeNodeMaintenanceModeOff
{
	<#
			.SYNOPSIS
			Return Exchange Node to normal operation
	
			.DESCRIPTION
			Return Exchange Node to normal operation
	
			.PARAMETER ComputerName
			Name of the Exchange Node, default is local system
	
			.EXAMPLE
			# Enable normal operations

			PS C:\> Set-ExchangeNodeMaintenanceModeOff
			$true

			.EXAMPLE
			# Fails to enable noprmal operations

			PS C:\> Set-ExchangeNodeMaintenanceModeOff
			$false

			.NOTES

			. LINK
			Invoke-Exchange2016Workaround
			Set-ExchangeNodeMaintenanceModeOn
			Test-ExchangeNodeMaintenanceMode
			Invoke-ApplyExchangeCumulativeUpdate
	#>
	
	[OutputType([bool])]
	param
	(
		[Parameter(ValueFromPipeline = $true,
				ValueFromPipelineByPropertyName = $true,
		Position = 1)]
		[ValidateNotNullOrEmpty()]
		[string]
		$ComputerName = $env:COMPUTERNAME
	)
	
	Begin
	{
		# Workaround for Exchange 2016 on Windows Server 2016
		Invoke-Exchange2016Workaround
	}
	
	Process
	{
		try
		{
			# Activate the components
			$paramSetServerComponentState = @{
				identity  = $ComputerName
				Component = 'ServerWideOffline'
				State     = 'Active'
				Requester = 'Maintenance'
			}
			$null = (Set-ServerComponentState @paramSetServerComponentState)
			
			# Activate the Cluster Node
			$paramResumeClusterNode = @{
				Name          = $ComputerName
				ErrorAction   = 'Stop'
				WarningAction = 'SilentlyContinue'
			}
			$null = (Resume-ClusterNode @paramResumeClusterNode)
			
			# Activate the Databases
			$paramSetMailboxServer = @{
				identity                                 = $ComputerName
				DatabaseCopyAutoActivationPolicy         = 'Unrestricted'
				DatabaseCopyActivationDisabledAndMoveNow = $false
				ErrorAction                              = 'Stop'
				WarningAction                            = 'SilentlyContinue'
			}
			$null = (Set-MailboxServer @paramSetMailboxServer)
		}
		catch
		{
			return $false
		}

		# Default
		return $true
	}
}

function Test-ExchangeNodeMaintenanceMode
{
	<#
			.SYNOPSIS
			Check if the exchange node is in maintenance mode
	
			.DESCRIPTION
			Check if the exchange node is in maintenance mode
	
			.PARAMETER ComputerName
			Name of the Exchange Node, default is local system
	
			.EXAMPLE
			# Given node is in normal operation mode

			PS C:\> Test-ExchangeNodeMaintenanceMode
			$false

			.EXAMPLE
			# Given node is in maintenance mode

			PS C:\> Test-ExchangeNodeMaintenanceMode
			$true
	
			.NOTES
			TODO: The certificate handler is not perfect. Find a betetr solution!
			TODO: Need a few more checks.
	
			. LINK
			Invoke-Exchange2016Workaround
			Set-ExchangeNodeMaintenanceModeOn
			Set-ExchangeNodeMaintenanceModeOff
			Invoke-ApplyExchangeCumulativeUpdate
	#>
	
	[OutputType([bool])]
	param
	(
		[Parameter(ValueFromPipeline = $true,
				ValueFromPipelineByPropertyName = $true,
		Position = 1)]
		[ValidateNotNullOrEmpty()]
		[string]
		$ComputerName = $env:COMPUTERNAME
	)
	
	Begin
	{
		# Workaround for Exchange 2016 on Windows Server 2016
		Invoke-Exchange2016Workaround
		
		# Set the Default
		$IsFalse = $false
	}
	
	Process
	{
		# Wait until all databases are moved
		$paramGetMailboxDatabaseCopyStatus = @{
			server        = $ComputerName
			ErrorAction   = 'Stop'
			WarningAction = 'SilentlyContinue'
		}
		try
		{
			$ActiveDBs = $null
			$ActiveDBs = (Get-MailboxDatabaseCopyStatus @paramGetMailboxDatabaseCopyStatus | Where-Object -FilterScript {
					$_.Status -eq 'Mounted'
			})
		}
		catch
		{
			$IsFalse = $true
		}
		
		if ($ActiveDBs)
		{
			$IsFalse = $false
		}
		else
		{
			# Build the URL to check
			$URL = 'https://' + $ComputerName + '/owa/healthcheck.htm'
			
			# Ignore certificate warning (Will not match anyway)
			try 
			{
				Add-Type -TypeDefinition @'
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(
        ServicePoint srvPoint, X509Certificate certificate,
        WebRequest request, int certificateProblem) {
        return true;
    }
}
'@
			}
			catch
			{
				Write-Verbose -Message 'Unable to add new Type'
			}
			
			$paramNewObject = @{
				TypeName      = 'TrustAllCertsPolicy'
				ErrorAction   = 'SilentlyContinue'
				WarningAction = 'SilentlyContinue'
			}
			
			[Net.ServicePointManager]::CertificatePolicy = (New-Object @paramNewObject)
			
			try
			{
				$result = $null
				
				# Get the result
				$paramInvokeWebRequest = @{
					Uri           = $URL
					ErrorAction   = 'Stop'
					WarningAction = 'SilentlyContinue'
				}
				$result = $null
				$result = (Invoke-WebRequest @paramInvokeWebRequest)
			}
			catch
			{
				$IsFalse = $true
			}
			
			# Check the result
			if ($result.StatusCode -eq '200')
			{
				$IsFalse = $false
			}
		}
	}
	
	End
	{
		# Default
		return $IsFalse
	}
}

function Invoke-ApplyExchangeCumulativeUpdate
{
	<#
			.SYNOPSIS
			Apply an Exchange Cumulative Update
	
			.DESCRIPTION
			Apply an Exchange Cumulative Update, with the optional AD and Schema
			update, and an optional UM language Update.
	
			.PARAMETER Source
			Source Directory of the Exchange Cumulative Update, must exist.
	
			.PARAMETER Prepare
			Run prepare of Schema, Active Directory and AD Domain.
			Enabled by default
	
			.PARAMETER UMLangHandling
			Handle the UMLangHandling.
			Disabled by default
	
			.PARAMETER UMLangSource
			Source Directory of the UM Lang Packs, must exist
	
			.PARAMETER UMLanguages
			UM Languages to handle. This is one string that should contain all languages.
	
			.EXAMPLE
			# Use the defaults to install the CU
			PS C:\> Invoke-ApplyExchangeCumulativeUpdate
	
			.EXAMPLE
			# Use the defaults to install the CU, where '\\SERVER\Share\' is the
			# location of the CU (Sources)
			PS C:\> Invoke-ApplyExchangeCumulativeUpdate -Source '\\SERVER\Share\'
	
			.EXAMPLE
			# Install the the and the updates the default UM Languages from a given location
			PS C:\> Invoke-ApplyExchangeCumulativeUpdate -Source '\\SERVER\Share\' -UMLangHandling -UMLangSource '\\SERVER\Share\UM-Updates\'
	
			.EXAMPLE
			# Install the the and the updates the given UM Languages
			PS C:\> Invoke-ApplyExchangeCumulativeUpdate -UMLangHandling -UMLanguages = 'es-MX,es-ES'
	
			.NOTES
			TODO: Error handling. At the moment it is just a fire an forget thing!
	
			This function is just a wrapper for the default SETUP.EXE of the
			Exchange Cumulative Update package.
			You might tweak the directory variable. Or just use the parameter.
	
			. LINK
			Invoke-Exchange2016Workaround
			Set-ExchangeNodeMaintenanceModeOn
			Set-ExchangeNodeMaintenanceModeOff
			Test-ExchangeNodeMaintenanceMode
	#>
	
	[CmdletBinding()]
	param
	(
		[Parameter(ValueFromPipeline = $true,
				ValueFromPipelineByPropertyName = $true,
		Position = 1)]
		[ValidateNotNullOrEmpty()]
		[string]
		$Source = 'E:\',
		[Parameter(ValueFromPipeline = $true,
				ValueFromPipelineByPropertyName = $true,
		Position = 2)]
		[switch]
		$Prepare = $true,
		[Parameter(ValueFromPipeline = $true,
				ValueFromPipelineByPropertyName = $true,
		Position = 3)]
		[switch]
		$UMLangHandling = $null,
		[Parameter(ValueFromPipeline = $true,
				ValueFromPipelineByPropertyName = $true,
		Position = 4)]
		[string]
		$UMLangSource = 'F:\',
		[Parameter(ValueFromPipeline = $true,
				ValueFromPipelineByPropertyName = $true,
		Position = 5)]
		[string]
		$UMLanguages = 'de-DE,en-GB,en-US'
	)
	
	BEGIN
	{
		# Check if the given Directory conains the setup
		
		if ($UMLangHandling)
		{
			# Check if the given directory exists
		}
		
		if ($Prepare)
		{
			# Change to the Installer location
			Push-Location -Path $Source
			
			# Start the Setup
			.\Setup.exe /PrepareSchema /IAcceptExchangeServerLicenseTerms
			.\Setup.exe /PrepareAD /IAcceptExchangeServerLicenseTerms
			.\Setup.exe /PrepareDomain /IAcceptExchangeServerLicenseTerms
			
			# Return
			Pop-Location
		}
	}
	
	PROCESS
	{
		if ($UMLangHandling)
		{
			# Remove the old UM Languages
			# Change to the Installer location
			Push-Location -Path $Source
			
			# Start the Setup
			.\Setup.exe /RemoveUMLanguagePack:$UMLanguages
			
			# Return
			Pop-Location
		}
		
		# Default installation
		# Change to the Installer location
		Push-Location -Path $Source
			
		# Start the Setup
		.\Setup.exe /PrepareSchema /IAcceptExchangeServerLicenseTerms
		.\Setup.exe /PrepareAD /IAcceptExchangeServerLicenseTerms
		.\Setup.exe /PrepareDomain /IAcceptExchangeServerLicenseTerms
			
		# Return
		Pop-Location
		
		if ($UMLangHandling)
		{
			#
			# Change to the Installer location
			Push-Location -Path $Source
			
			# Start the Setup
			.\Setup.exe /AddUMLanguagePack:$UMLanguages /s:$UMLangSource /IAcceptExchangeServerLicenseTerms
			
			# Return
			Pop-Location
		}
	}
	
	END
	{
		# Cleanup
	}
}

Export-ModuleMember -Function Invoke-Exchange2016Workaround, Set-ExchangeNodeMaintenanceModeOn, Set-ExchangeNodeMaintenanceModeOff, Test-ExchangeNodeMaintenanceMode, Invoke-ApplyExchangeCumulativeUpdate

# SIG # Begin signature block
# MIITegYJKoZIhvcNAQcCoIITazCCE2cCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUt0PhsYSC6gNgNL8nT8KuJ9QU
# 2qCggg4LMIIEFDCCAvygAwIBAgILBAAAAAABL07hUtcwDQYJKoZIhvcNAQEFBQAw
# VzELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExEDAOBgNV
# BAsTB1Jvb3QgQ0ExGzAZBgNVBAMTEkdsb2JhbFNpZ24gUm9vdCBDQTAeFw0xMTA0
# MTMxMDAwMDBaFw0yODAxMjgxMjAwMDBaMFIxCzAJBgNVBAYTAkJFMRkwFwYDVQQK
# ExBHbG9iYWxTaWduIG52LXNhMSgwJgYDVQQDEx9HbG9iYWxTaWduIFRpbWVzdGFt
# cGluZyBDQSAtIEcyMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAlO9l
# +LVXn6BTDTQG6wkft0cYasvwW+T/J6U00feJGr+esc0SQW5m1IGghYtkWkYvmaCN
# d7HivFzdItdqZ9C76Mp03otPDbBS5ZBb60cO8eefnAuQZT4XljBFcm05oRc2yrmg
# jBtPCBn2gTGtYRakYua0QJ7D/PuV9vu1LpWBmODvxevYAll4d/eq41JrUJEpxfz3
# zZNl0mBhIvIG+zLdFlH6Dv2KMPAXCae78wSuq5DnbN96qfTvxGInX2+ZbTh0qhGL
# 2t/HFEzphbLswn1KJo/nVrqm4M+SU4B09APsaLJgvIQgAIMboe60dAXBKY5i0Eex
# +vBTzBj5Ljv5cH60JQIDAQABo4HlMIHiMA4GA1UdDwEB/wQEAwIBBjASBgNVHRMB
# Af8ECDAGAQH/AgEAMB0GA1UdDgQWBBRG2D7/3OO+/4Pm9IWbsN1q1hSpwTBHBgNV
# HSAEQDA+MDwGBFUdIAAwNDAyBggrBgEFBQcCARYmaHR0cHM6Ly93d3cuZ2xvYmFs
# c2lnbi5jb20vcmVwb3NpdG9yeS8wMwYDVR0fBCwwKjAooCagJIYiaHR0cDovL2Ny
# bC5nbG9iYWxzaWduLm5ldC9yb290LmNybDAfBgNVHSMEGDAWgBRge2YaRQ2XyolQ
# L30EzTSo//z9SzANBgkqhkiG9w0BAQUFAAOCAQEATl5WkB5GtNlJMfO7FzkoG8IW
# 3f1B3AkFBJtvsqKa1pkuQJkAVbXqP6UgdtOGNNQXzFU6x4Lu76i6vNgGnxVQ380W
# e1I6AtcZGv2v8Hhc4EvFGN86JB7arLipWAQCBzDbsBJe/jG+8ARI9PBw+DpeVoPP
# PfsNvPTF7ZedudTbpSeE4zibi6c1hkQgpDttpGoLoYP9KOva7yj2zIhd+wo7AKvg
# IeviLzVsD440RZfroveZMzV+y5qKu0VN5z+fwtmK+mWybsd+Zf/okuEsMaL3sCc2
# SI8mbzvuTXYfecPlf5Y1vC0OzAGwjn//UYCAp5LUs0RGZIyHTxZjBzFLY7Df8zCC
# BJ8wggOHoAMCAQICEhEh1pmnZJc+8fhCfukZzFNBFDANBgkqhkiG9w0BAQUFADBS
# MQswCQYDVQQGEwJCRTEZMBcGA1UEChMQR2xvYmFsU2lnbiBudi1zYTEoMCYGA1UE
# AxMfR2xvYmFsU2lnbiBUaW1lc3RhbXBpbmcgQ0EgLSBHMjAeFw0xNjA1MjQwMDAw
# MDBaFw0yNzA2MjQwMDAwMDBaMGAxCzAJBgNVBAYTAlNHMR8wHQYDVQQKExZHTU8g
# R2xvYmFsU2lnbiBQdGUgTHRkMTAwLgYDVQQDEydHbG9iYWxTaWduIFRTQSBmb3Ig
# TVMgQXV0aGVudGljb2RlIC0gRzIwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK
# AoIBAQCwF66i07YEMFYeWA+x7VWk1lTL2PZzOuxdXqsl/Tal+oTDYUDFRrVZUjtC
# oi5fE2IQqVvmc9aSJbF9I+MGs4c6DkPw1wCJU6IRMVIobl1AcjzyCXenSZKX1GyQ
# oHan/bjcs53yB2AsT1iYAGvTFVTg+t3/gCxfGKaY/9Sr7KFFWbIub2Jd4NkZrItX
# nKgmK9kXpRDSRwgacCwzi39ogCq1oV1r3Y0CAikDqnw3u7spTj1Tk7Om+o/SWJMV
# TLktq4CjoyX7r/cIZLB6RA9cENdfYTeqTmvT0lMlnYJz+iz5crCpGTkqUPqp0Dw6
# yuhb7/VfUfT5CtmXNd5qheYjBEKvAgMBAAGjggFfMIIBWzAOBgNVHQ8BAf8EBAMC
# B4AwTAYDVR0gBEUwQzBBBgkrBgEEAaAyAR4wNDAyBggrBgEFBQcCARYmaHR0cHM6
# Ly93d3cuZ2xvYmFsc2lnbi5jb20vcmVwb3NpdG9yeS8wCQYDVR0TBAIwADAWBgNV
# HSUBAf8EDDAKBggrBgEFBQcDCDBCBgNVHR8EOzA5MDegNaAzhjFodHRwOi8vY3Js
# Lmdsb2JhbHNpZ24uY29tL2dzL2dzdGltZXN0YW1waW5nZzIuY3JsMFQGCCsGAQUF
# BwEBBEgwRjBEBggrBgEFBQcwAoY4aHR0cDovL3NlY3VyZS5nbG9iYWxzaWduLmNv
# bS9jYWNlcnQvZ3N0aW1lc3RhbXBpbmdnMi5jcnQwHQYDVR0OBBYEFNSihEo4Whh/
# uk8wUL2d1XqH1gn3MB8GA1UdIwQYMBaAFEbYPv/c477/g+b0hZuw3WrWFKnBMA0G
# CSqGSIb3DQEBBQUAA4IBAQCPqRqRbQSmNyAOg5beI9Nrbh9u3WQ9aCEitfhHNmmO
# 4aVFxySiIrcpCcxUWq7GvM1jjrM9UEjltMyuzZKNniiLE0oRqr2j79OyNvy0oXK/
# bZdjeYxEvHAvfvO83YJTqxr26/ocl7y2N5ykHDC8q7wtRzbfkiAD6HHGWPZ1BZo0
# 8AtZWoJENKqA5C+E9kddlsm2ysqdt6a65FDT1De4uiAO0NOSKlvEWbuhbds8zkSd
# wTgqreONvc0JdxoQvmcKAjZkiLmzGybu555gxEaovGEzbM9OuZy5avCfN/61PU+a
# 003/3iCOTpem/Z8JvE3KGHbJsE2FUPKA0h0G9VgEB7EYMIIFTDCCBDSgAwIBAgIQ
# FtT3Ux2bGCdP8iZzNFGAXDANBgkqhkiG9w0BAQsFADB9MQswCQYDVQQGEwJHQjEb
# MBkGA1UECBMSR3JlYXRlciBNYW5jaGVzdGVyMRAwDgYDVQQHEwdTYWxmb3JkMRow
# GAYDVQQKExFDT01PRE8gQ0EgTGltaXRlZDEjMCEGA1UEAxMaQ09NT0RPIFJTQSBD
# b2RlIFNpZ25pbmcgQ0EwHhcNMTUwNzE3MDAwMDAwWhcNMTgwNzE2MjM1OTU5WjCB
# kDELMAkGA1UEBhMCREUxDjAMBgNVBBEMBTM1NTc2MQ8wDQYDVQQIDAZIZXNzZW4x
# EDAOBgNVBAcMB0xpbWJ1cmcxGDAWBgNVBAkMD0JhaG5ob2ZzcGxhdHogMTEZMBcG
# A1UECgwQS3JlYXRpdlNpZ24gR21iSDEZMBcGA1UEAwwQS3JlYXRpdlNpZ24gR21i
# SDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAK8jDmF0TO09qJndJ9eG
# Fqra1lf14NDhM8wIT8cFcZ/AX2XzrE6zb/8kE5sL4/dMhuTOp+SMt0tI/SON6BY3
# 208v/NlDI7fozAqHfmvPhLX6p/TtDkmSH1sD8AIyrTH9b27wDNX4rC914Ka4EBI8
# sGtZwZOQkwQdlV6gCBmadar+7YkVhAbIIkSazE9yyRTuffidmtHV49DHPr+ql4ji
# NJ/K27ZFZbwM6kGBlDBBSgLUKvufMY+XPUukpzdCaA0UzygGUdDfgy0htSSp8MR9
# Rnq4WML0t/fT0IZvmrxCrh7NXkQXACk2xtnkq0bXUIC6H0Zolnfl4fanvVYyvD88
# qIECAwEAAaOCAbIwggGuMB8GA1UdIwQYMBaAFCmRYP+KTfrr+aZquM/55ku9Sc4S
# MB0GA1UdDgQWBBSeVG4/9UvVjmv8STy4f7kGHucShjAOBgNVHQ8BAf8EBAMCB4Aw
# DAYDVR0TAQH/BAIwADATBgNVHSUEDDAKBggrBgEFBQcDAzARBglghkgBhvhCAQEE
# BAMCBBAwRgYDVR0gBD8wPTA7BgwrBgEEAbIxAQIBAwIwKzApBggrBgEFBQcCARYd
# aHR0cHM6Ly9zZWN1cmUuY29tb2RvLm5ldC9DUFMwQwYDVR0fBDwwOjA4oDagNIYy
# aHR0cDovL2NybC5jb21vZG9jYS5jb20vQ09NT0RPUlNBQ29kZVNpZ25pbmdDQS5j
# cmwwdAYIKwYBBQUHAQEEaDBmMD4GCCsGAQUFBzAChjJodHRwOi8vY3J0LmNvbW9k
# b2NhLmNvbS9DT01PRE9SU0FDb2RlU2lnbmluZ0NBLmNydDAkBggrBgEFBQcwAYYY
# aHR0cDovL29jc3AuY29tb2RvY2EuY29tMCMGA1UdEQQcMBqBGGhvY2h3YWxkQGty
# ZWF0aXZzaWduLm5ldDANBgkqhkiG9w0BAQsFAAOCAQEASSZkxKo3EyEk/qW0ZCs7
# CDDHKTx3UcqExigsaY0DRo9fbWgqWynItsqdwFkuQYJxzknqm2JMvwIK6BtfWc64
# WZhy0BtI3S3hxzYHxDjVDBLBy91kj/mddPjen60W+L66oNEXiBuIsOcJ9e7tH6Vn
# 9eFEUjuq5esoJM6FV+MIKv/jPFWMp5B6EtX4LDHEpYpLRVQnuxoc38mmd+NfjcD2
# /o/81bu6LmBFegHAaGDpThGf8Hk3NVy0GcpQ3trqmH6e3Cpm8Ut5UkoSONZdkYWw
# rzkmzFgJyoM2rnTMTh4ficxBQpB7Ikv4VEnrHRReihZ0zwN+HkXO1XEnd3hm+08j
# LzGCBNkwggTVAgEBMIGRMH0xCzAJBgNVBAYTAkdCMRswGQYDVQQIExJHcmVhdGVy
# IE1hbmNoZXN0ZXIxEDAOBgNVBAcTB1NhbGZvcmQxGjAYBgNVBAoTEUNPTU9ETyBD
# QSBMaW1pdGVkMSMwIQYDVQQDExpDT01PRE8gUlNBIENvZGUgU2lnbmluZyBDQQIQ
# FtT3Ux2bGCdP8iZzNFGAXDAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAig
# AoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgEL
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUuhrqH/M37MCPx0sgc1pm
# J1gSd68wDQYJKoZIhvcNAQEBBQAEggEAPAlPN8JFQWrVU20pV8VDaT+nmMZjc5j+
# traBgrtmfOt3ZP+4RsdbpfimDHJNQ1mnwgfJIfayBZVd4R6ds53fRIR9ZWmehqFY
# S0+KOKlUJze83KiUJMmh5HNQQI+T3shQllBexNXVTlNiVuy/C68J0oTlNqM5v/yf
# 7SIJ/LXs+rDn40MvZosxMqY2ApJ8/Xu+fkFuK9eOO/xv83zOshVM/pJZqdLN5DXl
# VUg3o9DfaFfXjWkN4vqkKH05OAJ4+nHICFE02DkPP7tElqzZ1/n1INQEbFadyQd8
# IP1Dfx+pRk/E56wyRtsLoixn8T/orsKUJgFVdBFDr2W9ULrC5aNt1qGCAqIwggKe
# BgkqhkiG9w0BCQYxggKPMIICiwIBATBoMFIxCzAJBgNVBAYTAkJFMRkwFwYDVQQK
# ExBHbG9iYWxTaWduIG52LXNhMSgwJgYDVQQDEx9HbG9iYWxTaWduIFRpbWVzdGFt
# cGluZyBDQSAtIEcyAhIRIdaZp2SXPvH4Qn7pGcxTQRQwCQYFKw4DAhoFAKCB/TAY
# BgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0xNzA2MTYx
# MDU0NDNaMCMGCSqGSIb3DQEJBDEWBBSRGuTTxVN72NjUomv59tCCUJLl2TCBnQYL
# KoZIhvcNAQkQAgwxgY0wgYowgYcwgYQEFGO4L6th9YOQlpUFCwAknFApM+x5MGww
# VqRUMFIxCzAJBgNVBAYTAkJFMRkwFwYDVQQKExBHbG9iYWxTaWduIG52LXNhMSgw
# JgYDVQQDEx9HbG9iYWxTaWduIFRpbWVzdGFtcGluZyBDQSAtIEcyAhIRIdaZp2SX
# PvH4Qn7pGcxTQRQwDQYJKoZIhvcNAQEBBQAEggEAg6OHBxAZ9rmdmtlnOB2odvWo
# 3W/YLKZsE4/bkTbMQhsGVajU25Vx48IrIMKdUk+QQVWFDJPpc0QGFyW0UFleqB3n
# PEmyQAsd2plBiEv3oQrb2/RjybIXSomW6I8723fg7cp0FJ/sLYkv3uIwqVfLClpS
# jeb9Ttbdvk46DyXJepVw8bachCnO48rkCgPV+O38s64XirfKpDGkSZuW19ni0EOJ
# TlL+309oYYEoGByRsCZuVTII8mBhPTOPR6+X+4d7extPsBq6m3Pbo/5IhZlk8U0T
# RhINqaKDBU0kkCbQbM8HvHCTXrlgiB4mBj3RgLR9ETdIdkDMaMPQOviDsCAsIQ==
# SIG # End signature block
