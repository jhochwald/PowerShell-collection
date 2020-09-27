@ECHO OFF

:: ********************************************************************************************************************
::
:: enabling Technology progressive OS deployment (ETPOSD)
:: Client System Bootstrapper for Windows 10 Enterprise Installations
::
:: Version 1.4.8
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

:: pause for a momet
TIMEOUT /t 5 >nul 2>&1

:: Ensure NTP is used and that the time is correct
%SystemRoot%\System32\net.exe stop w32time >nul 2>&1
%SystemRoot%\System32\w32tm.exe /config /syncfromflags:manual /manualpeerlist:"0.de.pool.ntp.org 1.de.pool.ntp.org 2.de.pool.ntp.org 3.de.pool.ntp.org" >nul 2>&1
%SystemRoot%\System32\net.exe start w32time >nul 2>&1
%SystemRoot%\System32\sc.exe config w32time start= auto >nul 2>&1
%SystemRoot%\System32\w32tm.exe /resync /force >nul 2>&1

:SetLogHeader
ECHO ******************************************************************************** >%logfile_setup%
ECHO Started %Module% on %DATE:~0% - %TIME:~0,8%
ECHO For %COMPUTERNAME% by %USERDOMAIN%\%USERNAME% >>%logfile_setup%

ECHO.>>%logfile_setup% 2>nul

:ControlPanelClassicView
ECHO Control Panel Classic View
ECHO %TIME:~0,8% Control Panel Classic View >>%logfile_setup%
"%SystemRoot%\System32\reg.exe" ADD "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" /v StartupPage /t REG_DWORD /d 1 /f >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

ECHO.>>%logfile_setup% 2>nul

:ControlPanelIconSize
ECHO Control Panel Icon Size
ECHO %TIME:~0,8% Control Panel Icon Size >>%logfile_setup%
"%SystemRoot%\System32\reg.exe" ADD "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" /v AllItemsIconView /t REG_DWORD /d 1 /f >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

ECHO.>>%logfile_setup% 2>nul

:DisableTheNetworkDiscoveryPromptWindow
ECHO Disable the network discovery prompt window
ECHO %TIME:~0,8% Disable the network discovery prompt window >>%logfile_setup%
"%SystemRoot%\System32\reg.exe" ADD "HKLM\System\CurrentControlSet\Control\Network\NewNetworkWindowOff" /f >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

ECHO.>>%logfile_setup% 2>nul

:NoBackgroundImageAtTheLogonPage
ECHO No Background Image at the Logon Page
ECHO %TIME:~0,8% No Background Image at the Logon Page >>%logfile_setup%
"%SystemRoot%\System32\reg.exe" ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\System" /v DisableLogonBackgroundImage /t REG_DWORD /d 1 /f >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

ECHO.>>%logfile_setup% 2>nul

:IncreaseTaskbarTransparencyLevel
ECHO Increase Taskbar Transparency Level
ECHO %TIME:~0,8% Increase Taskbar Transparency Level >>%logfile_setup%
"%SystemRoot%\System32\reg.exe" ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v UseOLEDTaskbarTransparency /t REG_DWORD /d 1 /f >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

ECHO.>>%logfile_setup% 2>nul

:QuickShutdown
ECHO Quick Shutdown
ECHO %TIME:~0,8% Quick Shutdown >>%logfile_setup%
"%SystemRoot%\System32\reg.exe" ADD "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control" /v WaitToKillServiceTimeout /t REG_SZ /d 1000 /f >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

ECHO.>>%logfile_setup% 2>nul

:SetWaitToKillServiceTimeoutTo1000
ECHO Set wait to kill service timeout to 1000
ECHO %TIME:~0,8% Set wait to kill service timeout to 1000 >>%logfile_setup%
"%SystemRoot%\System32\reg.exe" ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control" /v WaitToKillServiceTimeout /t REG_SZ /d 1000 /f >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

ECHO.>>%logfile_setup% 2>nul

:DisableFirstTimeSignInAnimation
ECHO Disable First Time Sign-in Animation
ECHO %TIME:~0,8% Disable First Time Sign-in Animation >>%logfile_setup%
"%SystemRoot%\System32\reg.exe" ADD "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableFirstLogonAnimation /t REG_DWORD /d 0 /f >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

