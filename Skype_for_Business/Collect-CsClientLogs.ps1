<#
      .SYNOPSIS
      Allows you to collect the Lync/Skype for Business Client logs and puts them
      in a Zip file on your desktop.

      .DESCRIPTION
      This script identifies which version of Lync 2013 or Skype for Business 2015/2016
      client that you are using to identify where the Tracing folder is stored.  Then
      it checks to see if the lync.exe is running.  If so, it prompts you to exit the
      client so that it can zip the complete tracing folder and place it on your desktop.

      .EXAMPLE
      .\Collect-CsClientLogs.ps1

      This will collect the logs and put them on your desktop in a file named Tracing_DATETIME.zip

      .NOTES
      The client tracing logs contain personally identifiable information or PII. If
      you are sending these logs to someone for analysis, do not send it in any manner
      that isn't encrypted with SSL or TLS.  Email is not a secure way to transfer
      this data.

      This script DOES NOT work with Lync 2010.  Lync 2010 Client logs are in %UserProfile%\Tracing

#>
Function getDateTimeForFileName
{
   $DT = (Get-Date)
   $FileNameAddition = '_'
   $FileNameAddition += ($DT.Month).ToString('00') + '-'
   $FileNameAddition += ($DT.Day).ToString('00') + '-'
   $FileNameAddition += ($DT.Year).ToString('0000') + '_'
   $FileNameAddition += ($DT.Hour).ToString('00') + '.'
   $FileNameAddition += ($DT.Minute).ToString('00') + '.'
   $FileNameAddition += ($DT.Second).ToString('00')
   Return $FileNameAddition
}

# Show PII Warning
Write-Warning -Message "The client tracing logs contain personally identifiable information or PII. If you are sending these logs to someone for analysis, do not send it in any manner that isn't encrypted with SSL or TLS.  Email is not a secure way to transfer this data."
$Answer = Read-Host -Prompt 'Type YES and hit [Enter] if you understand this warning'

If (-not ($Answer -eq 'yes'))
{
   Write-Warning -Message "You did not type `"Yes`" to the above warning.  Script has ended and no data has been collected"
   Break
}

# Stop Lync and Skype from Running
Write-Warning -Message 'The following programs must be closed: Outlook, and Skype for Business. Please close them now.'

$Answer2 = Read-Host -Prompt 'Are Skype for Business and Outlook closed? YES or NO?'

while ($Answer2 -ne 'yes')
{
   Write-Output -InputObject "Please close the programs and confirm with 'YES'"
   $Answer2 = Read-Host -Prompt 'Waiting for answer: '
}

# Turn off the proceesses on the machine. These lines will forcibly kill the programs.
$OutlookProcess = (Get-Process -Name Outlook -ErrorVariable OutlookError -ErrorAction SilentlyContinue)
if ($OutlookProcess -ne $null)
{
   $OutlookProcess.CloseMainWindow()
}

$LyncPS = (Get-Process -Name lync* -ErrorVariable LyncError -ErrorAction SilentlyContinue)
if ($LyncPS -ne $null)
{
   $LyncPS.CloseMainWindow()
}
# Figure out which Lync/Skype version is being used.
$OfficeInstalls = Get-ChildItem -Path hklm:\software\microsoft\windows\currentversion\uninstall | ForEach-Object -Process {
   Get-ItemProperty -Path $_.pspath
} | Where-Object -FilterScript {
   ($_.displayname -match 'Office') -and ($_.InstallLocation.Length -gt 1)
}
$Found = $False
ForEach ($Path in $OfficeInstalls.InstallLocation)
{
   $File = Get-ChildItem -Path $Path -Filter 'Lync.exe' -Recurse

   If ($File.Name.Length -gt 0)
   {
      $LyncVersion = [Diagnostics.FileVersionInfo]::GetVersionInfo($File.FullName).FileVersion
      $LyncPath = $File.FullName
      $Found = $true
   }
}

If ($Found)
{
   $Version = $LyncVersion.Substring(0, 4)
}

# Set the Tracing Folder Path
$LogPath = ($env:USERPROFILE + '\AppData\Local\Microsoft\Office\' + $Version + '\Lync\Tracing')

if (Test-Path -Path $LogPath)
{
   # Check to see if Lync.exe is running.
   $LyncPID = ((Get-WmiObject -Class win32_process | Where-Object -FilterScript {
            ($_.ProcessName -eq 'lync.exe') -and ($_.GetOwner().User -eq $env:USERNAME)
         }).ProcessID)
   $LyncProcess = (Get-Process -Id $LyncPID -ErrorAction SilentlyContinue)

   While ($LyncProcess.ProcessName.Length -ne 0)
   {
      # If Running Prompt to Exit Lync.exe
      Write-Warning -Message 'Lync/Skype is still running'
      Write-Output -InputObject 'Please Exit Lync/Skype and press Any Key to continue...'

      $null = ($Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown'))
      $LyncProcess = (Get-Process -Id $LyncPID -ErrorAction SilentlyContinue)
   }

   # Compress entire Tracing Folder and place on Desktop (Filename with DateTimeStamp in name)
   $ZipFile = 'Tracing$(getDateTimeForFilename).zip'

   Write-Output -InputObject ('Zipping Tracing folder and placing on your Desktop ({0})' -f $ZipFile)

   $null = (Add-Type -AssemblyName 'system.io.compression.filesystem')

   # Alter the destination

   [io.compression.zipfile]::CreateFromDirectory($LogPath, "$env:USERPROFILE\Desktop\$ZipFile")

   Write-Output -InputObject 'Log Collection Complete.'
   Write-Output -InputObject "Press `"Y`" to Launch the Lync/Skype Client.  Hit any other key to quit."

   $Answer = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')

   If ($Answer.VirtualKeyCode -eq 89)
   {
      . "$LyncPath"
   }
}
else
{
   Write-Output -InputObject "Cannot find Tracing folder path ($LogPath)"
   Write-Output -InputObject 'This might be because you have never launched Lync or the Script detected the wrong version'
   Write-Output -InputObject 'You are going to have to manually collect the logs'
}

#region LICENSE
<#
      BSD 3-Clause License

      Copyright (c) 2021, enabling Technology
      All rights reserved.

      Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
      1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
      2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
      3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

      THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>
#endregion LICENSE

#region DISCLAIMER
<#
      DISCLAIMER:
      - Use at your own risk, etc.
      - This is open-source software, if you find an issue try to fix it yourself. There is no support and/or warranty in any kind
      - This is a third-party Software
      - The developer of this Software is NOT sponsored by or affiliated with Microsoft Corp (MSFT) or any of its subsidiaries in any way
      - The Software is not supported by Microsoft Corp (MSFT)
      - By using the Software, you agree to the License, Terms, and any Conditions declared and described above
      - If you disagree with any of the Terms, and any Conditions declared: Just delete it and build your own solution
#>
#endregion DISCLAIMER
