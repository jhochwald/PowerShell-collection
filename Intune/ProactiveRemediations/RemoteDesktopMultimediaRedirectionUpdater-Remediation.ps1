<#
      .COPYRIGHT
      Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT license.
      See LICENSE in the project root for license information.
#>

# RemoteDesktopMultimediaRedirectionUpdater-Remediation.ps1
# Remote Desktop Multimedia Redirection updater - Remediation Script
# Version 0.0.1
param (
   [parameter(HelpMessage = 'Log path and file name')]
   [string]
   $logpath = "$env:windir\temp\TeamsWebRTC-remediate.log",
   [parameter(HelpMessage = 'time to wait past disconnect')]
   [string]
   $DCNTwait = 600,
   [parameter(HelpMessage = 'time to wait to re-check user state')]
   [string]
   $StateDetWait = 300,
   [parameter(HelpMessage = 'evaluate user state only once')]
   [switch]
   $retry,
   [parameter(HelpMessage = 'time in minutes to timeout')]
   [int]
   $TimeOut = 60
)

#function to handle logging
function Update-Log
{
   param (
      [Parameter(
                 Mandatory = $true,
                 ValueFromPipeline = $true,
                 ValueFromPipelineByPropertyName = $true,
                 Position = 0
                 )]
      [string]
      $Data,
      [validateset('Information', 'Warning', 'Error', 'Comment')]
      [string]
      $Class = 'Information',
      [validateset('Console', 'File', 'Both')]
      [string]
      $Output
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

#function to query the user state and convert to variable
function Get-UserState
{
   (((quser.exe) -replace '^>', '') -replace '\s{2,}', ',').Trim() | ForEach-Object -Process {
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

#function to perform the upgrading
function Invoke-Remediation
{
   $MMRCurrent = Get-CurrentMMRver
   
   $MMRInstalled = Get-InstalledMMRver
   $String = 'Installed MMR agent version is ' + $MMRInstalled
   Update-Log -Data $String -Class Information -Output Both
   $String = 'Latest version of MMR agent is ' + $MMRCurrent
   Update-Log -Data $String -Class Information -Output Both
   
   try
   {
      #Create a directory to save download files
      $tempCreated = $false
      if (!(Test-Path -Path C:\RDMMRtemp))
      {
         $null = New-Item -Path C:\ -ItemType Directory -Name RDMMRtemp
         Update-Log -data 'Temp path created' -output both -Class Information
         $tempCreated = $true
      }
      
      #Download MMR
      Update-Log -Data 'Downloading RD MMR client' -Class Information -output both
      Invoke-WebRequest -Uri 'https://aka.ms/avdmmr/msi' -OutFile 'C:\RDMMRtemp\MMR_Installer.msi' -UseBasicParsing -PassThru
      
      #Install MMR
      Update-Log -Data 'Installing RD MMR client' -Class Information -output both
      $msireturn = Start-Process -FilePath msiexec.exe -ArgumentList '/i C:\RDMMRtemp\MMR_Installer.msi /q /n /l*voicewarmup c:\windows\temp\RDMMRmsi.log' -Wait -PassThru
      if ($msireturn.ExitCode -eq '0')
      {
         Update-Log -data 'MSIEXEC returned 0' -Class Information -Output Both
      }
      else
      {
         $String = 'MSIEXEC returned exit code ' + $msireturn.ExitCode
         Update-Log -data $String -Class Information -Output Both
         exit 1
      }
      
      if ($tempCreated -eq $true)
      {
         #Remove temp folder
         Update-Log -Data 'Removing temp directory' -Class Information -output both
         $null = Remove-Item -Path C:\RDMMRtemp\ -Recurse
      }
      else
      {
         #Remove downloaded WebRTC file
         Update-Log -Data 'Removing RD MMR client installer file' -Class Information -output both
         Remove-Item -Path C:\RDMMRtemp\MsRdcWebRTCSvc_HostSetup.msi
      }
      #Return Success
      Update-Log -Data 'Media Optimization Installed' -Class Information -output both
      $MMRCurrent = Get-CurrentMMRver
      $String = 'Current installed version is now ' + $MMRCurrent
      Update-Log -Data $String -Class Information -Output Both
      return 'Success'
   }
   catch
   {
      Write-Error -ErrorRecord $_
      return /b 'Fail'
   }
}

#function to handle user state detection logic
function Invoke-UserDetect
{
   Update-Log -data 'Detecting user state.' -Class Information -output both
   $explorerprocesses = @(Get-WmiObject -Query "Select * FROM Win32_Process WHERE Name='explorer.exe'" -ErrorAction SilentlyContinue)
   if ($explorerprocesses.Count -eq 0)
   {
      Update-Log -data 'There is not a user logged in. Skipping user state detection.' -Class Information -Output both
      return
   }
   else
   {
      foreach ($i in $explorerprocesses)
      {
         $Username = $i.GetOwner().User
         $Domain = $i.GetOwner().Domain
         $String = $Domain + '\' + $Username + ' logged on since: ' + ($i.ConvertToDateTime($i.CreationDate))
         Update-Log -data $String -Class Information -Output Both
      }
      Update-Log -data 'There is a logged on user' -Class Information -Output Both
   }
   
   if ($retry -eq $true)
   {
      do
      {
         $session = Get-UserState
         $text = "Waiting for non-active user state."
         Update-Log -data $text -Class Information -output both
         $String = "Session State is " + $session.STATE
         Update-Log -data $String -output both -Class Information
         $String = "Idle Time is " + $session.'IDLE TIME'
         Update-Log -data $String -output both -Class Information
         
         if ($TimeOut -gt 0)
         {
            Start-Sleep -Seconds $StateDetWait
            $TimeOut = ($TimeOut - $StateDetWait)
         }
         else
         {
            Update-Log -Data "Timed out. Returning fail" -Class Error -output both
            return 3
         }
      }
      while ($session.state -eq 'Active')
      
      Update-Log -data 'User state is not active.' -output both -Class Information
      Invoke-DiscTimer
   }
   
   if ($retry -eq $false)
   {
      Update-Log -Data 'Attempting to detect only once.' -Class Information -output both
      $session = Get-UserState
      if ($session.state -eq 'disc')
      {
         $text = 'User state is disconnected'
         Update-Log -data $text -Class Information -output both
      }
      else
      {
         Update-Log -Data 'User state is not disconnected' -Class Warning -output both
         return 2
      }
   }
}

#function to handle wait time between first non-active discovery and upgrade
function Invoke-DiscTimer
{
   $String = 'Waiting ' + $DCNTwait + ' seconds...'
   Update-Log -Data $String -Class Information -output both
   Start-Sleep -Seconds $DCNTwait
   $TimeOut = ($TimeOut - $DCNTwait)
   
   $session = Get-UserState
   if ($session.STATE -eq 'Active')
   {
      Update-Log -Data 'User state has become active again. Waiting for non-active state...' -Class Warning -output both
      Invoke-UserDetect
   }
   else
   {
      Update-Log -data 'Session state is still non-active. Continuing with remediation...' -Class Information -output both
   }
}

#function to query the latest available version number of RD MMR client
function Get-CurrentMMRver
{
   $response = (Invoke-WebRequest -Uri 'https://aka.ms/avdmmr/msi' -UseBasicParsing)
   $versionC = $response.BaseResponse.ResponseUri.AbsolutePath -replace '.*HostInstaller_', '' -replace '.x64.msi*', ''
   $String = 'The latest available version of the RD MMR client is ' + $versionC
   Update-Log -Data $String -Class Information -output both
   return $versionC
}

#function to determine what version of RDMMR is installed
function Get-InstalledMMRver
{
   if ((Test-Path -Path 'C:\Program Files\MsRDCMMRHost\MsMmrHost.exe') -eq $true)
   {
      $version = (Get-ItemProperty -Path 'C:\Program Files\MsRDCMMRHost\MsMmrHost.exe')
      $String = 'The currently installed version of the RD MMR client is ' + $version.VersionInfo.ProductVersion
      Update-Log -Data $String -Class Information -output both
      return $version.VersionInfo.ProductVersion
   }
   else
   {
      Update-Log -data "It doesn't appear that the RD MMR client is installed" -Class Warning -output both
      return '0'
   }
}

#Opening text of log. 
Update-Log -Data ' ' -Class Information -output both
Update-Log -Data '*** Starting RD MMR agent remediation ***' -Class Information -output both
Update-Log -Data ' ' -Class Information -output both

#Display timeout amount in the log - if using retry function
if ($retry -eq $true)
{
   $String = 'Time out set for ' + $TimeOut + ' minutes'
   Update-Log -Data $String -output both -Class Information
}

#Converts Timeout minutes to seconds
$TimeOut = $TimeOut * 60

#Starts the user state detection and handling
$var1 = Invoke-UserDetect

# Exit if user is active (default). 
#Return code for no retry - user is active
if ($var1 -eq 2)
{
   Update-Log -Data 'User State is active. Returning fail. Try again' -Class Warning -output both
   exit 1
}

#Exit if process times out. Used with "-retry" parameter. 
#Return code for time out
if ($var1 -eq 3)
{
   Update-Log -Data 'Timed out. Returning fail. Try again' -Class Warning -output both
   exit 1
}

#Starts the remediaiton function
$result = $null
$result = Invoke-Remediation

#Exit if the remediation was successful
if ($result -eq 'Success')
{
   Update-Log -Data 'Remediation Complete' -Class Information -output both
   exit 0
}

#Exit if remediation failed
if ($result -ne 'Success')
{
   Update-Log -Data 'An error occured.' -Class Error -output both
   exit 1
}
    