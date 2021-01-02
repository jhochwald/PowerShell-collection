function Set-ExchangeNodeMaintenanceModeOff
{
	<#
			.SYNOPSIS
			Return Exchange Node to normal operation
	
			.DESCRIPTION
			Disable the Maintenance Mode on a given the Exchange Node.
	
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
			If you installed an update (or CU), you might need a reboot anyway.

			. LINK
			Invoke-Exchange2016Workaround
			Set-ExchangeNodeMaintenanceModeOn
			Test-ExchangeNodeMaintenanceMode
			Invoke-ApplyExchangeCumulativeUpdate
	#>
	
	[CmdletBinding(ConfirmImpact = 'Low',
	SupportsShouldProcess = $true)]
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
		if ($pscmdlet.ShouldProcess("$ComputerName", 'Activate Maintenance'))
		{
			if (Get-Command -Name Invoke-Exchange2016Workaround -ErrorAction SilentlyContinue) 
			{
				try 
				{
					Invoke-Exchange2016Workaround
				}
				catch 
				{
					break
				}
			}
		}

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
			if ($pscmdlet.ShouldProcess("$ComputerName", 'Deactivate Maintenance'))
			{
				$null = (Set-ServerComponentState @paramSetServerComponentState)
			}
			
			# Activate the Cluster Node
			$paramResumeClusterNode = @{
				Name          = $ComputerName
				ErrorAction   = 'Stop'
				WarningAction = 'SilentlyContinue'
			}
			if ($pscmdlet.ShouldProcess("$ComputerName", 'Resume Cluster Node'))
			{
				$null = (Resume-ClusterNode @paramResumeClusterNode)
			}
			
			# Activate the Databases
			$paramSetMailboxServer = @{
				identity                                 = $ComputerName
				DatabaseCopyAutoActivationPolicy         = 'Unrestricted'
				DatabaseCopyActivationDisabledAndMoveNow = $false
				ErrorAction                              = 'Stop'
				WarningAction                            = 'SilentlyContinue'
			}
			if ($pscmdlet.ShouldProcess("$ComputerName", 'Activate default MailboxServer operation'))
			{
				$null = (Set-MailboxServer @paramSetMailboxServer)
			}
		}
		catch
		{
			return $false
		}

		# Default
		return $true
	}
}
