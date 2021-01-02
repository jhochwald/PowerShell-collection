#requires -Version 3.0 -Modules BitsTransfer -RunAsAdministrator

<#
      .SYNOPSIS
      Download and install the Skype for Business Online PowerShell Module

      .DESCRIPTION
      Download and install the Skype for Business Online PowerShell Module

      .NOTES
      It may be necessary to set up Windows Remote Management (WinRM)!

      If the connect to Skype for Business Online and/or Microsoft Teams requires to,
      please execute the following command(s) in an administrative (elevated) command prompt/PowerShell:

      winrm quickconfig

      And optionally this (for legacy authentication fallback support):
      winrm set winrm/config/client/auth@{Basic="true"}

      Changelog:
      1.0.0: Initial Release

      Version 1.0.0

      .LINK
      http://enatec.io
#>
[CmdletBinding(ConfirmImpact = 'Low',
   SupportsShouldProcess)]
param ()

begin
{
   Write-Warning -Message 'This module is no longer supported and recommended!'
   Write-Warning -Message 'Please use the Microsoft Teams Module instead!!!'

   exit 1

   Write-Output -InputObject 'Download and install the Skype for Business Online PowerShell Module'

   # Default URL
   [string]$SkypeOnlinePowerShellUrl = 'https://download.microsoft.com/download/2/0/5/2050B39B-4DA5-48E0-B768-583533B42C3B/SkypeOnlinePowerShell.exe'

   #region PossibleParameters
   # Where to Store it
   [string]$Target = ($env:Temp)

   # File Name
   [string]$TargetName = 'SkypeOnlinePowerShell.exe'

   # Install Switch
   [string]$Arguments = '/install /quiet /norestart'
   #endregion PossibleParameters

   #region Defaults
   # Set the full path of the downloaded installer
   [string]$InstallerPackage = ($Target + '\' + $TargetName)

   $SCT = 'SilentlyContinue'
   $STP = 'Stop'
   #endregion Defaults
}

process
{
   # Use BitsTransfer to download the latest installer
   $paramStartBitsTransfer = @{
      Source         = $SkypeOnlinePowerShellUrl
      Destination    = $InstallerPackage
      Priority       = 'Foreground'
      TransferPolicy = 'Always'
      ErrorAction    = $STP
   }
   $null = (Start-BitsTransfer @paramStartBitsTransfer)


   $paramTestPath = @{
      Path        = $InstallerPackage
      ErrorAction = $SCT
   }
   if (Test-Path @paramTestPath)
   {
      $paramGetItemProperty = @{
         Path        = $InstallerPackage
         ErrorAction = $SCT
      }
      $InstallerVersion = ((Get-ItemProperty @paramGetItemProperty).VersionInfo.ProductVersion)

      Write-Verbose -Message ('Running SkypeOnlinePowerShell installer version  {0}' -f $InstallerVersion)

      $paramStartProcess = @{
         FilePath     = $InstallerPackage
         ArgumentList = $Arguments
         Wait         = $true
         PassThru     = $true
         ErrorAction  = $STP
      }
      $InstallerProcess = (Start-Process @paramStartProcess)

      if (($InstallerProcess | Select-Object -ExpandProperty ExitCode) -eq 0)
      {
         Write-Verbose -Message ('Installed FSLogix version  {0}' -f $InstallerVersion)
      }
      else
      {
         Write-Warning -Message ('Installer exit code  {0}.' -f $InstallerProcess.ExitCode)
      }

      Write-Verbose -Message ('Removing file: {0}' -f $InstallerPackage)

      # Remove the downloaded Installaer Package
      $paramRemoveItem = @{
         Path        = $InstallerPackage
         Confirm     = $false
         Force       = $true
         ErrorAction = $SCT
      }
      $null = (Remove-Item @paramRemoveItem)
   }
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
