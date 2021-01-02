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
	
	BEGIN 
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
				Message       = $ErrorMessage
				ErrorAction   = $STP
				WarningAction = $SC
			}
			
			Write-Error @paramWriteError 
			break
		}
		
		if (-not ($ActiveDirectoryInfo))
		{
			$paramWriteError = @{
				Message       = $ErrorMessage
				ErrorAction   = $STP
				WarningAction = $SC
			}
			
			Write-Error @paramWriteError 
			break
		}
		
		# Create a new Object
		$ADExchangeInfo = @()
	}

	PROCESS
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
									path    = $_.properties.msexchinternalhostname[0]
									server  = $SingleServer
									Site    = $SingleActiveDirectorySite
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

	END
	{
		# Just dump the plain object
		if ($ADExchangeInfo) 
		{
			$ADExchangeInfo
		}
		else 
		{
			$paramWriteError = @{
				Message       = $ErrorMessage
				ErrorAction   = $STP
				WarningAction = $SC
			}
			
			Write-Error @paramWriteError 
			break
		}
	}
}
Get-ADExchangeServers