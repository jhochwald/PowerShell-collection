<#
      .COPYRIGHT
      Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT license.
      See LICENSE in the project root for license information.
#>


# Version 0.2.8

#####################################

[CmdletBinding()]
Param(
   [string]$logpath = "$env:windir\temp\TeamsWebRTC-remediate.log",
   [string]$DCNTwait = 600,
   [string]$StateDetWait = 300,
   [switch]$retry,
   [int]$TimeOut = 60
)

# function to handle logging
function update-log 
{
   Param(
      [Parameter(
            Mandatory,HelpMessage = 'Add help message for user',
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 0
      )]
      [string]$Data,
      [validateset('Information', 'Warning', 'Error', 'Comment')]
      [string]$Class = 'Information',
      [validateset('Console', 'File', 'Both')]
      [string]$Output
   )

   $date = Get-Date -UFormat '%m/%d/%y %r'
   $String = $Class + ' ' + $date + ' ' + $Data

   if ($Output -eq 'Console') 
   {
      Write-Output -InputObject $String | Out-Host 
   }

   if ($Output -eq 'file') 
   {
      Write-Output -InputObject $String | Out-File -FilePath $logpath -Append 
   }

   if ($Output -eq 'Both') 
   {
      Write-Output -InputObject $String | Out-Host
      Write-Output -InputObject $String | Out-File -FilePath $logpath -Append
   }
}

# function to query the user state and convert to variable
function get-userstate 
{
   (((& "$env:windir\system32\quser.exe") -replace '^>', '') -replace '\s{2,}', ',').Trim() | ForEach-Object -Process {
      if ($_.Split(',').Count -eq 5) 
      {
         Write-Output -InputObject ($_ -replace '(^[^,]+)', '$1,')
      }
      else 
      {
         Write-Output -InputObject $_
      }
   } | ConvertFrom-Csv
}

# function to perform the upgrading
function invoke-remediation 
{
   $folders = Get-ChildItem -Path C:\users -Directory -Force -ErrorAction SilentlyContinue | Select-Object -Property fullname, name
   $TeamsReg = 'HKCU:\Software\Microsoft\Office\Teams'
   $TeamRegExist = Test-Path -Path $TeamsReg
   $RTCCurrent = get-CurrentRTCver
   $global:currentversion
   $RTCInstalled = get-installedRTCver

   try 
   {
      if ($TeamRegExist -eq $True) 
      {
         $PreventInstallStateKey = Get-Item -Path $TeamsReg
         $preventInstall = $PreventInstallStateKey.GetValue('PreventInstallationFromMsi')
         if ($preventInstall -ne $null) 
         {
            update-log -data 'Removing PreventInstallationFromMsi reg key' -Class Information -output both
            Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Office\Teams' -Name 'PreventInstallationFromMsi'
         }
      }

      # Create a directory to save download files
      $tempCreated = $false

      if (!(Test-Path -Path C:\temp)) 
      {
         $null = New-Item -Path C:\ -ItemType Directory -Name temp
         update-log -data 'Temp path created' -output both -Class Information
         $tempCreated = $True
      }

      # Add registry Key
      update-log -Data 'Adding IsWVDEnvironment reg key' -Class Information -output both
      & "$env:windir\system32\reg.exe" add 'HKLM\SOFTWARE\Microsoft\Teams' /v IsWVDEnvironment /t REG_DWORD /d 1 /f /reg:64

      # Download WebRTC
      update-log -Data 'Downloading Web RTC client' -Class Information -output both
      Invoke-WebRequest -Uri 'https://aka.ms/msrdcwebrtcsvc/msi' -OutFile 'C:\temp\MsRdcWebRTCSvc_HostSetup.msi' -UseBasicParsing -PassThru

      # Install MSRDCWEBTRCSVC
      update-log -Data 'Installing WebRTC client' -Class Information -output both
      $msireturn = Start-Process -FilePath msiexec.exe -ArgumentList '/i C:\temp\MsRdcWebRTCSvc_HostSetup.msi /q /n /l*voicewarmup c:\windows\temp\webrtcmsi.log' -Wait -PassThru

      if ($msireturn.ExitCode -eq '0') 
      {
         update-log -data 'MSIEXEC returned 0' -Class Information -Output Both
      }
      else 
      {
         $String = 'MSIEXEC returned exit code ' + $msireturn.ExitCode
         update-log -data $String -Class Information -Output Both
         exit 1
      }

      if ($tempCreated) 
      {
         # Remove temp folder
         update-log -Data 'Removing temp directory' -Class Information -output both
         $null = Remove-Item -Path C:\temp\ -Recurse
      }
      else 
      {
         # Remove downloaded WebRTC file
         update-log -Data 'Removing WebRTC client installer file' -Class Information -output both
         Remove-Item -Path C:\temp\MsRdcWebRTCSvc_HostSetup.msi
      }

      # Return Success
      update-log -Data 'Media Optimization Installed' -Class Information -output both
      return 'Success'
   }
   catch 
   {
      Write-Error -ErrorRecord $_
      return 'Fail'
   }
}