ECHO.>>%logfile_setup% 2>nul

:DisableTheLockScreen
ECHO Disable the Lock Screen
ECHO %TIME:~0,8% Disable the Lock Screen >>%logfile_setup%
"%SystemRoot%\System32\reg.exe" ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Personalization" /v NoLockScreen /t REG_DWORD /d 1 /f >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

ECHO.>>%logfile_setup% 2>nul

:TurnOffFastStartup
ECHO Turn off Fast Startup
ECHO %TIME:~0,8% Turn off Fast Startup >>%logfile_setup%
"%SystemRoot%\System32\reg.exe" ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v HiberbootEnabled /t REG_DWORD /d 0 /f >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

ECHO.>>%logfile_setup% 2>nul

:DisablePrivacySettingsExperienceAtSignIn
ECHO Disable Privacy Settings Experience at Sign-in
ECHO %TIME:~0,8% Disable Privacy Settings Experience at Sign-in >>%logfile_setup%
"%SystemRoot%\System32\reg.exe" ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\OOBE" /v DisablePrivacyExperience /t REG_DWORD /d 1 /f >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

ECHO.>>%logfile_setup% 2>nul

:DisableTelemetry
ECHO Disable Telemetry
ECHO %TIME:~0,8% Disable Telemetry >>%logfile_setup%
"%SystemRoot%\System32\reg.exe" ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

ECHO.>>%logfile_setup% 2>nul

:AllowMicrosoftUpdatesForOtherProducts
ECHO Allow Microsoft Updates for other products
ECHO %TIME:~0,8% Allow Microsoft Updates for other products >>%logfile_setup%
"%SystemRoot%\System32\reg.exe" ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\WindowsUpdate\Services\7971f918-a847-4430-9279-4a52d1efe18d" /v RegisteredWithAU /t REG_DWORD /d 1 /f >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

ECHO.>>%logfile_setup% 2>nul

:UnnecessarilyWritingOnSSDWillShortenTheLifetime
ECHO Unnecessarily writing on SSD will shorten the lifetime
ECHO %TIME:~0,8% Unnecessarily writing on SSD will shorten the lifetime >>%logfile_setup%
"%SystemRoot%\System32\reg.exe" ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\FileSystem" /v NtfsDisableLastAccessUpdate /t REG_DWORD /d 80000001 /f >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

ECHO.>>%logfile_setup% 2>nul

:DisableAutoRunForAllVolumes
ECHO Disable Auto Run for all volumes
ECHO %TIME:~0,8% Disable Auto Run for all volumes >>%logfile_setup%
"%SystemRoot%\System32\reg.exe" ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v NoAutoplayfornonVolume /t REG_DWORD /d 1 /f >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

ECHO.>>%logfile_setup% 2>nul

:DisplayDetailedInformationInDeviceManager
ECHO Display detailed information in Device Manager
ECHO %TIME:~0,8% Display detailed information in Device Manager >>%logfile_setup%
"%SystemRoot%\System32\reg.exe" ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v "DEVMGR_SHOW_DETAILS" /t REG_DWORD /d 1 /f >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

ECHO.>>%logfile_setup% 2>nul

:DisableCortanaSearchbar
ECHO Disable Cortana Searchbar
ECHO %TIME:~0,8% Disable Cortana Searchbar >>%logfile_setup%
"%SystemRoot%\System32\reg.exe" ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v SearchboxTaskbarMode /t REG_DWORD /d 0 /f >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

ECHO.>>%logfile_setup% 2>nul

:DisableEdgeFirstRun
ECHO Disable Edge First Run
ECHO %TIME:~0,8% Disable Edge First Run >>%logfile_setup%
"%SystemRoot%\System32\reg.exe" ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main" /v PreventFirstRunPage /t REG_DWORD /d 1 /reg:64 /f >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

ECHO.>>%logfile_setup% 2>nul

