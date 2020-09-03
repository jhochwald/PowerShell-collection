@echo off

rem Part of the enabling Technology Windows 10 Jumpstart installation

title FinalTweaks
set Module=FinalTweaks
echo start %Module% %time% =================== >>%logfile_setup%

echo attrib +A -R -S -H c:\scripts >>%logfile_setup%
attrib +A -R -S -H c:\scripts >>%logfile_setup%
echo %Module% "Errorlevel=%Errorlevel% ">>%logfile_setup%

echo attrib +A -R -S -H c:\scripts\PowerShell >>%logfile_setup%
attrib +A -R -S -H c:\scripts\PowerShell >>%logfile_setup%
echo %Module% "Errorlevel=%Errorlevel% ">>%logfile_setup%

echo attrib +A -R -S -H c:\scripts\Batch >>%logfile_setup%
attrib +A -R -S -H c:\scripts\Batch >>%logfile_setup%
echo %Module% "Errorlevel=%Errorlevel% ">>%logfile_setup%

echo attrib +A -R -S -H c:\scripts\Install /S /D >>%logfile_setup%
attrib +A -R -S -H c:\scripts\Install /S /D >>%logfile_setup%
echo %Module% "Errorlevel=%Errorlevel% ">>%logfile_setup%

echo attrib +A -R -S -H c:\scripts\Temp /S /D >>%logfile_setup%
attrib +A -R -S -H c:\scripts\Temp /S /D >>%logfile_setup%
echo %Module% "Errorlevel=%Errorlevel% ">>%logfile_setup%

echo attrib +A -R -S -H c:\scripts\powershell\*.* /S /D >>%logfile_setup%
attrib +A -R -S -H c:\scripts\powershell\*.* /S /D >>%logfile_setup%
echo %Module% "Errorlevel=%Errorlevel% ">>%logfile_setup%

echo attrib +A -R -S -H c:\scripts\Batch\*.* /S /D >>%logfile_setup%
attrib +A -R -S -H c:\scripts\Batch\*.* /S /D >>%logfile_setup%
echo %Module% "Errorlevel=%Errorlevel% ">>%logfile_setup%

echo attrib +A -R -S -H c:\tools\*.* /S /D >>%logfile_setup%
attrib +A -R -S -H c:\tools\*.* /S /D >>%logfile_setup%
echo %Module% "Errorlevel=%Errorlevel% ">>%logfile_setup%

echo attrib +A -R -S -H c:\Install\*.* /S /D >>%logfile_setup%
attrib +A -R -S -H c:\Install\*.* /S /D >>%logfile_setup%
echo %Module% "Errorlevel=%Errorlevel% ">>%logfile_setup%

echo attrib +A -R -S -H c:\Temp\*.* /S /D >>%logfile_setup%
attrib +A -R -S -H c:\Temp\*.* /S /D >>%logfile_setup%
echo %Module% "Errorlevel=%Errorlevel% ">>%logfile_setup%

echo stop %Module% %time% =================== >>%logfile_setup%
echo.>>%logfile_setup%
