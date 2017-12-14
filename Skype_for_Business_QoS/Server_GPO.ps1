<#
		.SYNOPSIS
		Create the S4B Server QoS Group Policy

		.DESCRIPTION
		Create the Skype for Busines related Quality of Services Server Group Policy

		.EXAMPLE
		PS C:\> .\Server_GPO.ps1

		.EXAMPLE
		PS C:\> .\Server_GPO.ps1 -verbose

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

	#region GroupPolicyInfo

	# GPO (Policy) Name
	[string]$PolicyName = 'S4B QoS - Server'

	# GPO (Policy) Comment
	[string]$PolicyComment = 'DSCP markings for Lync/Skype for Business front end server traffic. This GPO should be applied to all Organizational Units (OUs) containing Lync/Skype for Business front-end servers.'

	#endregion GroupPolicyInfo

	#region Executables

	# Executables
	[string]$OcsAppServerHost = 'OcsAppServerHost.exe'
	[string]$avmcusvc = 'avmcusvc.exe'
	[string]$asmcusvc = 'asmcusvc.exe'

	#endregion Executables

	#region Defaults

	# Define some Defaults
	[string]$SC = 'SilentlyContinue'
	[string]$STP = 'Stop'
	[string]$MinusOne = '-1'
	[string]$OneZero = '1.0'
	[string]$One = '1'
	[string]$WC = '*'
	[string]$ThrotRate = 'Throttle Rate'
	[string]$DscpVal = 'DSCP Value'
	[string]$RemIPLen = 'Remote IP Prefix Length'
	[string]$RemIP = 'Remote IP'
	[string]$RemPort = 'Remote Port'
	[string]$LocIPLen = 'Local IP Prefix Length'
	[string]$LocIP = 'Local IP'
	[string]$LocPort = 'Local Port'
	[string]$Protocol = 'Protocol'
	[string]$AppName = 'Application Name'
	[string]$Version = 'Version'
	[string]$STRG = 'String'
	[string]$UserSettingsDisabled = 'UserSettingsDisabled'
	[string]$ServicesTcpipQoSName = 'HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\QoS'
	[string]$ServicesTcpipQoSValue = 'Do not use NLA'
	[string]$Action = 'Update'
	[string]$Context = 'Computer'

	#endregion Defaults

	#region ModuleHandler

	try
	{
		# List of Modules
		$Modules = 'ActiveDirectory', 'GroupPolicy'

		# Loop over the Module List
		foreach ($Module in $Modules)
		{
			# Import the Module
			Write-Verbose -Message ('Importing {0}' -f $Module)

			$null = (Import-Module -Name $Module -ErrorAction $STP -WarningAction $SC)

			Write-Verbose -Message ('Imported {0}' -f $Module)
		}
	}
	catch
	{
		# Whoops
		Write-Error -Message ('Unable to import the {0} Module, please check your Setup!' -f $Module) -ErrorAction $STP

		# We are done here...
		break
	}

	#endregion ModuleHandler
}

