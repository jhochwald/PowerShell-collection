<#
		.SYNOPSIS
		Setup the S4B Edge server for QoS

		.DESCRIPTION
		Setup the Skype for Business 2015 Edge Server for Quality of Services
		Edge Servers are not domain joined, we have to modify the registry instead of using a Group Policy

		.EXAMPLE
		PS C:\> .\Edge_REG.ps1

		.EXAMPLE
		PS C:\> .\Edge_REG.ps1 -verbose

		.NOTES
		Check that the ports and port ranges fit your requirements!

		The ports and ranges we use here should fit the Skype for Business Online setup
#>
[CmdletBinding()]
param ()

#Requires -RunAsAdministrator

BEGIN
{
	#region Variables

	# Ports to use for Application Sharing
	[string]$AppSharePorts = '50040:50059'

	# QoS marking for Application Sharing
	[string]$AppShareMark = '24'

	# Ports to use for Video
	[string]$VideoPorts = '50020:50039'

	# QoS marking for Video
	[string]$VideoMark = '34'

	# Ports to use for Audio
	[string]$AudioPorts = '50000:50019'

	# QoS marking for Audio
	[string]$AudioMark = '46'

	#endregion Variables

	#region Defaults

	# Define some Defaults
	[string]$SC = 'SilentlyContinue'
	[string]$STP = 'Stop'
	[string]$DscpVal = 'DSCP Value'
	[string]$MinusOne = '-1'
	[string]$One = '1'
	[string]$OneZero = '1.0'
	[string]$WC = '*'
	[string]$ThrotRate = 'Throttle Rate'
	[string]$RemIPLen = 'Remote IP Prefix Length'
	[string]$RemIP = 'Remote IP'
	[string]$RemPort = 'Remote Port'
	[string]$LocIPLen = 'Local IP Prefix Length'
	[string]$LocIP = 'Local IP'
	[string]$LocPort = 'Local Port'
	[string]$Protocol = 'Protocol'
	[string]$Version = 'Version'
	[string]$STRG = 'String'
	[string]$ServerAppSharePath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\QoS\S4B QoS - Edge - App Sharing'
	[string]$ServerVideoPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\QoS\S4B QoS - Edge - Server Video'
	[string]$ServerAudioPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\QoS\S4B QoS - Edge - Server Audio'
	[string]$TcpQosPath = 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\QoS'
	[string]$ServicesTcpipQoSValue = 'Do not use NLA'
	[string]$IPv4Connectivity = 'LocalNetwork'
	[string]$AddressFamily = 'IPv4'

	#endregion Defaults
}

