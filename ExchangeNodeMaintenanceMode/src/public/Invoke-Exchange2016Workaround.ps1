function Invoke-Exchange2016Workaround
{
	<#
			.SYNOPSIS
			Workaround for Exchange 2016 on Windows Server 2016
	
			.DESCRIPTION
			Workaround for Exchange 2016 on Windows Server 2016
	
			.EXAMPLE
			PS > Invoke-Exchange2016Workaround
	
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
