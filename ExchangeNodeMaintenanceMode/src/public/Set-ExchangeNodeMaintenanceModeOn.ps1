function Set-ExchangeNodeMaintenanceModeOn
{
	<#
			.SYNOPSIS
			Set the Exchange Node to Service
	
			.DESCRIPTION
			Enable the Maintenance Mode on a given the Exchange Node.
	
			.PARAMETER ComputerName
			Name of the Exchange Node, default is local system
	
			.EXAMPLE
			# Node is in Maintenance Mode
			PS > Set-ExchangeNodeMaintenanceModeOn
			$false

			.EXAMPLE
			# Node is not in Maintenance Mode
			PS > Set-ExchangeNodeMaintenanceModeOn
			$true

			.NOTES
			Perfect to apply Updates (or even CU installations). Check the Update/CU, aou might need a
			restart of the Server, so there might be no need to bring the Node back in Service.

			. LINK
			Invoke-Exchange2016Workaround
			Set-ExchangeNodeMaintenanceModeOff
			Test-ExchangeNodeMaintenanceMode
			Invoke-ApplyExchangeCumulativeUpdate
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
		# Draining the server
		$paramSetServerComponentState = @{
			identity  = $ComputerName
			Component = 'ServerWideOffline'
			State     = 'Draining'
			Requester = 'Maintenance'
		}
		if ($pscmdlet.ShouldProcess("$ComputerName", 'Set-ServerComponentState'))
		{
			$null = (Set-ServerComponentState @paramSetServerComponentState)
		}
		
		# Restart of the Sertvices enforces the draining
		$paramRestartService = @{
			Name          = 'MSExchangeTransport'
			Force         = $true
			ErrorAction   = 'SilentlyContinue'
			WarningAction = 'SilentlyContinue'
			Confirm       = $false
		}
		if ($pscmdlet.ShouldProcess("$ComputerName", 'Restart MSExchangeTransport Service'))
		{
			$null = (Restart-Service @paramRestartService)
		}
		
		$paramRestartService = @{
			Name          = 'MSExchangeFrontEndTransport'
			Force         = $true
			ErrorAction   = 'SilentlyContinue'
			WarningAction = 'SilentlyContinue'
			Confirm       = $false
		}
		if ($pscmdlet.ShouldProcess("$ComputerName", 'Restart MSExchangeFrontEndTransport Service'))
		{
			$null = (Restart-Service @paramRestartService)
		}
		
		# Suspend the cluster node
		$paramSuspendClusterNode = @{
			Name    = $ComputerName
			Confirm = $false
		}
		if ($pscmdlet.ShouldProcess("$ComputerName", 'Suspend-ClusterNode'))
		{
			$null = (Suspend-ClusterNode @paramSuspendClusterNode)
		}
		
		# Move all databases to the other servers
		$paramSetMailboxServer = @{
			identity                                 = $ComputerName
			DatabaseCopyActivationDisabledAndMoveNow = $true
		}
		if ($pscmdlet.ShouldProcess("$ComputerName", 'Set-MailboxServer'))
		{
			$null = (Set-MailboxServer @paramSetMailboxServer)
		}
		
		if ($pscmdlet.ShouldProcess("$ComputerName", 'Get-ClusterNode'))
		{
			# Get the Cluster Twin
			$PartnerNode = (Get-ClusterNode | Where-Object -FilterScript {
					$_.Name -ne $ComputerName
			} | Select-Object -ExpandProperty name)
		}
		
		$paramResolveDnsName = @{
			Name = $PartnerNode
			Type = 'A'
		}
		if ($pscmdlet.ShouldProcess("$ComputerName Node Partner", 'Resolve-DnsName'))
		{
			$PartnerNodeFQDN = ((Resolve-DnsName @paramResolveDnsName).name)
		}
		
		$paramSetServerComponentState = @{
			identity  = $ComputerName
			Component = 'ServerWideOffline'
			State     = 'Inactive'
			Requester = 'Maintenance'
		}
		if ($pscmdlet.ShouldProcess("$ComputerName", 'Activate Maintenance'))
		{
			$null = (Set-ServerComponentState @paramSetServerComponentState)
		}
		
		$paramRedirectMessage = @{
			Server  = $ComputerName
			Target  = $PartnerNodeFQDN
			Confirm = $false
		}
		if ($pscmdlet.ShouldProcess("$ComputerName Cluster Partner", 'Redirect'))
		{
			$null = (Redirect-Message @paramRedirectMessage)
		}
	}
}
