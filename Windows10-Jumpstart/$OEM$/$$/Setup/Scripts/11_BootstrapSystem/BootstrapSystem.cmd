title BootstrapSystem
set Module=BootstrapSystem
echo start %Module% %time% =================== >>%logfile_setup%

echo start /MIN /WAIT "BootstrapSystem" %SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (C:\scripts\PowerShell\Invoke-BootstrapSystem.ps1)" >>%logfile_setup%
start /MIN /WAIT "BootstrapSystem" %SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (C:\scripts\PowerShell\Invoke-BootstrapSystem.ps1)" >>%logfile_setup%
echo %Module% "Errorlevel=%Errorlevel% ">>%logfile_setup%

echo start /MIN /WAIT "Sync Clock" %SystemRoot%\System32\w32tm.exe /resync /force >>%logfile_setup%
start /MIN /WAIT "Sync Clock" %SystemRoot%\System32\w32tm.exe /resync /force >>%logfile_setup%
echo %Module% "Errorlevel=%Errorlevel% ">>%logfile_setup%

echo stop %Module% %time% =================== >>%logfile_setup%
echo.>>%logfile_setup%
