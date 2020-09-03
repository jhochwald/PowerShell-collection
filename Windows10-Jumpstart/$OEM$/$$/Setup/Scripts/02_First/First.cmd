@echo off

rem Part of the enabling Technology Windows 10 Jumpstart installation

title First
set Module=First
echo start %Module% %time% =================== >>%logfile_setup%

rem Enable Remote PowerShell
echo start /MIN /WAIT "Enable Remote PowerShell" %SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "Enable-PSRemoting -Force -ErrorAction Continue" >>%logfile_setup%
start /MIN /WAIT "Enable Remote PowerShell" %SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "Enable-PSRemoting -Force -ErrorAction Continue" >>%logfile_setup%
echo %Module% "Errorlevel=%Errorlevel% " >>%logfile_setup%

rem Installing Chocolatey
echo start /MIN /WAIT "Installing Chocolatey" %SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "([Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072);(Invoke-Expression -Command ((New-Object -TypeName System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')))" >>%logfile_setup%
start /MIN /WAIT "Installing Chocolatey" %SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "([Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072);(Invoke-Expression -Command ((New-Object -TypeName System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')))" >>%logfile_setup%
echo %Module% "Errorlevel=%Errorlevel% " >>%logfile_setup%

rem Add NuGet Package Source
echo start /MIN /WAIT "Add NuGet Package Source" %SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "(Install-PackageProvider -Name NuGet -Force -ErrorAction Continue)" >>%logfile_setup%
start /MIN /WAIT "Add NuGet Package Source" %SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "(Install-PackageProvider -Name NuGet -Force -ErrorAction Continue)" >>%logfile_setup%
echo %Module% "Errorlevel=%Errorlevel% " >>%logfile_setup%

rem Register Nuget Repository
echo start /MIN /WAIT"Register Nuget Repository" %SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "(Register-PackageSource -Name Nuget -Location 'http://www.nuget.org/api/v2' -ProviderName Nuget -Trusted -ErrorAction Continue)" >>%logfile_setup%
start /MIN /WAIT"Register Nuget Repository" %SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "(Register-PackageSource -Name Nuget -Location 'http://www.nuget.org/api/v2' -ProviderName Nuget -Trusted -ErrorAction Continue)" >>%logfile_setup%
echo %Module% "Errorlevel=%Errorlevel% " >>%logfile_setup%

rem Configures Windows Remote Management (WinRM)
echo start /MIN /WAIT "Configures Windows Remote Management (WinRM)" cmd /c winrm quickconfig -force -quiet >>%logfile_setup%
start /MIN /WAIT "Configures Windows Remote Management (WinRM)" cmd /c winrm quickconfig -force -quiet >>%logfile_setup%
echo %Module% "Errorlevel=%Errorlevel% " >>%logfile_setup%

rem Allow Basic authentication Windows Remote Management (WinRM)
echo start /MIN /WAIT "Allow Basic authentication Windows Remote Management (WinRM)" cmd /c winrm set winrm/config/client/auth @{Basic="true"} >>%logfile_setup%
start /MIN /WAIT "Allow Basic authentication Windows Remote Management (WinRM)" cmd /c winrm set winrm/config/client/auth @{Basic="true"} >>%logfile_setup%
echo %Module% "Errorlevel=%Errorlevel% " >>%logfile_setup%

echo stop %Module% %time% =================== >>%logfile_setup%
echo.>>%logfile_setup%