:DisableEdgePrelaunch
ECHO Disable Edge Prelaunch
ECHO %TIME:~0,8% Disable Edge Prelaunch >>%logfile_setup%
"%SystemRoot%\System32\reg.exe" ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main" /v AllowPrelaunch /t REG_DWORD /d 0 /reg:64 /f >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

ECHO.>>%logfile_setup% 2>nul

:DisableEdgeTabPreloading
ECHO Disable Edge Tab Preloading
ECHO %TIME:~0,8% Disable Edge Tab Preloading >>%logfile_setup%
"%SystemRoot%\System32\reg.exe" ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\MicrosoftEdge\TabPreloader" /v AllowTabPreloading /t REG_DWORD /d 0 /reg:64 /f >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

:: DEFAULT
ECHO.>>%logfile_setup% 2>nul
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction SilentlyContinue)" >nul 2>&1
SC stop wsearch >nul 2>&1
:: DEFAULT

:EnableRemotePowerShell
ECHO Enable Remote PowerShell
ECHO %TIME:~0,8% Enable Remote PowerShell >>%logfile_setup%
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "Enable-PSRemoting -SkipNetworkProfileCheck -Force -Confirm:$false -ErrorAction Continue" >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

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

:InstallingChocolatey
ECHO Installing Chocolatey
ECHO %TIME:~0,8% Installing Chocolatey >>%logfile_setup%
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "(Invoke-Expression -Command (New-Object -TypeName System.Net.WebClient -ErrorAction Continue).DownloadString('https://chocolatey.org/install.ps1') -ErrorAction Continue)" >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

:: DEFAULT
ECHO.>>%logfile_setup% 2>nul
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction SilentlyContinue)" >nul 2>&1
SC stop wsearch >nul 2>&1
:: DEFAULT

:AddNuGetPackageSource
ECHO Add NuGet Package Source
ECHO %TIME:~0,8% Add NuGet Package Source >>%logfile_setup%
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "(Install-PackageProvider -Name NuGet -Force -ErrorAction Continue)" >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

:: DEFAULT
ECHO.>>%logfile_setup% 2>nul
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction SilentlyContinue)" >nul 2>&1
SC stop wsearch >nul 2>&1
:: DEFAULT

:RegisterNugetRepository
ECHO Register Nuget Repository
ECHO %TIME:~0,8% Register Nuget Repository >>%logfile_setup%
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "(Register-PackageSource -Name Nuget -Location 'http://www.nuget.org/api/v2' -ProviderName Nuget -Trusted -ErrorAction Continue)" >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

:: DEFAULT
ECHO.>>%logfile_setup% 2>nul
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction SilentlyContinue)" >nul 2>&1
SC stop wsearch >nul 2>&1
:: DEFAULT

:ConfiguresWindowsRemoteManagement
ECHO Configures Windows Remote Management
ECHO %TIME:~0,8% Configures Windows Remote Management >>%logfile_setup%
start /MIN /WAIT "Configures Windows Remote Management (WinRM)" cmd /c winrm quickconfig -force -quiet >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

:: DEFAULT
ECHO.>>%logfile_setup% 2>nul
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction SilentlyContinue)" >nul 2>&1
SC stop wsearch >nul 2>&1
:: DEFAULT

:AllowBasicAuthenticationWindowsRemoteManagement
ECHO Allow Basic authentication Windows Remote Management
ECHO %TIME:~0,8% Allow Basic authentication Windows Remote Management >>%logfile_setup%
start /MIN /WAIT "Allow Basic authentication Windows Remote Management (WinRM)" cmd /c winrm set winrm/config/client/auth @{Basic="true"} >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

:: DEFAULT
ECHO.>>%logfile_setup% 2>nul
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction SilentlyContinue)" >nul 2>&1
SC stop wsearch >nul 2>&1
:: DEFAULT

:SetPowerConfigProfile
ECHO Set Power Config profile
ECHO %TIME:~0,8% Set Power Config profile >>%logfile_setup%
start /MIN /WAIT "Set Power Config profile" %SystemRoot%\system32\powercfg.exe -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

:: DEFAULT
ECHO.>>%logfile_setup% 2>nul
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction SilentlyContinue)" >nul 2>&1
SC stop wsearch >nul 2>&1
:: DEFAULT

