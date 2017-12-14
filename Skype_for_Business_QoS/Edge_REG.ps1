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
