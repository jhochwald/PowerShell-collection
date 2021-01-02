function Restart-ExchangeClusterNode
{
	<#
			.SYNOPSIS
			Wrapper to initiate a clean reboot
	
			.DESCRIPTION
			This function is a neat wrapper to initiate a clean reboot of a given Exchange Cluster Node.
			Brings the Exchange Cluster Node in Maintenance Mode and reboots it.
	
			.PARAMETER ComputerName
			Name of the Exchange Node.
			Default is the local system.
	
			.EXAMPLE
			PS > Restart-ExchangeClusterNode
	
			.NOTES
			Wrapper to initiate a clean reboot
	#>
	
	[CmdletBinding(ConfirmImpact = 'Low',
	SupportsShouldProcess = $true)]
	param
	(
		[Parameter(ValueFromPipeline = $true,
				ValueFromPipelineByPropertyName = $true,
		Position = 1)]
		[ValidateNotNullOrEmpty()]
		[string]
		$ComputerName = $env:COMPUTERNAME
	)
	
	PROCESS
	{
		if ($pscmdlet.ShouldProcess("$ComputerName", 'Enable Maintenance Mode'))
		{
			try
			{
				$EnableMaintenanceMode = $null
				
				if (Get-Command -Name Set-ExchangeNodeMaintenanceModeOn -ErrorAction SilentlyContinue) 
				{
					try 
					{
						$paramSetExchangeNodeMaintenanceModeOn = @{
							ComputerName  = $ComputerName
							Confirm       = $false
							ErrorAction   = 'Stop'
							WarningAction = 'SilentlyContinue'
						}
						$EnableMaintenanceMode = (Set-ExchangeNodeMaintenanceModeOn @paramSetExchangeNodeMaintenanceModeOn)
					}
					catch 
					{
						break
					}
				}
			}
			catch
			{
				$paramWriteError = @{
					Message     = "Unable to activate Maintenance Mode on $ComputerName"
					ErrorAction = 'Stop'
				}
				Write-Error @paramWriteError 
				break
			}
		}
		
		if ($pscmdlet.ShouldProcess("$ComputerName", 'Reboot'))
		{
			if ($EnableMaintenanceMode)
			{
				$paramRestartComputer = @{
					ComputerName  = $ComputerName
					Force         = $true
					Confirm       = $false
					ErrorAction   = 'SilentlyContinue'
					WarningAction = 'SilentlyContinue'
				}
				Restart-Computer @paramRestartComputer 
			}
		}
	}
}
