function Invoke-Exchange2016Workaround
{
	<#
    .EXTERNALHELP ExchangeNodeMaintenanceMode-help.xml
    .LINK
        https://github.com/jhochwald/PowerShell-collection/tree/master/release/1.0.0.7/docs/Functions/Invoke-Exchange2016Workaround.md
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

