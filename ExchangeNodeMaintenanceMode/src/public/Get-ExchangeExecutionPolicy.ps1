function Get-ExchangeExecutionPolicy
{
	<#
			.SYNOPSIS
			Just a neat wrapper for Get-ExecutionPolicy
	
			.DESCRIPTION
			Nothing fancy, just a wrapper for the regular Get-ExecutionPolicy.
	
			.EXAMPLE
			# Good case
			PS > Get-ExchangeExecutionPolicy
	
			.EXAMPLE
			# Bad case
			PS > Get-ExchangeExecutionPolicy
	
			Error: Your PowerShell Execution Policy is Default and it should be Unrestricted or Bypass
	
			.NOTES
			Just an internal function.
	#>
	
	[CmdletBinding()]
	param ()
	
	# Define some defaults
	$SC = 'SilentlyContinue'

	# Cleanup
	$ExecutionPolicy = $null
	
	# Get the Infos
	$paramGetExecutionPolicy = @{
		ErrorAction   = $SC
		WarningAction = $SC
	}
	$ExecutionPolicy = (Get-ExecutionPolicy @paramGetExecutionPolicy)

	if ((-not ($ExecutionPolicy -eq 'Bypass')) -or (-not ($ExecutionPolicy -eq 'Bypass')))
	{
		$paramWriteError = @{
			Message     = "Your PowerShell Execution Policy is $ExecutionPolicy and it should be Unrestricted or Bypass"
			ErrorAction = 'Stop'
		}
		Write-Error @paramWriteError 
	}
	else 
	{
		Write-Verbose -Message "Your Execution Policy is $ExecutionPolicy"
	}
}