# function to handle user state detection logic
function invoke-userdetect 
{
   update-log -data 'Detecting user state.' -Class Information -output both
   $explorerprocesses = @(Get-WmiObject -Query "Select * FROM Win32_Process WHERE Name='explorer.exe'" -ErrorAction SilentlyContinue)

   if ($explorerprocesses.Count -eq 0) 
   {
      update-log -data 'There is not a user logged in. Skipping user state detection.' -Class Information -Output both
      Return
   }
   else 
   {
      foreach ($i in $explorerprocesses) 
      {
         $Username = $i.GetOwner().User
         $Domain = $i.GetOwner().Domain
         $String = $Domain + '\' + $Username + ' logged on since: ' + ($i.ConvertToDateTime($i.CreationDate))
         update-log -data $String -Class Information -Output Both
      }
      update-log -data 'There is a logged on user' -Class Information -Output Both
   }

   if ($retry -eq $True) 
   {
      do 
      {
         $session = get-userstate
         $text = 'Waiting for non-active user state.'
         update-log -data $text -Class Information -output both
         $String = 'Session State is ' + $session.STATE
         update-log -data $String -output both -Class Information
         $String = 'Idle Time is ' + $session.'IDLE TIME'
         update-log -data $String -output both -Class Information

         if ($TimeOut -gt 0) 
         {
            Start-Sleep -Seconds $StateDetWait
            $TimeOut = ($TimeOut - $StateDetWait)
         }
         else 
         {
            update-log -Data 'Timed out. Returning fail' -Class Error -output both
            return 3
         }
      }
      while ($session.state -eq 'Active')

      update-log -data 'User state is not active.' -output both -Class Information
      invoke-disctimer
   }

   if ($retry -eq $false) 
   {
      update-log -Data 'Attempting to detect only once.' -Class Information -output both
      $session = get-userstate

      if ($session.state -eq 'disc') 
      {
         $text = 'User state is disconnected'
         update-log -data $text -Class Information -output both
      }
      else 
      {
         update-log -Data 'User state is not disconnected' -Class Warning -output both
         return 2
      }
   }
}

# function to handle wait time between first non-active discovery and upgrade
function invoke-disctimer 
{
   $String = 'Waiting ' + $DCNTwait + ' seconds...'
   update-log -Data $String -Class Information -output both
   Start-Sleep -Seconds $DCNTwait
   $TimeOut = ($TimeOut - $DCNTwait)
   $session = get-userstate

   if ($session.STATE -eq 'Active') 
   {
      update-log -Data 'User state has become active again. Waiting for non-active state...' -Class Warning -output both
      invoke-userdetect
   }
   else 
   {
      update-log -data 'Session state is still non-active. Continuing with remediation...' -Class Information -output both
   }
}

# function to query the latest available version number of WebRTC client
function get-CurrentRTCver 
{
   $response = (Invoke-WebRequest -Uri 'https://aka.ms/msrdcwebrtcsvc/msi' -UseBasicParsing)
   $response.headers.'Content-Disposition'
   $versionC = $response.Headers.'Content-Disposition' -replace '.*HostSetup_', '' -replace '.x64.msi*', ''
   $String = 'The latest available version of the WebRTC client is ' + $versionC
   update-log -Data $String -Class Information -output both
   $global:currentversion = $versionC

   return $versionC
}

# function to determine what version of WebRTC is installed
function get-installedRTCver 
{
   if ((Test-Path -Path 'Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\AddIns\WebRTC Redirector\') -eq $True) 
   {
      $version = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\AddIns\WebRTC Redirector\')
      $String = 'The currently installed version of the WebRTC client is ' + $version.currentversion
      update-log -Data $String -Class Information -output both
      return $version.currentversion
   }
   else 
   {
      update-log -data "It doesn't appear that the WebRTC client is installed" -Class Warning -output both
      return '0'
   }
}

# Opening text of log.
update-log -Data ' ' -Class Information -output both
update-log -Data '*** Starting Teams WebRTC agent remediation ***' -Class Information -output both
update-log -Data ' ' -Class Information -output both

# Display timeout amount in the log - if using retry function
if ($retry -eq $True) 
{
   $String = 'Time out set for ' + $TimeOut + ' minutes'
   update-log -Data $String -output both -Class Information
}

# Converts Timeout minutes to seconds
$TimeOut = $TimeOut * 60

# Starts the user state detection and handling
$var1 = invoke-userdetect

# Exit if user is active (default).
# Return code for no retry - user is active
if ($var1 -eq 2) 
{
   update-log -Data 'User State is active. Returning fail. Try again' -Class Warning -output both
   exit 1
}

# Exit if process times out. Used with "-retry" parameter.
# Return code for time out
if ($var1 -eq 3) 
{
   update-log -Data 'Timed out. Returning fail. Try again' -Class Warning -output both
   exit 1
}

#Starts the remediaiton function
$result = $null
$result = invoke-remediation

# Exit if the remediation was successful
if ($result -eq 'Success') 
{
   update-log -Data 'Remediation Complete' -Class Information -output both
   exit 0
}

# Exit if remediation failed
if ($result -ne 'Success') 
{
   update-log -Data 'An error occured.' -Class Error -output both
   exit 1
}
