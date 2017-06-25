function Invoke-ApplyExchangeCumulativeUpdate
{
	<#
    .EXTERNALHELP ExchangeNodeMaintenanceMode-help.xml
    .LINK
        https://github.com/jhochwald/PowerShell-collection/tree/master/release/1.0.0.7/docs/Functions/Invoke-ApplyExchangeCumulativeUpdate.md
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

