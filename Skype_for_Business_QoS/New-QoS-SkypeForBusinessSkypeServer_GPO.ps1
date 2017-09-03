#Requires -RunAsAdministrator

<#
		.SYNOPSIS
		DSCP markings for Lync/Skype for Business client traffic.

		.DESCRIPTION
		Creates a new GPO for DSCP markings for Lync/Skype for Business client traffic.

		.EXAMPLE
		PS C:\> .\New-QoS-SkypeForBusinessSkypeServer_GPO.ps1

		# Creates a new GPO for DSCP markings for Lync/Skype for Business client traffic.

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
$GPOName = 'QoS - Skype for Business Client'
$SC = 'SilentlyContinue'
$STP = 'Stop'
#endregion Variables

#region LoadActiveDirectoryModule
try
{
	$paramImportModule = @{
		Name          = 'ActiveDirectory'
		ErrorAction   = $STP
		WarningAction = $SC
	}
	$null = (Import-Module @paramImportModule)
}
catch
{
	Write-Error -Message 'ActiveDirectory PowerShell Module not found...' -ErrorAction $STP
}
#endregion LoadActiveDirectoryModule

#region LoadGroupPolicyModule
try
{
	$paramImportModule = @{
		Name          = 'GroupPolicy'
		ErrorAction   = $STP
		WarningAction = $SC
	}
	$null = (Import-Module @paramImportModule)
}
catch
{
	Write-Error -Message 'GroupPolicy PowerShell Module not found...' -ErrorAction $STP
}
#endregion LoadGroupPolicyModule

#region CreateThePolicy
try
{
	$paramNewGPO = @{
		Name          = $GPOName
		Comment       = 'DSCP markings for Lync/Skype for Business client traffic.'
		ErrorAction   = $STP
		WarningAction = $SC
	}
	$null = (New-GPO @paramNewGPO)

	$paramGetGPO = @{
		Name          = $GPOName
		ErrorAction   = $STP
		WarningAction = $SC
	}
	$null = ((Get-GPO @paramGetGPO).GpoStatus = 'UserSettingsDisabled')
}
catch
{
	Write-Error "Unable to create $GPOName" -ErrorAction Stop
}
#endregion CreateThePolicy

#region DoNotUseNLA
try
{
	$paramSetGPPrefRegistryValue = @{
		Name          = $GPOName
		Context       = 'Computer'
		Key           = 'HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\QoS'
		ValueName     = 'Do not use NLA'
		Value         = '1'
		Type          = 'String'
		Action        = 'Update'
		ErrorAction   = $STP
		WarningAction = $SC
	}
	$null = (Set-GPPrefRegistryValue @paramSetGPPrefRegistryValue)
}
catch
{
	Write-Warning 'Unable to create Do Not Use NLA'
}
#endregion DoNotUseNLA

#region SIPSignallingQoS
try
{
	$paramSetGPRegistryValue = @{
		Name          = $GPOName
		Key           = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\Skype for Business Client SIP Signaling QoS'
		ValueName     = 'Version', 'Application Name', 'Protocol', 'Local Port', 'Local IP', 'Local IP Prefix Length', 'Remote Port', 'Remote IP', 'Remote IP Prefix Length', 'DSCP Value', 'Throttle Rate'
		Type          = 'String'
		Value         = '1.0', '*', '*', '5060:5069', '*', '*', '*', '*', '*', '40', '-1'
		ErrorAction   = $STP
		WarningAction = $SC
	}
	$null = (Set-GPRegistryValue @paramSetGPRegistryValue)
}
catch
{
	Write-Warning 'Unable to create SIP Signaling QoS'
}
#endregion SIPSignallingQoS

#region ClientAudioQoS
try
{
	$paramSetGPRegistryValue = @{
		Name          = $GPOName
		Key           = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\Skype for Business Client Audio QoS'
		ValueName     = 'Version', 'Application Name', 'Protocol', 'Local Port', 'Local IP', 'Local IP Prefix Length', 'Remote Port', 'Remote IP', 'Remote IP Prefix Length', 'DSCP Value', 'Throttle Rate'
		Type          = 'String'
		Value         = '1.0', '*', '*', '50020:50039', '*', '*', '*', '*', '*', '46', '-1'
		ErrorAction   = $STP
		WarningAction = $SC
	}
	$null = (Set-GPRegistryValue @paramSetGPRegistryValue)
}
catch
{
	Write-Warning 'Unable to create Client Audio QoS'
}
#endregion ClientAudioQoS

#region ClientVideoQoS
try
{
	$paramSetGPRegistryValue = @{
		Name          = $GPOName
		Key           = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\Skype for Business Client Video QoS'
		ValueName     = 'Version', 'Application Name', 'Protocol', 'Local Port', 'Local IP', 'Local IP Prefix Length', 'Remote Port', 'Remote IP', 'Remote IP Prefix Length', 'DSCP Value', 'Throttle Rate'
		Type          = 'String'
		Value         = '1.0', '*', '*', '58000:58019', '*', '*', '*', '*', '*', '34', '-1'
		ErrorAction   = $STP
		WarningAction = $SC
	}
	$null = (Set-GPRegistryValue @paramSetGPRegistryValue)
}
catch
{
	Write-Warning 'Unable to create Client Video QoS'
}
#endregion ClientVideoQoS

#region ClientApplicationSharingQoS
try
{
	$paramSetGPRegistryValue = @{
		Name          = $GPOName
		Key           = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\Skype for Business Client Application Sharing QoS'
		ValueName     = 'Version', 'Application Name', 'Protocol', 'Local Port', 'Local IP', 'Local IP Prefix Length', 'Remote Port', 'Remote IP', 'Remote IP Prefix Length', 'DSCP Value', 'Throttle Rate'
		Type          = 'String'
		Value         = '1.0', '*', '*', '42000:42019', '*', '*', '*', '*', '*', '24', '-1'
		ErrorAction   = $STP
		WarningAction = $SC
	}
	$null = (Set-GPRegistryValue @paramSetGPRegistryValue)
}
catch
{
	Write-Warning 'Unable to create Client Application Sharing QoS'
}
#endregion ClientApplicationSharingQoS

#region ClientMediaPortQoS
try
{
	$paramSetGPRegistryValue = @{
		Name          = $GPOName
		Key           = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\Skype for Business Client Media Port QoS'
		ValueName     = 'Version', 'Application Name', 'Protocol', 'Local Port', 'Local IP', 'Local IP Prefix Length', 'Remote Port', 'Remote IP', 'Remote IP Prefix Length', 'DSCP Value', 'Throttle Rate'
		Type          = 'String'
		Value         = '1.0', '*', '*', '5350:5389', '*', '*', '*', '*', '*', '34', '-1'
		ErrorAction   = $STP
		WarningAction = $SC
	}
	$null = (Set-GPRegistryValue @paramSetGPRegistryValue)
}
catch
{
	Write-Warning 'Unable to create Client Media Port QoS'
}
#endregion ClientMediaPortQoS
