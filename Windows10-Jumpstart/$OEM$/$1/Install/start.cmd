@echo off

rem Show Splash Screen
@start /LOW /MAX "Installation is running, please wait" c:\tools\enaTec_Installer.exe >nul 2>&1

rem Pause the Indexer
@sc stop wsearch >nul 2>&1


@echo "Bootstrap the User"
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Disabled -Force -ErrorAction SilentlyContinue)"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (C:\scripts\PowerShell\Invoke-BootstrapUser.ps1)"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction SilentlyContinue)"

rem Pause the Indexer
@sc stop wsearch >nul 2>&1


@echo "Bootstrap the All User Profile"
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Disabled -Force -ErrorAction SilentlyContinue)"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (C:\scripts\PowerShell\Invoke-BootstrapAllUserProfile.ps1)"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction SilentlyContinue)"

rem Pause the Indexer
@sc stop wsearch >nul 2>&1


@echo "Update all Microsoft Store Apps"
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Disabled -Force -ErrorAction SilentlyContinue)"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (C:\scripts\PowerShell\Update-AllMicrosoftStoreApps.ps1)"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction SilentlyContinue)"

rem Pause the Indexer
@sc stop wsearch >nul 2>&1


rem Install the Microsoft Office Suite
@pushd c:\install\Office\

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Disabled -Force -ErrorAction SilentlyContinue)"

@echo "Set OneDrive to get Insider builds"
@reg.exe add HKCU\Software\Microsoft\OneDrive /v EnableTeamTier_Internal /t REG_DWORD /d 1 /f >nul 2>&1

@echo "Force OneDrive to update and restart"
@C:\Windows\SysWOW64/OneDriveSetup.exe /update /restart /force >nul 2>&1

@echo "Install our default office deployment"
@C:\install\Office\setup.exe /configure c:\install\Office\Configuration.xml >nul 2>&1

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction SilentlyContinue)"

@popd

rem Pause the Indexer
@sc stop wsearch >nul 2>&1

@echo "Clean up after the office setup is done"
@if exist c:\install\Office\ @rd /s /q c:\install\Office\ >nul 2>&1

rem Pause the Indexer
@sc stop wsearch >nul 2>&1

rem Microsoft Teams related
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Disabled -Force -ErrorAction SilentlyContinue)"

@echo "Download and install latest version of Microsoft Teams"
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (C:\scripts\PowerShell\Install-LatestTeamsClient.ps1)"

@echo "Enable QoS for Microsoft Teams"
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (C:\scripts\PowerShell\Set-QoSForMicrosoftTeams.ps1)"

@echo "Tweak the Firewall for Microsoft Teams"
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (C:\scripts\PowerShell\Invoke-TweakTeamsClientFirewall.ps1)"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction SilentlyContinue)"

rem Pause the Indexer
@sc stop wsearch >nul 2>&1


@echo "Configure Microsoft Defender"
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Disabled -Force -ErrorAction SilentlyContinue)"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (C:\scripts\PowerShell\Optimize-MicrosoftDefenderExclusions.ps1)"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction SilentlyContinue)"

rem Pause the Indexer
@sc stop wsearch >nul 2>&1


@echo "Install some PowerShell Modules"
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Disabled -Force -ErrorAction SilentlyContinue)"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (C:\scripts\PowerShell\Install-PowerShellModules_required.ps1)"
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction SilentlyContinue)"

rem Pause the Indexer
@sc stop wsearch >nul 2>&1


@echo "Update help files for all installed PowerShell Modules"
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Disabled -Force -ErrorAction SilentlyContinue)"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (C:\scripts\PowerShell\Update-PowerShellModulesHelp.ps1)"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction SilentlyContinue)"

rem Pause the Indexer
@sc stop wsearch >nul 2>&1


@echo "Install some VC Redistributable Choco packages"
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Disabled -Force -ErrorAction SilentlyContinue)"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (c:\scripts\PowerShell\Install-ChocoPackages_vcredist.ps1)"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction SilentlyContinue)"

rem Pause the Indexer
@sc stop wsearch >nul 2>&1


@echo "Install default .NET Choco packages"
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Disabled -Force -ErrorAction SilentlyContinue)"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (c:\scripts\PowerShell\Install-ChocoPackages_dotnet.ps1)"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction SilentlyContinue)"

rem Pause the Indexer
@sc stop wsearch >nul 2>&1


@echo "Install Choco default packages"
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Disabled -Force -ErrorAction SilentlyContinue)"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (c:\scripts\PowerShell\Install-ChocoPackages.ps1)"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction SilentlyContinue)"

rem Pause the Indexer
@sc stop wsearch >nul 2>&1


@echo "Install Choco Workstation packages"
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Disabled -Force -ErrorAction SilentlyContinue)"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (c:\scripts\PowerShell\Install-ChocoPackages_Workstation.ps1)"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction SilentlyContinue)"

rem Pause the Indexer
@sc stop wsearch >nul 2>&1


@echo "Desktop Cleanup"
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Disabled -Force -ErrorAction SilentlyContinue)"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (C:\scripts\PowerShell\Remove-AllPublicDesktopLinks.ps1)"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction SilentlyContinue)"

rem Pause the Indexer
@sc stop wsearch >nul 2>&1


@echo "Apply all pending Microsoft updates"
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Disabled -Force -ErrorAction SilentlyContinue)"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (C:\scripts\PowerShell\Install-AllMissingMicrosoftUpdates.ps1)"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction SilentlyContinue)"

rem Pause the Indexer
@sc stop wsearch >nul 2>&1


@echo "Initiate a restart"
@SHUTDOWN -r -t 5 >nul 2>&1


rem Go away
@cd /


rem Close the Splash Screen
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Get-Process -ErrorAction SilentlyContinue -WarningAction SilentlyContinue | Where-Object {$_.name -like '*enaTec_Installer*'} | Stop-Process -Force -Confirm:$false -ErrorAction SilentlyContinue -WarningAction SilentlyContinue)"

rem Pause the Indexer
@sc stop wsearch >nul 2>&1


@echo "Clean up after the basic setup is done"
@if exist c:\tools\enaTec_Installer.* rd /s /q c:\tools\enaTec_Installer.* >nul 2>&1
@if exist c:\install rd /s /q c:\install >nul 2>&1

rem Pause the Indexer
@sc stop wsearch >nul 2>&1
