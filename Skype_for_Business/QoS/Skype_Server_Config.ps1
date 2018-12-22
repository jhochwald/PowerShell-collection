<#
		.SYNOPSIS
		Setup the S4B server for QoS
	
		.DESCRIPTION
		Setup the Skype for Business 2015 Server for Quality of Services
	
		.PARAMETER FrontEndPool
		Skype for Business Front End Pool
	
		.PARAMETER EdgePool
		Skype for Business Edge Pool
	
		.EXAMPLE
		PS C:\> .\Skype_Server_Config.ps1
	
		.EXAMPLE
		PS C:\> .\Skype_Server_Config.ps1 -verbose
	
		.NOTES
		Check that the ports and port ranges fit your requirements!
		
		The ports and ranges we use here should fit the Skype for Business Online setup
#>
[CmdletBinding()]
param
(
	[Parameter(ValueFromPipeline,
	Position = 1)]
	[string]
	$FrontEndPool = 's4bfe.fra.hicts.net',
	[Parameter(ValueFromPipeline,
	Position = 2)]
	[string]
	$EdgePool = 's4bedge.dmz.hicts.net'
)

#Requires -RunAsAdministrator

BEGIN
{
	#region Variables

	# QoS marking for Audio
	[string]$AudioMark = '46'

	# Audio Start Port
	[string]$AudioPortStart = '50000'

	# Number of Ports to use
	[string]$AudioPortCount = '20'

	# Video Start Port
	[string]$VideoPortStart = ([int]$AudioPortStart + [int]$AudioPortCount)
	# Legacy variante of the above (without calculating)
	#[string]$VideoPortStart = '50020'

	# Number of Ports to use
	[string]$VideoPortCount = '20'

	# App Sharing Start Port
	[string]$AppSharingPortStart = ([int]$VideoPortStart + [int]$VideoPortCount)
	# Legacy variante of the above (without calculating)
	#[string]$AppSharingPortStart = '50040'

	# Number of Ports to use
	[string]$AppSharingPortCount = '20'

	# Start File Transfer Port
	[string]$ClientFileTransferPort = '5350'

	# Number of Ports to use
	[string]$ClientFileTransferPortRange = '20'

	# Start Legacy Media Port
	[string]$ClientMediaPort = '5370'

	# Number of Ports to use (Legacy)
	[string]$ClientMediaPortRange = '20'

	# Number of Ports to use (Legacy)
	[string]$MediaCommunicationPortCount = '10000'
	
	<#
	
			# Legacy variables
	
			# Skype for Business Front End Pool
			[string]$FrontEndPool = 's4bfe.fra.hicts.net'

			# Skype for Business Edge Pool
			[string]$EdgePool = 's4bedge.dmz.hicts.net'
	#>
	
	#endregion Variables

	#region Defaults

	# Define some Defaults
	[string]$SC = 'SilentlyContinue'
	[string]$STP = 'Stop'
	[string]$Global = 'global'
	[string]$Voice8021p = '0'

	#endregion Defaults

	#region CheckCmd

	# All Skype for Business Server related commands
	$AllCommands = 'Set-CsConferencingConfiguration', 'Set-CsUCPhoneConfiguration', 'Set-CsMediaConfiguration', 'Set-CsConferenceServer', 'Set-CsApplicationServer', 'Set-CsMediationServer', 'Set-CsWebServer', 'Set-CsEdgeServer'

	# Loop over the list of commands
	foreach ($TheCommand in $AllCommands)
	{
		try
		{
			Write-Verbose -Message ('Check for {0}' -f $TheCommand)

			# Cleanup
			$paramGetCommand = $null

			# Splat reusable parameters
			$paramGetCommand = @{
				Name          = $TheCommand
				ErrorAction   = $STP
				WarningAction = $SC
			}
			$null = (Get-Command @paramGetCommand)

			Write-Verbose -Message ('Found {0}' -f $TheCommand)
		}
		catch
		{
			# Whoops
			$paramWriteError = @{
				Message     = ('Unable to find {0} - Please check your Setup!' -f $TheCommand)
				ErrorAction = $STP
			}
			Write-Error @paramWriteError

			# We are done here...
			break
		}
	}

	#endregion CheckCmd
}