:ChangeMonitorTimeout
ECHO Change monitor timeout
ECHO %TIME:~0,8% Change monitor timeout >>%logfile_setup%
start /MIN /WAIT "Change monitor timeout" %SystemRoot%\system32\powercfg.exe -Change -monitor-timeout-ac 10 >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

:: DEFAULT
ECHO.>>%logfile_setup% 2>nul
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction SilentlyContinue)" >nul 2>&1
SC stop wsearch >nul 2>&1
:: DEFAULT

:CleanupWindows10StockApps
ECHO Cleanup Windows 10 Stock Apps
ECHO %TIME:~0,8% Cleanup Windows 10 Stock Apps >>%logfile_setup%
start /MIN /WAIT "CleanupStockApps" %SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "C:\scripts\PowerShell\Cleanup_StockApps.ps1" >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

:: DEFAULT
ECHO.>>%logfile_setup% 2>nul
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction SilentlyContinue)" >nul 2>&1
SC stop wsearch >nul 2>&1
:: DEFAULT

:BootstrapTheWindows10System
ECHO Bootstrap the Windows 10 System
ECHO %TIME:~0,8% Bootstrap the Windows 10 System >>%logfile_setup%
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "(C:\scripts\PowerShell\Invoke-BootstrapSystem.ps1 -ErrorAction Continue)" >>%logfile_setup% 2>&1
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

:AllowPingAndRemoteDesktop
ECHO Allow Ping and RemoteDesktop
ECHO %TIME:~0,8% Allow Ping and RemoteDesktop >>%logfile_setup%
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "(C:\scripts\PowerShell\Set-AllowPingAndRemoteDesktop.ps1 -ErrorAction Continue)" >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

:: DEFAULT
ECHO.>>%logfile_setup% 2>nul
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction SilentlyContinue)" >nul 2>&1
SC stop wsearch >nul 2>&1
:: DEFAULT

:SaveSystemImageInfo
ECHO Save System Image Info
ECHO %TIME:~0,8% Save System Image Info >>%logfile_setup%
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "(C:\install\SetImageInfo.ps1 -ErrorAction Continue)" >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

:: DEFAULT
ECHO.>>%logfile_setup% 2>nul
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction SilentlyContinue)" >nul 2>&1
SC stop wsearch >nul 2>&1
:: DEFAULT

:ChangeSomeAttributes
ECHO Change some attributes
ECHO %TIME:~0,8% Change some attributes >>%logfile_setup%

ECHO.>>%logfile_setup% 2>nul

ECHO %TIME:~0,8% ATTRIB +A -R -S -H c:\scripts >>%logfile_setup%
ATTRIB +A -R -S -H c:\scripts >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

ECHO.>>%logfile_setup% 2>nul

ECHO %TIME:~0,8% ATTRIB +A -R -S -H c:\scripts\PowerShell >>%logfile_setup%
ATTRIB +A -R -S -H c:\scripts\PowerShell >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

ECHO.>>%logfile_setup% 2>nul

ECHO %TIME:~0,8% ATTRIB +A -R -S -H c:\scripts\Batch >>%logfile_setup%
ATTRIB +A -R -S -H c:\scripts\Batch >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

ECHO.>>%logfile_setup% 2>nul

ECHO %TIME:~0,8% ATTRIB +A -R -S -H c:\Install /S /D >>%logfile_setup%
ATTRIB +A -R -S -H c:\Install /S /D >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

ECHO.>>%logfile_setup% 2>nul

ECHO %TIME:~0,8% ATTRIB +A -R -S -H c:\Temp /S /D >>%logfile_setup%
ATTRIB +A -R -S -H c:\Temp /S /D >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

ECHO.>>%logfile_setup% 2>nul

ECHO %TIME:~0,8% ATTRIB +A -R -S -H c:\scripts\powershell\*.* /S /D >>%logfile_setup%
ATTRIB +A -R -S -H c:\scripts\powershell\*.* /S /D >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

ECHO.>>%logfile_setup% 2>nul

ECHO %TIME:~0,8% ATTRIB +A -R -S -H c:\scripts\Batch\*.* /S /D >>%logfile_setup%
ATTRIB +A -R -S -H c:\scripts\Batch\*.* /S /D >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

