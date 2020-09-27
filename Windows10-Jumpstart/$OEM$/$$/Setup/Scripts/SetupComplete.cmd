@echo off

set logfile_setup=%HOMEDRIVE%\Temp\SETUPCOMPLETE.txt

rem Change some attributes of the Scripts directory
attrib +A -R -S -H %windir%\setup\SCRIPTS\*.* /S /D

rem Show Splash Screen
start /LOW /MAX "Installation is running, please wait" c:\tools\enaTec_Installer.exe

rem # Start any existing CMD file (including subfolders
cd %systemroot%\setup\SCRIPTS
for /D %%f in (*) do (
	pushd %%f
	rem for %%g in (*.cmd) do call %%g
	popd
)

rem Close the Splash Screen
%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (Get-Process -ErrorAction SilentlyContinue -WarningAction SilentlyContinue | Where-Object {$_.name -like '*enaTec_Installer*'} | Stop-Process -Force -Confirm:$false -ErrorAction SilentlyContinue -WarningAction SilentlyContinue)"

rem # Clean up after the setup is done
if exist %systemroot%\setup\SCRIPTS\done rd /s /q %systemroot%\setup\SCRIPTS >nul 2>&1
