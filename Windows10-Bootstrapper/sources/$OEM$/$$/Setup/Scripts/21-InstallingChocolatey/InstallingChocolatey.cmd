@ECHO OFF

:: ********************************************************************************************************************
::
:: enabling Technology progressive OS deployment
:: Client System Bootstrapper for Windows 10 Enterprise Installations
::
:: Installing Chocolatey
:: Version 1.0.2
::
:: Tested with Windows 10 Enterprise Release 2004 and Release 2009
::
:: Please review all the scripts BEFORE you install it on any of your systems.
:: This installation/configuration is customized to our internal requirements and might not fit for everyone!
::
:: ********************************************************************************************************************

SETLOCAL

:InstallingChocolatey
TITLE InstallingChocolatey
SET Module=InstallingChocolatey
SET logfile_setup=%HOMEDRIVE%\Temp\%Module%.txt

:SetLogHeader
ECHO ******************************************************************************** >%logfile_setup%
ECHO Started %Module% on %DATE:~0% - %TIME:~0,8%
ECHO For %COMPUTERNAME% by %USERDOMAIN%\%USERNAME% >>%logfile_setup%

ECHO.>>%logfile_setup% 2>nul

:LOGIC
ECHO Installing Chocolatey
ECHO %TIME:~0,8% Installing Chocolatey >>%logfile_setup%
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "(C:\scripts\PowerShell\Install-Choco.ps1 -ErrorAction Continue)" >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

ECHO.>>%logfile_setup% 2>nul

ECHO Finished %Module% on %DATE:~0% - %TIME:~0,8%
ECHO ******************************************************************************** >>%logfile_setup%
ECHO.>>%logfile_setup% 2>nul


:: ********************************************************************************************************************
::
:: Changelog:
::
:: 0.9.0: Internal Test
:: 1.0.0: Initial Release
:: 1.0.1: Fix Typo
:: 1.0.2: Moved the installation to a dedicated PowerShell Script
::
:: ********************************************************************************************************************
::
:: License: BSD 3-Clause License
::
:: Copyright 2020, enabling Technology
:: All rights reserved.
::
:: Redistribution and use in source and binary forms, with or without modification, are permitted provided that the
:: following conditions are met:
:: 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following
::    disclaimer.
:: 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the
::    following disclaimer in the documentation and/or other materials provided with the distribution.
:: 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote
::    products derived from this software without specific prior written permission.
::
:: THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
:: INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
:: DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
:: SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
:: SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
:: WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
:: USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
::
:: ********************************************************************************************************************
::
:: Disclaimer:
:: - Use at your own risk, etc.
:: - This is open-source software, if you find an issue try to fix it yourself. There is no support and/or warranty
::   in any kind
:: - This is a third-party Software
:: - The developer of this Software is NOT sponsored by or affiliated with Microsoft Corp (MSFT) or any of its
::   subsidiaries in any way
:: - The Software is not supported by Microsoft Corp (MSFT)
:: - By using the Software, you agree to the License, Terms, and any Conditions declared and described above
:: - If you disagree with any of the Terms, and any Conditions declared: Just delete it and build your own solution
::
:: ********************************************************************************************************************