ECHO.>>%logfile_setup% 2>nul

ECHO %TIME:~0,8% ATTRIB +A -R -S -H c:\tools\*.* /S /D >>%logfile_setup%
ATTRIB +A -R -S -H c:\tools\*.* /S /D >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

ECHO.>>%logfile_setup% 2>nul

ECHO %TIME:~0,8% ATTRIB +A -R -S -H c:\Install\*.* /S /D >>%logfile_setup%
ATTRIB +A -R -S -H c:\Install\*.* /S /D >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

ECHO.>>%logfile_setup% 2>nul

ECHO %TIME:~0,8% ATTRIB +A -R -S -H c:\Temp\*.* /S /D >>%logfile_setup%
ATTRIB +A -R -S -H c:\Temp\*.* /S /D >>%logfile_setup% 2>&1
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

:: DEFAULT
ECHO.>>%logfile_setup% 2>nul
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction SilentlyContinue)" >nul 2>&1
SC stop wsearch >nul 2>&1
:: DEFAULT

:BootstrapTheAllUserProfile
:: TODO: Check this!!!
ECHO Bootstrap the All User Profile
ECHO %TIME:~0,8% Bootstrap the All User Profile >>%logfile_setup% 2>&1
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "(C:\scripts\PowerShell\Invoke-BootstrapAllUserProfile.ps1 -ErrorAction Continue)" >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

:: DEFAULT
ECHO.>>%logfile_setup% 2>nul
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction SilentlyContinue)" >nul 2>&1
SC stop wsearch >nul 2>&1
:: DEFAULT

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

:InstallTheMicrosoftOfficeSuite
PUSHD c:\install\Office\ >nul 2>&1

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

:InstallOurDefaultOfficeDeployment
ECHO Install our default office deployment
ECHO %TIME:~0,8% Install our default office deployment >>%logfile_setup% 2>&1
C:\install\Office\setup.exe /configure c:\install\Office\Configuration.xml >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

POPD >nul 2>&1

:: DEFAULT
ECHO.>>%logfile_setup% 2>nul
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction SilentlyContinue)" >nul 2>&1
SC stop wsearch >nul 2>&1
:: DEFAULT

:CleanupAfterTheOfficeSetupIsDone
ECHO Clean up after the office setup is done
ECHO %TIME:~0,8% Clean up after the office setup is done >>%logfile_setup% 2>&1
if exist c:\install\Office\ rd /s /q c:\install\Office\ >>%logfile_setup% 2>&1

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

:UpdateHelpFilesForAllInstalledPowerShellModules
ECHO Update help files for all installed PowerShell Modules
ECHO %TIME:~0,8% Update help files for all installed PowerShell Modules >>%logfile_setup% 2>&1
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "(C:\scripts\PowerShell\Update-PowerShellModulesHelp.ps1 -ErrorAction Continue)" >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

:: DEFAULT
ECHO.>>%logfile_setup% 2>nul
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction SilentlyContinue)" >nul 2>&1
SC stop wsearch >nul 2>&1
:: DEFAULT

:InstallSomeVCRedistributableChocoPackages
ECHO Install some VC Redistributable Choco packages
ECHO %TIME:~0,8% Install some VC Redistributable Choco packages >>%logfile_setup% 2>&1
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "(c:\scripts\PowerShell\Install-ChocoPackages_vcredist.ps1 -ErrorAction Continue)" >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

:: DEFAULT
ECHO.>>%logfile_setup% 2>nul
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction SilentlyContinue)" >nul 2>&1
SC stop wsearch >nul 2>&1
:: DEFAULT

:InstallDefaultDotNETChocoPackages
ECHO Install default .NET Choco packages
ECHO %TIME:~0,8% Install default .NET Choco packages >>%logfile_setup% 2>&1
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "(c:\scripts\PowerShell\Install-ChocoPackages_dotnet.ps1 -ErrorAction Continue)" >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

:: DEFAULT
ECHO.>>%logfile_setup% 2>nul
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction SilentlyContinue)" >nul 2>&1
SC stop wsearch >nul 2>&1
:: DEFAULT

