function Get-ExchangeAdminExecution
{
	<#
			.SYNOPSIS
			Just a neat function to check if we are elevated
	
			.DESCRIPTION
			Just a neat function to check if we are elevated
	
			.EXAMPLE
			# Good case
			PS > Get-ExchangeAdminExecution
	
			.EXAMPLE
			# Bad case
			PS > Get-ExchangeAdminExecution
	
			Error: You need to start the PowerShell session as Admin (Elevated)
	
			.NOTES
			Just an internal function.
	#>
	
	[CmdletBinding()]
	param ()
	
	If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator'))
	{
		$paramWriteError = @{
			Message     = 'You need to start the PowerShell session as Admin (Elevated)'
			ErrorAction = 'Stop'
		}
		Write-Error @paramWriteError
	}
	else
	{
		Write-Verbose -Message 'OK, you are Admin and the shell is elevated...'
	}
}
