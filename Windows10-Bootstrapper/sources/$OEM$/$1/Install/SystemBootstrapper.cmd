@ECHO OFF

:: ********************************************************************************************************************
::
:: enabling Technology progressive OS deployment
:: Client System Bootstrapper for Windows 10 Enterprise Installations
::
:: Version 1.0.0
::
:: Tested with Windows 10 Enterprise Release 2004 and Release 2009
::
:: Please review all the scripts BEFORE you install it on any of your systems.
:: This installation/configuration is customized to our internal requirements and might not fit for everyone!
::
:: ********************************************************************************************************************

SETLOCAL

:: check if runs as Administrator
OPENFILES >nul 2>&1
IF %errorlevel%==0 (
	GOTO MakeNonCancelable
) ELSE (
	ECHO You are not running as Administrator...
	ECHO This batch cannot do it's job without elevation!
	ECHO.
	ECHO Right-click and select ^'Run as Administrator^' and try again...
	ECHO.
	ECHO Press any key to exit...
	PAUSE >nul

	EXIT
)

:MakeNonCancelable
:: prevent CTRL + C
IF "%~1" EQU "NonCancelable" GOTO NonCancelable
START "" /B CMD /C "%~F0" NonCancelable
EXIT

:NonCancelable
TITLE enabling Technology Client System Bootstrapper
SET Module=SystemBootstrapper
SET logfile_setup=%HOMEDRIVE%\Temp\%Module%.txt

:: Show Splash Screen
START /LOW /MAX "Installation is running, please wait" c:\tools\enaTec_Installer.exe >nul 2>&1

:: Ensure NTP is used and that the time is correct
%SystemRoot%\System32\net.exe stop w32time >nul 2>&1
%SystemRoot%\System32\w32tm.exe /config /syncfromflags:manual /manualpeerlist:"0.de.pool.ntp.org 1.de.pool.ntp.org 2.de.pool.ntp.org 3.de.pool.ntp.org" >nul 2>&1
%SystemRoot%\System32\net.exe start w32time >nul 2>&1
%SystemRoot%\System32\sc.exe config w32time start= auto >nul 2>&1
%SystemRoot%\System32\w32tm.exe /resync /force >nul 2>&1

:: Wait for the Splash Screen to load
:LOOP
:: Check if the Splash Screen is running
%SystemRoot%\system32\tasklist.exe | %SystemRoot%\system32\find.exe /i "enaTec_Installer" >nul 2>&1
IF ERRORLEVEL 1 (
	:: Wait for 5 seconds
	%SystemRoot%\system32\timeout.exe /T 5 /Nobreak >nul 2>&1
	:: Check again
	GOTO LOOP
) ELSE (
	:: Splash Screen is running
	GOTO SetLogHeader
)

:SetLogHeader
ECHO ******************************************************************************** >%logfile_setup%
ECHO Started %Module% on %DATE:~0% - %TIME:~0,8%
ECHO For %COMPUTERNAME% by %USERDOMAIN%\%USERNAME% >>%logfile_setup%

ECHO.>>%logfile_setup% 2>nul

:: DEFAULT
ECHO.>>%logfile_setup% 2>nul
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction SilentlyContinue)" >nul 2>&1
SC stop wsearch >nul 2>&1
:: DEFAULT

:SetPowerPlanToHighPerformance
ECHO Set Power Plan to High Performance
ECHO %TIME:~0,8% Set Power Plan to High Performance >>%logfile_setup%
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "c:\scripts\PowerShell\Set-PowerPlanToHighPerformance.ps1" >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

ECHO.>>%logfile_setup% 2>nul

:DisableCortanaSearchbar
ECHO Disable Cortana Searchbar
ECHO %TIME:~0,8% Disable Cortana Searchbar >>%logfile_setup%
"%SystemRoot%\System32\reg.exe" ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v SearchboxTaskbarMode /t REG_DWORD /d 0 /f >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

ECHO.>>%logfile_setup% 2>nul

:: DEFAULT
ECHO.>>%logfile_setup% 2>nul
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction SilentlyContinue)" >nul 2>&1
SC stop wsearch >nul 2>&1
:: DEFAULT

