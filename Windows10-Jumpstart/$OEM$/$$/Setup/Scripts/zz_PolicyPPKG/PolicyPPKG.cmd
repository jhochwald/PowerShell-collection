title PolicyPPKG
set Module=PolicyPPKG
echo start %Module% %time% =================== >>%logfile_setup%

echo start /MIN /WAIT "Apply windows 10 provisioning package" %SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ".\PolicyPPKG.ps1" >>%logfile_setup%
start /MIN /WAIT "Apply windows 10 provisioning package" %SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ".\PolicyPPKG.ps1" >>%logfile_setup%
echo %Module% "Errorlevel=%Errorlevel% ">>%logfile_setup%

echo stop %Module% %time% =================== >>%logfile_setup%
echo.>>%logfile_setup%
