#requires -Version 2.0 -RunAsAdministrator

<#
      .SYNOPSIS
      Jumpstart and Bootstrap the Windows 10 Installation

      .DESCRIPTION
      Jumpstart and Bootstrap the Windows 10 Installation
#>
[CmdletBinding(ConfirmImpact = 'Low')]
param ()

begin
{
   Write-Output -InputObject 'Jumpstart and Bootstrap the Windows 10 Installation'

   #region Defaults
   $SCT = 'SilentlyContinue'
   #endregion Defaults

   $null = (Set-MpPreference -EnableControlledFolderAccess Disabled -Force -ErrorAction $SCT)

   #region ExecutionPolicy
   try
   {
      $null = (Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force -ErrorAction $SCT)
   }
   catch
   {
      Write-Verbose -Message 'Known Issue'
   }

   try
   {
      $null = (Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted -Force -ErrorAction $SCT)
   }
   catch
   {
      Write-Verbose -Message 'Known Issue'
   }
   #endregion ExecutionPolicy
}

process
{
   #region Tweaks
   # If we need to use a Proxy
   $null = (New-Object -TypeName System.Net.WebClient).Proxy.Credentials = [Net.CredentialCache]::DefaultNetworkCredentials

   # enable Remote PowerShell
   try
   {
      $null = (Enable-PSRemoting -Force -ErrorAction $SCT)
   }
   catch
   {
      Write-Warning -Message 'Unable to setup PS Remoting'
   }

   # Twaek some directories
   $null = (Get-Item -Path ($Home + '\3D Objects'), ($Home + '\Contacts'), ($Home + '\Favorites'), ($Home + '\Links'), ($Home + '\Saved Games'), ($Home + '\Searches') -Force | ForEach-Object -Process {
         $_.Attributes = $_.Attributes -bor 'Hidden'
      })

   # Create Directory structure
   'C:\temp', 'C:\Tools', 'C:\scripts\Batch', 'C:\scripts\PowerShell' | ForEach-Object -Process {
      $null = (New-Item -Path $_ -ItemType Directory -Force -Confirm:$false -ErrorAction SilentlyContinue)
   }

   # Create all PowerShell related Profiles
   (($PROFILE).AllUsersAllHosts), (($PROFILE).AllUsersCurrentHost), (($PROFILE).CurrentUserAllHosts), (($PROFILE).CurrentUserCurrentHost) | ForEach-Object -Process {
      if (-not (Test-Path -Path $_ -ErrorAction $SCT))
      {
         $null = (New-Item -Path $_ -ItemType File -Force -Confirm:$false -ErrorAction $SCT)
      }
   }
   #endregion Tweaks

   #region Transfer
   # Copy the PowerShell stuff
   if (Test-Path -Path '.\ps1\*.ps1' -ErrorAction $SCT)
   {
      $null = (Get-ChildItem -Path '.\ps1\*.ps1' -ErrorAction $SCT | ForEach-Object -Process {
            $null = (Copy-Item -Path $_ -Destination 'C:\scripts\PowerShell' -Force -Confirm:$false -ErrorAction SilentlyContinue)
         })
   }

   if (Test-Path -Path '.\tools\*.exe' -ErrorAction $SCT)
   {
      $null = (Get-ChildItem -Path '.\tools\*.exe' -ErrorAction $SCT | ForEach-Object -Process {
            $null = (Copy-Item -Path $_ -Destination 'C:\Tools' -Force -Confirm:$false -ErrorAction SilentlyContinue)
         })
   }

   if (Test-Path -Path '.\tools\*.bgi' -ErrorAction $SCT)
   {
      $null = (Get-ChildItem -Path '.\tools\*.bgi' -ErrorAction $SCT | ForEach-Object -Process {
            $null = (Copy-Item -Path $_ -Destination 'C:\Tools' -Force -Confirm:$false -ErrorAction SilentlyContinue)
         })
   }
   #endregion Transfer

   #region PowerShellProfiles
   # Create all PowerShell related Profiles as dummy (empty)
   $AllSystemProfiles = @(
      "$PROFILE.CurrentUserCurrentHost"
      "$PROFILE.CurrentUserAllHosts"
      "$PROFILE.AllUsersCurrentHost"
      "$PROFILE.AllUsersAllHosts"
      "$PSHOME\Microsoft.VSCode_profile.ps1"
      "$env:DOCUMENTS\PowerShell\Microsoft.VSCode_profile.ps1'"
   )

   foreach ($SystemProfile in $AllSystemProfiles)
   {
      if (-not (Test-Path -Path $SystemProfile -ErrorAction SilentlyContinue))
      {
         $null = (New-Item -ItemType File -Path $SystemProfile -Force -ErrorAction SilentlyContinue)
      }
   }
   #endregion PowerShellProfiles

   #region InstallingChocolatey
   $null = ([Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072)
   $null = (Invoke-Expression -Command ((New-Object -TypeName System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')))
   $null = (& "C:\ProgramData\chocolatey\bin\refreshenv.cmd")
   #endregion InstallingChocolatey

   #region PackageSource
   # Install Nuget as Package Provider
   $null = (Install-PackageProvider -Name NuGet -Force -ErrorAction $SCT)

   # Register Nuget Repository
   $null = (Register-PackageSource -Name Nuget -Location 'http://www.nuget.org/api/v2' -ProviderName Nuget -Trusted -ErrorAction $SCT)

   # PS Gallery Repository
   try
   {
      $null = (Register-PSRepository -Default -InstallationPolicy Trusted -ErrorAction Stop)
   }
   catch
   {
      $null = (Set-PSRepository -Name PSGallery -InstallationPolicy Trusted -ErrorAction $SCT)
   }
   #endregion PackageSource
}

end
{
   $null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction $SCT)
}

#region LICENSE
<#
      BSD 3-Clause License

      Copyright (c) 2020, enabling Technology
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