PROCESS
{
	#region TcpQosPath

	try
	{
		Write-Verbose -Message ('Create {0}' -f $TcpQosPath)

		# Splat reusable parameters
		$paramNewItem = @{
			Path          = $TcpQosPath
			Force         = $true
			Confirm       = $false
			ErrorAction   = $STP
			WarningAction = $SC
		}

		$null = (New-Item @paramNewItem)

		Write-Verbose -Message ('Created {0}' -f $TcpQosPath)
	}
	catch
	{
		Write-Verbose -Message ('Unable to create {0}' -f $TcpQosPath)
	}

	try
	{
		Write-Verbose -Message ('Try to create {0} in {1} with value {2}' -f $ServicesTcpipQoSValue, $TcpQosPath, $One)

		# Cleanup
		$paramNewItemProperty = $null

		# Splat reusable parameters
		$paramNewItemProperty = @{
			Path          = $TcpQosPath
			Name          = $ServicesTcpipQoSValue
			Value         = $One
			PropertyType  = $STRG
			Force         = $true
			Confirm       = $false
			ErrorAction   = $STP
			WarningAction = $SC
		}

		$null = (New-ItemProperty @paramNewItemProperty)

		Write-Verbose -Message ('Created {0} in {1} with value {2}' -f $ServicesTcpipQoSValue, $TcpQosPath, $One)
	}
	catch
	{
		# Try to modify it instead
		try
		{
			Write-Verbose -Message ('Try to modify {0} in {1} with value {2}' -f $ServicesTcpipQoSValue, $TcpQosPath, $One)

			$null = (Set-ItemProperty @paramNewItemProperty)

			Write-Verbose -Message ('Modified {0} in {1} with value {2}' -f $ServicesTcpipQoSValue, $TcpQosPath, $One)
		}
		catch
		{
			# Whoooops
			Write-Warning -Message ('Unable to set {0} in {1} to {2}' -f $ServicesTcpipQoSValue, $TcpQosPath, $One)
		}
	}

	#endregion TcpQosPath

	#region GetIpInfo

	<#
			Check if this matches your Edge configuration!!!
	#>
	try
	{
		# Cleanup
		$paramGetNetConnectionProfile = $null

		# Splat reusable parameters
		$paramGetNetConnectionProfile = @{
			ErrorAction   = $STP
			WarningAction = $SC
		}

		# Get the first Interface (See internal above)
		[int] $Adapter = (Get-NetConnectionProfile @paramGetNetConnectionProfile | Where-Object -FilterScript {
				$_.IPv4Connectivity -eq $IPv4Connectivity
		}).InterfaceIndex | Select-Object -First $One

		# Cleanup
		$IP = $null
		$paramGetNetIPAddress = $null


		# Splat reusable parameters
		$paramGetNetIPAddress = @{
			InterfaceIndex = $Adapter
			AddressFamily  = $AddressFamily
			ErrorAction    = $STP
			WarningAction  = $SC
		}

		# The IP of the Interface
		[string]$IP = (Get-NetIPAddress @paramGetNetIPAddress ).ipaddress

		# check if IP exists
		if (-not $IP)
		{
			# Nothing fancy, we just need a stop here
			throw
		}

		#endregion GetIpInfo

		#region ServerAudioPath

		try
		{
			Write-Verbose -Message ('Try to create {0}' -f $ServerAudioPath)

			# Cleanup
			$paramNewItem = $null

			# Splat reusable parameters
			$paramNewItem = @{
				Path          = $ServerAudioPath
				Force         = $true
				Confirm       = $false
				ErrorAction   = $STP
				WarningAction = $SC
			}
			$null = (New-Item @paramNewItem)

			Write-Verbose -Message ('Created {0}' -f $ServerAudioPath)
		}
		catch
		{
			Write-Verbose -Message ('Unable to create {0}' -f $ServerAudioPath)
		}

		try
		{
			Write-Verbose -Message ('Try to create {0} with value {1} as {2} in {3}' -f $Protocol, $WC, $STRG, $ServerAudioPath)

			# Cleanup
			$paramNewItemProperty = $null

			# Splat reusable parameters
			$paramNewItemProperty = @{
				Path          = $ServerAudioPath
				Force         = $true
				Confirm       = $false
				PropertyType  = $STRG
				Name          = $Protocol
				Value         = $WC
				ErrorAction   = $STP
				WarningAction = $SC
			}

			$null = (New-ItemProperty @paramNewItemProperty)

			Write-Verbose -Message ('Created {0} with value {1} as {2} in {3}' -f $Protocol, $WC, $STRG, $ServerAudioPath)
		}
		catch
		{
			try
			{
				Write-Verbose -Message ('Try to set {0} with value {1} as {2} in {3}' -f $Protocol, $WC, $STRG, $ServerAudioPath)

				$null = (Set-ItemProperty @paramNewItemProperty)

				Write-Verbose -Message ('Modified {0} with value {1} as {2} in {3}' -f $Protocol, $WC, $STRG, $ServerAudioPath)
			}
			catch
			{
				Write-Warning -Message ('Unable to create {0} with value {1} as {2} in {3}' -f $Protocol, $WC, $STRG, $ServerAudioPath)
			}
		}

		try
		{
			Write-Verbose -Message ('Try to create {0} with value {1} as {2} in {3}' -f $DscpVal, $AudioMark, $STRG, $ServerAudioPath)

			# Cleanup
			$paramNewItemProperty = $null

			# Splat reusable parameters
			$paramNewItemProperty = @{
				Path          = $ServerAudioPath
				Force         = $true
				Confirm       = $false
				PropertyType  = $STRG
				Name          = $DscpVal
				Value         = $AudioMark
				ErrorAction   = $STP
				WarningAction = $SC
			}

			$null = (New-ItemProperty @paramNewItemProperty)

			Write-Verbose -Message ('Created {0} with value {1} as {2} in {3}' -f $DscpVal, $AudioMark, $STRG, $ServerAudioPath)
		}
		catch
		{
			try
			{
				Write-Verbose -Message ('Try to Modify {0} with value {1} as {2} in {3}' -f $DscpVal, $AudioMark, $STRG, $ServerAudioPath)

				$null = (Set-ItemProperty @paramNewItemProperty)

				Write-Verbose -Message ('Modified {0} with value {1} as {2} in {3}' -f $DscpVal, $AudioMark, $STRG, $ServerAudioPath)
			}
			catch
			{
				Write-Warning -Message ('Unable to create {0} with value {1} as {2} in {3}' -f $DscpVal, $AudioMark, $STRG, $ServerAudioPath)
			}
		}

		try
		{
			Write-Verbose -Message ('Try to create {0} with value {1} as {2} in {3}' -f $LocIP, $IP, $STRG, $ServerAudioPath)

			# Cleanup
			$paramNewItemProperty = $null

			# Splat reusable parameters
			$paramNewItemProperty = @{
				Path          = $ServerAudioPath
				Force         = $true
				Confirm       = $false
				PropertyType  = $STRG
				Name          = $LocIP
				Value         = $IP
				ErrorAction   = $STP
				WarningAction = $SC
			}

			$null = (New-ItemProperty @paramNewItemProperty)

			Write-Verbose -Message ('Created {0} with value {1} as {2} in {3}' -f $LocIP, $IP, $STRG, $ServerAudioPath)
		}
		catch
		{
			try
			{
				Write-Verbose -Message ('Try to modify {0} with value {1} as {2} in {3}' -f $LocIP, $IP, $STRG, $ServerAudioPath)

				$null = (Set-ItemProperty @paramNewItemProperty)

				Write-Verbose -Message ('Modified {0} with value {1} as {2} in {3}' -f $LocIP, $IP, $STRG, $ServerAudioPath)
			}
			catch
			{
				Write-Warning -Message ('Unable to create {0} with value {1} as {2} in {3}' -f $LocIP, $IP, $STRG, $ServerAudioPath)
			}
		}

		try
		{
			Write-Verbose -Message ('Try to create {0} with value {1} as {2} in {3}' -f $LocIPLen, $WC, $STRG, $ServerAudioPath)

			# Cleanup
			$paramNewItemProperty = $null

			# Splat reusable parameters
			$paramNewItemProperty = @{
				Path          = $ServerAudioPath
				Force         = $true
				Confirm       = $false
				PropertyType  = $STRG
				Name          = $LocIPLen
				Value         = $WC
				ErrorAction   = $STP
				WarningAction = $SC
			}

			$null = (New-ItemProperty @paramNewItemProperty)

			Write-Verbose -Message ('Create {0} with value {1} as {2} in {3}' -f $LocIPLen, $WC, $STRG, $ServerAudioPath)
		}
		catch
		{
			try
			{
				Write-Verbose -Message ('Try to modify {0} with value {1} as {2} in {3}' -f $LocIPLen, $WC, $STRG, $ServerAudioPath)

				$null = (Set-ItemProperty @paramNewItemProperty)

				Write-Verbose -Message ('Modified {0} with value {1} as {2} in {3}' -f $LocIPLen, $WC, $STRG, $ServerAudioPath)
			}
			catch
			{
				Write-Warning -Message ('Unable to create {0} with value {1} as {2} in {3}' -f $LocIPLen, $WC, $STRG, $ServerAudioPath)
			}
		}

		try
		{
			Write-Verbose -Message ('Try to create {0} with value {1} as {2} in {3}' -f $LocPort, $AudioPorts, $STRG, $ServerAudioPath)

			# Cleanup
			$paramNewItemProperty = $null

			# Splat reusable parameters
			$paramNewItemProperty = @{
				Path          = $ServerAudioPath
				Force         = $true
				Confirm       = $false
				PropertyType  = $STRG
				Name          = $LocPort
				Value         = $AudioPorts
				ErrorAction   = $STP
				WarningAction = $SC
			}

			$null = (New-ItemProperty @paramNewItemProperty)

			Write-Verbose -Message ('Created {0} with value {1} as {2} in {3}' -f $LocPort, $AudioPorts, $STRG, $ServerAudioPath)
		}
		catch
		{
			try
			{
				Write-Verbose -Message ('Try to modify {0} with value {1} as {2} in {3}' -f $LocPort, $AudioPorts, $STRG, $ServerAudioPath)

				$null = (Set-ItemProperty @paramNewItemProperty)

				Write-Verbose -Message ('Modified {0} with value {1} as {2} in {3}' -f $LocPort, $AudioPorts, $STRG, $ServerAudioPath)
			}
			catch
			{
				Write-Warning -Message ('Unable to create {0} with value {1} as {2} in {3}' -f $LocPort, $AudioPorts, $STRG, $ServerAudioPath)
			}
		}

		try
		{
			Write-Verbose -Message ('Try to create {0} with value {1} as {2} in {3}' -f $RemIP, $WC, $STRG, $ServerAudioPath)

			# Cleanup
			$paramNewItemProperty = $null

			# Splat reusable parameters
			$paramNewItemProperty = @{
				Path          = $ServerAudioPath
				Force         = $true
				Confirm       = $false
				PropertyType  = $STRG
				Name          = $RemIP
				Value         = $WC
				ErrorAction   = $STP
				WarningAction = $SC
			}

			$null = (New-ItemProperty @paramNewItemProperty)

			Write-Verbose -Message ('Created {0} with value {1} as {2} in {3}' -f $RemIP, $WC, $STRG, $ServerAudioPath)
		}
		catch
		{
			try
			{
				Write-Verbose -Message ('Try to modify {0} with value {1} as {2} in {3}' -f $RemIP, $WC, $STRG, $ServerAudioPath)

				$null = (Set-ItemProperty @paramNewItemProperty)

				Write-Verbose -Message ('Modified {0} with value {1} as {2} in {3}' -f $RemIP, $WC, $STRG, $ServerAudioPath)
			}
			catch
			{
				Write-Warning -Message ('Unable to create {0} with value {1} as {2} in {3}' -f $RemIP, $WC, $STRG, $ServerAudioPath)
			}
		}

		try
		{
			Write-Verbose -Message ('Try to create {0} with value {1} as {2} in {3}' -f $RemIPLen, $WC, $STRG, $ServerAudioPath)

			# Cleanup
			$paramNewItemProperty = $null

			# Splat reusable parameters
			$paramNewItemProperty = @{
				Path          = $ServerAudioPath
				Force         = $true
				Confirm       = $false
				PropertyType  = $STRG
				Name          = $RemIPLen
				Value         = $WC
				ErrorAction   = $STP
				WarningAction = $SC
			}

			$null = (New-ItemProperty @paramNewItemProperty)

			Write-Verbose -Message ('Created {0} with value {1} as {2} in {3}' -f $RemIPLen, $WC, $STRG, $ServerAudioPath)
		}
		catch
		{
			try
			{
				Write-Verbose -Message ('Try to modify {0} with value {1} as {2} in {3}' -f $RemIPLen, $WC, $STRG, $ServerAudioPath)

				$null = (Set-ItemProperty @paramNewItemProperty)

				Write-Verbose -Message ('Modified {0} with value {1} as {2} in {3}' -f $RemIPLen, $WC, $STRG, $ServerAudioPath)
			}
			catch
			{
				Write-Warning -Message ('Unable to create {0} with value {1} as {2} in {3}' -f $RemIPLen, $WC, $STRG, $ServerAudioPath)
			}
		}

		try
		{
			Write-Verbose -Message ('Try to create {0} with value {1} as {2} in {3}' -f $RemPort, $WC, $STRG, $ServerAudioPath)

			# Cleanup
			$paramNewItemProperty = $null

			# Splat reusable parameters
			$paramNewItemProperty = @{
				Path          = $ServerAudioPath
				Force         = $true
				Confirm       = $false
				PropertyType  = $STRG
				Name          = $RemPort
				Value         = $WC
				ErrorAction   = $STP
				WarningAction = $SC
			}

			$null = (New-ItemProperty @paramNewItemProperty)

			Write-Verbose -Message ('Created {0} with value {1} as {2} in {3}' -f $RemPort, $WC, $STRG, $ServerAudioPath)
		}
		catch
		{
			try
			{
				Write-Verbose -Message ('Try to modify {0} with value {1} as {2} in {3}' -f $RemPort, $WC, $STRG, $ServerAudioPath)

				$null = (Set-ItemProperty @paramNewItemProperty)

				Write-Verbose -Message ('Modified {0} with value {1} as {2} in {3}' -f $RemPort, $WC, $STRG, $ServerAudioPath)
			}
			catch
			{
				Write-Warning -Message ('Unable to create {0} with value {1} as {2} in {3}' -f $RemPort, $WC, $STRG, $ServerAudioPath)
			}
		}

		try
		{
			Write-Verbose -Message ('Try to create {0} with value {1} as {2} in {3}' -f $ThrotRate, $MinusOne, $STRG, $ServerAudioPath)

			# Cleanup
			$paramNewItemProperty = $null

			# Splat reusable parameters
			$paramNewItemProperty = @{
				Path          = $ServerAudioPath
				Force         = $true
				Confirm       = $false
				PropertyType  = $STRG
				Name          = $ThrotRate
				Value         = $MinusOne
				ErrorAction   = $STP
				WarningAction = $SC
			}

			$null = (New-ItemProperty @paramNewItemProperty)

			Write-Verbose -Message ('Created {0} with value {1} as {2} in {3}' -f $ThrotRate, $MinusOne, $STRG, $ServerAudioPath)
		}
		catch
		{
			try
			{
				Write-Verbose -Message ('Try to modify {0} with value {1} as {2} in {3}' -f $ThrotRate, $MinusOne, $STRG, $ServerAudioPath)

				$null = (Set-ItemProperty @paramNewItemProperty)

				Write-Verbose -Message ('Modified {0} with value {1} as {2} in {3}' -f $ThrotRate, $MinusOne, $STRG, $ServerAudioPath)
			}
			catch
			{
				Write-Warning -Message ('Unable to create {0} with value {1} as {2} in {3}' -f $ThrotRate, $MinusOne, $STRG, $ServerAudioPath)
			}
		}

		try
		{
			Write-Verbose -Message ('Try to create {0} with value {1} as {2} in {3}' -f $Version, $OneZero, $STRG, $ServerAudioPath)

			# Cleanup
			$paramNewItemProperty = $null

			# Splat reusable parameters
			$paramNewItemProperty = @{
				Path          = $ServerAudioPath
				Force         = $true
				Confirm       = $false
				PropertyType  = $STRG
				Name          = $Version
				Value         = $OneZero
				ErrorAction   = $STP
				WarningAction = $SC
			}

			$null = (New-ItemProperty @paramNewItemProperty)

			Write-Verbose -Message ('Created {0} with value {1} as {2} in {3}' -f $Version, $OneZero, $STRG, $ServerAudioPath)
		}
		catch
		{
			try
			{
				Write-Verbose -Message ('Try to modify {0} with value {1} as {2} in {3}' -f $Version, $OneZero, $STRG, $ServerAudioPath)

				$null = (Set-ItemProperty @paramNewItemProperty)

				Write-Verbose -Message ('Modified {0} with value {1} as {2} in {3}' -f $Version, $OneZero, $STRG, $ServerAudioPath)
			}
			catch
			{
				Write-Warning -Message ('Unable to create {0} with value {1} as {2} in {3}' -f $Version, $OneZero, $STRG, $ServerAudioPath)
			}
		}

		#endregion ServerAudioPath

		#region ServerVideoPath

		try
		{
			Write-Verbose -Message ('Try to create {0}' -f $ServerVideoPath)

			# Cleanup
			$paramNewItem = $null

			# Splat reusable parameters
			$paramNewItem = @{
				Path          = $ServerVideoPath
				Force         = $true
				Confirm       = $false
				ErrorAction   = $STP
				WarningAction = $SC
			}

			$null = (New-Item @paramNewItem)

			Write-Verbose -Message ('Created {0}' -f $ServerVideoPath)
		}
		catch
		{
			Write-Verbose -Message ('Unable to create {0}' -f $ServerVideoPath)
		}

		try
		{
			Write-Verbose -Message ('Try to create {0} with value {1} as {2} in {3}' -f $Protocol, $WC, $STRG, $ServerVideoPath)

			# Cleanup
			$paramNewItemProperty = $null

			# Splat reusable parameters
			$paramNewItemProperty = @{
				Path          = $ServerVideoPath
				Force         = $true
				Confirm       = $false
				PropertyType  = $STRG
				Name          = $Protocol
				Value         = $WC
				ErrorAction   = $STP
				WarningAction = $SC
			}

			$null = (New-ItemProperty @paramNewItemProperty)

			Write-Verbose -Message ('Created {0} with value {1} as {2} in {3}' -f $Protocol, $WC, $STRG, $ServerVideoPath)
		}
		catch
		{
			try
			{
				Write-Verbose -Message ('Try to modify {0} with value {1} as {2} in {3}' -f $Protocol, $WC, $STRG, $ServerVideoPath)

				$null = (Set-ItemProperty @paramNewItemProperty)

				Write-Verbose -Message ('Modified {0} with value {1} as {2} in {3}' -f $Protocol, $WC, $STRG, $ServerVideoPath)
			}
			catch
			{
				Write-Warning -Message ('Unable to create {0} with value {1} as {2} in {3}' -f $Protocol, $WC, $STRG, $ServerVideoPath)
			}
		}

		try
		{
			Write-Verbose -Message ('Try to create {0} with value {1} as {2} in {3}' -f $DscpVal, $VideoMark, $STRG, $ServerVideoPath)

			# Cleanup
			$paramNewItemProperty = $null

			# Splat reusable parameters
			$paramNewItemProperty = @{
				Path          = $ServerVideoPath
				Force         = $true
				Confirm       = $false
				PropertyType  = $STRG
				Name          = $DscpVal
				Value         = $VideoMark
				ErrorAction   = $STP
				WarningAction = $SC
			}

			$null = (New-ItemProperty @paramNewItemProperty)

			Write-Verbose -Message ('Created {0} with value {1} as {2} in {3}' -f $DscpVal, $VideoMark, $STRG, $ServerVideoPath)
		}
		catch
		{
			try
			{
				Write-Verbose -Message ('Try to modify {0} with value {1} as {2} in {3}' -f $DscpVal, $VideoMark, $STRG, $ServerVideoPath)

				$null = (Set-ItemProperty @paramNewItemProperty)

				Write-Verbose -Message ('Modified {0} with value {1} as {2} in {3}' -f $DscpVal, $VideoMark, $STRG, $ServerVideoPath)
			}
			catch
			{
				Write-Warning -Message ('Unable to create {0} with value {1} as {2} in {3}' -f $DscpVal, $VideoMark, $STRG, $ServerVideoPath)
			}
		}

		try
		{
			Write-Verbose -Message ('Try to create {0} with value {1} as {2} in {3}' -f $LocIP, $IP, $STRG, $ServerVideoPath)

			# Cleanup
			$paramNewItemProperty = $null

			# Splat reusable parameters
			$paramNewItemProperty = @{
				Path          = $ServerVideoPath
				Force         = $true
				Confirm       = $false
				PropertyType  = $STRG
				Name          = $LocIP
				Value         = $IP
				ErrorAction   = $STP
				WarningAction = $SC
			}

			$null = (New-ItemProperty @paramNewItemProperty)

			Write-Verbose -Message ('Created {0} with value {1} as {2} in {3}' -f $LocIP, $IP, $STRG, $ServerVideoPath)
		}
		catch
		{
			try
			{
				Write-Verbose -Message ('Try to modify {0} with value {1} as {2} in {3}' -f $LocIP, $IP, $STRG, $ServerVideoPath)

				$null = (Set-ItemProperty @paramNewItemProperty)

				Write-Verbose -Message ('Modified {0} with value {1} as {2} in {3}' -f $LocIP, $IP, $STRG, $ServerVideoPath)
			}
			catch
			{
				Write-Warning -Message ('Unable to create {0} with value {1} as {2} in {3}' -f $LocIP, $IP, $STRG, $ServerVideoPath)
			}
		}

		try
		{
			Write-Verbose -Message ('Try to create {0} with value {1} as {2} in {3}' -f $LocIPLen, $WC, $STRG, $ServerVideoPath)

			# Cleanup
			$paramNewItemProperty = $null

			# Splat reusable parameters
			$paramNewItemProperty = @{
				Path          = $ServerVideoPath
				Force         = $true
				Confirm       = $false
				PropertyType  = $STRG
				Name          = $LocIPLen
				Value         = $WC
				ErrorAction   = $STP
				WarningAction = $SC
			}

			$null = (New-ItemProperty @paramNewItemProperty)

			Write-Verbose -Message ('Created {0} with value {1} as {2} in {3}' -f $LocIPLen, $WC, $STRG, $ServerVideoPath)
		}
		catch
		{
			try
			{
				Write-Verbose -Message ('Try to modify {0} with value {1} as {2} in {3}' -f $LocIPLen, $WC, $STRG, $ServerVideoPath)

				$null = (Set-ItemProperty @paramNewItemProperty)

				Write-Verbose -Message ('Modified {0} with value {1} as {2} in {3}' -f $LocIPLen, $WC, $STRG, $ServerVideoPath)
			}
			catch
			{
				Write-Warning -Message ('Unable to create {0} with value {1} as {2} in {3}' -f $LocIPLen, $WC, $STRG, $ServerVideoPath)
			}
		}

		try
		{
			Write-Verbose -Message ('Try to create {0} with value {1} as {2} in {3}' -f $LocPort, $VideoPorts, $STRG, $ServerVideoPath)

			# Cleanup
			$paramNewItemProperty = $null

			# Splat reusable parameters
			$paramNewItemProperty = @{
				Path          = $ServerVideoPath
				Force         = $true
				Confirm       = $false
				PropertyType  = $STRG
				Name          = $LocPort
				Value         = $VideoPorts
				ErrorAction   = $STP
				WarningAction = $SC
			}

			$null = (New-ItemProperty @paramNewItemProperty)

			Write-Verbose -Message ('created {0} with value {1} as {2} in {3}' -f $LocPort, $VideoPorts, $STRG, $ServerVideoPath)
		}
		catch
		{
			try
			{
				Write-Verbose -Message ('Try to modify {0} with value {1} as {2} in {3}' -f $LocPort, $VideoPorts, $STRG, $ServerVideoPath)

				$null = (Set-ItemProperty @paramNewItemProperty)

				Write-Verbose -Message ('Modified {0} with value {1} as {2} in {3}' -f $LocPort, $VideoPorts, $STRG, $ServerVideoPath)
			}
			catch
			{
				Write-Warning -Message ('Unable to create {0} with value {1} as {2} in {3}' -f $LocPort, $VideoPorts, $STRG, $ServerVideoPath)
			}
		}

		try
		{
			Write-Verbose -Message ('Try to create {0} with value {1} as {2} in {3}' -f $RemIP, $WC, $STRG, $ServerVideoPath)

			# Cleanup
			$paramNewItemProperty = $null

			# Splat reusable parameters
			$paramNewItemProperty = @{
				Path          = $ServerVideoPath
				Force         = $true
				Confirm       = $false
				PropertyType  = $STRG
				Name          = $RemIP
				Value         = $WC
				ErrorAction   = $STP
				WarningAction = $SC
			}

			$null = (New-ItemProperty @paramNewItemProperty)

			Write-Verbose -Message ('Created {0} with value {1} as {2} in {3}' -f $RemIP, $WC, $STRG, $ServerVideoPath)
		}
		catch
		{
			try
			{
				Write-Verbose -Message ('Try to modify {0} with value {1} as {2} in {3}' -f $RemIP, $WC, $STRG, $ServerVideoPath)

				$null = (Set-ItemProperty @paramNewItemProperty)

				Write-Verbose -Message ('Modified {0} with value {1} as {2} in {3}' -f $RemIP, $WC, $STRG, $ServerVideoPath)
			}
			catch
			{
				Write-Warning -Message ('Unable to create {0} with value {1} as {2} in {3}' -f $RemIP, $WC, $STRG, $ServerVideoPath)
			}
		}

		try
		{
			Write-Verbose -Message ('Try to create {0} with value {1} as {2} in {3}' -f $RemIPLen, $WC, $STRG, $ServerVideoPath)

			# Cleanup
			$paramNewItemProperty = $null

			# Splat reusable parameters
			$paramNewItemProperty = @{
				Path          = $ServerVideoPath
				Force         = $true
				Confirm       = $false
				PropertyType  = $STRG
				Name          = $RemIPLen
				Value         = $WC
				ErrorAction   = $STP
				WarningAction = $SC
			}

			$null = (New-ItemProperty @paramNewItemProperty)

			Write-Verbose -Message ('Created {0} with value {1} as {2} in {3}' -f $RemIPLen, $WC, $STRG, $ServerVideoPath)
		}
		catch
		{
			try
			{
				Write-Verbose -Message ('Try to modify {0} with value {1} as {2} in {3}' -f $RemIPLen, $WC, $STRG, $ServerVideoPath)

				$null = (Set-ItemProperty @paramNewItemProperty)

				Write-Verbose -Message ('Modified {0} with value {1} as {2} in {3}' -f $RemIPLen, $WC, $STRG, $ServerVideoPath)
			}
			catch
			{
				Write-Warning -Message ('Try to create {0} with value {1} as {2} in {3}' -f $RemIPLen, $WC, $STRG, $ServerVideoPath)
			}
		}

		try
		{
			Write-Verbose -Message ('Try to create {0} with value {1} as {2} in {3}' -f $RemPort, $WC, $STRG, $ServerVideoPath)

			# Cleanup
			$paramNewItemProperty = $null

			# Splat reusable parameters
			$paramNewItemProperty = @{
				Path          = $ServerVideoPath
				Force         = $true
				Confirm       = $false
				PropertyType  = $STRG
				Name          = $RemPort
				Value         = $WC
				ErrorAction   = $STP
				WarningAction = $SC
			}

			$null = (New-ItemProperty @paramNewItemProperty)

			Write-Verbose -Message ('Created {0} with value {1} as {2} in {3}' -f $RemPort, $WC, $STRG, $ServerVideoPath)
		}
		catch
		{
			try
			{
				Write-Verbose -Message ('Try to modify {0} with value {1} as {2} in {3}' -f $RemPort, $WC, $STRG, $ServerVideoPath)

				$null = (Set-ItemProperty @paramNewItemProperty)

				Write-Verbose -Message ('Modified {0} with value {1} as {2} in {3}' -f $RemPort, $WC, $STRG, $ServerVideoPath)
			}
			catch
			{
				Write-Warning -Message ('Unable to create {0} with value {1} as {2} in {3}' -f $RemPort, $WC, $STRG, $ServerVideoPath)
			}
		}

		try
		{
			Write-Verbose -Message ('Try to create {0} with value {1} as {2} in {3}' -f $ThrotRate, $MinusOne, $STRG, $ServerVideoPath)

			# Cleanup
			$paramNewItemProperty = $null

			# Splat reusable parameters
			$paramNewItemProperty = @{
				Path          = $ServerVideoPath
				Force         = $true
				Confirm       = $false
				PropertyType  = $STRG
				Name          = $ThrotRate
				Value         = $MinusOne
				ErrorAction   = $STP
				WarningAction = $SC
			}

			$null = (New-ItemProperty @paramNewItemProperty)

			Write-Verbose -Message ('Created {0} with value {1} as {2} in {3}' -f $ThrotRate, $MinusOne, $STRG, $ServerVideoPath)
		}
		catch
		{
			try
			{
				Write-Verbose -Message ('Try to modify {0} with value {1} as {2} in {3}' -f $ThrotRate, $MinusOne, $STRG, $ServerVideoPath)

				$null = (Set-ItemProperty @paramNewItemProperty)

				Write-Verbose -Message ('Modified {0} with value {1} as {2} in {3}' -f $ThrotRate, $MinusOne, $STRG, $ServerVideoPath)
			}
			catch
			{
				Write-Warning -Message ('Unable to create {0} with value {1} as {2} in {3}' -f $ThrotRate, $MinusOne, $STRG, $ServerVideoPath)
			}
		}

		try
		{
			Write-Verbose -Message ('Try to create {0} with value {1} as {2} in {3}' -f $Version, $OneZero, $STRG, $ServerVideoPath)

			# Cleanup
			$paramNewItemProperty = $null

			# Splat reusable parameters
			$paramNewItemProperty = @{
				Path          = $ServerVideoPath
				Force         = $true
				Confirm       = $false
				PropertyType  = $STRG
				Name          = $Version
				Value         = $OneZero
				ErrorAction   = $STP
				WarningAction = $SC
			}

			$null = (New-ItemProperty @paramNewItemProperty)

			Write-Verbose -Message ('Created {0} with value {1} as {2} in {3}' -f $Version, $OneZero, $STRG, $ServerVideoPath)
		}
		catch
		{
			try
			{
				Write-Verbose -Message ('Try to modify {0} with value {1} as {2} in {3}' -f $Version, $OneZero, $STRG, $ServerVideoPath)

				$null = (Set-ItemProperty @paramNewItemProperty)

				Write-Verbose -Message ('Modified {0} with value {1} as {2} in {3}' -f $Version, $OneZero, $STRG, $ServerVideoPath)
			}
			catch
			{
				Write-Warning -Message ('Unable to create {0} with value {1} as {2} in {3}' -f $Version, $OneZero, $STRG, $ServerVideoPath)
			}
		}

		#endregion ServerVideoPath

		#region ServerAppSharePath

		try
		{
			Write-Verbose -Message ('Try to create {0}' -f $ServerAppSharePath)

			# Cleanup
			$paramNewItem = $null

			# Splat reusable parameters
			$paramNewItem = @{
				Path          = $ServerAppSharePath
				Force         = $true
				Confirm       = $false
				ErrorAction   = $STP
				WarningAction = $SC
			}

			$null = (New-Item @paramNewItem)

			Write-Verbose -Message ('Created {0}' -f $ServerAppSharePath)
		}
		catch
		{
			Write-Verbose -Message ('Unable to create {0}' -f $ServerAppSharePath)
		}

		try
		{
			Write-Verbose -Message ('Try to create {0} with value {1} as {2} in {3}' -f $Protocol, $WC, $STRG, $ServerAppSharePath)

			# Cleanup
			$paramNewItemProperty = $null

			# Splat reusable parameters
			$paramNewItemProperty = @{
				Path          = $ServerAppSharePath
				Force         = $true
				Confirm       = $false
				PropertyType  = $STRG
				Name          = $Protocol
				Value         = $WC
				ErrorAction   = $STP
				WarningAction = $SC
			}

			$null = (New-ItemProperty @paramNewItemProperty)

			Write-Verbose -Message ('Created {0} with value {1} as {2} in {3}' -f $Protocol, $WC, $STRG, $ServerAppSharePath)
		}
		catch
		{
			try
			{
				Write-Verbose -Message ('Try to Modify {0} with value {1} as {2} in {3}' -f $Protocol, $WC, $STRG, $ServerAppSharePath)

				$null = (Set-ItemProperty @paramNewItemProperty)

				Write-Verbose -Message ('Modified {0} with value {1} as {2} in {3}' -f $Protocol, $WC, $STRG, $ServerAppSharePath)
			}
			catch
			{
				Write-Warning -Message ('Unable to create {0} with value {1} as {2} in {3}' -f $Protocol, $WC, $STRG, $ServerAppSharePath)
			}
		}

		try
		{
			Write-Verbose -Message ('Try to create {0} with value {1} as {2} in {3}' -f $DscpVal, $AppShareMark, $STRG, $ServerAppSharePath)

			# Cleanup
			$paramNewItemProperty = $null

			# Splat reusable parameters
			$paramNewItemProperty = @{
				Path          = $ServerAppSharePath
				Force         = $true
				Confirm       = $false
				PropertyType  = $STRG
				Name          = $DscpVal
				Value         = $AppShareMark
				ErrorAction   = $STP
				WarningAction = $SC
			}

			$null = (New-ItemProperty @paramNewItemProperty)

			Write-Verbose -Message ('Created {0} with value {1} as {2} in {3}' -f $DscpVal, $AppShareMark, $STRG, $ServerAppSharePath)
		}
		catch
		{
			try
			{
				Write-Verbose -Message ('Try to Modify {0} with value {1} as {2} in {2}' -f $DscpVal, $AppShareMark, $ServerAppSharePath)

				$null = (Set-ItemProperty @paramNewItemProperty)

				Write-Verbose -Message ('Modified {0} with value {1} as {2} in {3}' -f $DscpVal, $AppShareMark, $STRG, $ServerAppSharePath)
			}
			catch
			{
				Write-Warning -Message ('Unable to create {0} with value {1} as {2} in {3}' -f $DscpVal, $AppShareMark, $STRG, $ServerAppSharePath)
			}
		}

		try
		{
			Write-Verbose -Message ('Try to create {0} with value {1} as {2} in {3}' -f $LocIP, $IP, $STRG, $ServerAppSharePath)

			# Cleanup
			$paramNewItemProperty = $null

			# Splat reusable parameters
			$paramNewItemProperty = @{
				Path          = $ServerAppSharePath
				Force         = $true
				Confirm       = $false
				PropertyType  = $STRG
				Name          = $LocIP
				Value         = $IP
				ErrorAction   = $STP
				WarningAction = $SC
			}

			$null = (New-ItemProperty @paramNewItemProperty)

			Write-Verbose -Message ('Created {0} with value {1} as {2} in {3}' -f $LocIP, $IP, $STRG, $ServerAppSharePath)
		}
		catch
		{
			try
			{
				Write-Verbose -Message ('Try to modify {0} with value {1} as {2} in {3}' -f $LocIP, $IP, $STRG, $ServerAppSharePath)

				$null = (Set-ItemProperty @paramNewItemProperty)

				Write-Verbose -Message ('Modified {0} with value {1} as {2} in {3}' -f $LocIP, $IP, $STRG, $ServerAppSharePath)
			}
			catch
			{
				Write-Warning -Message ('Unable to create {0} with value {1} as {2} in {3}' -f $LocIP, $IP, $STRG, $ServerAppSharePath)
			}
		}

		try
		{
			Write-Verbose -Message ('Try to create {0} with value {1} as {2} in {3}' -f $LocIPLen, $WC, $STRG, $ServerAppSharePath)

			# Cleanup
			$paramNewItemProperty = $null

			# Splat reusable parameters
			$paramNewItemProperty = @{
				Path          = $ServerAppSharePath
				Force         = $true
				Confirm       = $false
				PropertyType  = $STRG
				Name          = $LocIPLen
				Value         = $WC
				ErrorAction   = $STP
				WarningAction = $SC
			}

			$null = (New-ItemProperty @paramNewItemProperty)

			Write-Verbose -Message ('Created {0} with value {1} as {2} in {3}' -f $LocIPLen, $WC, $STRG, $ServerAppSharePath)
		}
		catch
		{
			try
			{
				Write-Verbose -Message ('Try to modify {0} with value {1} as {2} in {3}' -f $LocIPLen, $WC, $STRG, $ServerAppSharePath)

				$null = (Set-ItemProperty @paramNewItemProperty)

				Write-Verbose -Message ('Modified {0} with value {1} as {2} in {3}' -f $LocIPLen, $WC, $STRG, $ServerAppSharePath)
			}
			catch
			{
				Write-Warning -Message ('Unable to create {0} with value {1} as {2} in {3}' -f $LocIPLen, $WC, $STRG, $ServerAppSharePath)
			}
		}

		try
		{
			Write-Verbose -Message ('Try to create {0} with value {1} as {2} in {3}' -f $LocPort, $AppSharePorts, $STRG, $ServerAppSharePath)

			# Cleanup
			$paramNewItemProperty = $null

			# Splat reusable parameters
			$paramNewItemProperty = @{
				Path          = $ServerAppSharePath
				Force         = $true
				Confirm       = $false
				PropertyType  = $STRG
				Name          = $LocPort
				Value         = $AppSharePorts
				ErrorAction   = $STP
				WarningAction = $SC
			}

			$null = (New-ItemProperty @paramNewItemProperty)

			Write-Verbose -Message ('Created {0} with value {1} as {2} in {3}' -f $LocPort, $AppSharePorts, $STRG, $ServerAppSharePath)
		}
		catch
		{
			try
			{
				Write-Verbose -Message ('Try to modify {0} with value {1} as {2} in {3}' -f $LocPort, $AppSharePorts, $STRG, $ServerAppSharePath)

				$null = (Set-ItemProperty @paramNewItemProperty)

				Write-Verbose -Message ('Modified {0} with value {1} as {2} in {3}' -f $LocPort, $AppSharePorts, $STRG, $ServerAppSharePath)
			}
			catch
			{
				Write-Warning -Message ('Unable to create {0} with value {1} as {2} in {3}' -f $LocPort, $AppSharePorts, $STRG, $ServerAppSharePath)
			}
		}

		try
		{
			Write-Verbose -Message ('Try to create {0} with value {1} as {2} in {3}' -f $RemIP, $WC, $STRG, $ServerAppSharePath)

			# Cleanup
			$paramNewItemProperty = $null

			# Splat reusable parameters
			$paramNewItemProperty = @{
				Path          = $ServerAppSharePath
				Force         = $true
				Confirm       = $false
				PropertyType  = $STRG
				Name          = $RemIP
				Value         = $WC
				ErrorAction   = $STP
				WarningAction = $SC
			}

			$null = (New-ItemProperty @paramNewItemProperty)

			Write-Verbose -Message ('Created {0} with value {1} as {2} in {3}' -f $RemIP, $WC, $STRG, $ServerAppSharePath)
		}
		catch
		{
			try
			{
				Write-Verbose -Message ('Try to moddify {0} with value {1} as {2} in {3}' -f $RemIP, $WC, $STRG, $ServerAppSharePath)

				$null = (Set-ItemProperty @paramNewItemProperty)

				Write-Verbose -Message ('Modified {0} with value {1} as {2} in {3}' -f $RemIP, $WC, $STRG, $ServerAppSharePath)
			}
			catch
			{
				Write-Warning -Message ('Unable to create {0} with value {1} as {2} in {3}' -f $RemIP, $WC, $STRG, $ServerAppSharePath)
			}
		}

		try
		{
			Write-Verbose -Message ('Try to create {0} with value {1} as {2} in {3}' -f $RemIPLen, $WC, $STRG, $ServerAppSharePath)

			# Cleanup
			$paramNewItemProperty = $null

			# Splat reusable parameters
			$paramNewItemProperty = @{
				Path          = $ServerAppSharePath
				Force         = $true
				Confirm       = $false
				PropertyType  = $STRG
				Name          = $RemIPLen
				Value         = $WC
				ErrorAction   = $STP
				WarningAction = $SC
			}

			$null = (New-ItemProperty @paramNewItemProperty)

			Write-Verbose -Message ('Created {0} with value {1} as {2} in {3}' -f $RemIPLen, $WC, $STRG, $ServerAppSharePath)
		}
		catch
		{
			try
			{
				Write-Verbose -Message ('Try to modify {0} with value {1} as {2} in {3}' -f $RemIPLen, $WC, $STRG, $ServerAppSharePath)

				$null = (Set-ItemProperty @paramNewItemProperty)

				Write-Verbose -Message ('Modified {0} with value {1} as {2} in {3}' -f $RemIPLen, $WC, $STRG, $ServerAppSharePath)
			}
			catch
			{
				Write-Warning -Message ('Unable to create {0} with value {1} as {2} in {3}' -f $RemIPLen, $WC, $STRG, $ServerAppSharePath)
			}
		}

		try
		{
			Write-Verbose -Message ('Try to create {0} with value {1} as {2} in {3}' -f $RemPort, $WC, $STRG, $ServerAppSharePath)

			# Cleanup
			$paramNewItemProperty = $null

			# Splat reusable parameters
			$paramNewItemProperty = @{
				Path          = $ServerAppSharePath
				Force         = $true
				Confirm       = $false
				PropertyType  = $STRG
				Name          = $RemPort
				Value         = $WC
				ErrorAction   = $STP
				WarningAction = $SC
			}

			$null = (New-ItemProperty @paramNewItemProperty)

			Write-Verbose -Message ('Created {0} with value {1} as {2} in {3}' -f $RemPort, $WC, $STRG, $ServerAppSharePath)
		}
		catch
		{
			try
			{
				Write-Verbose -Message ('Try to modify {0} with value {1} as {2} in {3}' -f $RemPort, $WC, $STRG, $ServerAppSharePath)

				$null = (Set-ItemProperty @paramNewItemProperty)

				Write-Verbose -Message ('Modified {0} with value {1} as {2} in {3}' -f $RemPort, $WC, $STRG, $ServerAppSharePath)
			}
			catch
			{
				Write-Warning -Message ('Unable to create {0} with value {1} as {2} in {3}' -f $RemPort, $WC, $STRG, $ServerAppSharePath)
			}
		}

		try
		{
			Write-Verbose -Message ('Try to create {0} with value {1} as {2} in {3}' -f $ThrotRate, $MinusOne, $STRG, $ServerAppSharePath)

			# Cleanup
			$paramNewItemProperty = $null

			# Splat reusable parameters
			$paramNewItemProperty = @{
				Path          = $ServerAppSharePath
				Force         = $true
				Confirm       = $false
				PropertyType  = $STRG
				Name          = $ThrotRate
				Value         = $MinusOne
				ErrorAction   = $STP
				WarningAction = $SC
			}

			$null = (New-ItemProperty @paramNewItemProperty)

			Write-Verbose -Message ('Created {0} with value {1} as {2} in {3}' -f $ThrotRate, $MinusOne, $STRG, $ServerAppSharePath)
		}
		catch
		{
			try
			{
				Write-Verbose -Message ('Try to modify {0} with value {1} as {2} in {3}' -f $ThrotRate, $MinusOne, $STRG, $ServerAppSharePath)

				$null = (Set-ItemProperty @paramNewItemProperty)

				Write-Verbose -Message ('Modified {0} with value {1} as {2} in {3}' -f $ThrotRate, $MinusOne, $STRG, $ServerAppSharePath)
			}
			catch
			{
				Write-Warning -Message ('Unable to create {0} with value {1} as {2} in {3}' -f $ThrotRate, $MinusOne, $STRG, $ServerAppSharePath)
			}
		}

		try
		{
			Write-Verbose -Message ('Try to create {0} with value {1} as {2} in {3}' -f $Version, $OneZero, $STRG, $ServerAppSharePath)

			# Cleanup
			$paramNewItemProperty = $null

			# Splat reusable parameters
			$paramNewItemProperty = @{
				Path          = $ServerAppSharePath
				Force         = $true
				Confirm       = $false
				PropertyType  = $STRG
				Name          = $Version
				Value         = $OneZero
				ErrorAction   = $STP
				WarningAction = $SC
			}

			$null = (New-ItemProperty @paramNewItemProperty)

			Write-Verbose -Message ('Created {0} with value {1} as {2} in {3}' -f $Version, $OneZero, $STRG, $ServerAppSharePath)
		}
		catch
		{
			try
			{
				Write-Verbose -Message ('Try to modify {0} with value {1} as {2} in {3}' -f $Version, $OneZero, $STRG, $ServerAppSharePath)

				$null = (Set-ItemProperty @paramNewItemProperty)

				Write-Verbose -Message ('Modified {0} with value {1} as {2} in {3}' -f $Version, $OneZero, $STRG, $ServerAppSharePath)
			}
			catch
			{
				Write-Warning -Message ('Unable to create {0} with value {1} as {2} in {3}' -f $Version, $OneZero, $STRG, $ServerAppSharePath)
			}
		}

		#endregion ServerAppSharePath
	}
	catch
	{
		Write-Error -Message 'Unable to find the IP Address of the Edge Node.' -ErrorAction $STP

		# Make sure we are done
		break
	}
}

