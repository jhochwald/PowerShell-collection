title LenovoSpecific
set Module=LenovoSpecific
echo start %Module% %time% =================== >>%logfile_setup%

rem install Lenovo System Update for Windows
echo system_update_5.07.0106.exe /VERYSILENT /SUPPRESSMSGBOXES /LOG='c:\temp\LenovoSysupdate.log' /NOCANCEL /NORESTART /CLOSEAPPLICATIONS /NORESTARTAPPLICATIONS >>%logfile_setup%
@system_update_5.07.0106.exe /VERYSILENT /SUPPRESSMSGBOXES /LOG='c:\temp\LenovoSysupdate.log' /NOCANCEL /NORESTART /CLOSEAPPLICATIONS /NORESTARTAPPLICATIONS >>%logfile_setup%

echo stop %Module% %time% =================== >>%logfile_setup%
echo.>>%logfile_setup%
