<#
      .COPYRIGHT
      Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT license.
      See LICENSE in the project root for license information.
#>

# Version 0.2.3
#
#####################################

[CmdletBinding()]
Param(
   [string]$logpath = "$env:windir\temp\TeamsWebRTC-detect.log"
)

# Retrives the version number of the current Web RTC client
function get-CurrentRTCver 
{
   $response = (Invoke-WebRequest -Uri 'https://aka.ms/msrdcwebrtcsvc/msi' -UseBasicParsing)
   $response.headers.'Content-Disposition'
   $versionC = $response.Headers.'Content-Disposition' -replace '.*HostSetup_', '' -replace '.x64.msi*', ''
   $string = 'The latest available version of the WebRTC client is ' + $versionC
   update-log -Data $string -Class Information -output both
   $global:currentversion = $versionC
   return $versionC
}

# Retrieves the installed version of the Web RTC client
function get-installedRTCver 
{
   if ((Test-Path -Path 'Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\AddIns\WebRTC Redirector\') -eq $true) 
   {
      $version = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\AddIns\WebRTC Redirector\')
      $string = 'The currently installed version of the WebRTC client is ' + $version.currentversion
      update-log -Data $string -Class Information -output both
      return $version.currentversion
   }
   else 
   {
      update-log -data "It doesn't appear that the WebRTC client is installed" -Class Warning -output both
      return '0'
   }
}

# Logging function
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
   $string = $Class + ' ' + $date + ' ' + $Data

   if ($Output -eq 'Console') 
   {
      Write-Output -InputObject $string | Out-Host 
   }

   if ($Output -eq 'file') 
   {
      Write-Output -InputObject $string | Out-File -FilePath $logpath -Append 
   }

   if ($Output -eq 'Both') 
   {
      Write-Output -InputObject $string | Out-Host
      Write-Output -InputObject $string | Out-File -FilePath $logpath -Append
   }
}

# function to detect if Teams is installed
function get-teamsinstall 
{
   $rootpath = 'c:\users\'
   $userfolders = (Get-ChildItem -Path $rootpath -Attributes directory).Name
   $count = 0

   foreach ($userfolder in $userfolders) 
   {
      if ($userfolder -ne 'Public') 
      {
         if ((Test-Path -Path ('c:\users\{0}\Appdata\Local\Microsoft\Teams\current\teams.exe' -f $userfolder)) -eq $true) 
         {
            $count = $count + 1
         }
      }
   }

   if ($count -eq '0') 
   {
      update-log -data 'Teams install not found. User may not have logged into machine yet. Returning Compliant' -Class Information -Output Both
      Exit 0
   }
   else 
   {
      update-log -data 'Teams install found.' -Class Information -Output Both
   }
}

# Writes the header of the log
update-log -Data ' ' -Class Information -output both
update-log -Data '*** Starting WebRTC agent detection ***' -Class Information -output both
update-log -Data ' ' -Class Information -output both

# Calls the function to check if Teams is installed. WebRTC client cannot upgrade if teams isn't detected in a user profile.
get-teamsinstall

# Calls the function to get the current available version number
$global:currentversion = $null
$RTCCurrent = get-CurrentRTCver
$RTCCurrent = $global:currentversion

# Calls the function to get the installed version number
$RTCInstalled = get-installedRTCver -Erroraction SilentlyContinue

# Handles the error code if Web RTC client is not installed.
if ($RTCInstalled -eq $null) 
{
   update-log -Data 'WebRTC client was not detected. Returning Non-compliant' -Class Warning -output both
   Exit 1
}

# Handles the error code if the Web RTC client is out of date.
if ($RTCInstalled -lt $RTCCurrent) 
{
   update-log -Data 'WebRTC was detected to be out of date. Returning Non-compliant' -Class Warning -output both
   Exit 1
}

# Handles the error code if the installed agent is newer than the latest available client. (shouldn't happen)
if ($RTCInstalled -gt $RTCCurrent) 
{
   update-log -data 'The installed version is newer than what is available.' -Class Warning -output both
   exit 1
}

# Handles the error code if the agent is current.
if ($RTCInstalled -eq $RTCCurrent) 
{
   update-log -Data 'The WebRTC client is current. Returning Compliant' -Class Information -output both
   Exit 0
}
