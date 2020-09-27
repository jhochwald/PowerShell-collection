#requires -Version 3.0 -RunAsAdministrator

<#
      .SYNOPSIS
      Apply the Defender exclusions based on recommendations by Microsoft

      .DESCRIPTION
	  Apply the Defender exclusions based on recommendations by Microsoft,
	  Some additional Controlled Folder Access Allowed Applications will be added as well

      .EXAMPLE
      PS C:\> Optimize-MicrosoftDefenderExclusions.ps1

      .NOTES
      Do not just use set-mppreference here, this might remove any existing exclusions.
      Might be the right thing to do, but with add-mppreference you append to the list (if exists).

	  Changelog:
	  1.0.3: Add ControlledFolderAccessAllowedApplications handling
	  1.0.2: First real release
	  1.0.0: Intital beta version
      Version 1.0.3

      .LINK
      http://beyond-datacenter.com

      .LINK
      https://support.microsoft.com/en-ie/help/822158/virus-scanning-recommendations-for-enterprise-computers-that-are-runni

      .LINK
      https://docs.microsoft.com/en-us/powershell/module/defender/add-mppreference

      .LINK
      https://docs.microsoft.com/en-us/powershell/module/defender/set-mppreference
#>
[CmdletBinding(ConfirmImpact = 'Medium',
	SupportsShouldProcess)]
param ()

