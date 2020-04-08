function Get-TeamsServiceNumbers
{
   <#
         .SYNOPSIS
         Get the Phone numbers assigned to Teams/SfB Services

         .DESCRIPTION
         Get the Phone numbers assigned to Teams/SfB Services
         Supported are AutoAttendant and/or CallQueue

         .PARAMETER AutoAttendant
         Get the numbers assigned to AutoAttendant(s)

         .PARAMETER CallQueue
         Get the numbers assigned to CallQueue(s)

         .PARAMETER All
         Get all Numbers, assignee to AutoAttendant(s) and CallQueue(s)

         .PARAMETER LeaveTel
         Normally the function dumps phone numbers with a stripped tel:
			With this switch the function will dump it with the leading tel:

         .PARAMETER Export
         Export the result to a CSV

         .PARAMETER Path
         Path for the CSV Export

         .EXAMPLE
         PS C:\> Get-TeamsServiceNumbers -All

			Get all Services numbers, AutoAttendant(s) and CallQueue(s), and dump them to the terminal

			.EXAMPLE
         PS C:\> Get-TeamsServiceNumbers -All -Export -Path '.\TeamsServiceNumbers.csv'

			Get all Services numbers, AutoAttendant(s) and CallQueue(s), and export them to the given CSV file '.\TeamsServiceNumbers.csv'
			TeamsServiceNumbers.csv is in the directory where the user is right now (and calls the function)

			.EXAMPLE
         PS C:\> Get-TeamsServiceNumbers -All -Export -Path 'c:\temp\TeamsServiceNumbers.csv'

			Get all Services numbers, AutoAttendant(s) and CallQueue(s), and export them to the given CSV file 'c:\temp\TeamsServiceNumbers.csv'

			.EXAMPLE
         PS C:\> Get-TeamsServiceNumbers -All -Export

			Get all Services numbers, AutoAttendant(s) and CallQueue(s), and export them to a CSV
			The funtion will ask for the Path to the CSV File

			.EXAMPLE
         PS C:\> Get-TeamsServiceNumbers -AutoAttendant

			Get all AutoAttendant(s) Services numbers and dump them to the terminal

			.EXAMPLE
         PS C:\> Get-TeamsServiceNumbers -AA

			Get all AutoAttendant(s) Services numbers and dump them to the terminal
			Same as above, but use the Alias (Shorter)

			.EXAMPLE
         PS C:\> Get-TeamsServiceNumbers -CallQueue

			Get all CallQueue(s) Services numbers and dump them to the terminal

			.EXAMPLE
         PS C:\> Get-TeamsServiceNumbers -CQ

			Get all CallQueue(s) Services numbers and dump them to the terminal
			Same as above, but use the Alias (Shorter)

         .NOTES
         Additional information about the function.
   #>

	[CmdletBinding(DefaultParameterSetName = 'AllNumbers',
						ConfirmImpact = 'None')]
	[OutputType([psobject])]
	param
	(
		[Parameter(ParameterSetName = 'AANumbers',
					  ValueFromPipeline = $true,
					  ValueFromPipelineByPropertyName = $true)]
		[Alias('AA')]
		[switch]
		$AutoAttendant = $null,
		[Parameter(ParameterSetName = 'CQNumbers',
					  ValueFromPipeline = $true,
					  ValueFromPipelineByPropertyName = $true)]
		[Alias('CQ')]
		[switch]
		$CallQueue = $null,
		[Parameter(ParameterSetName = 'AllNumbers',
					  ValueFromPipeline = $true,
					  ValueFromPipelineByPropertyName = $true)]
		[Alias('Any')]
		[switch]
		$All,
		[Parameter(ParameterSetName = '__AllParameterSets',
					  ValueFromPipeline = $true,
					  ValueFromPipelineByPropertyName = $true)]
		[switch]
		$LeaveTel = $null,
		[Parameter(ParameterSetName = '__AllParameterSets',
					  ValueFromPipeline = $true,
					  ValueFromPipelineByPropertyName = $true)]
		[Alias('ExportCsv', 'CSV')]
		[switch]
		$Export = $false
	)

	dynamicparam
	{
		if ($PSBoundParameters['Export'])
		{
			# The PATH parameter is only needed if -Export is given
			$PathAttribute = New-Object System.Management.Automation.ParameterAttribute
			$PathAttribute.Mandatory = $true
			$PathAttribute.HelpMessage = "Path for the CSV Export:"
			$PathAttribute.ValueFromPipeline = $true
			$PathAttribute.ValueFromPipelineByPropertyName = $true
			$PathAttribute.ParameterSetName = '__AllParameterSets'
			$attributeCollection = new-object System.Collections.ObjectModel.Collection[System.Attribute]
			$attributeCollection.Add($PathAttribute)
			$PathParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Path', [String], $attributeCollection)
			$paramDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
			$paramDictionary.Add('Path', $PathParam)
			$paramDictionary
		}
	}

	begin
	{
		switch ($PsCmdlet.ParameterSetName)
		{
			'AANumbers' {
				$AutoAttendant = $true
			}
			'CQNumbers' {
				$CallQueue = $true
			}
			'AllNumbers' {
				$All = $true
			}
			default {
				$All = $true
			}
		}

		if ($PSBoundParameters.Path)
		{
			$Path = $PSBoundParameters.Path
		}

		$NumberReport = @()
	}

	process
	{
		if (($AutoAttendant) -or ($All))
		{
			foreach ($AA in (Get-CsAutoAttendant -ErrorAction Continue))
			{
				foreach ($AppInstance in $AA.ApplicationInstances)
				{
					$AAName = $AA.Name
					$AppPhoneNum = $null

					if ($LeaveTel)
					{
						$AppPhoneNum = ((Get-CsOnlineApplicationInstance -Identity $AppInstance -ErrorAction Continue).PhoneNumber)
					}
					else
					{
						$AppPhoneNum = (((Get-CsOnlineApplicationInstance -Identity $AppInstance -ErrorAction Continue).PhoneNumber).replace('tel:', ''))
					}

					Write-Verbose ('AutoAttendant ' + $AA.Name + ' has ' + $AppPhoneNum + ' assigned')

					$NewRow = $null
					$NewRow = [PSCustomObject][ordered]@{
						Name = ($AA.Name)
						Number = ($AppPhoneNum)
						Type = 'AutoAttendant'
					}

					$NumberReport += $newrow
				}
			}
		}

		if (($CallQueue) -or ($All))
		{
			foreach ($CQ in (Get-CsCallQueue -ErrorAction Continue))
			{
				foreach ($AppInstance in $CQ.ApplicationInstances)
				{
					$CQName = $null
					$CQName = $CQ.Name

					$AppPhoneNum = $null

					if ($LeaveTel)
					{
						$AppPhoneNum = ((Get-CsOnlineApplicationInstance -Identity $AppInstance -ErrorAction Continue).PhoneNumber)
					}
					else
					{
						$AppPhoneNum = (((Get-CsOnlineApplicationInstance -Identity $AppInstance -ErrorAction Continue).PhoneNumber).replace('tel:', ''))
					}

					Write-Verbose ('CallQueue ' + $CQ.Name + ' has ' + $AppPhoneNum + ' assigned')

					$NewRow = $null
					$NewRow = [PSCustomObject][ordered]@{
						Name   = ($CQ.Name)
						Number = ($AppPhoneNum)
						Type   = 'CallQueue'
					}

					$NumberReport += $newrow
				}
			}
		}
	}

	end
	{
		if (($PSBoundParameters['Export']) -or ($Path))
		{
			$NumberReport | Export-Csv -Path $Path -NoTypeInformation -Encoding UTF8 -ErrorAction Stop -WarningAction Continue

			Write-Verbose -Message $NumberReport
		}
		else
		{
			$NumberReport
		}
	}
}

Get-Help Get-TeamsServiceNumbers -Detailed
