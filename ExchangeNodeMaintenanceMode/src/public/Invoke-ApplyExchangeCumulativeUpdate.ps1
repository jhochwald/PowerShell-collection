function Invoke-ApplyExchangeCumulativeUpdate
{
	<#
			.SYNOPSIS
			Apply an Exchange Cumulative Update
	
			.DESCRIPTION
			Apply an Exchange Cumulative Update, with the optional AD and Schema updates,
			and additional UM language packs update.

			Please read the Release Notes from Microsoft carefully, some updates need an Active
			Directory schema and/or Active Directory and/or Active Directory domain updates.
			If this is the case, please use the "Prepare" Switch on ONE Node!

			Nevertheless, please keep in mind, that you do NOT need to run the command with this
			Switch more than once. However, even if, the Switch will not harm in any kind,
			it is just a waste of time, and the installation will take longer.

			.PARAMETER Source
			Source Directory of the Exchange Cumulative Update.
			Must exist.
	
			.PARAMETER Prepare
			Run prepare of Schema, Active Directory and AD Domain.
			You need to do this one one Node. the 2nd one could run the installer without it.
			Enabled by default
	
			.PARAMETER UMLangHandling
			Handle the UM Language(s).
			Disabled by default
	
			.PARAMETER UMLangSource
			Source Directory of the UM Language Pack(s).
			The Directory must exist!
	
			.PARAMETER UMLanguages
			UM Languages to handle.
			This is one string that should contain all languages.
	
			.EXAMPLE
			# Use the defaults to install the CU

			PS > Invoke-ApplyExchangeCumulativeUpdate

			Microsoft Exchange Server 2016 Cumulative Update 6 Unattended Setup
			Copying Files...
			File copy complete. Setup will now collect additional information needed for installation.
			Performing Microsoft Exchange Server Prerequisite Check
			Prerequisite Analysis                                                                             COMPLETED
			Extending Active Directory schema                                                                 COMPLETED
			Organization Preparation                                                                          COMPLETED

			.EXAMPLE
			# Use the defaults to install the CU, where '\\SERVER\Share\' is the location of the CU (Sources)

			PS > Invoke-ApplyExchangeCumulativeUpdate -Source '\\SERVER\Share\'

			Performing Microsoft Exchange Server Prerequisite Check

			Configuring Prerequisites                                                                         COMPLETED
			Prerequisite Analysis                                                                             COMPLETED

			Configuring Microsoft Exchange Server

			Preparing Setup                                                                                   COMPLETED
			Stopping Services                                                                                 COMPLETED
			Language Files                                                                                    COMPLETED
			Removing Exchange Files                                                                           COMPLETED
			Preparing Files                                                                                   COMPLETED
			Copying Exchange Files                                                                            COMPLETED
			Language Files                                                                                    COMPLETED
			Restoring Services                                                                                COMPLETED
			Language Configuration                                                                            COMPLETED
			Exchange Management Tools                                                                         COMPLETED
			Mailbox role: Transport service                                                                   COMPLETED
			Mailbox role: Client Access service                                                               COMPLETED
			Mailbox role: Unified Messaging service                                                           COMPLETED
			Mailbox role: Mailbox service                                                                     COMPLETED
			Mailbox role: Front End Transport service                                                         COMPLETED
			Mailbox role: Client Access Front End service                                                     COMPLETED
			Finalizing Setup                                                                                  COMPLETED
	
			.EXAMPLE
			# Install the the and the updates the default UM Languages from a given location
			PS > Invoke-ApplyExchangeCumulativeUpdate -Source '\\SERVER\Share\' -UMLangHandling -UMLangSource '\\SERVER\Share\UM-Updates\'

			.EXAMPLE
			# Install the the and the updates the given UM Languages
			PS > Invoke-ApplyExchangeCumulativeUpdate -UMLangHandling -UMLanguages 'es-MX,es-ES'

			Microsoft Exchange Server 2016 Cumulative Update 6 Unattended Setup

			UM Language Pack for es-MX
			UM Language Pack for es-ES

			Performing Microsoft Exchange Server Prerequisite Check

			Prerequisite Analysis                                                                             COMPLETED

			Configuring Microsoft Exchange Server

			UM language pack for (es-MX)                                                                      COMPLETED
			UM language pack for (es-ES)                                                                      COMPLETED

			The Exchange Server setup operation completed successfully.
	
			.NOTES
			TODO: Error handling. At the moment it is just a fire an forget thing!
	
			This function is just a wrapper for the default SETUP.EXE of the Exchange Cumulative 
			Update package and the UM Language Pack update(s).

			You might tweak the directory variable. Or just use the parameters to do so.

			Someone asked me: "Why not stopping the Windows Defender during the update? Defender will
			consume a lot of CPU." I agree; it will use some CPU during the update, but I'm not a fan
			of doing this. There is a reason for an Anti-Virus tool, by stopping the scan engine the
			system would be at risk! And this is something I don't want a system I'm responsible for!
			If you want to do something like this, this is your decision. However, I "highly" recommend
			not doing it. And this applies to all AV scanners on your servers!

			One last thing: Be patient if you install the Exchange Cumulative Update! The preparation
			(e.g. Schema, Active Directory and Domain) should be quick, even if you environment is
			distributed. The removal of the old installation and especially the update installation
			with the restart of all services might take a while to complete (depending on your
			hardware, it could be 30 minutes, or more!).
			Why this is important: During the installation, the other Node(s) needs to handle the load,
			and you might need to communicate, that you have the risk of a single point of failure.
	
			. LINK
			Invoke-Exchange2016Workaround
			Set-ExchangeNodeMaintenanceModeOn
			Set-ExchangeNodeMaintenanceModeOff
			Test-ExchangeNodeMaintenanceMode
	#>
	
	[CmdletBinding(ConfirmImpact = 'Medium',
	SupportsShouldProcess = $true)]
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
		$UMLanguages = 'de-DE,en-GB'
	)
	
	BEGIN
	{

		# Are we admin and elevated?
		if (Get-Command -Name Get-ExchangeAdminExecution -ErrorAction SilentlyContinue) 
		{
			try 
			{
				if ($pscmdlet.ShouldProcess('PowerShell Session', 'Check if execution is elevated'))
				{
					Get-ExchangeAdminExecution
				}
			}
			catch 
			{
				break
			}
		}
		else 
		{
			Write-Warning -Message 'Unable to check if this is an elevated Session!'
			break
		}

		# Check the Exeution Policy
		if (Get-Command -Name Get-ExchangeExecutionPolicy -ErrorAction SilentlyContinue) 
		{
			try 
			{
				if ($pscmdlet.ShouldProcess('PowerShell Session', 'Check Execution Policy'))
				{
					Get-ExchangeExecutionPolicy
				}
			}
			catch 
			{
				break
			}
		}
		else 
		{
			Write-Warning -Message 'Unable to check your PowerShell Execution Policy. Please do it by yourself!' -ErrorAction Stop
			break
		}

		# Check if the given Directory conains the setup
		if ($UMLangHandling)
		{
			# Check if the given directory exists
			If (-not (Test-Path -Path $UMLangSource -ErrorAction Stop))
			{
				Write-Error -Message "The given Directory ($UMLangSource) does NOT exist!" -ErrorAction Stop
				break
			}
		}
		
		if ($Prepare)
		{
			# Change to the Installer location
			Push-Location -Path $Source
			
			# Start the Setup
			if ($pscmdlet.ShouldProcess('AD Schema', 'Prepare'))
			{
				Write-Verbose -Message 'Prepare AD Schema'
				.\Setup.exe /PrepareSchema /IAcceptExchangeServerLicenseTerms
			}

			if ($pscmdlet.ShouldProcess('Active Directory', 'Prepare'))
			{
				Write-Verbose -Message 'Prepare AD'
				.\Setup.exe /PrepareAD /IAcceptExchangeServerLicenseTerms
			}

			if ($pscmdlet.ShouldProcess('Active Directory Domain', 'Prepare'))
			{
				Write-Verbose -Message 'Prepare AD Domain'
				.\Setup.exe /PrepareDomain /IAcceptExchangeServerLicenseTerms
			}

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
			if ($pscmdlet.ShouldProcess('UM Language Pack(s)', 'Remove'))
			{
				Write-Verbose -Message 'Remove UM Language Pack'
				.\Setup.exe /RemoveUMLanguagePack:$UMLanguages
			}

			# Return
			Pop-Location
		}
		
		# Default installation
		# Change to the Installer location
		Push-Location -Path $Source
			
		# Start the Setup
		if ($pscmdlet.ShouldProcess('Exchange Installation', 'upgrade'))
		{
			Write-Verbose -Message 'Start the Update: Now is the perfect time to get yourself a coffee...'
			.\Setup.exe /m:upgrade /IAcceptExchangeServerLicenseTerms
		}
		
			
		# Return
		Pop-Location
		
		if ($UMLangHandling)
		{
			#
			# Change to the Installer location
			Push-Location -Path $Source
			
			# Start the Setup
			if ($pscmdlet.ShouldProcess('UM language(s)', "Installation of $UMLanguages from $UMLangSource"))
			{
				Write-Verbose -Message 'Ok, now we update the UM language(s).'
				#.\Setup.exe /AddUMLanguagePack:$UMLanguages /s:$UMLangSource /IAcceptExchangeServerLicenseTerms
				Write-Warning -Message 'The UM language pack installation is delayed! In most cases a reboot if needed before installing these.'
				Write-Output -InputObject "Please reboot an then execute this command: .\Setup.exe /AddUMLanguagePack:$UMLanguages /s:$UMLangSource /IAcceptExchangeServerLicenseTerms"
			}

			# Return
			Pop-Location
		}
	}
	
	END
	{
		# Cleanup will come soon.
		Write-Verbose -Message 'You are a hero! You have updated your Exchange Node.'
	}
}
