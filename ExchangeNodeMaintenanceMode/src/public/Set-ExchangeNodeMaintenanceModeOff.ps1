function Set-ExchangeNodeMaintenanceModeOff
{
	<#
			.SYNOPSIS
			Return Exchange Node to normal operation
	
			.DESCRIPTION
			Return Exchange Node to normal operation
	
			.PARAMETER ComputerName
			Name of the Exchange Node, default is local system
	
			.EXAMPLE
			# Enable normal operations

			PS > Set-ExchangeNodeMaintenanceModeOff
			$true

			.EXAMPLE
			# Fails to enable noprmal operations

			PS > Set-ExchangeNodeMaintenanceModeOff
			$false

			.NOTES

			. LINK
			Invoke-Exchange2016Workaround
			Set-ExchangeNodeMaintenanceModeOn
			Test-ExchangeNodeMaintenanceMode
			Invoke-ApplyExchangeCumulativeUpdate
	#>
	
	[OutputType([bool])]
	param
	(
		[Parameter(ValueFromPipeline = $true,
				ValueFromPipelineByPropertyName = $true,
		Position = 1)]
		[ValidateNotNullOrEmpty()]
		[string]
		$ComputerName = $env:COMPUTERNAME
	)
	
	Begin
	{
		# Workaround for Exchange 2016 on Windows Server 2016
		Invoke-Exchange2016Workaround
	}
	
	Process
	{
		try
		{
			# Activate the components
			$paramSetServerComponentState = @{
				identity  = $ComputerName
				Component = 'ServerWideOffline'
				State     = 'Active'
				Requester = 'Maintenance'
			}
			$null = (Set-ServerComponentState @paramSetServerComponentState)
			
			# Activate the Cluster Node
			$paramResumeClusterNode = @{
				Name          = $ComputerName
				ErrorAction   = 'Stop'
				WarningAction = 'SilentlyContinue'
			}
			$null = (Resume-ClusterNode @paramResumeClusterNode)
			
			# Activate the Databases
			$paramSetMailboxServer = @{
				identity                                 = $ComputerName
				DatabaseCopyAutoActivationPolicy         = 'Unrestricted'
				DatabaseCopyActivationDisabledAndMoveNow = $false
				ErrorAction                              = 'Stop'
				WarningAction                            = 'SilentlyContinue'
			}
			$null = (Set-MailboxServer @paramSetMailboxServer)
		}
		catch
		{
			return $false
		}

		# Default
		return $true
	}
}