:InstallChocoDefaultPackages
ECHO Install Choco default packages
ECHO %TIME:~0,8% Install Choco default packages >>%logfile_setup% 2>&1
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "(c:\scripts\PowerShell\Install-ChocoPackages.ps1 -ErrorAction Continue)" >>%logfile_setup% 2>&1
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

ECHO Set the default Start menu
ECHO %TIME:~0,8% Set the default Start menu >>%logfile_setup%
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "(C:\scripts\PowerShell\Set-DefaultStartMenu.ps1 -ErrorAction Continue)" >>%logfile_setup% 2>&1
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

:ManufacturerSpecificConfigAndSoftwareInstallation
ECHO Manufacturer specific config and software installation
ECHO %TIME:~0,8% Manufacturer specific config and software installation >>%logfile_setup%
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "(C:\install\ManufacturerSpecific.ps1 -ErrorAction Continue)" >>%logfile_setup% 2>&1
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

:ApplyMicrosoftWindows10EnterpriseKey
:: https://docs.microsoft.com/de-de/windows-server/get-started/kmsclientkeys
ECHO Apply Microsoft Windows 10 Enterprise key
ECHO %TIME:~0,8% Apply Microsoft Windows 10 Enterprise key >>%logfile_setup%
"%SystemRoot%\System32\cscript.exe" //nologo c:\windows\system32\slmgr.vbs /ipk NPPR9-FWDCX-D2C8J-H872K-2YT43 >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

:SetTheInternalKMSServerForWindows10
:: For now, this will need VPN
ECHO Set the internal KMS Server for Windows 10
ECHO %TIME:~0,8% Set the internal KMS Server for Windows 10 >>%logfile_setup%
"%SystemRoot%\System32\cscript.exe" //nologo c:\windows\system32\slmgr.vbs /skms kms.enatec.net >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

:: Ping the KMS server for Windows 10 activation
:CheckW10KMSViaPing
ping -n 3 -w 1000 kms.enatec.net >null 2>&1
if %errorlevel% GTR 0 goto ChangeToTheOfficeDirectory

:ActivateWindows10ViaInternalKMSServer
:: For now, this will need VPN
ECHO Activate Windows 10 via internal KMS Server
ECHO %TIME:~0,8% Activate Windows 10 via internal KMS Server >>%logfile_setup%
"%SystemRoot%\System32\cscript.exe" //nologo c:\windows\system32\slmgr.vbs /ato >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

:ChangeToTheOfficeDirectory
ECHO Change to the Office directory
ECHO %TIME:~0,8% Change to the Office directory >>%logfile_setup%
PUSHD "%ProgramFiles%\Microsoft Office\Office16" >nul 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

:ApplyMicrosoftOfficeProfessionalPlus2019Key
ECHO Apply Microsoft Office Professional Plus 2019 key
ECHO %TIME:~0,8% Apply Microsoft Office Professional Plus 2019 key >>%logfile_setup%
"%SystemRoot%\System32\cscript.exe" //nologo ospp.vbs /inpkey:NMMKJ-6RK4F-KMJVX-8D9MJ-6MWKP >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

:: Ping the KMS server for Office activation
:CheckOfficeKMSViaPing
ping -n 3 -w 1000 kms.enatec.net >null 2>&1
if %errorlevel% GTR 0 goto endInternalKMSServer

:SetTheInternalKMSServerForOfficeProducts
ECHO Set the internal KMS Server for Office products
ECHO %TIME:~0,8% Set the internal KMS Server for Office products >>%logfile_setup%
"%SystemRoot%\System32\cscript.exe" //nologo ospp.vbs /sethst:kms.enatec.net >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

:: For now, this will need VPN
:ActivateTheOffice2019ProductsViaTheInternalKMSServer
ECHO Activate Office Professional Plus 2019 via internal KMS Server
ECHO %TIME:~0,8% Activate Office Professional Plus 2019 via internal KMS Server >>%logfile_setup%
"%SystemRoot%\System32\cscript.exe" //nologo ospp.vbs /act >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

