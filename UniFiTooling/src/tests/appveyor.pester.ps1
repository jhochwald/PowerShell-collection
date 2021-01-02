#requires -Version 3.0 -Modules Pester


# Taken with love from https://raw.githubusercontent.com/RamblingCookieMonster/PSDiskPart/master/Tests/appveyor.pester.ps1

# This script will invoke pester tests
# We serialize XML results and pull them in appveyor.yml

# If Finalize is specified, we collect XML output, upload tests, and indicate build errors
param ([switch]$Finalize)

#Initialize some variables, move to the project root
$PSVersion = ($PSVersionTable.PSVersion.Major)
$TestFile = "TestResultsPS$PSVersion.xml"
$ProjectRoot = ($ENV:APPVEYOR_BUILD_FOLDER)
Set-Location -Path $ProjectRoot

#Run a test with the current version of PowerShell
if (-not $Finalize) {
	"`n`tSTATUS: Testing with PowerShell $PSVersion`n"

	Import-Module -Name Pester

	Invoke-Pester -Path "$ProjectRoot\Tests" -OutputFormat NUnitXml -OutputFile "$ProjectRoot\$TestFile" -PassThru |
	Export-Clixml -Path "$ProjectRoot\PesterResults$PSVersion.xml"
} else {
	# If finalize is specified, check for failures and

	#Show status...
	$AllFiles = Get-ChildItem -Path $ProjectRoot\*Results*.xml | Select-Object -ExpandProperty FullName
	"`n`tSTATUS: Finalizing results`n"
	"COLLATING FILES:`n$($AllFiles | Out-String)"

	#Upload results for test page
	Get-ChildItem -Path "$ProjectRoot\TestResultsPS*.xml" | ForEach-Object -Process {

		$Address = "https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)"
		$Source = $_.FullName

		"UPLOADING FILES: $Address $Source"

		(New-Object -TypeName 'System.Net.WebClient').UploadFile($Address, $Source)
	}

	#What failed?
	$Results = @(Get-ChildItem -Path "$ProjectRoot\PesterResults*.xml" | Import-Clixml)

	$FailedCount = $Results |
	Select-Object -ExpandProperty FailedCount |
	Measure-Object -Sum |
	Select-Object -ExpandProperty Sum

	if ($FailedCount -gt 0) {
		$FailedItems = $Results |
		Select-Object -ExpandProperty TestResult |
		Where-Object -FilterScript { $_.Passed -notlike $True }

		"FAILED TESTS SUMMARY:`n"
		$FailedItems |
		ForEach-Object -Process {
			$Test = $_
			[pscustomobject]@{
				Describe = $Test.Describe
				Context  = $Test.Context
				Name     = "It $($Test.Name)"
				Result   = $Test.Result
			}
		} |
		Sort-Object -Property Describe, Context, Name, Result |
		Format-List

		throw "$FailedCount tests failed."
	}
}