begin {
	Write-Output -InputObject 'Apply the Defender exclusions based on recommendations by Microsoft'

	#region
	$SCT = 'SilentlyContinue'
	#endregion

	$null = (Set-MpPreference -EnableControlledFolderAccess Disabled -Force -ErrorAction $SCT)

	#region DefaultExclusions
	$ExcludePathList = @(
		"$env:windir\SoftwareDistribution\DataStore\Datastore.edb",
		"$env:windir\SoftwareDistribution\DataStore\Logs\Edb*.jrs",
		"$env:windir\SoftwareDistribution\DataStore\Logs\Edb.chk",
		"$env:windir\SoftwareDistribution\DataStore\Logs\Tmp.edb",
		"$env:windir\Security\Database\*.edb",
		"$env:windir\Security\Database\*.sdb",
		"$env:windir\Security\Database\*.log",
		"$env:windir\Security\Database\*.chk",
		"$env:windir\Security\Database\*.jrs",
		"$env:windir\Security\Database\*.xml",
		"$env:windir\Security\Database\*.csv",
		"$env:windir\Security\Database\*.cmtx",
		"$env:windir\System32\GroupPolicy\Machine\Registry.pol",
		"$env:windir\System32\GroupPolicy\Machine\Registry.tmp",
		"$env:windir\System32\GroupPolicy\User\Registry.pol",
		"$env:windir\System32\GroupPolicy\User\Registry.tmp",
		"$env:ProgramData\ntuser.pol",
		"$env:ProgramData\chocolatey\lib\sysinternals\tools\*.exe"
	)
	#endregion DefaultExclusions

	#region AdExclusions
	# Turn off scanning of Active Directory and Active Directory-related files

	# Exclude the Main NTDS database files.
	$DSADatabaseFile = 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NTDS\Parameters'
	$DSADatabaseFilePath = ('Registry::' + $DSADatabaseFile)
	if (Test-Path -Path $DSADatabaseFilePath) {
		$DSADatabaseFileValue = (Get-ItemProperty -Path $DSADatabaseFilePath | Select-Object -ExpandProperty 'DSA Database file' -ErrorAction $SCT)
		if ($DSADatabaseFileValue) {
			$ExcludePathList += ($DSADatabaseFileValue)
			$ExcludePathList += ($DSADatabaseFileValue).Replace('.dit', '.pat')
		}
	}
	else {
		Write-Verbose -Message 'No NTDS database files to exclude'
	}

	# Exclude the Active Directory transaction log files.
	$DatabaseLogFiles = 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NTDS\Parameters'
	$DatabaseLogFilesPath = ('Registry::' + $DatabaseLogFiles)
	if (Test-Path -Path $DatabaseLogFilesPath) {
		$DatabaseLogFilesPathValue = (Get-ItemProperty -Path $DatabaseLogFilesPath | Select-Object -ExpandProperty 'Database Log Files Path' -ErrorAction $SCT)
		if ($DatabaseLogFilesPathValue) {
			$ExcludePathList += ($DatabaseLogFilesPathValue + '\EDB*.log')
			$ExcludePathList += ($DatabaseLogFilesPathValue + '\Res*.log')
			$ExcludePathList += ($DatabaseLogFilesPathValue + '\Edb*.jrs')
			$ExcludePathList += ($DatabaseLogFilesPathValue + '\Ntds.pat')
		}
	}
	else {
		Write-Verbose -Message 'No Active Directory transaction log files to exclude'
	}

	# Exclude the files in the NTDS Working folder
	$DSAWorkingDir = 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NTDS\Parameters'
	$DSAWorkingDirPath = ('Registry::' + $DSAWorkingDir)
	if (Test-Path -Path $DSAWorkingDirPath) {
		$DSAWorkingDirValue = (Get-ItemProperty -Path $DSAWorkingDirPath | Select-Object -ExpandProperty 'DSA Working Directory' -ErrorAction $SCT)
		if ($DSAWorkingDirValue) {
			$ExcludePathList += ($DSAWorkingDirValue + '\Temp.edb')
			$ExcludePathList += ($DSAWorkingDirValue + '\Edb.chk')
		}
	}
	else {
		Write-Verbose -Message 'No NTDS Working folder to exclude'
	}
	#endregion AdExclusions

	#region SysVolExclusions
	# Turn off scanning of SYSVOL files

	# Turn off scanning of files in the File Replication Service (FRS) Working folder
	$SysVolWorkingDir = 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NtFrs\Parameters'
	$SysVolWorkingDirPath = ('Registry::' + $SysVolWorkingDir)
	if (Test-Path -Path $SysVolWorkingDirPath) {
		$SysVolWorkingDirValue = (Get-ItemProperty -Path $SysVolWorkingDirPath | Select-Object -ExpandProperty 'Working Directory' -ErrorAction $SCT)
		if ($SysVolWorkingDirValue) {
			$ExcludePathList += ($SysVolWorkingDirValue + '\jet\sys\edb.chk')
			$ExcludePathList += ($SysVolWorkingDirValue + '\jet\Ntfrs.jdb')
			$ExcludePathList += ($SysVolWorkingDirValue + '\jet\log\*.log')
		}
	}
	else {
		Write-Verbose -Message 'No File Replication Service Working folder to exclude'
	}

	# Turn off scanning of files in the File Replication Service Database Log files
	$SysVolDBLogFileDir = 'HKEY_LOCAL_MACHINE\SYSTEM\Currentcontrolset\Services\Ntfrs\Parameters'
	$SysVolDBLogFileDirPath = ('Registry::' + $SysVolDBLogFileDir)
	if (Test-Path -Path $SysVolDBLogFileDirPath) {
		$SysVolDBLogFileDirValue = (Get-ItemProperty -Path $SysVolWorkingDirPath | Select-Object -ExpandProperty 'Working Directory' -ErrorAction $SCT)
		if ($SysVolDBLogFileDirValue) {
			$ExcludePathList += ($SysVolDBLogFileDirValue + '\Jet\Log\Edb*.jrs')
		}
		else {
			if ($SysVolWorkingDirValue) {
				$ExcludePathList += ($SysVolWorkingDirValue + '\jet\Log\Edb*.log')
			}
		}
	}
	else {
		Write-Verbose -Message 'No File Replication Service Database Log files to exclude'
	}
	#endregion SysVolExclusions

	#region DhcpExclusions
	# Turn off scanning of DHCP files
	$DhcpFiles = 'HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\DHCPServer\Parameters'
	$DhcpFilesPath = ('Registry::' + $DhcpFiles)
	if (Test-Path -Path $DhcpFilesPath) {
		$DhcpDatabasePathValue = (Get-ItemProperty -Path $DhcpFilesPath | Select-Object -ExpandProperty 'DatabasePath' -ErrorAction $SCT)
		if ($DhcpDatabasePathValue) {
			$ExcludePathList += ($DhcpDatabasePathValue + '\*.mdb')
			$ExcludePathList += ($DhcpDatabasePathValue + '\*.pat')
			$ExcludePathList += ($DhcpDatabasePathValue + '\*.chk')
			$ExcludePathList += ($DhcpDatabasePathValue + '\*.edb')
		}

		$DhcpLogFilePathValue = (Get-ItemProperty -Path $DhcpFilesPath | Select-Object -ExpandProperty 'DhcpLogFilePath' -ErrorAction $SCT)
		if (($DhcpLogFilePathValue) -and ($DhcpLogFilePathValue -ne $DhcpDatabasePathValue)) {
			$ExcludePathList += ($DhcpLogFilePathValue + '\*.log')
		}
		else {
			$ExcludePathList += ($DhcpDatabasePathValue + '\*.log')
		}

		$DhcpBackupDatabasePathValue = (Get-ItemProperty -Path $DhcpFilesPath | Select-Object -ExpandProperty 'BackupDatabasePath' -ErrorAction $SCT)
		if ($DhcpBackupDatabasePathValue) {
			$ExcludePathList += ($DhcpBackupDatabasePathValue + '\new\*.mdb')
			$ExcludePathList += ($DhcpBackupDatabasePathValue + '\new\*.pat')
			$ExcludePathList += ($DhcpBackupDatabasePathValue + '\new\*.chk')
			$ExcludePathList += ($DhcpBackupDatabasePathValue + '\new\*.edb')
			$ExcludePathList += ($DhcpBackupDatabasePathValue + '\new\*.log')
		}
	}
	else {
		Write-Verbose -Message 'No DHCP Server Directory found'
	}
	#endregion DhcpExclusions

	#region DnsExclusions
	$DnsServerDir = "$env:windir\System32\dns"
	if (Test-Path -Path $DnsServerDir -ErrorAction $SCT) {
		$ExcludePathList += ($DnsServerDir + '\*.log')
		$ExcludePathList += ($DnsServerDir + '\*.dns')
		$ExcludePathList += ($DnsServerDir + '\BOOT')

		$DnsBackupServerDir = ($DnsServerDir + '\backup')
		if (Test-Path -Path $DnsBackupServerDir -ErrorAction $SCT) {
			$ExcludePathList += ($DnsBackupServerDir + '\*.log')
			$ExcludePathList += ($DnsBackupServerDir + '\*.dns')
			$ExcludePathList += ($DnsBackupServerDir + '\BOOT')
		}
	}
	else {
		Write-Verbose -Message 'No DNS Server Directory found'
	}
	#endregion DnsExclusions

	#region WinsExclusions
	$WinsServerDir = "$env:windir\System32\Wins"
	if (Test-Path -Path $WinsServerDir -ErrorAction $SCT) {
		Write-Warning -Message 'WINS is still installed on this system!' -WarningAction Continue

		$ExcludePathList += ($WinsServerDir + '\*.chk')
		$ExcludePathList += ($WinsServerDir + '\*.log')
		$ExcludePathList += ($WinsServerDir + '\*.mdb')
	}
	else {
		Write-Verbose -Message 'No WINS Server Directory found'
	}
	#endregion WinsExclusions
}