:endInternalKMSServer
POPD >nul 2>&1

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

ECHO Set the default Start menu
ECHO %TIME:~0,8% Set the default Start menu >>%logfile_setup%
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "(C:\scripts\PowerShell\Set-DefaultStartMenu.ps1 -ErrorAction Continue)" >>%logfile_setup% 2>&1
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
:: Public Changelog for this Wrapper:
::
:: 1.4.8:  Add CreatePowerShellProfiles part to create empty PowerShell Profiles, if needed -JHO
:: 1.4.7:  Add KMS Ping checks for Windows and Office activation - JHO
:: 1.4.6:  Test Release - ALL
:: 1.4.5:  Change the logging and add errorlevel to all enties - JHO
:: 1.4.4:  Rewrite this Wrapper Batch file to make it more robust - JHO
:: 1.4.3:  Tweak the BitLocker part and add auto upload to AzureAD/Intune - JHO
:: 1.4.2:  Add Storage Sense part - PDU
:: 1.4.1:  Test Release - ALL
:: 1.4.0:  Bugfix Release (Error handling) - PDU
:: 1.3.12: Test Release - ALL
:: 1.3.11: Hardware Vendor handling changed - PDU
:: 1.3.10: Hardware Vendor handling online test - JHO
:: 1.3.9:  Automated Driver installer added - PDU
:: 1.3.8:  WinGet added - JHO
:: 1.3.7:  Test with Windows 10 Enterprise Release 2009 - ALL
:: 1.3.6:  Add the BitLocker part - JHO
:: 1.3.5:  Remove the Office sources after installation - PDU
:: 1.3.4:  Change the Autoupdate handling - PDU
:: 1.3.3:  Remove the WinGet Test - JHO
:: 1.3.2:  Test Release - ALL
:: 1.3.1:  Add a WinGet Test - PDU
:: 1.3.0:  Test Release - ALL
:: 1.2.6:  Removed all Batch Modules - JHO
:: 1.2.5:  Test Release - ALL
:: 1.2.4:  Bugfix for the Modules - JHO
:: 1.2.3:  Test Release - ALL
:: 1.2.2:  Removed AutoPilot automated Upload due to login issues - JHO
:: 1.2.1:  Automated AutoPilot info upload to Intune introduced - JHO
:: 1.2.0:  Rewrite the complete Wrapper: Use Batch Modules - PDU
:: 1.1.3:  Test Release - ALL
:: 1.1.2:  Remove the WiFi Setup - JHO
:: 1.1.1:  Remove the Ping and VPN Test - JHO
:: 1.1.0:  Remove the local Domain login - JHO
:: 1.0.8:  Test Release - ALL
:: 1.0.7:  Rename the Log File (Now the Module Name) - RBU
:: 1.0.6:  Change the Log format (Add Time Stamps) - RDU
:: 1.0.5:  Change Naming convention (Removed here, no in the Provisioning package) - JHO
:: 1.0.4:  Test Release - ALL
:: 1.0.3:  Add Intune/AzureAD Provisioning package - JHO
:: 1.0.2:  Test Release - ALL
:: 1.0.1:  Hardcoded AutoPilot Info added - JHO
:: 1.0.0:  Changed to this Wrapper - JHO
:: Older:  Internal test Releases - ALL
::
:: Changes for the scripts should be documented in the scripts file itself.
::
:: ********************************************************************************************************************
::
:: Public ETPOSD To-Do:
::
:: - Fix the PowerShell scripts (errorlevel return)
:: - Tweak the Output of the PowerShell Scripts
:: - Fix NuGet Explorer Shortcut (Choco DEV packages)
:: - Change some of the used PowerShell Scripts
:: - Move the Provisioning Package (In the root now)
:: - Fix Error during HKU handling (Permission)
::
:: ********************************************************************************************************************
::
:: Public ETPOSD Backlog:
::
:: - Auto upload AutoPilot info to the Microsoft 365 tenant
:: - Cleanup Autostart
:: - Add Sysinfo Shortcut
:: - Add Sysinfo to Autostart
:: - Release the Build script on the public GitHub repository
:: - Remove the hardcoded values from all scripts and move them to a central config file
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
