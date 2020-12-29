#Requires -RunAsAdministrator

<#
		.SYNOPSIS
		Get the latest QoS Group policies
	
		.DESCRIPTION
		Get the latest QoS Group policies and delete all existing ones before do so.
	
		.EXAMPLE
		PS > .\Get-CleanSkypeQoS.ps1

		Get the latest QoS Group policies and delete all existing ones before do so.

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
$Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\QoS'
#endregion Variables

#region CleanUp
$paramTestPath = @{
	Path        = $Path
	ErrorAction = $SC
}
if (Test-Path @paramTestPath)
{
	try
	{
		Write-Verbose -Message 'START: Cleanup the Policies'
		
		$paramRemoveItem = @{
			Path        = $Path
			Recurse     = $true
			Force       = $true
			Confirm     = $false
			ErrorAction = $STP
		}
		$null = (Remove-Item @paramRemoveItem)
		
		Write-Verbose -Message 'DONE: Cleanup the Policies'
	}
	catch
	{
		Write-Warning -Message 'Unable to cleanup the Policies...'
	}
}
#endregion CleanUp

#region GetLatest
Write-Verbose -Message 'Get the latest Policies...'
$null = (& "$env:windir\system32\gpupdate.exe" /force)
#endregion GetLatest