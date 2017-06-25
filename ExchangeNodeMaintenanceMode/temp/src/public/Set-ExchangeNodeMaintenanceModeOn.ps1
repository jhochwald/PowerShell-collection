function Set-ExchangeNodeMaintenanceModeOn
{
	<#
    .EXTERNALHELP ExchangeNodeMaintenanceMode-help.xml
    .LINK
        https://github.com/jhochwald/PowerShell-collection/tree/master/release/1.0.0.7/docs/Functions/Set-ExchangeNodeMaintenanceModeOn.md
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
