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
			PS > Invoke-ApplyExchangeCumulativeUpdate
	
			.EXAMPLE
			# Use the defaults to install the CU, where '\\SERVER\Share\' is the location of the CU (Sources)
			PS > Invoke-ApplyExchangeCumulativeUpdate -Source '\\SERVER\Share\'
	
			.EXAMPLE
			# Install the the and the updates the default UM Languages from a given location
			PS > Invoke-ApplyExchangeCumulativeUpdate -Source '\\SERVER\Share\' -UMLangHandling -UMLangSource '\\SERVER\Share\UM-Updates\'
	
			.EXAMPLE
			# Install the the and the updates the given UM Languages
			PS > Invoke-ApplyExchangeCumulativeUpdate -UMLangHandling -UMLanguages = 'es-MX,es-ES'
	
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