PROCESS
{
	#region CreateGroupPolicy

	try
	{
		Write-Verbose -Message ('Try to create {0}' -f $PolicyName)

		#Cleanup
		$paramNewGPO = $null

		# Splat reusable parameters
		$paramNewGPO = @{
			Name          = $PolicyName
			Comment       = $PolicyComment
			ErrorAction   = Stop
			WarningAction = SilentlyContinue
			Confirm       = $false
		}

		$null = (New-GPO @paramNewGPO)

		Write-Verbose -Message ('Created {0}' -f $PolicyName)
	}
	catch
	{
		Write-Verbose -Message ('The Policy {0} exists' -f $PolicyName)
	}

	#endregion CreateGroupPolicy

	#region ModifyGroupPolicy

	try
	{
		Write-Verbose -Message ('Try to modify {0}' -f $PolicyName)

		$null = ((Get-GPO -Name $PolicyName).GpoStatus = $UserSettingsDisabled)

		Write-Verbose -Message ('Modified {0}' -f $PolicyName)
	}
	catch
	{
		Write-Error -Message ('Unable to modify {0}' -f $PolicyName) -ErrorAction $STP

		# We are done here...
		break
	}

	#endregion ModifyGroupPolicy

	#region ServicesTcpipQoSName

	try
	{
		Write-Verbose -Message ('Try to Set {0} to {1} {2} in {3}' -f $ServicesTcpipQoSName, $ServicesTcpipQoSValue, $One, $PolicyName)

		# Cleanup
		$paramSetGPPrefRegistryValue = $null

		# Splat reusable parameters
		$paramSetGPPrefRegistryValue = @{
			Name          = $PolicyName
			ErrorAction   = Stop
			WarningAction = SilentlyContinue
			Context       = $Context
			Key           = $ServicesTcpipQoSName
			ValueName     = $ServicesTcpipQoSValue
			Value         = $One
			Type          = $STRG
			Action        = $Action
		}

		$null = (Set-GPPrefRegistryValue @paramSetGPPrefRegistryValue)

		Write-Verbose -Message ('Set {0} to {1} {2} in {3}' -f $ServicesTcpipQoSName, $ServicesTcpipQoSValue, $One, $PolicyName)
	}
	catch
	{
		Write-Warning -Message ('Unable to Set {0} to {1} {2} in {3}' -f $ServicesTcpipQoSName, $ServicesTcpipQoSValue, $One, $PolicyName)
	}

	#endregion ServicesTcpipQoSName

	#region ServerConferencing

	try
	{
		Write-Verbose -Message ('Try to set Server Conferencing Audio QoS in {0}' -f $PolicyName)

		# Cleanup
		$paramSetGPRegistryValue = $null

		# Splat reusable parameters
		$paramSetGPRegistryValue = @{
			Name          = $PolicyName
			ErrorAction   = $STP
			WarningAction = $SC
			Confirm       = $false
			Key           = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\Server Conferencing Audio QoS'
			ValueName     = $Version, $AppName, $Protocol, $LocPort, $LocIP, $LocIPLen, $RemPort, $RemIP, $RemIPLen, $DscpVal, $ThrotRate
			Type          = $STRG
			Value         = $OneZero, $avmcusvc, $WC, $AudioPorts, $WC, $WC, $WC, $WC, $WC, $AudioMark, $MinusOne
		}

		$null = (Set-GPRegistryValue @paramSetGPRegistryValue)

		Write-Verbose -Message ('Set Server Conferencing Audio QoS in {0}' -f $PolicyName)
	}
	catch
	{
		Write-Warning -Message ('Unable to set Server Conferencing Audio QoS in {0}' -f $PolicyName)
	}

	try
	{
		Write-Verbose -Message ('Try to set Server Conferencing Video QoS in {0}' -f $PolicyName)

		# Cleanup
		$paramSetGPRegistryValue = $null

		# Splat reusable parameters
		$paramSetGPRegistryValue = @{
			Name          = $PolicyName
			ErrorAction   = $STP
			WarningAction = $SC
			Confirm       = $false
			Key           = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\Server Conferencing Video QoS'
			ValueName     = $Version, $AppName, $Protocol, $LocPort, $LocIP, $LocIPLen, $RemPort, $RemIP, $RemIPLen, $DscpVal, $ThrotRate
			Type          = $STRG
			Value         = $OneZero, $avmcusvc, $WC, $VideoPorts, $WC, $WC, $WC, $WC, $WC, $VideoMark, $MinusOne
		}

		$null = (Set-GPRegistryValue @paramSetGPRegistryValue)

		Write-Verbose -Message ('Set Server Conferencing Video QoS in {0}' -f $PolicyName)
	}
	catch
	{
		Write-Warning -Message ('Unable to set Server Conferencing Video QoS in {0}' -f $PolicyName)
	}

	#endregion ServerConferencing

	#region ServerApplicationSharing

	try
	{
		Write-Verbose -Message ('Try to set Server Application Sharing QoS in {0}' -f $PolicyName)
		# Cleanup
		$paramSetGPRegistryValue = $null

		# Splat reusable parameters
		$paramSetGPRegistryValue = @{
			Name          = $PolicyName
			ErrorAction   = $STP
			WarningAction = $SC
			Confirm       = $false
			Key           = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\Server Application Sharing QoS'
			ValueName     = $Version, $AppName, $Protocol, $LocPort, $LocIP, $LocIPLen, $RemPort, $RemIP, $RemIPLen, $DscpVal, $ThrotRate
			Type          = $STRG
			Value         = $OneZero, $asmcusvc, $WC, $AppSharePorts, $WC, $WC, $WC, $WC, $WC, $AppShareMark, $MinusOne
		}

		$null = (Set-GPRegistryValue @paramSetGPRegistryValue)

		Write-Verbose -Message ('Set Server Application Sharing QoS in {0}' -f $PolicyName)
	}
	catch
	{
		Write-Warning -Message ('Unable to set Server Application Sharing QoS in {0}' -f $PolicyName)
	}

	#endregion ServerApplicationSharing

	#region ServerResponseGroup

	try
	{
		Write-Verbose -Message ('Try to set Server Response Group QoS in {0}' -f $PolicyName)

		# Cleanup
		$paramSetGPRegistryValue = $null

		# Splat reusable parameters
		$paramSetGPRegistryValue = @{
			Name          = $PolicyName
			ErrorAction   = $STP
			WarningAction = $SC
			Confirm       = $false
			Key           = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\Server Response Group QoS'
			ValueName     = $Version, $AppName, $Protocol, $LocPort, $LocIP, $LocIPLen, $RemPort, $RemIP, $RemIPLen, $DscpVal, $ThrotRate
			Type          = $STRG
			Value         = $OneZero, $OcsAppServerHost, $WC, $AudioPorts, $WC, $WC, $WC, $WC, $WC, $AudioMark, $MinusOne
		}

		$null = (Set-GPRegistryValue @paramSetGPRegistryValue)

		Write-Verbose -Message ('Set Server Response Group QoS in {0}' -f $PolicyName)
	}
	catch
	{
		Write-Warning -Message ('Unable to set Server Response Group QoS in {0}' -f $PolicyName)
	}

	#endregion ServerResponseGroup

	#region ServerConferenceAnnouncement

	try
	{
		Write-Verbose -Message ('Try to set Server Conference Announcement Service QoS in {0}' -f $PolicyName)

		# Cleanup
		$paramSetGPRegistryValue = $null

		# Splat reusable parameters
		$paramSetGPRegistryValue = @{
			Name          = $PolicyName
			ErrorAction   = $STP
			WarningAction = $SC
			Confirm       = $false
			Key           = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\Server Conference Announcement Service QoS'
			ValueName     = $Version, $AppName, $Protocol, $LocPort, $LocIP, $LocIPLen, $RemPort, $RemIP, $RemIPLen, $DscpVal, $ThrotRate
			Type          = $STRG
			Value         = $OneZero, $OcsAppServerHost, $WC, $AudioPorts, $WC, $WC, $WC, $WC, $WC, $AudioMark, $MinusOne
		}

		$null = (Set-GPRegistryValue @paramSetGPRegistryValue)

		Write-Verbose -Message ('Set Server Conference Announcement Service QoS in {0}' -f $PolicyName)
	}
	catch
	{
		Write-Warning -Message ('Unable to set Server Conference Announcement Service QoS in {0}' -f $PolicyName)
	}

	#endregion ServerConferenceAnnouncement

	#region ServerCallPark

	try
	{
		Write-Verbose -Message ('Try to set Server Call Park QoS in {0}' -f $PolicyName)

		# Cleanup
		$paramSetGPRegistryValue = $null

		# Splat reusable parameters
		$paramSetGPRegistryValue = @{
			Name          = $PolicyName
			ErrorAction   = $STP
			WarningAction = $SC
			Confirm       = $false
			Key           = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\Server Call Park QoS'
			ValueName     = $Version, $AppName, $Protocol, $LocPort, $LocIP, $LocIPLen, $RemPort, $RemIP, $RemIPLen, $DscpVal, $ThrotRate
			Type          = $STRG
			Value         = $OneZero, $OcsAppServerHost, $WC, $AudioPorts, $WC, $WC, $WC, $WC, $WC, $AudioMark, $MinusOne
		}

		$null = (Set-GPRegistryValue @paramSetGPRegistryValue)

		Write-Verbose -Message ('Set Server Call Park QoS in {0}' -f $PolicyName)
	}
	catch
	{
		Write-Warning -Message ('Unable to set Server Call Park QoS in {0}' -f $PolicyName)
	}

	#endregion ServerCallPark

	#region ServerUCMAApplications

	try
	{
		Write-Verbose -Message ('Try to set Server UCMA Applications Audio QoS in {0}' -f $PolicyName)

		# Cleanup
		$paramSetGPRegistryValue = $null

		# Splat reusable parameters
		$paramSetGPRegistryValue = @{
			Name          = $PolicyName
			ErrorAction   = $STP
			WarningAction = $SC
			Confirm       = $false
			Key           = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\Server UCMA Applications Audio QoS'
			ValueName     = $Version, $AppName, $Protocol, $LocPort, $LocIP, $LocIPLen, $RemPort, $RemIP, $RemIPLen, $DscpVal, $ThrotRate
			Type          = $STRG
			Value         = $OneZero, $OcsAppServerHost, $WC, $AudioPorts, $WC, $WC, $WC, $WC, $WC, $AudioMark, $MinusOne
		}

		$null = (Set-GPRegistryValue @paramSetGPRegistryValue)

		Write-Verbose -Message ('Set Server UCMA Applications Audio QoS in {0}' -f $PolicyName)
	}
	catch
	{
		Write-Warning -Message ('Unable to set Server UCMA Applications Audio QoS in {0}' -f $PolicyName)
	}

	try
	{
		Write-Verbose -Message ('Try to set Server UCMA Applications Video QoS in {0}' -f $PolicyName)

		# Cleanup
		$paramSetGPRegistryValue = $null

		# Splat reusable parameters
		$paramSetGPRegistryValue = @{
			Name          = $PolicyName
			ErrorAction   = $STP
			WarningAction = $SC
			Confirm       = $false
			Key           = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\Server UCMA Applications Video QoS'
			ValueName     = $Version, $AppName, $Protocol, $LocPort, $LocIP, $LocIPLen, $RemPort, $RemIP, $RemIPLen, $DscpVal, $ThrotRate
			Type          = $STRG
			Value         = $OneZero, $OcsAppServerHost, $WC, $VideoPorts, $WC, $WC, $WC, $WC, $WC, $VideoMark, $MinusOne
		}

		$null = (Set-GPRegistryValue @paramSetGPRegistryValue)

		Write-Verbose -Message ('Set Server UCMA Applications Video QoS in {0}' -f $PolicyName)
	}
	catch
	{
		Write-Warning -Message ('Unable to set Server UCMA Applications Video QoS in {0}' -f $PolicyName)
	}

	#endregion ServerUCMAApplications
}

END
{
	Write-Output -InputObject ('Done with the creation of {0}' -f $PolicyName)
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
