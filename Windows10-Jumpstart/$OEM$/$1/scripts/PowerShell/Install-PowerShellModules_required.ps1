﻿#requires -Version 2.0 -RunAsAdministrator

<#
      .SYNOPSIS
      Install some madatory PowerShell Modules

      .DESCRIPTION
      Install some madatory PowerShell Modules from the PowerShell Gallery

      .NOTES
      Version 1.0.1

      .LINK
      http://beyond-datacenter.com
#>
[CmdletBinding(ConfirmImpact = 'Low')]
param ()

begin
{
	Write-Output -InputObject 'Install some madatory PowerShell Modules'

	#region Defaults
	$SCT = 'SilentlyContinue'
	#endregion Defaults

	$null = (Set-MpPreference -EnableControlledFolderAccess Disabled -Force -ErrorAction $SCT)

	# Every System should have these Modules
	$PowerShellModuleList = @(
		'PoShKeePass'
		'Pester'
		'PackageManagement'
		'PowerShellGet'
		'PSScriptAnalyzer'
		'posh-git'
		'PSWindowsUpdate'
		'BurntToast'
	)
}

process
{
	# Force the installation of the Modules listed above
	$null = ($PowerShellModuleList | ForEach-Object -Process {
			# Stop Search - Gain performance
			$null = (Get-Service -Name 'WSearch' -ErrorAction $SCT | Where-Object { $_.Status -eq "Running" } | Stop-Service -Force -Confirm:$false -ErrorAction $SCT)

			(Install-Module -Name $_ -Scope AllUsers -Repository PSGallery -Force -Confirm:$false -AllowClobber -SkipPublisherCheck -ErrorAction $SCT)
		})

	# Refresh
	$null = (Get-Module -ListAvailable -Refresh -ErrorAction $SCT)
}

end
{
	$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction $SCT)
}

#region LICENSE
<#
      BSD 3-Clause License

      Copyright (c) 2020, Beyond Datacenter
      All rights reserved.

      Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
      1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
      2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
      3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

      THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>
#endregion LICENSE

#region DISCLAIMER
<#
      DISCLAIMER:
      - Use at your own risk, etc.
      - This is open-source software, if you find an issue try to fix it yourself. There is no support and/or warranty in any kind
      - This is a third-party Software
      - The developer of this Software is NOT sponsored by or affiliated with Microsoft Corp (MSFT) or any of its subsidiaries in any way
      - The Software is not supported by Microsoft Corp (MSFT)
      - By using the Software, you agree to the License, Terms, and any Conditions declared and described above
      - If you disagree with any of the Terms, and any Conditions declared: Just delete it and build your own solution
#>
#endregion DISCLAIMER