process {
	if ($pscmdlet.ShouldProcess($ExcludePathList, 'Exclude from Microsoft Defender Scanning')) {
		# Loop over the list we created
		foreach ($ExcludePath in $ExcludePathList) {
			try {
				# Splat the parameters for Add-MpPreference
				$SplatAddMpPreference = @{
					ExclusionPath = $ExcludePath
					Force         = $true
					ErrorAction   = 'Stop'
					WarningAction = 'Continue'
				}
				$null = (Add-MpPreference @SplatAddMpPreference)
			}
			catch {
				#region ErrorHandler
				# get error record
				[Management.Automation.ErrorRecord]$e = $_

				# retrieve information about runtime error
				$info = @{
					Exception = $e.Exception.Message
					Reason    = $e.CategoryInfo.Reason
					Target    = $e.CategoryInfo.TargetName
					Script    = $e.InvocationInfo.ScriptName
					Line      = $e.InvocationInfo.ScriptLineNumber
					Column    = $e.InvocationInfo.OffsetInLine
				}

				# Error Stack
				$info | Out-String | Write-Verbose

				# Just display the info on continue with the rest of the list
				Write-Warning -Message ($info.Exception) -ErrorAction Continue -WarningAction Continue

				# Cleanup
				$info = $null
				$e = $null
				#endregion ErrorHandler
			}
		}
	}

	if ($pscmdlet.ShouldProcess($ExcludePathList, 'Tweak Controlled Folder AccessAllowed Applications')) {
		$CurrentAllowedApplications = ((Get-MpPreference -ErrorAction SilentlyContinue).ControlledFolderAccessAllowedApplications)

		# Prevent issues with missing allowed applications
		if (-not ($CurrentAllowedApplications)) {
			# New installations might not have allowed applications, let us create an empty object
			$CurrentAllowedApplications = @()
		}

		$AllowedApplications = @(
			'C:\Program Files (x86)\KeePass Password Safe 2\KeePass.exe'
			'C:\Program Files\Intel\Intel(R) Rapid Storage Technology\IAStorDataMgrSvc.exe'
			'C:\ProgramData\chocolatey\lib\vlc\tools\vlc-*-win64_x64.exe'
			'C:\swsetup\SP*\HPImageAssistant.dll'
			'C:\Users\*\AppData\Local\Programs\Mark Text\Mark Text.exe'
			'C:\Users\*\AppData\Local\Temp\chocolatey\is-*.tmp\WinSCP-*-Setup.tmp'
			'C:\Windows\explorer.exe'
			'C:\Windows\System32\svchost.exe'
			'C:\Windows\System32\WindowsPowerShell\v1.0\powershell_ise.exe'
		)

		$AllowedApplications | ForEach-Object -Process {
			if (-not ($CurrentAllowedApplications.Contains($_))) {
				# Not the fasted way, but this will work just fine
				$CurrentAllowedApplications += $_
			}
		}

		try {
			# Apply the new (merged) allowed application list to the Defender Controlled Folder Access Allowed feature
			$null = (Add-MpPreference -ControlledFolderAccessAllowedApplications $CurrentAllowedApplications -Force -ErrorAction Stop)
		}
		catch {
			Write-Warning -Message "Unable to modify the allow list..."
		}
	}
}

end {
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
