function Set-ExchangeNodeMaintenanceModeOn
{
	<#
			.SYNOPSIS
			Set the Exchange Node to Service
	
			.DESCRIPTION
			Set the Exchange Node to Service
	
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
			TODO: Find a detection for the Workaround
			TODO: Find a better solution for the certificate check issue

			. LINK
			Invoke-Exchange2016Workaround
			Set-ExchangeNodeMaintenanceModeOff
			Test-ExchangeNodeMaintenanceMode
			Invoke-ApplyExchangeCumulativeUpdate
	#>
	
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
		# Draining the server
		$paramSetServerComponentState = @{
			identity  = $ComputerName
			Component = 'ServerWideOffline'
			State     = 'Draining'
			Requester = 'Maintenance'
		}
		Set-ServerComponentState @paramSetServerComponentState
		
		# Restart of the Sertvices enforces the draining
		$paramRestartService = @{
			Name          = 'MSExchangeTransport'
			Force         = $true
			ErrorAction   = 'SilentlyContinue'
			WarningAction = 'SilentlyContinue'
			Confirm       = $false
		}
		$null = (Restart-Service @paramRestartService)
		
		$paramRestartService = @{
			Name          = 'MSExchangeFrontEndTransport'
			Force         = $true
			ErrorAction   = 'SilentlyContinue'
			WarningAction = 'SilentlyContinue'
			Confirm       = $false
		}
		$null = (Restart-Service @paramRestartService)
		
		# Suspend the cluster node
		$paramSuspendClusterNode = @{
			Name    = $ComputerName
			Confirm = $false
		}
		$null = (Suspend-ClusterNode @paramSuspendClusterNode)
		
		# Move all databases to the other servers
		$paramSetMailboxServer = @{
			identity                                 = $ComputerName
			DatabaseCopyActivationDisabledAndMoveNow = $true
		}
		$null = (Set-MailboxServer @paramSetMailboxServer)
		
		# Get the Cluster Twin
		$PartnerNode = (Get-ClusterNode | Where-Object -FilterScript {
				$_.Name -ne $ComputerName
		} | Select-Object -ExpandProperty name)
		
		$paramResolveDnsName = @{
			Name = $PartnerNode
			Type = 'A'
		}
		$PartnerNodeFQDN = ((Resolve-DnsName @paramResolveDnsName).name)
		
		$paramSetServerComponentState = @{
			identity  = $ComputerName
			Component = 'ServerWideOffline'
			State     = 'Inactive'
			Requester = 'Maintenance'
		}
		$null = (Set-ServerComponentState @paramSetServerComponentState)
		
		$paramRedirectMessage = @{
			Server  = $ComputerName
			Target  = $PartnerNodeFQDN
			Confirm = $false
		}
		$null = (Redirect-Message @paramRedirectMessage)
	}
}