#Requires -RunAsAdministrator

<#
		.SYNOPSIS
		Set QoS Settings for all Skype for Business Server Roles

		.DESCRIPTION
		Set QoS Settings for all Skype for Business Server Roles, except Edge. This is in a dedicated script

		.EXAMPLE
		PS C:\> .\Set-SkypeQoS.ps1

		.NOTES
		Copyright (c) 2017 Joerg Hochwald (http://jhochwald.com). All rights reserved.

		Redistribution and use in source and binary forms, with or without modification,
		are permitted provided that the following conditions are met:

		1.	Redistributions of source code must retain the above copyright notice,
		this list of conditions and the following disclaimer.

		2.	Redistributions in binary form must reproduce the above copyright notice, this list of
		conditions and the following disclaimer in the documentation and/or other materials
		provided with the distribution.

		3.	Neither the name of the copyright holder nor the names of its contributors may be used
		to endorse or promote products derived from this software without specific prior
		written permission.

		THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
		IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
		AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
		CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
		CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
		SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
		THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
		OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
		POSSIBILITY OF SUCH DAMAGE.

		By using the Software, you agree to the License, Terms and Conditions above!
#>
[CmdletBinding()]
param ()

#region Variables
$SC = 'SilentlyContinue'
$STP = 'Stop'
#endregion Variables

#region LoadSkypeModule
try
{
	$paramImportModule = @{
		Name          = 'SkypeforBusiness'
		ErrorAction   = $STP
		WarningAction = $SC
	}
	$null = (Import-Module @paramImportModule)
}
catch
{
	Write-Error -Message 'Skype for Business PowerShell Module not found...' -ErrorAction $STP
}
#endregion LoadSkypeModule

#region EnableMediaQoS
try
{
	$paramGetCsMediaConfiguration = @{
		ErrorAction   = $STP
		WarningAction = $SC
	}
	$paramSetCsMediaConfiguration = @{
		EnableQoS     = $True
		ErrorAction   = $STP
		WarningAction = $SC
	}
	$null = (Get-CsMediaConfiguration @paramGetCsMediaConfiguration | Set-CsMediaConfiguration @paramSetCsMediaConfiguration)

	Write-Verbose -Message 'Enabled Media Configuration for Quality of Service'
}
catch
{
	Write-Warning -Message 'To enable Media Configuration for Quality of Service'
}
#endregion EnableMediaQoS

#region SetTheMediationServerPortRanges
try
{
	$paramGetCsService = @{
		MediationServer = $True
		ErrorAction     = $STP
		WarningAction   = $SC
	}
	Get-CsService @paramGetCsService | ForEach-Object -Process {
		try
		{
			$paramSetCsMediationServer = @{
				Identity       = $_.Identity
				AudioPortStart = 49152
				AudioPortCount = 8348
				ErrorAction    = $STP
				WarningAction  = $SC
			}
			$null = (Set-CsMediationServer @paramSetCsMediationServer)

			#
			Write-Verbose -Message ('Set {0} Audio Port Range for Quality of Service' -f $_.Identity)
		}
		catch
		{
			Write-Warning -Message ('To set {0} for for Quality of Service' -f $_.Identity)
		}
	}
	Write-Verbose -Message 'Configuring Mediation Servers for Quality of Service'
}
catch
{
	Write-Warning -Message 'To set Mediation servers for Quality of Services'
}
#endregion SetTheMediationServerPortRanges

#region SetTheApplicationServersPortRanges
try
{
	$paramGetCsService = @{
		ApplicationServer = $True
		ErrorAction       = $STP
		WarningAction     = $SC
	}
	Get-CsService @paramGetCsService | ForEach-Object -Process {
		try
		{
			$paramSetCsApplicationServer = @{
				Identity            = $_.Identity
				AudioPortStart      = 49152
				AudioPortCount      = 8348
				AppSharingPortStart = 40803
				AppSharingPortCount = 8348
				VideoPortStart      = 57501
				VideoPortCount      = 8034
				ErrorAction         = $STP
				WarningAction       = $SC
			}
			$null = (Set-CsApplicationServer @paramSetCsApplicationServer)

			#
			Write-Verbose -Message ('Set {0} Port Ranges for Quality of Service' -f $_.Identity)
		}
		catch
		{
			Write-Warning -Message ('To set {0} for for Quality of Service' -f $_.Identity)
		}
	}
	Write-Verbose -Message 'Configuring Application Servers for Quality of Service'
}
catch
{
	Write-Warning -Message 'To set Application servers for Quality of Services'
}
#endregion SetTheApplicationServersPortRanges

#region SetConferencingServersPortRanges
try
{
	$paramGetCsService = @{
		ConferencingServer = $True
		ErrorAction        = $STP
		WarningAction      = $SC
	}
	Get-CsService @paramGetCsService | ForEach-Object -Process {
		try
		{
			$paramSetCsConferenceServer = @{
				Identity            = $_.Identity
				AudioPortStart      = 49152
				AudioPortCount      = 8348
				AppSharingPortStart = 40803
				AppSharingPortCount = 8348
				VideoPortStart      = 57501
				VideoPortCount      = 8034
				ErrorAction         = $STP
				WarningAction       = $SC
			}
			$null = (Set-CsConferenceServer @paramSetCsConferenceServer)

			#
			Write-Verbose -Message ('Set {0} Port Ranges for Quality of Service' -f $_.Identity)
		}
		catch
		{
			Write-Warning -Message ('To set {0} for for Quality of Service' -f $_.Identity)
		}
	}
	Write-Verbose -Message 'Configuring Conferencing Servers for Quality of Service'
}
catch
{
	Write-Warning -Message 'To set Conferencing servers for Quality of Services'
}
#endregion SetConferencingServersPortRanges

#region SetClientPortPanges
try
{
	$paramGetCsConferencingConfiguration = @{
		ErrorAction   = $STP
		WarningAction = $SC
	}
	Get-CsConferencingConfiguration @paramGetCsConferencingConfiguration | ForEach-Object -Process {
		try
		{
			$paramSetCsConferencingConfiguration = @{
				Identity                    = $_.Identity
				ClientMediaPortRangeEnabled = $True
				ClientAudioPort             = 50020
				ClientAudioPortRange        = 20
				ClientVideoPort             = 58000
				ClientVideoPortRange        = 20
				ClientAppSharingPort        = 42000
				ClientAppSharingPortRange   = 20
				ClientFileTransferPort      = 42020
				ClientFileTransferPortRange = 20
				ErrorAction                 = $STP
				WarningAction               = $SC
			}
			$null = (Set-CsConferencingConfiguration @paramSetCsConferencingConfiguration)

			#
			Write-Verbose -Message ('Set {0} Port Ranges for Quality of Service' -f $_.Identity)
		}
		catch
		{
			Write-Warning -Message ('To set {0} for for Quality of Service' -f $_.Identity)
		}
	}
	Write-Verbose -Message 'Configuring Client Applications for Quality of Service'
}
catch
{
	Write-Warning -Message 'To set Client Applications for Quality of Services'
}
#endregion SetClientPortPanges
