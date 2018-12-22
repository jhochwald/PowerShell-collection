<#
		.SYNOPSIS
		Create the S4B Client QoS Group Policy

		.DESCRIPTION
		Create the Skype for Busines related Quality of Services Client Group Policy

		.EXAMPLE
		PS C:\> .\Client_GPO.ps1

		.EXAMPLE
		PS C:\> .\Client_GPO.ps1 -verbose

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

	# Ports to use for File Transfer
	[string]$FileTransferPorts = '5350:5369'

	# QoS marking for File Transfer
	[string]$FileTransferMark = '14'

	# Legacy Media Ports (OCS 2007 R2 Media)
	[string]$LegacyMediaPorts = '5370:5389'

	# Lync SIP Ports
	[string]$LyncSipPorts = '5390:5409'

	#endregion Variables

	#region Executables

	# Executables
	[string]$MediaEngineService = 'MediaEngineService.exe'
	[string]$mstsc = 'mstsc.exe'
	[string]$LyncStore = 'lyncmx.exe'
	[string]$Lync = 'lync.exe'
	[string]$Communicator = 'communicator.exe'
	[string]$AttendantConsole = 'AttendantConsole.exe'

	#endregion Executables

	#region GroupPolicyInfo

	# GPO (Policy) Name
	[string]$PolicyName = 'S4B QoS - Client'

	# GPO (Policy) Comment
	[string]$PolicyComment = 'DSCP markings for Lync/Skype for Business client traffic. This GPO should be applied to all Organizational Units (OUs) containing client machines that will use Lync/Skype for Business.'

	#endregion GroupPolicyInfo

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
			ErrorAction   = $STP
			WarningAction = $SC
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
			ErrorAction   = $STP
			WarningAction = $SC
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

	#region communicator_exe

	try
	{
		Write-Verbose -Message ('Try to set OCS 2007 R2 Media - communicator.exe in {0}' -f $PolicyName)

		# Cleanup
		$paramSetGPRegistryValue = $null

		# Splat reusable parameters
		$paramSetGPRegistryValue = @{
			Name          = $PolicyName
			ErrorAction   = $STP
			WarningAction = $SC
			Confirm       = $false
			Key           = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\OCS 2007 R2 Media - communicator.exe'
			ValueName     = $Version, $AppName, $Protocol, $LocPort, $LocIP, $LocIPLen, $RemPort, $RemIP, $RemIPLen, $DscpVal, $ThrotRate
			Type          = $STRG
			Value         = $OneZero, $Communicator, $WC, $LegacyMediaPorts, $WC, $WC, $WC, $WC, $WC, $AudioMark, $MinusOne
		}

		$null = (Set-GPRegistryValue @paramSetGPRegistryValue)

		Write-Verbose -Message ('Set OCS 2007 R2 Media - communicator.exe in {0}' -f $PolicyName)
	}
	catch
	{
		Write-Warning -Message ('Unable to set OCS 2007 R2 Media - communicator.exe in {0}' -f $PolicyName)
	}

	try
	{
		Write-Verbose -Message ('Try to set Lync 2010 Audio QoS - communicator.exe in {0}' -f $PolicyName)

		# Cleanup
		$paramSetGPRegistryValue = $null

		# Splat reusable parameters
		$paramSetGPRegistryValue = @{
			Name          = $PolicyName
			ErrorAction   = $STP
			WarningAction = $SC
			Confirm       = $false
			Key           = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\Lync 2010 Audio QoS - communicator.exe'
			ValueName     = $Version, $AppName, $Protocol, $LocPort, $LocIP, $LocIPLen, $RemPort, $RemIP, $RemIPLen, $DscpVal, $ThrotRate
			Type          = $STRG
			Value         = $OneZero, $Communicator, $WC, $AudioPorts, $WC, $WC, $WC, $WC, $WC, $AudioMark, $MinusOne
		}

		$null = (Set-GPRegistryValue @paramSetGPRegistryValue)

		Write-Verbose -Message ('Set Lync 2010 Audio QoS - communicator.exe in {0}' -f $PolicyName)
	}
	catch
	{
		Write-Warning -Message ('Unable to set Lync 2010 Audio QoS - communicator.exe in {0}' -f $PolicyName)
	}

	try
	{
		Write-Verbose -Message ('Try to set Lync 2010 Video QoS - communicator.exe in {0}' -f $PolicyName)

		# Cleanup
		$paramSetGPRegistryValue = $null

		# Splat reusable parameters
		$paramSetGPRegistryValue = @{
			Name          = $PolicyName
			ErrorAction   = $STP
			WarningAction = $SC
			Confirm       = $false
			Key           = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\Lync 2010 Video QoS - communicator.exe'
			ValueName     = $Version, $AppName, $Protocol, $LocPort, $LocIP, $LocIPLen, $RemPort, $RemIP, $RemIPLen, $DscpVal, $ThrotRate
			Type          = $STRG
			Value         = $OneZero, $Communicator, $WC, $VideoPorts, $WC, $WC, $WC, $WC, $WC, $VideoMark, $MinusOne
		}

		$null = (Set-GPRegistryValue @paramSetGPRegistryValue)

		Write-Verbose -Message ('Set Lync 2010 Video QoS - communicator.exe in {0}' -f $PolicyName)
	}
	catch
	{
		Write-Warning -Message ('Unable to set Lync 2010 Video QoS - communicator.exe in {0}' -f $PolicyName)
	}

	try
	{
		Write-Verbose -Message ('Try to set Lync 2010 Application Sharing QoS - communicator.exe in {0}' -f $PolicyName)

		# Cleanup
		$paramSetGPRegistryValue = $null

		# Splat reusable parameters
		$paramSetGPRegistryValue = @{
			Name          = $PolicyName
			ErrorAction   = $STP
			WarningAction = $SC
			Confirm       = $false
			Key           = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\Lync 2010 Application Sharing QoS - communicator.exe'
			ValueName     = $Version, $AppName, $Protocol, $LocPort, $LocIP, $LocIPLen, $RemPort, $RemIP, $RemIPLen, $DscpVal, $ThrotRate
			Type          = $STRG
			Value         = $OneZero, $Communicator, $WC, $AppSharePorts, $WC, $WC, $WC, $WC, $WC, $AppShareMark, $MinusOne
		}

		$null = (Set-GPRegistryValue @paramSetGPRegistryValue)

		Write-Verbose -Message ('Set Lync 2010 Application Sharing QoS - communicator.exe in {0}' -f $PolicyName)
	}
	catch
	{
		Write-Warning -Message ('Unable to Set Lync 2010 Application Sharing QoS - communicator.exe in {0}' -f $PolicyName)
	}

	try
	{
		Write-Verbose -Message ('Try to set Lync 2010 File Transfer QoS - communicator.exe in {0}' -f $PolicyName)

		# Cleanup
		$paramSetGPRegistryValue = $null

		# Splat reusable parameters
		$paramSetGPRegistryValue = @{
			Name          = $PolicyName
			ErrorAction   = $STP
			WarningAction = $SC
			Confirm       = $false
			Key           = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\Lync 2010 File Transfer QoS - communicator.exe'
			ValueName     = $Version, $AppName, $Protocol, $LocPort, $LocIP, $LocIPLen, $RemPort, $RemIP, $RemIPLen, $DscpVal, $ThrotRate
			Type          = $STRG
			Value         = $OneZero, $Communicator, $WC, $FileTransferPorts, $WC, $WC, $WC, $WC, $WC, $FileTransferMark, $MinusOne
		}

		$null = (Set-GPRegistryValue @paramSetGPRegistryValue)

		Write-Verbose -Message ('Set Lync 2010 File Transfer QoS - communicator.exe in {0}' -f $PolicyName)
	}
	catch
	{
		Write-Warning -Message ('Unable to set Lync 2010 File Transfer QoS - communicator.exe in {0}' -f $PolicyName)
	}

	#endregion communicator_exe

	#region attendantconsole_exe

	try
	{
		Write-Verbose -Message ('Try to set Lync 2010 Attendant Audio QoS - attendantconsole.exe in {0}' -f $PolicyName)

		# Cleanup
		$paramSetGPRegistryValue = $null

		# Splat reusable parameters
		$paramSetGPRegistryValue = @{
			Name          = $PolicyName
			ErrorAction   = $STP
			WarningAction = $SC
			Confirm       = $false
			Key           = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\Lync 2010 Attendant Audio QoS - attendantconsole.exe'
			ValueName     = $Version, $AppName, $Protocol, $LocPort, $LocIP, $LocIPLen, $RemPort, $RemIP, $RemIPLen, $DscpVal, $ThrotRate
			Type          = $STRG
			Value         = $OneZero, $AttendantConsole, $WC, $AudioPorts, $WC, $WC, $WC, $WC, $WC, $AudioMark, $MinusOne
		}

		$null = (Set-GPRegistryValue @paramSetGPRegistryValue)

		Write-Verbose -Message ('Set Lync 2010 Attendant Audio QoS - attendantconsole.exe in {0}' -f $PolicyName)
	}
	catch
	{
		Write-Warning -Message ('Unable to set Lync 2010 Attendant Audio QoS - attendantconsole.exe in {0}' -f $PolicyName)
	}

	#endregion attendantconsole_exe

	#region lync_exe

	try
	{
		Write-Verbose -Message ('Try to set Lync 2013 Audio QoS - lync.exe in {0}' -f $PolicyName)

		# Cleanup
		$paramSetGPRegistryValue = $null

		# Splat reusable parameters
		$paramSetGPRegistryValue = @{
			Name          = $PolicyName
			ErrorAction   = $STP
			WarningAction = $SC
			Confirm       = $false
			Key           = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\Lync 2013 Audio QoS - lync.exe'
			ValueName     = $Version, $AppName, $Protocol, $LocPort, $LocIP, $LocIPLen, $RemPort, $RemIP, $RemIPLen, $DscpVal, $ThrotRate
			Type          = $STRG
			Value         = $OneZero, $Lync, $WC, $AudioPorts, $WC, $WC, $WC, $WC, $WC, $AudioMark, $MinusOne
		}

		$null = (Set-GPRegistryValue @paramSetGPRegistryValue)

		Write-Verbose -Message ('Set Lync 2013 Audio QoS - lync.exe in {0}' -f $PolicyName)
	}
	catch
	{
		Write-Warning -Message ('Unable to set Lync 2013 Audio QoS - lync.exe in {0}' -f $PolicyName)
	}

	try
	{
		Write-Verbose -Message ('Try to set Lync 2013 Video QoS - lync.exe in {0}' -f $PolicyName)

		# Cleanup
		$paramSetGPRegistryValue = $null

		# Splat reusable parameters
		$paramSetGPRegistryValue = @{
			Name          = $PolicyName
			ErrorAction   = $STP
			WarningAction = $SC
			Confirm       = $false
			Key           = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\Lync 2013 Video QoS - lync.exe'
			ValueName     = $Version, $AppName, $Protocol, $LocPort, $LocIP, $LocIPLen, $RemPort, $RemIP, $RemIPLen, $DscpVal, $ThrotRate
			Type          = $STRG
			Value         = $OneZero, $Lync, $WC, $VideoPorts, $WC, $WC, $WC, $WC, $WC, $VideoMark, $MinusOne
		}

		$null = (Set-GPRegistryValue @paramSetGPRegistryValue)

		Write-Verbose -Message ('Set Lync 2013 Video QoS - lync.exe in {0}' -f $PolicyName)
	}
	catch
	{
		Write-Warning -Message ('Unable to set Lync 2013 Video QoS - lync.exe in {0}' -f $PolicyName)
	}

	try
	{
		Write-Verbose -Message ('Try to set Lync 2013 Application Sharing QoS - lync.exe in {0}' -f $PolicyName)

		# Cleanup
		$paramSetGPRegistryValue = $null

		# Splat reusable parameters
		$paramSetGPRegistryValue = @{
			Name          = $PolicyName
			ErrorAction   = $STP
			WarningAction = $SC
			Confirm       = $false
			Key           = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\Lync 2013 Application Sharing QoS - lync.exe'
			ValueName     = $Version, $AppName, $Protocol, $LocPort, $LocIP, $LocIPLen, $RemPort, $RemIP, $RemIPLen, $DscpVal, $ThrotRate
			Type          = $STRG
			Value         = $OneZero, $Lync, $WC, $AppSharePorts, $WC, $WC, $WC, $WC, $WC, $AppShareMark, $MinusOne
		}

		$null = (Set-GPRegistryValue @paramSetGPRegistryValue)

		Write-Verbose -Message ('Set Lync 2013 Application Sharing QoS - lync.exe in {0}' -f $PolicyName)
	}
	catch
	{
		Write-Warning -Message ('Unable to set Lync 2013 Application Sharing QoS - lync.exe in {0}' -f $PolicyName)
	}

	try
	{
		Write-Verbose -Message ('Try to set Lync 2013 File Transfer QoS - lync.exe in {0}' -f $PolicyName)

		# Cleanup
		$paramSetGPRegistryValue = $null

		# Splat reusable parameters
		$paramSetGPRegistryValue = @{
			Name          = $PolicyName
			ErrorAction   = $STP
			WarningAction = $SC
			Confirm       = $false
			Key           = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\Lync 2013 File Transfer QoS - lync.exe'
			ValueName     = $Version, $AppName, $Protocol, $LocPort, $LocIP, $LocIPLen, $RemPort, $RemIP, $RemIPLen, $DscpVal, $ThrotRate
			Type          = $STRG
			Value         = $OneZero, $Lync, $WC, $FileTransferPorts, $WC, $WC, $WC, $WC, $WC, $FileTransferMark, $MinusOne
		}

		$null = (Set-GPRegistryValue @paramSetGPRegistryValue)

		Write-Verbose -Message ('Set Lync 2013 File Transfer QoS - lync.exe in {0}' -f $PolicyName)
	}
	catch
	{
		Write-Warning -Message ('Unable to set Lync 2013 File Transfer QoS - lync.exe in {0}' -f $PolicyName)
	}

	try
	{
		Write-Verbose -Message ('Try to set Lync 2013 SIP - lync.exe in {0}' -f $PolicyName)

		# Cleanup
		$paramSetGPRegistryValue = $null

		# Splat reusable parameters
		$paramSetGPRegistryValue = @{
			Name          = $PolicyName
			ErrorAction   = $STP
			WarningAction = $SC
			Confirm       = $false
			Key           = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\Lync 2013 SIP - lync.exe'
			ValueName     = $Version, $AppName, $Protocol, $LocPort, $LocIP, $LocIPLen, $RemPort, $RemIP, $RemIPLen, $DscpVal, $ThrotRate
			Type          = $STRG
			Value         = $OneZero, $Lync, $WC, $LyncSipPorts, $WC, $WC, $WC, $WC, $WC, $AppShareMark, $MinusOne
		}

		$null = (Set-GPRegistryValue @paramSetGPRegistryValue)

		Write-Verbose -Message ('Set Lync 2013 SIP - lync.exe in {0}' -f $PolicyName)
	}
	catch
	{
		Write-Warning -Message ('Unable to set Lync 2013 SIP - lync.exe in {0}' -f $PolicyName)
	}

	#endregion lync_exe

	#region lyncmx_exe

	try
	{
		Write-Verbose -Message ('Try to set Lync Windows Store App Audio QoS - lyncmx.exe in {0}' -f $PolicyName)

		# Cleanup
		$paramSetGPRegistryValue = $null

		# Splat reusable parameters
		$paramSetGPRegistryValue = @{
			Name          = $PolicyName
			ErrorAction   = $STP
			WarningAction = $SC
			Confirm       = $false
			Key           = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\Lync Windows Store App Audio QoS - lyncmx.exe'
			ValueName     = $Version, $AppName, $Protocol, $LocPort, $LocIP, $LocIPLen, $RemPort, $RemIP, $RemIPLen, $DscpVal, $ThrotRate
			Type          = $STRG
			Value         = $OneZero, $LyncStore, $WC, $AudioPorts, $WC, $WC, $WC, $WC, $WC, $AudioMark, $MinusOne
		}

		$null = (Set-GPRegistryValue @paramSetGPRegistryValue)

		Write-Verbose -Message ('Set Lync Windows Store App Audio QoS - lyncmx.exe in {0}' -f $PolicyName)
	}
	catch
	{
		Write-Warning -Message ('Unable to set Lync Windows Store App Audio QoS - lyncmx.exe in {0}' -f $PolicyName)
	}

	try
	{
		Write-Verbose -Message ('Try to set Lync Windows Store App Video QoS - lyncmx.exe in {0}' -f $PolicyName)

		# Cleanup
		$paramSetGPRegistryValue = $null

		# Splat reusable parameters
		$paramSetGPRegistryValue = @{
			Name          = $PolicyName
			ErrorAction   = $STP
			WarningAction = $SC
			Confirm       = $false
			Key           = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\Lync Windows Store App Video QoS - lyncmx.exe'
			ValueName     = $Version, $AppName, $Protocol, $LocPort, $LocIP, $LocIPLen, $RemPort, $RemIP, $RemIPLen, $DscpVal, $ThrotRate
			Type          = $STRG
			Value         = $OneZero, $LyncStore, $WC, $VideoPorts, $WC, $WC, $WC, $WC, $WC, $VideoMark, $MinusOne
		}

		$null = (Set-GPRegistryValue @paramSetGPRegistryValue)

		Write-Verbose -Message ('Set Lync Windows Store App Video QoS - lyncmx.exe in {0}' -f $PolicyName)
	}
	catch
	{
		Write-Warning -Message ('Unable to set Lync Windows Store App Video QoS - lyncmx.exe in {0}' -f $PolicyName)
	}

	#endregion lyncmx_exe

	#region VdiSetup

	try
	{
		Write-Verbose -Message ('Try to set VDI Audio QoS in {0}' -f $PolicyName)

		# Cleanup
		$paramSetGPRegistryValue = $null

		# Splat reusable parameters
		$paramSetGPRegistryValue = @{
			Name          = $PolicyName
			ErrorAction   = $STP
			WarningAction = $SC
			Confirm       = $false
			Key           = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\VDI Audio QoS'
			ValueName     = $Version, $AppName, $Protocol, $LocPort, $LocIP, $LocIPLen, $RemPort, $RemIP, $RemIPLen, $DscpVal, $ThrotRate
			Type          = $STRG
			Value         = $OneZero, $mstsc, $WC, $AudioPorts, $WC, $WC, $WC, $WC, $WC, $AudioMark, $MinusOne
		}

		$null = (Set-GPRegistryValue @paramSetGPRegistryValue)

		Write-Verbose -Message ('Set VDI Audio QoS in {0}' -f $PolicyName)
	}
	catch
	{
		Write-Warning -Message ('Unable to set VDI Audio QoS in {0}' -f $PolicyName)
	}

	try
	{
		Write-Verbose -Message ('Try to set VDI Video QoS in {0}' -f $PolicyName)

		# Cleanup
		$paramSetGPRegistryValue = $null

		# Splat reusable parameters
		$paramSetGPRegistryValue = @{
			Name          = $PolicyName
			ErrorAction   = $STP
			WarningAction = $SC
			Confirm       = $false
			Key           = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\VDI Video QoS'
			ValueName     = $Version, $AppName, $Protocol, $LocPort, $LocIP, $LocIPLen, $RemPort, $RemIP, $RemIPLen, $DscpVal, $ThrotRate
			Type          = $STRG
			Value         = $OneZero, $mstsc, $WC, $VideoPorts, $WC, $WC, $WC, $WC, $WC, $VideoMark, $MinusOne
		}

		$null = (Set-GPRegistryValue @paramSetGPRegistryValue)

		Write-Verbose -Message ('Set VDI Video QoS in {0}' -f $PolicyName)
	}
	catch
	{
		Write-Warning -Message ('Unable to set VDI Video QoS in {0}' -f $PolicyName)
	}

	try
	{
		Write-Verbose -Message ('Try to set VDI Application Sharing QoS in {0}' -f $PolicyName)

		# Cleanup
		$paramSetGPRegistryValue = $null

		# Splat reusable parameters
		$paramSetGPRegistryValue = @{
			Name          = $PolicyName
			ErrorAction   = $STP
			WarningAction = $SC
			Confirm       = $false
			Key           = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\VDI Application Sharing QoS'
			ValueName     = $Version, $AppName, $Protocol, $LocPort, $LocIP, $LocIPLen, $RemPort, $RemIP, $RemIPLen, $DscpVal, $ThrotRate
			Type          = $STRG
			Value         = $OneZero, $mstsc, $WC, $AppSharePorts, $WC, $WC, $WC, $WC, $WC, $AppShareMark, $MinusOne
		}

		$null = (Set-GPRegistryValue @paramSetGPRegistryValue)

		Write-Verbose -Message ('Set VDI Application Sharing QoS in {0}' -f $PolicyName)
	}
	catch
	{
		Write-Warning -Message ('Unable to set VDI Application Sharing QoS in {0}' -f $PolicyName)
	}

	#endregion VdiSetup

	#region VdiHdxSetup

	try
	{
		Write-Verbose -Message ('Try to set VDI Audio QoS (Citrix HDX RealTime Optimization Pack 2.0) in {0}' -f $PolicyName)

		# Cleanup
		$paramSetGPRegistryValue = $null

		# Splat reusable parameters
		$paramSetGPRegistryValue = @{
			Name          = $PolicyName
			ErrorAction   = $STP
			WarningAction = $SC
			Confirm       = $false
			Key           = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\VDI Audio QoS (Citrix HDX RealTime Optimization Pack 2.0)'
			ValueName     = $Version, $AppName, $Protocol, $LocPort, $LocIP, $LocIPLen, $RemPort, $RemIP, $RemIPLen, $DscpVal, $ThrotRate
			Type          = $STRG
			Value         = $OneZero, $MediaEngineService, $WC, $AudioPorts, $WC, $WC, $WC, $WC, $WC, $AudioMark, $MinusOne
		}

		$null = (Set-GPRegistryValue @paramSetGPRegistryValue)

		Write-Verbose -Message ('Set VDI Audio QoS (Citrix HDX RealTime Optimization Pack 2.0) in {0}' -f $PolicyName)
	}
	catch
	{
		Write-Warning -Message ('Unable to set VDI Audio QoS (Citrix HDX RealTime Optimization Pack 2.0) in {0}' -f $PolicyName)
	}

	try
	{
		Write-Verbose -Message ('Try to set VDI Video QoS (Citrix HDX RealTime Optimization Pack 2.0) in {0}' -f $PolicyName)

		# Cleanup
		$paramSetGPRegistryValue = $null

		# Splat reusable parameters
		$paramSetGPRegistryValue = @{
			Name          = $PolicyName
			ErrorAction   = $STP
			WarningAction = $SC
			Confirm       = $false
			Key           = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\VDI Video QoS (Citrix HDX RealTime Optimization Pack 2.0)'
			ValueName     = $Version, $AppName, $Protocol, $LocPort, $LocIP, $LocIPLen, $RemPort, $RemIP, $RemIPLen, $DscpVal, $ThrotRate
			Type          = $STRG
			Value         = $OneZero, $MediaEngineService, $WC, $VideoPorts, $WC, $WC, $WC, $WC, $WC, $VideoMark, $MinusOne
		}

		$null = (Set-GPRegistryValue @paramSetGPRegistryValue)

		Write-Verbose -Message ('Set VDI Video QoS (Citrix HDX RealTime Optimization Pack 2.0) in {0}' -f $PolicyName)
	}
	catch
	{
		Write-Warning -Message ('Unable to set VDI Video QoS (Citrix HDX RealTime Optimization Pack 2.0) in {0}' -f $PolicyName)
	}

	try
	{
		Write-Verbose -Message ('Try to set VDI Application Sharing QoS (Citrix HDX RealTime Optimization Pack 2.0) in {0}' -f $PolicyName)

		# Cleanup
		$paramSetGPRegistryValue = $null

		# Splat reusable parameters
		$paramSetGPRegistryValue = @{
			Name          = $PolicyName
			ErrorAction   = $STP
			WarningAction = $SC
			Confirm       = $false
			Key           = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\VDI Application Sharing QoS (Citrix HDX RealTime Optimization Pack 2.0)'
			ValueName     = $Version, $AppName, $Protocol, $LocPort, $LocIP, $LocIPLen, $RemPort, $RemIP, $RemIPLen, $DscpVal, $ThrotRate
			Type          = $STRG
			Value         = $OneZero, $MediaEngineService, $WC, $AppSharePorts, $WC, $WC, $WC, $WC, $WC, $AppShareMark, $MinusOne
		}

		$null = (Set-GPRegistryValue @paramSetGPRegistryValue)

		Write-Verbose -Message ('Set VDI Application Sharing QoS (Citrix HDX RealTime Optimization Pack 2.0) in {0}' -f $PolicyName)
	}
	catch
	{
		Write-Warning -Message ('Unable to set VDI Application Sharing QoS (Citrix HDX RealTime Optimization Pack 2.0) in {0}' -f $PolicyName)
	}

	#endregion VdiHdxSetup
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
