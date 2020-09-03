@echo off

rem Part of the enabling Technology Windows 10 Jumpstart installation

rem Show Splash Screen
start /LOW /MAX "Installation is running, please wait" c:\tools\enaTec_Installer.exe

rem Bootstrap the User
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "C:\scripts\PowerShell\Invoke-BootstrapUser.ps1"

rem Bootstrap the All User Profile
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "C:\scripts\PowerShell\Invoke-BootstrapAllUserProfile.ps1"

rem Update all Microsoft Store Apps
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "C:\scripts\PowerShell\Update-AllMicrosoftStoreApps.ps1"

rem Install the Microsoft Office Suite
@echo Install the Microsoft Office Suite
@pushd c:\install\Office\
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Disabled -Force -ErrorAction SilentlyContinue)"
@C:\Windows\SysWOW64/OneDriveSetup.exe /update /restart /force
@C:\install\Office\setup.exe /configure c:\install\Office\Configuration.xml
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction SilentlyContinue)"
@popd

rem # Clean up after the setup is done
if exist c:\install\Office\ rd /s /q c:\install\Office\

rem Install some HP Tools
rem @call "%CD%hp\hpsetup.cmd"

rem Configure Microsoft Defender
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "C:\scripts\PowerShell\Optimize-MicrosoftDefenderExclusions.ps1"

rem Install some PowerShell Modules
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "C:\scripts\PowerShell\Install-PowerShellModules_required.ps1"

rem Update all help files for all installed PowerShell Modules
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "C:\scripts\PowerShell\Update-PowerShellModulesHelp.ps1"

rem Install Choco packages
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "c:\scripts\PowerShell\Install-ChocoPackages_vcredist.ps1"

rem Install Choco packages
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "c:\scripts\PowerShell\Install-ChocoPackages_dotnet.ps1"

rem Install Choco packages
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "c:\scripts\PowerShell\Install-ChocoPackages.ps1"

rem Install Choco packages
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "c:\scripts\PowerShell\Install-ChocoPackages_Workstation.ps1"

rem Desktop Cleanup
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "C:\scripts\PowerShell\Remove-AllPublicDesktopLinks.ps1"

rem Apply all pending microsoft updates
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "C:\scripts\PowerShell\Install-AllMissingMicrosoftUpdates.ps1"

rem Initiate a restart
SHUTDOWN -r -t 5

rem Go away
cd /

rem Close the Splash Screen
%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Get-Process -ErrorAction SilentlyContinue -WarningAction SilentlyContinue | Where-Object {$_.name -like '*enaTec_Installer*'} | Stop-Process -Force -Confirm:$false -ErrorAction SilentlyContinue -WarningAction SilentlyContinue)"

rem Clean up after the setup is done
if exist c:\tools\enaTec_Installer.* rd /s /q c:\tools\enaTec_Installer.*
if exist c:\install rd /s /q c:\install
