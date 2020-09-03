@echo off

rem Part of the enabling Technology Windows 10 Jumpstart installation

title Basic
set Module=Basic
echo start %Module% %time% =================== >>%logfile_setup%

rem Control Panel Classic View
echo reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" /v StartupPage /t REG_DWORD /d 1 /f >>%logfile_setup%
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" /v StartupPage /t REG_DWORD /d 1 /f >>%logfile_setup%
echo %Module% "Errorlevel=%Errorlevel% " >>%logfile_setup%

rem Control Panel Icon Size
echo reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" /v AllItemsIconView /t REG_DWORD /d 1 /f >>%logfile_setup%
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" /v AllItemsIconView /t REG_DWORD /d 1 /f >>%logfile_setup%
echo %Module% "Errorlevel=%Errorlevel% " >>%logfile_setup%

rem Disable the network discovery prompt window
echo reg add "HKLM\System\CurrentControlSet\Control\Network\NewNetworkWindowOff" >>%logfile_setup%
reg add "HKLM\System\CurrentControlSet\Control\Network\NewNetworkWindowOff" >>%logfile_setup%
echo %Module% "Errorlevel=%Errorlevel% " >>%logfile_setup%

rem No Background Image at the Logon Page
echo reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\System" /v DisableLogonBackgroundImage /t REG_DWORD /d 1 /f >>%logfile_setup%
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\System" /v DisableLogonBackgroundImage /t REG_DWORD /d 1 /f >>%logfile_setup%
echo %Module% "Errorlevel=%Errorlevel% " >>%logfile_setup%

rem Increase Taskbar Transparency Level
echo reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v UseOLEDTaskbarTransparency /t REG_DWORD /d 1 /f >>%logfile_setup%
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v UseOLEDTaskbarTransparency /t REG_DWORD /d 1 /f >>%logfile_setup%
echo %Module% "Errorlevel=%Errorlevel% " >>%logfile_setup%

rem Quick Shutdown
echo reg add "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control" /v WaitToKillServiceTimeout /t REG_SZ /d 1000 /f >>%logfile_setup%
reg add "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control" /v WaitToKillServiceTimeout /t REG_SZ /d 1000 /f >>%logfile_setup%
echo %Module% "Errorlevel=%Errorlevel% " >>%logfile_setup%

echo reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control" /v WaitToKillServiceTimeout /t REG_SZ /d 1000 /f >>%logfile_setup%
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control" /v WaitToKillServiceTimeout /t REG_SZ /d 1000 /f >>%logfile_setup%
echo %Module% "Errorlevel=%Errorlevel% " >>%logfile_setup%

rem Disable First Time Sign-in Animation
echo reg add "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableFirstLogonAnimation /t REG_DWORD /d 0 /f >>%logfile_setup%
reg add "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableFirstLogonAnimation /t REG_DWORD /d 0 /f >>%logfile_setup%
echo %Module% "Errorlevel=%Errorlevel% " >>%logfile_setup%

rem Disable the Lock Screen
echo reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Personalization" /v NoLockScreen /t REG_DWORD /d 1 /f >>%logfile_setup%
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Personalization" /v NoLockScreen /t REG_DWORD /d 1 /f >>%logfile_setup%
echo %Module% "Errorlevel=%Errorlevel% " >>%logfile_setup%

rem Turn off Fast Startup
echo reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v HiberbootEnabled /t REG_DWORD /d 0 /f >>%logfile_setup%
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v HiberbootEnabled /t REG_DWORD /d 0 /f >>%logfile_setup%
echo %Module% "Errorlevel=%Errorlevel% " >>%logfile_setup%

rem Disable Privacy Settings Experience at Sign-in
echo reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\OOBE" /v DisablePrivacyExperience /t REG_DWORD /d 1 /f >>%logfile_setup%
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\OOBE" /v DisablePrivacyExperience /t REG_DWORD /d 1 /f >>%logfile_setup%
echo %Module% "Errorlevel=%Errorlevel% " >>%logfile_setup%

rem Disable Telemetry
echo reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f >>%logfile_setup%
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f >>%logfile_setup%
echo %Module% "Errorlevel=%Errorlevel% " >>%logfile_setup%

rem Allow Windows Updates for other products (e.g. Microsoft Office)
echo reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\WindowsUpdate\Services\7971f918-a847-4430-9279-4a52d1efe18d" /v RegisteredWithAU /t REG_DWORD /d 1 /f >>%logfile_setup%
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\WindowsUpdate\Services\7971f918-a847-4430-9279-4a52d1efe18d" /v RegisteredWithAU /t REG_DWORD /d 1 /f >>%logfile_setup%
echo %Module% "Errorlevel=%Errorlevel% " >>%logfile_setup%

rem Unnecessarily writing on SSD will shorten the lifetime
echo reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\FileSystem" /v NtfsDisableLastAccessUpdate /t REG_DWORD /d 80000001 /f >>%logfile_setup%
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\FileSystem" /v NtfsDisableLastAccessUpdate /t REG_DWORD /d 80000001 /f >>%logfile_setup%
echo %Module% "Errorlevel=%Errorlevel% " >>%logfile_setup%

echo reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v NoAutoplayfornonVolume /t REG_DWORD /d 1 /f >>%logfile_setup%
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v NoAutoplayfornonVolume /t REG_DWORD /d 1 /f >>%logfile_setup%
echo %Module% "Errorlevel=%Errorlevel% " >>%logfile_setup%

rem Display detailed information in Device Manager
echo reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v "DEVMGR_SHOW_DETAILS" /t REG_DWORD /d 1 /f >>%logfile_setup%
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v "DEVMGR_SHOW_DETAILS" /t REG_DWORD /d 1 /f >>%logfile_setup%
echo %Module% "Errorlevel=%Errorlevel% " >>%logfile_setup%

rem Disable Cortana Search bar
echo reg.exe ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v SearchboxTaskbarMode /t REG_DWORD /d 0 >>%logfile_setup%
reg.exe ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v SearchboxTaskbarMode /t REG_DWORD /d 0 >>%logfile_setup%
echo %Module% "Errorlevel=%Errorlevel% " >>%logfile_setup%

rem Password of the Installation Admin never expires
echo start /wait "Tweak Admin User" %SystemRoot%\system32\wbem\wmic.exe useraccount where name="locadmin" set PasswordExpires=false >>%logfile_setup%
start /wait "Tweak Admin User" %SystemRoot%\system32\wbem\wmic.exe useraccount where name="locadmin" set PasswordExpires=false >>%logfile_setup%
echo %Module% "Errorlevel=%Errorlevel% " >>%logfile_setup%

echo stop %Module% %time% =================== >>%logfile_setup%
echo.>>%logfile_setup%