END
{
	Write-Output -InputObject 'Done with the Skype for Business Edge Server QoS setup, Please Reboot this node.'
}

#region License

<#
		Copyright (c) 2017, Joerg Hochwald. All rights reserved.

		Redistribution and use in source and binary forms, with or without
		modification, are permitted provided that the following conditions are met:
		* Redistributions of source code must retain the above copyright notice, this
		list of conditions and the following disclaimer.
		* Redistributions in binary form must reproduce the above copyright notice,
		this list of conditions and the following disclaimer in the documentation
		and/or other materials provided with the distribution.
		* Neither the name of the copyright holder nor the names of its
		contributors may be used to endorse or promote products derived from
		this software without specific prior written permission.

		THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
		AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
		IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
		DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
		FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
		DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
		SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
		CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
		OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
		OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

		By using the Software, you agree to the License, Terms and Conditions above!
#>

<#
		This is a third-party Software!

		The developer of this Software is NOT sponsored by or affiliated with Microsoft Corp (MSFT) or any of its subsidiaries in any way
		The Software is not supported by Microsoft Corp (MSFT)!
#>

#endregion License

# SIG # Begin signature block
# MIIYpQYJKoZIhvcNAQcCoIIYljCCGJICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUYSPySuWVgAlOV/A2coG4KjaF
# 9VugghPNMIID7jCCA1egAwIBAgIQfpPr+3zGTlnqS5p31Ab8OzANBgkqhkiG9w0B
# AQUFADCBizELMAkGA1UEBhMCWkExFTATBgNVBAgTDFdlc3Rlcm4gQ2FwZTEUMBIG
# A1UEBxMLRHVyYmFudmlsbGUxDzANBgNVBAoTBlRoYXd0ZTEdMBsGA1UECxMUVGhh
# d3RlIENlcnRpZmljYXRpb24xHzAdBgNVBAMTFlRoYXd0ZSBUaW1lc3RhbXBpbmcg
# Q0EwHhcNMTIxMjIxMDAwMDAwWhcNMjAxMjMwMjM1OTU5WjBeMQswCQYDVQQGEwJV
# UzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xMDAuBgNVBAMTJ1N5bWFu
# dGVjIFRpbWUgU3RhbXBpbmcgU2VydmljZXMgQ0EgLSBHMjCCASIwDQYJKoZIhvcN
# AQEBBQADggEPADCCAQoCggEBALGss0lUS5ccEgrYJXmRIlcqb9y4JsRDc2vCvy5Q
# WvsUwnaOQwElQ7Sh4kX06Ld7w3TMIte0lAAC903tv7S3RCRrzV9FO9FEzkMScxeC
# i2m0K8uZHqxyGyZNcR+xMd37UWECU6aq9UksBXhFpS+JzueZ5/6M4lc/PcaS3Er4
# ezPkeQr78HWIQZz/xQNRmarXbJ+TaYdlKYOFwmAUxMjJOxTawIHwHw103pIiq8r3
# +3R8J+b3Sht/p8OeLa6K6qbmqicWfWH3mHERvOJQoUvlXfrlDqcsn6plINPYlujI
# fKVOSET/GeJEB5IL12iEgF1qeGRFzWBGflTBE3zFefHJwXECAwEAAaOB+jCB9zAd
# BgNVHQ4EFgQUX5r1blzMzHSa1N197z/b7EyALt0wMgYIKwYBBQUHAQEEJjAkMCIG
# CCsGAQUFBzABhhZodHRwOi8vb2NzcC50aGF3dGUuY29tMBIGA1UdEwEB/wQIMAYB
# Af8CAQAwPwYDVR0fBDgwNjA0oDKgMIYuaHR0cDovL2NybC50aGF3dGUuY29tL1Ro
# YXd0ZVRpbWVzdGFtcGluZ0NBLmNybDATBgNVHSUEDDAKBggrBgEFBQcDCDAOBgNV
# HQ8BAf8EBAMCAQYwKAYDVR0RBCEwH6QdMBsxGTAXBgNVBAMTEFRpbWVTdGFtcC0y
# MDQ4LTEwDQYJKoZIhvcNAQEFBQADgYEAAwmbj3nvf1kwqu9otfrjCR27T4IGXTdf
# plKfFo3qHJIJRG71betYfDDo+WmNI3MLEm9Hqa45EfgqsZuwGsOO61mWAK3ODE2y
# 0DGmCFwqevzieh1XTKhlGOl5QGIllm7HxzdqgyEIjkHq3dlXPx13SYcqFgZepjhq
# IhKjURmDfrYwggSjMIIDi6ADAgECAhAOz/Q4yP6/NW4E2GqYGxpQMA0GCSqGSIb3
# DQEBBQUAMF4xCzAJBgNVBAYTAlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jwb3Jh
# dGlvbjEwMC4GA1UEAxMnU3ltYW50ZWMgVGltZSBTdGFtcGluZyBTZXJ2aWNlcyBD
# QSAtIEcyMB4XDTEyMTAxODAwMDAwMFoXDTIwMTIyOTIzNTk1OVowYjELMAkGA1UE
# BhMCVVMxHTAbBgNVBAoTFFN5bWFudGVjIENvcnBvcmF0aW9uMTQwMgYDVQQDEytT
# eW1hbnRlYyBUaW1lIFN0YW1waW5nIFNlcnZpY2VzIFNpZ25lciAtIEc0MIIBIjAN
# BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAomMLOUS4uyOnREm7Dv+h8GEKU5Ow
# mNutLA9KxW7/hjxTVQ8VzgQ/K/2plpbZvmF5C1vJTIZ25eBDSyKV7sIrQ8Gf2Gi0
# jkBP7oU4uRHFI/JkWPAVMm9OV6GuiKQC1yoezUvh3WPVF4kyW7BemVqonShQDhfu
# ltthO0VRHc8SVguSR/yrrvZmPUescHLnkudfzRC5xINklBm9JYDh6NIipdC6Anqh
# d5NbZcPuF3S8QYYq3AhMjJKMkS2ed0QfaNaodHfbDlsyi1aLM73ZY8hJnTrFxeoz
# C9Lxoxv0i77Zs1eLO94Ep3oisiSuLsdwxb5OgyYI+wu9qU+ZCOEQKHKqzQIDAQAB
# o4IBVzCCAVMwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAO
# BgNVHQ8BAf8EBAMCB4AwcwYIKwYBBQUHAQEEZzBlMCoGCCsGAQUFBzABhh5odHRw
# Oi8vdHMtb2NzcC53cy5zeW1hbnRlYy5jb20wNwYIKwYBBQUHMAKGK2h0dHA6Ly90
# cy1haWEud3Muc3ltYW50ZWMuY29tL3Rzcy1jYS1nMi5jZXIwPAYDVR0fBDUwMzAx
# oC+gLYYraHR0cDovL3RzLWNybC53cy5zeW1hbnRlYy5jb20vdHNzLWNhLWcyLmNy
# bDAoBgNVHREEITAfpB0wGzEZMBcGA1UEAxMQVGltZVN0YW1wLTIwNDgtMjAdBgNV
# HQ4EFgQURsZpow5KFB7VTNpSYxc/Xja8DeYwHwYDVR0jBBgwFoAUX5r1blzMzHSa
# 1N197z/b7EyALt0wDQYJKoZIhvcNAQEFBQADggEBAHg7tJEqAEzwj2IwN3ijhCcH
# bxiy3iXcoNSUA6qGTiWfmkADHN3O43nLIWgG2rYytG2/9CwmYzPkSWRtDebDZw73
# BaQ1bHyJFsbpst+y6d0gxnEPzZV03LZc3r03H0N45ni1zSgEIKOq8UvEiCmRDoDR
# EfzdXHZuT14ORUZBbg2w6jiasTraCXEQ/Bx5tIB7rGn0/Zy2DBYr8X9bCT2bW+IW
# yhOBbQAuOA2oKY8s4bL0WqkBrxWcLC9JG9siu8P+eJRRw4axgohd8D20UaF5Mysu
# e7ncIAkTcetqGVvP6KUwVyyJST+5z3/Jvz4iaGNTmr1pdKzFHTx/kuDDvBzYBHUw
# ggVMMIIENKADAgECAhAW1PdTHZsYJ0/yJnM0UYBcMA0GCSqGSIb3DQEBCwUAMH0x
# CzAJBgNVBAYTAkdCMRswGQYDVQQIExJHcmVhdGVyIE1hbmNoZXN0ZXIxEDAOBgNV
# BAcTB1NhbGZvcmQxGjAYBgNVBAoTEUNPTU9ETyBDQSBMaW1pdGVkMSMwIQYDVQQD
# ExpDT01PRE8gUlNBIENvZGUgU2lnbmluZyBDQTAeFw0xNTA3MTcwMDAwMDBaFw0x
# ODA3MTYyMzU5NTlaMIGQMQswCQYDVQQGEwJERTEOMAwGA1UEEQwFMzU1NzYxDzAN
# BgNVBAgMBkhlc3NlbjEQMA4GA1UEBwwHTGltYnVyZzEYMBYGA1UECQwPQmFobmhv
# ZnNwbGF0eiAxMRkwFwYDVQQKDBBLcmVhdGl2U2lnbiBHbWJIMRkwFwYDVQQDDBBL
# cmVhdGl2U2lnbiBHbWJIMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA
# ryMOYXRM7T2omd0n14YWqtrWV/Xg0OEzzAhPxwVxn8BfZfOsTrNv/yQTmwvj90yG
# 5M6n5Iy3S0j9I43oFjfbTy/82UMjt+jMCod+a8+Etfqn9O0OSZIfWwPwAjKtMf1v
# bvAM1fisL3XgprgQEjywa1nBk5CTBB2VXqAIGZp1qv7tiRWEBsgiRJrMT3LJFO59
# +J2a0dXj0Mc+v6qXiOI0n8rbtkVlvAzqQYGUMEFKAtQq+58xj5c9S6SnN0JoDRTP
# KAZR0N+DLSG1JKnwxH1GerhYwvS399PQhm+avEKuHs1eRBcAKTbG2eSrRtdQgLof
# RmiWd+Xh9qe9VjK8PzyogQIDAQABo4IBsjCCAa4wHwYDVR0jBBgwFoAUKZFg/4pN
# +uv5pmq4z/nmS71JzhIwHQYDVR0OBBYEFJ5Ubj/1S9WOa/xJPLh/uQYe5xKGMA4G
# A1UdDwEB/wQEAwIHgDAMBgNVHRMBAf8EAjAAMBMGA1UdJQQMMAoGCCsGAQUFBwMD
# MBEGCWCGSAGG+EIBAQQEAwIEEDBGBgNVHSAEPzA9MDsGDCsGAQQBsjEBAgEDAjAr
# MCkGCCsGAQUFBwIBFh1odHRwczovL3NlY3VyZS5jb21vZG8ubmV0L0NQUzBDBgNV
# HR8EPDA6MDigNqA0hjJodHRwOi8vY3JsLmNvbW9kb2NhLmNvbS9DT01PRE9SU0FD
# b2RlU2lnbmluZ0NBLmNybDB0BggrBgEFBQcBAQRoMGYwPgYIKwYBBQUHMAKGMmh0
# dHA6Ly9jcnQuY29tb2RvY2EuY29tL0NPTU9ET1JTQUNvZGVTaWduaW5nQ0EuY3J0
# MCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5jb21vZG9jYS5jb20wIwYDVR0RBBww
# GoEYaG9jaHdhbGRAa3JlYXRpdnNpZ24ubmV0MA0GCSqGSIb3DQEBCwUAA4IBAQBJ
# JmTEqjcTIST+pbRkKzsIMMcpPHdRyoTGKCxpjQNGj19taCpbKci2yp3AWS5BgnHO
# SeqbYky/AgroG19ZzrhZmHLQG0jdLeHHNgfEONUMEsHL3WSP+Z10+N6frRb4vrqg
# 0ReIG4iw5wn17u0fpWf14URSO6rl6ygkzoVX4wgq/+M8VYynkHoS1fgsMcSliktF
# VCe7GhzfyaZ341+NwPb+j/zVu7ouYEV6AcBoYOlOEZ/weTc1XLQZylDe2uqYfp7c
# KmbxS3lSShI41l2RhbCvOSbMWAnKgzaudMxOHh+JzEFCkHsiS/hUSesdFF6KFnTP
# A34eRc7VcSd3eGb7TyMvMIIF4DCCA8igAwIBAgIQLnyHzA6TSlL+lP0ct800rzAN
# BgkqhkiG9w0BAQwFADCBhTELMAkGA1UEBhMCR0IxGzAZBgNVBAgTEkdyZWF0ZXIg
# TWFuY2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9yZDEaMBgGA1UEChMRQ09NT0RPIENB
# IExpbWl0ZWQxKzApBgNVBAMTIkNPTU9ETyBSU0EgQ2VydGlmaWNhdGlvbiBBdXRo
# b3JpdHkwHhcNMTMwNTA5MDAwMDAwWhcNMjgwNTA4MjM1OTU5WjB9MQswCQYDVQQG
# EwJHQjEbMBkGA1UECBMSR3JlYXRlciBNYW5jaGVzdGVyMRAwDgYDVQQHEwdTYWxm
# b3JkMRowGAYDVQQKExFDT01PRE8gQ0EgTGltaXRlZDEjMCEGA1UEAxMaQ09NT0RP
# IFJTQSBDb2RlIFNpZ25pbmcgQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK
# AoIBAQCmmJBjd5E0f4rR3elnMRHrzB79MR2zuWJXP5O8W+OfHiQyESdrvFGRp8+e
# niWzX4GoGA8dHiAwDvthe4YJs+P9omidHCydv3Lj5HWg5TUjjsmK7hoMZMfYQqF7
# tVIDSzqwjiNLS2PgIpQ3e9V5kAoUGFEs5v7BEvAcP2FhCoyi3PbDMKrNKBh1SMF5
# WgjNu4xVjPfUdpA6M0ZQc5hc9IVKaw+A3V7Wvf2pL8Al9fl4141fEMJEVTyQPDFG
# y3CuB6kK46/BAW+QGiPiXzjbxghdR7ODQfAuADcUuRKqeZJSzYcPe9hiKaR+ML0b
# tYxytEjy4+gh+V5MYnmLAgaff9ULAgMBAAGjggFRMIIBTTAfBgNVHSMEGDAWgBS7
# r34CPfqm8TyEjq3uOJjs2TIy1DAdBgNVHQ4EFgQUKZFg/4pN+uv5pmq4z/nmS71J
# zhIwDgYDVR0PAQH/BAQDAgGGMBIGA1UdEwEB/wQIMAYBAf8CAQAwEwYDVR0lBAww
# CgYIKwYBBQUHAwMwEQYDVR0gBAowCDAGBgRVHSAAMEwGA1UdHwRFMEMwQaA/oD2G
# O2h0dHA6Ly9jcmwuY29tb2RvY2EuY29tL0NPTU9ET1JTQUNlcnRpZmljYXRpb25B
# dXRob3JpdHkuY3JsMHEGCCsGAQUFBwEBBGUwYzA7BggrBgEFBQcwAoYvaHR0cDov
# L2NydC5jb21vZG9jYS5jb20vQ09NT0RPUlNBQWRkVHJ1c3RDQS5jcnQwJAYIKwYB
# BQUHMAGGGGh0dHA6Ly9vY3NwLmNvbW9kb2NhLmNvbTANBgkqhkiG9w0BAQwFAAOC
# AgEAAj8COcPu+Mo7id4MbU2x8U6ST6/COCwEzMVjEasJY6+rotcCP8xvGcM91hoI
# lP8l2KmIpysQGuCbsQciGlEcOtTh6Qm/5iR0rx57FjFuI+9UUS1SAuJ1CAVM8bdR
# 4VEAxof2bO4QRHZXavHfWGshqknUfDdOvf+2dVRAGDZXZxHNTwLk/vPa/HUX2+y3
# 92UJI0kfQ1eD6n4gd2HITfK7ZU2o94VFB696aSdlkClAi997OlE5jKgfcHmtbUIg
# os8MbAOMTM1zB5TnWo46BLqioXwfy2M6FafUFRunUkcyqfS/ZEfRqh9TTjIwc8Jv
# t3iCnVz/RrtrIh2IC/gbqjSm/Iz13X9ljIwxVzHQNuxHoc/Li6jvHBhYxQZ3ykub
# Ua9MCEp6j+KjUuKOjswm5LLY5TjCqO3GgZw1a6lYYUoKl7RLQrZVnb6Z53BtWfht
# Kgx/GWBfDJqIbDCsUgmQFhv/K53b0CDKieoofjKOGd97SDMe12X4rsn4gxSTdn1k
# 0I7OvjV9/3IxTZ+evR5sL6iPDAZQ+4wns3bJ9ObXwzTijIchhmH+v1V04SF3Awpo
# bLvkyanmz1kl63zsRQ55ZmjoIs2475iFTZYRPAmK0H+8KCgT+2rKVI2SXM3CZZgG
# ns5IW9S1N5NGQXwH3c/6Q++6Z2H/fUnguzB9XIDj5hY5S6cxggRCMIIEPgIBATCB
# kTB9MQswCQYDVQQGEwJHQjEbMBkGA1UECBMSR3JlYXRlciBNYW5jaGVzdGVyMRAw
# DgYDVQQHEwdTYWxmb3JkMRowGAYDVQQKExFDT01PRE8gQ0EgTGltaXRlZDEjMCEG
# A1UEAxMaQ09NT0RPIFJTQSBDb2RlIFNpZ25pbmcgQ0ECEBbU91MdmxgnT/ImczRR
# gFwwCQYFKw4DAhoFAKB4MBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZI
# hvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcC
# ARUwIwYJKoZIhvcNAQkEMRYEFMnP4i5kqtaZckPadXuO7ae2nrifMA0GCSqGSIb3
# DQEBAQUABIIBADuVLnM9VD9Ih68WpaJ8BK9cCYys8gJif1L4wJTGLW/0pOerxKBs
# nm0DCSCJjCpu5rzrhgX/fW71MpBaH1PeO6M+xehBxGw00Zamj448psg8vqvojrSR
# tA5kC0/CaiU8K/6HYndeuVwE0en+qDa5gDRkApxik7/auMYRJSYJFTzOxEcU4w77
# 6bH0k//Lb+B7BmLo9/JNC7F/6N5j69W2dZdvMrOvWzfqr+vVCcHgoJx4JTsji+b4
# g8QfJsiXJSN7+PnlR+vZiN66h3iOE06dSdKiof8QAtSSFvePzc7h20xB1FFMw0co
# iug5PgWV3YCwkTLMyOxBQhsSDb28y7WQe56hggILMIICBwYJKoZIhvcNAQkGMYIB
# +DCCAfQCAQEwcjBeMQswCQYDVQQGEwJVUzEdMBsGA1UEChMUU3ltYW50ZWMgQ29y
# cG9yYXRpb24xMDAuBgNVBAMTJ1N5bWFudGVjIFRpbWUgU3RhbXBpbmcgU2Vydmlj
# ZXMgQ0EgLSBHMgIQDs/0OMj+vzVuBNhqmBsaUDAJBgUrDgMCGgUAoF0wGAYJKoZI
# hvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTcxMjE0MDk0NTIw
# WjAjBgkqhkiG9w0BCQQxFgQUZCQerDnAAUVRaTZXoTeKLMg0oEwwDQYJKoZIhvcN
# AQEBBQAEggEABcoyLMbWLDOWcqmcXhzl11UZt4BfZmgYxDqwWo/EJnEzuWS7yEMG
# Ou8t+bvnw0WiJnKj9jZyKM2RrUcHZ5W1L4bl6cDyGp23nMbDA3X1rHY00ol6S0XN
# nTBAfIeoPhDwToaSZf51Wp3pWYlT7HGDy7JbJOQMTvrYdViNk1yg4DsODFfsQhj4
# f6mH9oMzEXN4vlErGFmbgviqidziqMOCl7qGtij+RqGAskyUYXOYxlfdUHFzSdG8
# KVXwtTZ5T2EE/1NPw1Woqvvu4VR/2ILw9bMhIc5v19yW8N2n2+EeTZPfuzdaFZN2
# LF2P45zHDcKbaB4rA/GANXdiNodKMIBBKA==
# SIG # End signature block