:CreatePowerShellProfiles
ECHO Create plain PowerShell Profiles
ECHO %TIME:~0,8% Create plain PowerShell Profiles >>%logfile_setup%
start /MIN /WAIT "CleanupStockApps" %SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "C:\scripts\PowerShell\New-PowerShellProfiles.ps1" >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

:: DEFAULT
ECHO.>>%logfile_setup% 2>nul
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction SilentlyContinue)" >nul 2>&1
SC stop wsearch >nul 2>&1
:: DEFAULT

:ConfigureStorageSense
ECHO Configure Storage Sense
ECHO %TIME:~0,8% Configure Storage Sense >>%logfile_setup%
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "(C:\scripts\PowerShell\Set-StorageSense.ps1 -ErrorAction Continue)" >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

:: DEFAULT
ECHO.>>%logfile_setup% 2>nul
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction SilentlyContinue)" >nul 2>&1
SC stop wsearch >nul 2>&1
:: DEFAULT

:BootstrapTheUser
ECHO Bootstrap the User
ECHO %TIME:~0,8% Bootstrap the User >>%logfile_setup% 2>&1
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "(C:\scripts\PowerShell\Invoke-BootstrapUser.ps1 -ErrorAction Continue)" >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

:ApplyTweaksLocal
ECHO Apply tweaks local
ECHO %TIME:~0,8% Apply tweaks local >>%logfile_setup% 2>&1
"%SystemRoot%\System32\reg.exe" ADD HKU\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce /v BootstrapUser /t REG_SZ /d "powershell.exe -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command '$null = (C:\scripts\PowerShell\Invoke-BootstrapUser.ps1)'" /f >>%logfile_setup% 2>&1

:: DEFAULT
ECHO.>>%logfile_setup% 2>nul
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction SilentlyContinue)" >nul 2>&1
SC stop wsearch >nul 2>&1
:: DEFAULT

:UpdateAllMicrosoftStoreApps
ECHO Update all Microsoft Store Apps
ECHO %TIME:~0,8% Update all Microsoft Store Apps >>%logfile_setup% 2>&1
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "(C:\scripts\PowerShell\Update-AllMicrosoftStoreApps.ps1 -ErrorAction Continue)" >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

:: DEFAULT
ECHO.>>%logfile_setup% 2>nul
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction SilentlyContinue)" >nul 2>&1
SC stop wsearch >nul 2>&1
:: DEFAULT

:SetOneDriveToGetInsiderBuilds
ECHO Set OneDrive to get Insider builds
ECHO %TIME:~0,8% Set OneDrive to get Insider builds >>%logfile_setup% 2>&1
"%SystemRoot%\System32\reg.exe" add HKCU\Software\Microsoft\OneDrive /v EnableTeamTier_Internal /t REG_DWORD /d 1 /f >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

:: DEFAULT
ECHO.>>%logfile_setup% 2>nul
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction SilentlyContinue)" >nul 2>&1
SC stop wsearch >nul 2>&1
:: DEFAULT

:ForceOneDriveToUpdateAndRestart
ECHO Force OneDrive to update and restart
ECHO %TIME:~0,8% Force OneDrive to update and restart >>%logfile_setup% 2>&1
C:\Windows\SysWOW64/OneDriveSetup.exe /update /restart /force >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

:: DEFAULT
ECHO.>>%logfile_setup% 2>nul
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction SilentlyContinue)" >nul 2>&1
SC stop wsearch >nul 2>&1
:: DEFAULT

:DownloadAndInstallLatestVersionOfMicrosoftTeams
ECHO Download and install latest version of Microsoft Teams
ECHO %TIME:~0,8% Download and install latest version of Microsoft Teams >>%logfile_setup% 2>&1
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "(C:\scripts\PowerShell\Install-LatestTeamsClient.ps1 -ErrorAction Continue)" >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

:: DEFAULT
ECHO.>>%logfile_setup% 2>nul
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction SilentlyContinue)" >nul 2>&1
SC stop wsearch >nul 2>&1
:: DEFAULT

:EnableQoSForMicrosoftTeams
ECHO Enable QoS for Microsoft Teams
ECHO %TIME:~0,8% Enable QoS for Microsoft Teams >>%logfile_setup% 2>&1
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "(C:\scripts\PowerShell\Set-QoSForMicrosoftTeams.ps1 -ErrorAction Continue)" >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

