@echo off

rem Part of the enabling Technology Windows 10 Jumpstart installation

title PowerCFG
set Module=PowerCFG
echo start %Module% %time% ===================>>%logfile_setup%

echo start /MIN /WAIT "Set Power Config profile" %SystemRoot%\system32\powercfg.exe -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c >>%logfile_setup%
start /MIN /WAIT "Set Power Config profile" %SystemRoot%\system32\powercfg.exe -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c >>%logfile_setup%
echo %Module% "Errorlevel=%Errorlevel% ">>%logfile_setup%

echo start /MIN /WAIT "Change monitor timeout" %SystemRoot%\system32\powercfg.exe -Change -monitor-timeout-ac 10 >>%logfile_setup%
start /MIN /WAIT "Change monitor timeout" %SystemRoot%\system32\powercfg.exe -Change -monitor-timeout-ac 10 >>%logfile_setup%
echo %Module% "Errorlevel=%Errorlevel% ">>%logfile_setup%

echo stop %Module% %time% ===================>>%logfile_setup%
echo.>>%logfile_setup%
