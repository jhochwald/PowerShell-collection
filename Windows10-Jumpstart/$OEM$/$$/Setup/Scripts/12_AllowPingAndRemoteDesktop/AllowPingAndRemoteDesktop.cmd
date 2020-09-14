title AllowPingAndRemoteDesktop
set Module=AllowPingAndRemoteDesktop
echo start %Module% %time% =================== >>%logfile_setup%

echo start /MIN /WAIT  "AllowPingAndRemoteDesktop" %SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "C:\scripts\PowerShell\Set-AllowPingAndRemoteDesktop.ps1" >>%logfile_setup%
start /MIN /WAIT  "AllowPingAndRemoteDesktop" %SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "C:\scripts\PowerShell\Set-AllowPingAndRemoteDesktop.ps1" >>%logfile_setup%
echo %Module% "Errorlevel=%Errorlevel% ">>%logfile_setup%

echo stop %Module% %time% =================== >>%logfile_setup%
echo.>>%logfile_setup%