:: DEFAULT
ECHO.>>%logfile_setup% 2>nul
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction SilentlyContinue)" >nul 2>&1
SC stop wsearch >nul 2>&1
:: DEFAULT

:TweakTheFirewallForMicrosoftTeams
ECHO Tweak the Firewall for Microsoft Teams
ECHO %TIME:~0,8% Tweak the Firewall for Microsoft Teams >>%logfile_setup% 2>&1
SC stop wsearch >nul 2>&1
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "(C:\scripts\PowerShell\Invoke-TweakTeamsClientFirewall.ps1 -ErrorAction Continue)" >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

:: DEFAULT
ECHO.>>%logfile_setup% 2>nul
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction SilentlyContinue)" >nul 2>&1
SC stop wsearch >nul 2>&1
:: DEFAULT

:ConfigureMicrosoftDefender
ECHO Configure Microsoft Defender
ECHO %TIME:~0,8% Configure Microsoft Defender >>%logfile_setup% 2>&1
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "(C:\scripts\PowerShell\Optimize-MicrosoftDefenderExclusions.ps1 -ErrorAction Continue)" >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

:: DEFAULT
ECHO.>>%logfile_setup% 2>nul
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction SilentlyContinue)" >nul 2>&1
SC stop wsearch >nul 2>&1
:: DEFAULT

:InstallSomePowerShellModules
ECHO Install some PowerShell Modules
ECHO %TIME:~0,8% Install some PowerShell Modules >>%logfile_setup% 2>&1
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "(C:\scripts\PowerShell\Install-PowerShellModules_required.ps1 -ErrorAction Continue)" >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

:: DEFAULT
ECHO.>>%logfile_setup% 2>nul
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction SilentlyContinue)" >nul 2>&1
SC stop wsearch >nul 2>&1
:: DEFAULT

:InstallChocoWorkstationPackages
ECHO Install Choco Workstation packages
ECHO %TIME:~0,8% Install Choco Workstation packages >>%logfile_setup% 2>&1
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "(c:\scripts\PowerShell\Install-ChocoPackages_Workstation.ps1 -ErrorAction Continue)" >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

:: DEFAULT
ECHO.>>%logfile_setup% 2>nul
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction SilentlyContinue)" >nul 2>&1
SC stop wsearch >nul 2>&1
:: DEFAULT

:InstallWinGetFromTheGitHubRepository
ECHO Install WinGet from the GitHub Repository
ECHO %TIME:~0,8% Install WinGet from the GitHub Repository >>%logfile_setup%
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "(C:\scripts\PowerShell\Install-WingetFromRepositoryRelease.ps1 -ErrorAction Continue)" >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

:: DEFAULT
ECHO.>>%logfile_setup% 2>nul
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction SilentlyContinue)" >nul 2>&1
SC stop wsearch >nul 2>&1
:: DEFAULT

:AutomateTheDriverUpdateProcess
ECHO Automate the driver update process
ECHO %TIME:~0,8% Automate the driver update process >>%logfile_setup%
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -ExecutionPolicy Bypass -Command "(c:\scripts\PowerShell\Invoke-MSIntuneDriverUpdate.ps1 -ErrorAction Continue)" >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

:: DEFAULT
ECHO.>>%logfile_setup% 2>nul
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction SilentlyContinue)" >nul 2>&1
SC stop wsearch >nul 2>&1
:: DEFAULT

:DesktopCleanup
ECHO Desktop Cleanup
ECHO %TIME:~0,8% Desktop Cleanup >>%logfile_setup% 2>&1
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "(C:\scripts\PowerShell\Remove-AllPublicDesktopLinks.ps1 -ErrorAction Continue)" >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

:: DEFAULT
ECHO.>>%logfile_setup% 2>nul
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction SilentlyContinue)" >nul 2>&1
SC stop wsearch >nul 2>&1
:: DEFAULT

ECHO Set the default Start menu
ECHO %TIME:~0,8% Set the default Start menu >>%logfile_setup%
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "(C:\scripts\PowerShell\Set-DefaultStartMenu.ps1 -ErrorAction Continue)" >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

:: DEFAULT
ECHO.>>%logfile_setup% 2>nul
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction SilentlyContinue)" >nul 2>&1
SC stop wsearch >nul 2>&1
:: DEFAULT

