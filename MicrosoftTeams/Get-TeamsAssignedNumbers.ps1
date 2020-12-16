#requires -Version 3.0 -Modules MicrosoftTeams
<#
      .SYNOPSIS
      Collects assigned phone numbers from Microsoft Teams

      .DESCRIPTION
      This script queries Microsoft Teams for assigned numbers and displays in a formatted table with the option to export the report in several formats
      During processing LineURI's are run against a regex pattern to extract the DDI/DID and the extension to a separate column

      This script collects Microsoft Teams objects including:
      Users, Meeting Rooms, Online Application Instances (Resource Accounts)

      .PARAMETER OutputType
      Define the Script Output:
      CONSOLE - Dump a formatted list into the console
      HTML - Create a simple HTML report with Tables. Only here to be compatible to our older version
      XML - Create a simple Extensible Markup Language (XML) report
      YAML - Create a simple YAML Ain't Markup Language (YAML) report
      JSON - Create a simple JavaScript Object Notation (JSON) report. Handy if you need to upload the data via WebServices/APIs
      CSV - Create a simple comma-separated values (CSV) report. This is perfect for re-use within Excel, or other applications

      If you leave it empty (this is the default), the object will be dumped to the console!
      This can become handy, if you use this script to generate the report and re-use it in the pipe or your own application

      .PARAMETER Path
      Where to store the Report File
      Default is 'C:\scripts\PowerShell\logs\'

      .PARAMETER DateFormat
      Use the format for Get-Date
      Default is 'yyyyMMdd-HHmmUTC'

      .PARAMETER UTC
      Use ToUniversalTime for the Date Strings
      Default is $true

      .EXAMPLE
      PS C:\> .\Get-TeamsAssignedNumbers.ps1

      The Report will be dumped to the console (unformatted)

      .EXAMPLE
      PS C:\> .\Get-TeamsAssignedNumbers.ps1 -OutputType CONSOLE

      Dump a formatted list into the console

      .EXAMPLE
      PS C:\> .\Get-TeamsAssignedNumbers.ps1 -OutputType HTML

      Create a simple HTML report with Tables.

      .EXAMPLE
      PS C:\> .\Get-TeamsAssignedNumbers.ps1 -OutputType XML

      Create a simple Extensible Markup Language (XML) report

      .EXAMPLE
      PS C:\> .\Get-TeamsAssignedNumbers.ps1 -OutputType YAML

      Create a simple YAML Ain't Markup Language (YAML) report

      .EXAMPLE
      PS C:\> .\Get-TeamsAssignedNumbers.ps1 -OutputType JSON

      Create a simple JavaScript Object Notation (JSON) report.

      .EXAMPLE
      PS C:\> .\Get-TeamsAssignedNumbers.ps1 -OutputType CSV

      Create a simple comma-separated values (CSV) report.

      .NOTES
      Based on the work off Andrew Morpeth (https://ucgeek.co/)

      REQUIREMENTS:
      If you haven't already, you will need to install the MicrosoftTeams PowerShell module and connect to the Teams/Skype for Business Online Service of Microsoft Office 365
#>
[CmdletBinding(ConfirmImpact = 'None')]
param
(
	[Parameter(ValueFromPipeline,
		ValueFromPipelineByPropertyName)]
	[ValidateSet('CONSOLE', 'HTML', 'XML', 'YAML', 'JSON', 'CSV', IgnoreCase = $true)]
	[AllowEmptyCollection()]
	[AllowEmptyString()]
	[AllowNull()]
	[Alias('ReportType')]
	[string]
	$OutputType = $null,
	[Parameter(ValueFromPipeline,
		ValueFromPipelineByPropertyName)]
	[AllowEmptyCollection()]
	[AllowEmptyString()]
	[AllowNull()]
	[string]
	$Path = 'C:\scripts\PowerShell\logs',
	[Parameter(ValueFromPipeline,
		ValueFromPipelineByPropertyName)]
	[AllowEmptyCollection()]
	[AllowEmptyString()]
	[AllowNull()]
	[string]
	$DateFormat = 'yyyyMMdd-HHmmUTC',
	[Parameter(ValueFromPipeline,
		ValueFromPipelineByPropertyName)]
	[Alias('UseUTC')]
	[switch]
	$UTC
)

begin
{
	#region DateToUTC
	if (-not ($UTC))
 {
		$UTC = $true
	}
	#endregion DateToUTC

	#region UseDateUTC
	if (($UTC -eq $true) -and ($DateFormat))
 {
		$FileName = ('MicrosoftTeamsAssignedNumbers_' + ((Get-Date).ToUniversalTime()).ToString($DateFormat))
	}
	#endregion UseDateUTC

	#region UseDateFormat
	if ($DateFormat)
 {
		$FileName = ('MicrosoftTeamsAssignedNumbers_' + ((Get-Date).ToString($DateFormat)))
	}
	else
 {
		# This is the default
		$FileName = ('MicrosoftTeamsAssignedNumbers_' + (Get-Date -Format s).replace(':', '-'))
	}
	#endregion UseDateFormat

	#region PathMangle
	if ($Path)
 {
		# Save to a given PATH
		$FilePath = ($Path + '\' + $FileName)
	}
	else
 {
		# Save here (where the script was started)
		$FilePath = ('.\' + $FileName)
	}
	#endregion PathMangle

	#region Regex
	# Regex values
	$LineURIRegex = '^(?:tel:)?(?:\+)?(\d+)(?:;ext=(\d+))?(?:;([\w-]+))?$'
	#endregion Regex

	# Cleanup
	$Report = @()
}

process
{
	#region BoundParameters
	if (($PSCmdlet.MyInvocation.BoundParameters['Verbose']).IsPresent)
 {
		$VerboseValue = $true
	}
	else
 {
		$VerboseValue = $false
	}

	if (($PSCmdlet.MyInvocation.BoundParameters['Debug']).IsPresent)
 {
		$DebugValue = $true
	}
	else
 {
		$DebugValue = $false
	}
	#endregion BoundParameters

	#region Users
	# Get Users with LineURI
	$UsersLineURI = $null
	$paramGetCsOnlineUser = @{
		Verbose       = $VerboseValue
		Debug         = $DebugValue
		Filter        = {
			LineURI -ne $null
		}
		ErrorAction   = 'SilentlyContinue'
		WarningAction = 'SilentlyContinue'
	}
	$paramSelectObject = @{
		Property = 'UserPrincipalName', 'LineURI', 'DisplayName', 'FirstName', 'LastName'
		Verbose  = $VerboseValue
		Debug    = $DebugValue
	}
	$UsersLineURI = (Get-CsOnlineUser @paramGetCsOnlineUser | Select-Object @paramSelectObject)

	if ($UsersLineURI)
 {
		Write-Verbose -Message 'Processing User Numbers'

		foreach ($ReportingItem in $UsersLineURI)
		{
			$MatchedData = @()
			$null = $ReportingItem.LineURI -match $LineURIRegex

			$ReportingObject = (New-Object -TypeName System.Object)
			$null = ($ReportingObject | Add-Member -MemberType NoteProperty -Name 'UserPrincipalName' -Value $ReportingItem.UserPrincipalName)
			$null = ($ReportingObject | Add-Member -MemberType NoteProperty -Name 'LineURI' -Value $ReportingItem.LineURI)
			$null = ($ReportingObject | Add-Member -MemberType NoteProperty -Name 'DDI' -Value $MatchedData[1])
			$null = ($ReportingObject | Add-Member -MemberType NoteProperty -Name 'Ext' -Value $MatchedData[2])
			$null = ($ReportingObject | Add-Member -MemberType NoteProperty -Name 'DisplayName' -Value $ReportingItem.DisplayName)
			$null = ($ReportingObject | Add-Member -MemberType NoteProperty -Name 'FirstName' -Value $ReportingItem.FirstName)
			$null = ($ReportingObject | Add-Member -MemberType NoteProperty -Name 'LastName' -Value $ReportingItem.LastName)
			$null = ($ReportingObject | Add-Member -MemberType NoteProperty -Name 'Type' -Value 'User')

			# Add to array
			$null = ($Report += $ReportingObject)
		}
	}
	#endregion Users

	#region MeetingRooms
	# Get meeting room numbers
	$MeetingRoomLineURI = $null
	$paramGetCsMeetingRoom = @{
		Verbose       = $VerboseValue
		Debug         = $DebugValue
		Filter        = {
			LineURI -ne $null
		}
		ErrorAction   = 'SilentlyContinue'
		WarningAction = 'SilentlyContinue'
	}
	$paramSelectObject = @{
		Property = 'UserPrincipalName', 'LineURI', 'DisplayName'
		Verbose  = $VerboseValue
		Debug    = $DebugValue
	}
	$MeetingRoomLineURI = (Get-CsMeetingRoom @paramGetCsMeetingRoom | Select-Object @paramSelectObject)

	if ($MeetingRoomLineURI)
 {
		Write-Verbose -Message 'Processing Meeting Room Numbers'

		foreach ($ReportingItem in $MeetingRoomLineURI)
		{
			$MatchedData = @()
			$null = $ReportingItem.LineURI -match $LineURIRegex

			$ReportingObject = (New-Object -TypeName System.Object)
			$null = ($ReportingObject | Add-Member -MemberType NoteProperty -Name 'UserPrincipalName' -Value $ReportingItem.UserPrincipalName)
			$null = ($ReportingObject | Add-Member -MemberType NoteProperty -Name 'LineURI' -Value $ReportingItem.LineURI)
			$null = ($ReportingObject | Add-Member -MemberType NoteProperty -Name 'DDI' -Value $MatchedData[1])
			$null = ($ReportingObject | Add-Member -MemberType NoteProperty -Name 'Ext' -Value $MatchedData[2])
			$null = ($ReportingObject | Add-Member -MemberType NoteProperty -Name 'DisplayName' -Value $ReportingItem.DisplayName)
			$null = ($ReportingObject | Add-Member -MemberType NoteProperty -Name 'Type' -Value 'MeetingRoom')

			# Remove existing User entry (Rooms have an user object as well)
			$Report = ($Report | Where-Object -FilterScript {
					$_.UserPrincipalName -ne $ReportingItem.UserPrincipalName
				})

			# Add to array
			$null = ($Report += $ReportingObject)
		}
	}
	#endregion MeetingRooms

	#region ResourceAccounts
	# Get online resource accounts
	$OnlineApplicationInstanceLineURI = $null
	$paramGetCsOnlineApplicationInstance = @{
		Verbose       = $VerboseValue
		Debug         = $DebugValue
		ErrorAction   = 'SilentlyContinue'
		WarningAction = 'SilentlyContinue'
	}
	$paramSelectObject = @{
		Property = 'UserPrincipalName', 'DisplayName', 'PhoneNumber', 'ApplicationId'
		Verbose  = $VerboseValue
		Debug    = $DebugValue
	}
	$OnlineApplicationInstanceLineURI = (Get-CsOnlineApplicationInstance @paramGetCsOnlineApplicationInstance | Where-Object -FilterScript {
			$_.PhoneNumber -ne $null
		} -ErrorAction SilentlyContinue -WarningAction SilentlyContinue | Select-Object @paramSelectObject)

	if ($OnlineApplicationInstanceLineURI)
 {
		Write-Verbose -Message 'Processing Online Application Instances (Resource Accounts) Numbers'

		foreach ($ReportingItem in $OnlineApplicationInstanceLineURI)
		{
			$MatchedData = @()
			$null = $ReportingItem.PhoneNumber -match $LineURIRegex

			$ReportingObject = (New-Object -TypeName System.Object)
			$null = ($ReportingObject | Add-Member -MemberType NoteProperty -Name 'UserPrincipalName' -Value $ReportingItem.UserPrincipalName)
			$null = ($ReportingObject | Add-Member -MemberType NoteProperty -Name 'LineURI' -Value $ReportingItem.PhoneNumber)
			$null = ($ReportingObject | Add-Member -MemberType NoteProperty -Name 'DDI' -Value $MatchedData[1])
			$null = ($ReportingObject | Add-Member -MemberType NoteProperty -Name 'Ext' -Value $MatchedData[2])
			$null = ($ReportingObject | Add-Member -MemberType NoteProperty -Name 'DisplayName' -Value $ReportingItem.DisplayName)
			$null = ($ReportingObject | Add-Member -MemberType NoteProperty -Name 'Type' -Value $(
					if ($ReportingItem.ApplicationId -eq 'ce933385-9390-45d1-9512-c8d228074e07')
					{
						'Auto Attendant Resource Account'
					}
					elseif ($ReportingItem.ApplicationId -eq '11cd3e2e-fccb-42ad-ad00-878b93575e07')
					{
						'Call Queue Resource Account'
					}
					else
					{
						'Unknown Resource Account'
					}
				))

			# Remove existing User entry (Apps have an user object as well)
			$Report = ($Report | Where-Object -FilterScript {
					$_.UserPrincipalName -ne $ReportingItem.UserPrincipalName
				} -Verbose:$VerboseValue -Debug:$DebugValue)

			# Add to array
			$null = ($Report += $ReportingObject)
		}
	}
	#endregion ResourceAccounts

	# Sort the Array data, based on the LineURI object
	$paramSortObject = @{
		Property = 'LineURI'
		Verbose  = $VerboseValue
		Debug    = $DebugValue
	}
	$Report = ($Report | Sort-Object @paramSortObject)

	#region Output
	switch ($OutputType)
 {
		CSV
		{
			$FilePath = ($FilePath + '.csv')

			$paramConvertToCsv = @{
				Delimiter         = ','
				NoTypeInformation = $true
				Verbose           = $VerboseValue
				Debug             = $DebugValue
				ErrorAction       = 'Continue'
				WarningAction     = 'Continue'
			}
			$PsCsv = ($Report | ConvertTo-Csv @paramConvertToCsv)

			$paramOutFile = @{
				FilePath      = $FilePath
				Force         = $true
				Append        = $false
				Encoding      = 'utf8'
				ErrorAction   = 'Continue'
				WarningAction = 'Continue'
				Verbose       = $VerboseValue
				Debug         = $DebugValue
			}
			($PsCsv | Out-File @paramOutFile)

			Write-Verbose -Message ('Your CSV report was saved to: {0}' -f $FilePath)
		}
		JSON
		{
			$FilePath = ($FilePath + '.json')

			$PsJson = @($Report | ConvertTo-Json -Depth 5 -Verbose:$VerboseValue -Debug:$DebugValue)

			$paramOutFile = @{
				FilePath      = $FilePath
				Force         = $true
				Append        = $false
				Encoding      = 'utf8'
				ErrorAction   = 'Continue'
				WarningAction = 'Continue'
				Verbose       = $VerboseValue
				Debug         = $DebugValue
			}
			($PsJson | Out-File @paramOutFile)

			Write-Verbose -Message ('Your JSON report was saved to: {0}' -f $FilePath)
		}
		YAML
		{
			if (Get-Command -Name 'ConvertTo-Yaml' -ErrorAction SilentlyContinue)
			{
				$FilePath = ($FilePath + '.yml')

				<#
                  Workaround for ConvertTo-Yaml
            #>
				$Report = @($Report | ConvertTo-Json | ConvertFrom-Json)

				$paramConvertToYaml = @{
					Data          = $Report
					Force         = $true
					ErrorAction   = 'Continue'
					WarningAction = 'Continue'
					Verbose       = $VerboseValue
					Debug         = $DebugValue
				}
				$PsYaml = (ConvertTo-Yaml @paramConvertToYaml)

				$paramOutFile = @{
					FilePath      = $FilePath
					Force         = $true
					Append        = $false
					Encoding      = 'utf8'
					ErrorAction   = 'Continue'
					WarningAction = 'Continue'
					Verbose       = $VerboseValue
					Debug         = $DebugValue
				}
				($PsYaml | Out-File @paramOutFile)

				Write-Verbose -Message ('Your YAML report was saved to: {0}' -f $FilePath)
			}
			else
			{
				Write-Error -Exception 'The ConvertTo-Yaml command was not found' -Message 'Please ensure, that the ''powershell-yaml'' module is installed.' -Category NotInstalled -RecommendedAction 'Please use ''Install-Module -Name powershell-yaml'' to install the required module!' -ErrorAction Stop
			}
		}
		XML
		{
			$FilePath = ($FilePath + '.xml')

			$paramConvertToXml = @{
				As                = 'Stream'
				InputObject       = $Report
				NoTypeInformation = $true
				ErrorAction       = 'Continue'
				WarningAction     = 'Continue'
				Verbose           = $VerboseValue
				Debug             = $DebugValue
			}
			$PsXML = (ConvertTo-Xml @paramConvertToXml)

			$paramOutFile = @{
				FilePath      = $FilePath
				Force         = $true
				Append        = $false
				Encoding      = 'utf8'
				ErrorAction   = 'Continue'
				WarningAction = 'Continue'
				Verbose       = $VerboseValue
				Debug         = $DebugValue
			}
			($PsXML | Out-File @paramOutFile)

			Write-Verbose -Message ('Your XML report was saved to: {0}' -f $FilePath)
		}
		HTML
		{
			$FilePath = ($FilePath + '.html')

			$Header = @"
<title>Microsoft Teams assigned phone number report</title>
<meta charset='UTF-8'>
<meta name='viewport' content='width=device-width, initial-scale=1'>
<style>
   table {
      border-width: 1px;
      border-style: solid;
      border-color: black;
      border-collapse: collapse;
   }

   th {
      border-width: 1px;
      padding: 3px;
      border-style: solid;
      border-color: black;
      background-color: #6495ED;
   }

   td {
      border-width: 1px;
      padding: 3px;
      border-style: solid;
      border-color: black;
   }
</style>
"@

			$htmlParams = @{
				Title       = 'Microsoft Teams assigned phone number report'
				Head        = $Header
				body        = '<h3>Microsoft Teams assigned phone number report</h3>'
				PreContent  = '<p>The following Phone numbers are assigned in Microsoft Teams:</p>'
				PostContent = '<p><i>Last updated: ' + ((Get-Date).ToUniversalTime()).ToString('HH:MM dd.MM.yyyy (UTC)') + '</i></p>'
				Verbose     = $VerboseValue
				Debug       = $DebugValue
			}
			$PsHtml = ($Report | ConvertTo-Html @htmlParams)

			$paramOutFile = @{
				FilePath      = $FilePath
				Force         = $true
				Append        = $false
				Encoding      = 'utf8'
				ErrorAction   = 'Continue'
				WarningAction = 'Continue'
				Verbose       = $VerboseValue
				Debug         = $DebugValue
			}
			($PsHtml | Out-File @paramOutFile)

			Write-Verbose -Message ('Your HTML report was saved to: {0}' -f $FilePath)
		}
		CONSOLE
		{
			$paramFormatTable = @{
				AutoSize = $true
				Property = 'LineURI', 'DDI', 'Ext', 'DisplayName', 'Type'
				Verbose  = $VerboseValue
				Debug    = $DebugValue
			}
			($Report | Format-Table @paramFormatTable)

			Write-Verbose -Message 'Formated Object was dumped'
		}
		default
		{
			$Report

			Write-Verbose -Message 'Unformated Object was dumped'
		}
	}
	#endregion Output
}

end
{
	# Cleanup
	$Report = $null
}
