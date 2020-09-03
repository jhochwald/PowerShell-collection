@echo off

rem Part of the enabling Technology Windows 10 Jumpstart installation

title AllPublicDesktopLinks
set Module=AllPublicDesktopLinks
echo start %Module% %time% =================== >>%logfile_setup%

echo start /MIN /WAIT "AllPublicDesktopLinks" %SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "C:\scripts\PowerShell\Remove-AllPublicDesktopLinks.ps1" >>%logfile_setup%
start /MIN /WAIT "AllPublicDesktopLinks" %SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "C:\scripts\PowerShell\Remove-AllPublicDesktopLinks.ps1" >>%logfile_setup%
echo %Module% "Errorlevel=%Errorlevel% ">>%logfile_setup%

echo stop %Module% %time% =================== >>%logfile_setup%
echo.>>%logfile_setup%
