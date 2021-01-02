@ECHO OFF

:: ********************************************************************************************************************
::
:: enabling Technology progressive OS deployment
:: Client System Bootstrapper for Windows 10 Enterprise Installations
::
:: Change Handling and tweaks Windows Remote Management (WinRM) - PLEASE READ THE NOTE BELOW
:: Version 1.0.0
::
:: Tested with Windows 10 Enterprise Release 2004 and Release 2009
::
:: PLEASE NOTE THIS: This can become a security issue! <- <- <-
::
:: This script makes Windows Remote Management (WinRM) insecure!!!
:: We do this by purpose, we will reconfigure it later with an Intune Poliy.
:: We use it to administer the system within the local network, and this makes
:: it much easier to use Mac's or Linux systems to connect to this system.
::
:: It will be skipped if outside of the enabling Technology network (or use VPN).
::
:: Please review all the scripts BEFORE you install it on any of your systems.
:: This installation/configuration is customized to our internal requirements and might not fit for everyone!
::
:: ********************************************************************************************************************

SETLOCAL

:WinRMTwaeks
TITLE WinRMTwaeks
SET Module=WinRMTwaeks
SET logfile_setup=%HOMEDRIVE%\Temp\%Module%.txt

:SetLogHeader
ECHO ******************************************************************************** >%logfile_setup%
ECHO Started %Module% on %DATE:~0% - %TIME:~0,8%
ECHO For %COMPUTERNAME% by %USERDOMAIN%\%USERNAME% >>%logfile_setup%

ECHO.>>%logfile_setup% 2>nul

:LOGIC
: Use GHOST to figure out, if this system is connected directly to our Intranet
ping -n 3 -w 1000 ghost.enatec.net >null 2>&1
if %errorlevel% GTR 0 goto NotConnected

:EnableWindowsScriptHost
ECHO Turn on Windows Script Host
ECHO %TIME:~0,8% Turn on Windows Script Host >>%logfile_setup%
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (New-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows Script Host\Settings' -Name Enabled -PropertyType DWord -Value 1 -Force -ErrorAction Continue)" >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul

: Enable Remote PowerShell
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "Enable-PSRemoting -Force -ErrorAction Continue"

: Quick default configuration for Windows Remote Management (WinRM)
C:\Windows\system32\winrm.cmd quickconfig -q >null 2>&1

: Specifies the transport to use to send and receive WS-Management
: protocol requests and responses.
: The value must be either HTTP or HTTPS
C:\Windows\system32\winrm.cmd quickconfig -transport:http >null 2>&1

: Specifies the maximum time-out, in milliseconds,
: that can be used for any request other than Pull requests
: The default is 60000
C:\Windows\system32\winrm.cmd set winrm/config '@{MaxTimeoutms="1800000"}' >null 2>&1

: Specifies the maximum amount of memory allocated per shell,
: including the shell's child processes.
: The default is 150 MB
C:\Windows\system32\winrm.cmd set winrm/config/winrs '@{MaxMemoryPerShellMB="800"}' >null 2>&1

: Allows the client computer to request unencrypted traffic.
: By default, the client computer requires encrypted network traffic
: and this setting is False.
C:\Windows\system32\winrm.cmd set winrm/config/service '@{AllowUnencrypted="true"}' >null 2>&1

: Allows the client computer to use Basic authentication.
: Basic authentication is a scheme in which the user name and password
: are sent in clear text to the server or proxy.
: This method is the least secure method of authentication.
: The default is True.
C:\Windows\system32\winrm.cmd set winrm/config/service/auth '@{Basic="true"}' >null 2>&1

: Allows the client computer to use Basic authentication.
: Basic authentication is a scheme in which the user name and password
: are sent in clear text to the server or proxy.
: This method is the least secure method of authentication.
: The default is True.
C:\Windows\system32\winrm.cmd set winrm/config/client/auth '@{Basic="true"}' >null 2>&1

: Allows the client to use Credential Security Support Provider (CredSSP) authentication.
: CredSSP enables an application to delegate the user's credentials
: from the client computer to the target server.
: The default is False.
C:\Windows\system32\winrm.cmd set winrm/config/service/auth '@{CredSSP="true"}' >null 2>&1

: Specifies the TCP port for which this listener is created.
: WinRM 2.0: The default HTTP port is 5985.
C:\Windows\system32\winrm.cmd set winrm/config/listener?Address=*+Transport=HTTP '@{Port="5985"}' >null 2>&1

: Allow the Windows Remote Administration Rule Group
C:\Windows\system32\netsh.exe advfirewall firewall set rule group="Windows Remote Administration" new enable=yes >null 2>&1

: Allow the Windows Remote Management (HTTP-In) Rule
C:\Windows\system32\netsh.exe advfirewall firewall set rule name="Windows Remote Management (HTTP-In)" new localport=5985 enable=yes action=allow >null 2>&1

: Allow the Windows Remote Management (HTTPS-In) Rule
C:\Windows\system32\netsh.exe advfirewall firewall set rule name="Windows Remote Management (HTTPS-In)" new localport=5986 enable=yes action=allow >null 2>&1

: Enable the Autostart of the Windows Remote Management (WinRM) Windows Service
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "Set-Service winrm -startuptype 'auto'" >null 2>&1

: Restart the Windows Remote Management (WinRM) Service
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "Restart-Service winrm" >null 2>&1

:DisableWindowsScriptHost
:: Turn off Windows Script Host (current user only)
ECHO Turn off Windows Script Host
ECHO %TIME:~0,8% Turn on Windows Script Host >>%logfile_setup%
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "$null = (New-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows Script Host\Settings' -Name Enabled -PropertyType DWord -Value 0 -Force -ErrorAction Continue)" >>%logfile_setup% 2>&1
ECHO Errorlevel=%Errorlevel% >>%logfile_setup% 2>nul
goto ENDLOGIC

:NotConnected
ECHO This Host is not connected directly to the Intranet (Skipped)
ECHO %TIME:~0,8% This Host is not connected directly to the Intranet (Skipped) >>%logfile_setup%
goto ENDLOGIC

:ENDLOGIC
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
