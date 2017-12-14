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

# SIG # Begin signature block
# MIIYpQYJKoZIhvcNAQcCoIIYljCCGJICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU3MNAAWP79BzoykbvCcAfT6tx
# vS2gghPNMIID7jCCA1egAwIBAgIQfpPr+3zGTlnqS5p31Ab8OzANBgkqhkiG9w0B
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
# ARUwIwYJKoZIhvcNAQkEMRYEFFqwlIf1Nruwgj/OAi1fB3FMn9c/MA0GCSqGSIb3
# DQEBAQUABIIBAKQNFPTk8gJbdUXQ/f7pSUJGRtPOS/zEY2waOaK6rzzgmmJHo8mx
# X8mIaCVCcicD4L5BbqGYU8/5qemXj4ffb6yfDA0n5SrDCay8VNaTVymvVVbByL3h
# HxcAv0ZB/ECMCryGr0yFHF/ZHxstuUyPvxuE8cku3Qqn5iMhwxRUuHYpUgG/sW4c
# PGDb6PnEtnE8LNa8OEWd6ouvhhuL62e1zxMTcuOmgGR6zHw5OqQu3wjjTMISmr8d
# OU5b1rs5Nwy2Y8WhT6ZNcBfHZSAW49At/atAH77u45//4Foa2uuo605KyCXjr6Cc
# 5+fPyKn3cHkhata/DClkC4VAB2uoPAhHOO+hggILMIICBwYJKoZIhvcNAQkGMYIB
# +DCCAfQCAQEwcjBeMQswCQYDVQQGEwJVUzEdMBsGA1UEChMUU3ltYW50ZWMgQ29y
# cG9yYXRpb24xMDAuBgNVBAMTJ1N5bWFudGVjIFRpbWUgU3RhbXBpbmcgU2Vydmlj
# ZXMgQ0EgLSBHMgIQDs/0OMj+vzVuBNhqmBsaUDAJBgUrDgMCGgUAoF0wGAYJKoZI
# hvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTcxMjE0MDk0NTMw
# WjAjBgkqhkiG9w0BCQQxFgQUgS8Wj+YIwDkoLZPrtZLJJ7CeGHYwDQYJKoZIhvcN
# AQEBBQAEggEABF6ZOZR1ngv9odcmFFU0Fh1WYs1fjX+AVWfeC4NAhS3k5Vlg5WXZ
# Ounddk/S/a6+VHq9d/PqGxPpXJnGHCb3VcqZa4B0zX+rRFa4JXsztCMaann1K+0L
# QpnIX+YZW2Q3oF9nOq0VZ+2IdC3PfTr/nU0Z8SRW4qMs4pjJNco3zUG0s9yg/ZXK
# eOb0jW6ZhhJJoFqXSe4n/yQooPtvBOr2iOV23wdedSLcjmr6gkQbk3Uj6nHYpxC9
# hNss0pnV6Ks0Yza+Y5AZoxvLAD1HuYL6CLj32Q+2gS4PEzZRT+WxbrDm4hxSbeGl
# UNLVDrvq5EWZ4FJ7eXOgcpwFm/8tIdsjxg==
# SIG # End signature block
