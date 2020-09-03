#requires -Version 1.0 -RunAsAdministrator

<#
      .SYNOPSIS
      Tweak the All User Profiles

      .DESCRIPTION
      Tweak the All User Profiles

      .NOTES
      Still beta!

      Version 0.0.9

      .LINK
      http://beyond-datacenter.com
#>
[CmdletBinding(ConfirmImpact = 'Low',
SupportsShouldProcess)]
param ()

begin
{
   Write-Output -InputObject 'Download and install the chocolatey default base packages'
   $SCT = 'SilentlyContinue'
   $ErrorActionPreference = $SCT

   $null = (Set-MpPreference -EnableControlledFolderAccess Disabled -Force -ErrorAction $SCT)
}

process
{
   # Get default user profile path
   $DefaultUserProfile = ((Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList' -Name 'Default' -ErrorAction $SCT -WarningAction $SCT).Default)

   # Modify default startmenu and remove all tiles which will be downloaded later
   $XmlObjectPath = (Join-Path -Path $DefaultUserProfile -ChildPath 'AppData\Local\Microsoft\Windows\Shell\DefaultLayouts.xml' -ErrorAction $SCT -WarningAction $SCT)
   $XmlObject = (New-Object -TypeName xml -ErrorAction $SCT -WarningAction $SCT)
   $XmlObject.PreserveWhitespace = $true
   $null = ($XmlObject.Load($XmlObjectPath))
   $XmlNameSpace = (New-Object -TypeName System.Xml.XmlNamespaceManager -ArgumentList ($XmlObject.NameTable) -ErrorAction $SCT -WarningAction $SCT)
   $null = ($XmlNameSpace.AddNamespace('start', 'http://schemas.microsoft.com/Start/2014/StartLayout'))
   $null = ($XmlObject.SelectNodes('//start:SecondaryTile', $XmlNameSpace) | ForEach-Object { $null = $_.ParentNode.RemoveChild($_) })
   $null = ($XmlObject.Save($XmlObjectPath))

   # Easy HKU access
   $null = (New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS)

   # Load default user hive
   $null = (& "$env:windir\system32\reg.exe" load 'HKU\DEFAULT' (Join-Path -Path $DefaultUserProfile -ChildPath 'NTUSER.DAT' -ErrorAction $SCT -WarningAction $SCT))


   $RunOneOnjectPath = 'C:\scripts\PowerShell\Invoke-BootstrapUser.ps1'

   $RunOnceHku = 'HKU:\DEFAULT\Software\Microsoft\Windows\CurrentVersion\RunOnce'
   $null = (New-Item -Path $RunOnceHku -Force -ErrorAction $SCT -WarningAction $SCT)
   $null = (New-ItemProperty -Path $RunOnceHku -Force -Name '!run_once' -Value "powershell -NoProfile -WindowStyle Hidden -File $RunOneOnjectPath" -ErrorAction $SCT -WarningAction $SCT)

   $RuneOnceHkcu = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce'
   $null = (New-Item -Path $RuneOnceHkcu -Force -ErrorAction $SCT -WarningAction $SCT)
   $null = (New-ItemProperty -Path $RuneOnceHkcu -Force -Name '!run_once' -Value "powershell -NoProfile -WindowStyle Hidden -File $RunOneOnjectPath" -ErrorAction $SCT -WarningAction $SCT)

   # unload default user hive

   $null = (& "$env:windir\system32\reg.exe" unload 'HKU\DEFAULT')

   try
   {
      $null = (Remove-PSDrive -Name HKU -Force -ErrorAction $SCT -WarningAction $SCT)
   }
   catch
   {
      Write-Verbose -Message 'Known issue'
   }
}

end
{
   [GC]::Collect()

   $null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction $SCT)
}

#region LICENSE
<#
      BSD 3-Clause License

      Copyright (c) 2020, Beyond Datacenter
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