:DisableWindowsScriptHost
:: Turn off Windows Script Host (current user only)
ECHO Turn off Windows Script Host
ECHO %TIME:~0,8% Turn on Windows Script Host >>%logfile_setup%
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (New-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows Script Host\Settings' -Name Enabled -PropertyType DWord -Value 0 -Force -ErrorAction Continue)" >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

:: DEFAULT
ECHO.>>%logfile_setup% 2>nul
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction SilentlyContinue)" >nul 2>&1
SC stop wsearch >nul 2>&1
:: DEFAULT

:EncryptTheBootDriveWithBitLocker
ECHO Encrypt the Boot drive with BitLocker
ECHO %TIME:~0,8% Encrypt the Boot drive with BitLocker >>%logfile_setup%
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "(C:\scripts\PowerShell\Enable-BitLockerEncryption.ps1 -ErrorAction Continue)" >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

:: DEFAULT
ECHO.>>%logfile_setup% 2>nul
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction SilentlyContinue)" >nul 2>&1
SC stop wsearch >nul 2>&1
:: DEFAULT

:SaveBitLockerKeyToAzureAD
ECHO Save BitLocker Key to AzureAD
ECHO %TIME:~0,8% Save BitLocker Key to AzureAD >>%logfile_setup%
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "(C:\scripts\PowerShell\Invoke-BackupBitLockerKeyToAAD.ps1 -ErrorAction Continue)" >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

:: DEFAULT
ECHO.>>%logfile_setup% 2>nul
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction SilentlyContinue)" >nul 2>&1
SC stop wsearch >nul 2>&1
:: DEFAULT

:ApplyAllPendingMicrosoftUpdates
ECHO Apply all pending Microsoft updates
ECHO %TIME:~0,8% Apply all pending Microsoft updates >>%logfile_setup% 2>&1
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "(C:\scripts\PowerShell\Install-AllMissingMicrosoftUpdates.ps1 -ErrorAction Continue)" >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

:: DEFAULT
ECHO.>>%logfile_setup% 2>nul
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction SilentlyContinue)" >nul 2>&1
SC stop wsearch >nul 2>&1
:: DEFAULT

:SetPowerPlanToAuto
ECHO Set Power Plan to Auto
ECHO %TIME:~0,8% Set Power Plan to Auto >>%logfile_setup%
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "c:\scripts\PowerShell\Set-PowerPlanToAuto.ps1" >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

:: Go away
POPD >nul 2>&1
CD / >nul 2>&1

ECHO %TIME:~0,8% Bootstrap and JumpStart finished >>%logfile_setup%
ECHO ******************************************************************************** >>%logfile_setup%
ECHO.>>%logfile_setup% 2>nul

:: Initiate a restart
SHUTDOWN -r -t 5 >nul 2>&1

:: Final cleanup
IF EXIST c:\install\ rd /s /q c:\install\ >nul 2>&1

:: ********************************************************************************************************************
::
:: Changelog:
::
:: 0.9.0: Internal Test
:: 1.0.0: Initial Release
::
:: ********************************************************************************************************************
::
:: License: BSD 3-Clause License
::
:: Copyright 2020, enabling Technology
:: All rights reserved.
::
:: Redistribution and use in source and binary forms, with or without modification, are permitted provided that the
:: following conditions are met:
:: 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following
::    disclaimer.
:: 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the
::    following disclaimer in the documentation and/or other materials provided with the distribution.
:: 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote
::    products derived from this software without specific prior written permission.
::
:: THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
:: INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
:: DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
:: SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
:: SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
:: WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
:: USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
::
:: ********************************************************************************************************************
::
:: Disclaimer:
:: - Use at your own risk, etc.
:: - This is open-source software, if you find an issue try to fix it yourself. There is no support and/or warranty
::   in any kind
:: - This is a third-party Software
:: - The developer of this Software is NOT sponsored by or affiliated with Microsoft Corp (MSFT) or any of its
::   subsidiaries in any way
:: - The Software is not supported by Microsoft Corp (MSFT)
:: - By using the Software, you agree to the License, Terms, and any Conditions declared and described above
:: - If you disagree with any of the Terms, and any Conditions declared: Just delete it and build your own solution
::
:: ********************************************************************************************************************