PROCESS
{
	#region ConferencingConfiguration

	try
	{
		Write-Verbose -Message 'Change Conferencing Configuration'

		# Cleanup
		$paramSetCsConferencingConfiguration = $null

		# Splat reusable parameters
		$paramSetCsConferencingConfiguration = @{
			Identity                    = $Global
			ClientAudioPort             = $AudioPortStart
			ClientAudioPortRange        = $AudioPortCount
			ClientVideoPort             = $VideoPortStart
			ClientVideoPortRange        = $VideoPortCount
			ClientAppSharingPort        = $AppSharingPortStart
			ClientAppSharingPortRange   = $AppSharingPortCount
			ClientFileTransferPort      = $ClientFileTransferPort
			ClientFileTransferPortRange = $ClientFileTransferPortRange
			ClientMediaPortRangeEnabled = $true
			ClientMediaPort             = $ClientMediaPort
			ClientMediaPortRange        = $ClientMediaPortRange
			ErrorAction                 = $STP
			WarningAction               = $SC
		}

		$null = (Set-CsConferencingConfiguration @paramSetCsConferencingConfiguration)

		Write-Verbose -Message 'Changed Conferencing Configuration'
	}
	catch
	{
		Write-Warning -Message 'Unable to Set Conferencing Configuration'
	}

	#endregion ConferencingConfiguration

	#region ChangeUCPhoneConfiguration

	try
	{
		Write-Verbose -Message 'Change UC Phone Configuration'

		# Cleanup
		$paramSetCsUCPhoneConfiguration = $null

		# Splat reusable parameters
		$paramSetCsUCPhoneConfiguration = @{
			Identity         = $Global
			VoiceDiffServTag = $AudioMark
			Voice8021p       = $Voice8021p
			ErrorAction      = $STP
			WarningAction    = $SC
		}

		$null = (Set-CsUCPhoneConfiguration @paramSetCsUCPhoneConfiguration)

		Write-Verbose -Message 'Changed UC Phone Configuration'
	}
	catch
	{
		Write-Warning -Message 'Unable to Set UC Phone Configuration'
	}

	#endregion ChangeUCPhoneConfiguration

	#region ChangeMediaConfiguration

	try
	{
		Write-Verbose -Message 'Change Media Configuration'

		# Cleanup
		$paramSetCsMediaConfiguration = $null

		# Splat reusable parameters
		$paramSetCsMediaConfiguration = @{
			Identity      = $Global
			EnableQoS     = $true
			ErrorAction   = $STP
			WarningAction = $SC
		}

		$null = (Set-CsMediaConfiguration @paramSetCsMediaConfiguration)

		Write-Verbose -Message 'Changed Media Configuration'
	}
	catch
	{
		Write-Warning -Message 'Unable to Set Media Configuration'
	}

	#endregion ChangeMediaConfiguration

	#region ChangeConferenceServerConfiguration

	try
	{
		Write-Verbose -Message 'Change Conference Server Configuration'

		# Cleanup
		$paramSetCsConferenceServer = $null

		# Splat reusable parameters
		$paramSetCsConferenceServer = @{
			Identity            = $FrontEndPool
			AppSharingPortStart = $AppSharingPortStart
			AppSharingPortCount = $AppSharingPortCount
			AudioPortStart      = $AudioPortStart
			AudioPortCount      = $AudioPortCount
			VideoPortStart      = $VideoPortStart
			VideoPortCount      = $VideoPortCount
			ErrorAction         = $STP
			WarningAction       = $SC
		}

		$null = (Set-CsConferenceServer @paramSetCsConferenceServer)

		Write-Verbose -Message 'Changed Conference Server Configuration'
	}
	catch
	{
		Write-Warning -Message 'Unable to Set Conference Server Configuration'
	}

	#endregion ChangeConferenceServerConfiguration

	#region ChangeApplicationServerConfiguration

	try
	{
		Write-Verbose -Message 'Change Application Server Configuration'

		# Cleanup
		$paramSetCsApplicationServer = $null

		# Splat reusable parameters
		$paramSetCsApplicationServer = @{
			Identity            = $FrontEndPool
			AppSharingPortStart = $AppSharingPortStart
			AppSharingPortCount = $AppSharingPortCount
			AudioPortStart      = $AudioPortStart
			AudioPortCount      = $AudioPortCount
			VideoPortStart      = $VideoPortStart
			VideoPortCount      = $VideoPortCount
			ErrorAction         = $STP
			WarningAction       = $SC
		}

		$null = (Set-CsApplicationServer @paramSetCsApplicationServer)

		Write-Verbose -Message 'Changed Application Server Configuration'
	}
	catch
	{
		Write-Warning -Message 'Unable to Set Application Server Configuration'
	}

	#endregion ChangeApplicationServerConfiguration

	#region ChangeMediationServerConfiguration

	try
	{
		Write-Verbose -Message 'Change Mediation Server Configuration'

		#Cleanup
		$paramSetCsMediationServer = $null


		# Splat reusable parameters
		$paramSetCsMediationServer = @{
			Identity       = $FrontEndPool
			AudioPortStart = $AudioPortStart
			AudioPortCount = $AudioPortCount
			ErrorAction    = $STP
			WarningAction  = $SC
		}

		$null = (Set-CsMediationServer @paramSetCsMediationServer)

		Write-Verbose -Message 'Changed Mediation Server Configuration'
	}
	catch
	{
		Write-Warning -Message 'Unable to Set Mediation Server Configuration'
	}

	#endregion ChangeMediationServerConfiguration

	#region ChangeWebServerConfiguration

	try
	{
		Write-Verbose -Message 'Change Web Server Configuration'

		#Cleanup
		$paramSetCsWebServer = $null

		# Splat reusable parameters
		$paramSetCsWebServer = @{
			Identity            = $FrontEndPool
			AppSharingPortStart = $AppSharingPortStart
			AppSharingPortCount = $AppSharingPortCount
			ErrorAction         = $STP
			WarningAction       = $SC
		}

		$null = (Set-CsWebServer @paramSetCsWebServer)

		Write-Verbose -Message 'Changed Web Server Configuration'
	}
	catch
	{
		Write-Warning -Message 'Unable to Set Web Server Configuration'
	}

	#endregion ChangeWebServerConfiguration

	#region ChangeEdgeServerConfiguration

	try
	{
		Write-Verbose -Message 'Change Edge Server Configuration'

		# Cleanup
		$paramSetCsEdgeServer = $null

		# Splat reusable parameters
		$paramSetCsEdgeServer = @{
			Identity                    = $EdgePool
			MediaCommunicationPortStart = $AudioPortStart
			MediaCommunicationPortCount = $MediaCommunicationPortCount
			ErrorAction                 = $STP
			WarningAction               = $SC
		}

		$null = (Set-CsEdgeServer @paramSetCsEdgeServer)

		Write-Verbose -Message 'Changed Edge Server Configuration'
	}
	catch
	{
		Write-Warning -Message 'Unable to Set Edge Server Configuration'
	}

	#endregion ChangeEdgeServerConfiguration
}

END
{
	Write-Output -InputObject 'Done with the Skype for Business QoS setup.'
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
