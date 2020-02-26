@echo off

rem Label
label.exe c: 'Boot'

rem execute the initial setup script
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "./Invoke_first.ps1"

rem Remove some Stock Apps
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "C:\scripts\PowerShell\Cleanup_StockApps.ps1"

rem Bootstrap the System
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "C:\scripts\PowerShell\Invoke-BootstrapSystem.ps1"
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "C:\scripts\PowerShell\Invoke-BootstrapUser.ps1"

rem Get the latest time
W32tm /resync /force

rem Install some HP Tools
rem @"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "C:\scripts\PowerShell\Install-WrapperForHPTools.ps1"

rem Allow Pings and enable RDP
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "C:\scripts\PowerShell\Set-AllowPingAndRemoteDesktop.ps1"

rem Configure Microsoft Defender
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "C:\scripts\PowerShell\Optimize-MicrosoftDefenderExclusions.ps1"

rem Install some PowerShell Modules
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "C:\scripts\PowerShell\Install-PowerShellModules_required.ps1"

rem Install Choco packages
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "c:\scripts\PowerShell\Install-ChocoPackages_vcredist.ps1"

rem Install Choco packages
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "c:\scripts\PowerShell\Install-ChocoPackages_dotnet.ps1"

rem Install Choco packages
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "c:\scripts\PowerShell\Install-ChocoPackages.ps1"

rem Desktop Cleanup
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "C:\scripts\PowerShell\Remove-AllPublicDesktopLinks.ps1"

rem Apply all pending microsoft updates
rem @"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "C:\scripts\PowerShell\Install-AllMissingMicrosoftUpdates.ps1"

rem Restart
rem 
SHUTDOWN -r -t 10