#requires -Version 1.0 -RunAsAdministrator

<#
      .SYNOPSIS
      Setup the default enaTec Start Menu for the System

      .DESCRIPTION
      Setup the default enaTec Start Menu for the System

      .EXAMPLE
      PS C:\> .\Set-SystemStartMenuDefault.ps1

      .NOTES
      Minor Helper

      Version 1.0.0

      .LINK
      http://enatec.io
#>
[CmdletBinding(ConfirmImpact = 'None')]
param ()

begin
{
   Write-Output -InputObject 'Setup the default enaTec Start Menu for the System'

   #region Defaults
   $SCT = 'SilentlyContinue'
   $BasePath = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs"
   #endregion Defaults
}

process
{
   #region 7Zip
   $FolderName = '\7-Zip'
   $FolderPath = ($BasePath + $FolderName)

   $paramTestPath = @{
      Path          = $FolderPath
      PathType      = 'Container'
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if (Test-Path @paramTestPath)
   {
      $paramCopyItem = @{
         Path          = ($FolderPath + '\7-Zip File Manager.lnk')
         Destination   = $BasePath
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (Copy-Item @paramCopyItem)

      $paramRemoveItem = @{
         Path          = $FolderPath
         Recurse       = $true
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (Remove-Item @paramRemoveItem)
   }
   #endregion 7Zip

   #region Barco
   $FolderName = '\Barco'
   $FolderPath = ($BasePath + $FolderName)

   $paramTestPath = @{
      Path          = $FolderPath
      PathType      = 'Container'
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if (Test-Path @paramTestPath)
   {
      $paramCopyItem = @{
         Path          = ($FolderPath + '\ClickShare.lnk')
         Destination   = $BasePath
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (Copy-Item @paramCopyItem)

      $ClickShareLauncher = ($FolderPath + '\ClickShare Launcher\ClickShare Launcher.lnk')

      $paramTestPath = @{
         Path          = $ClickShareLauncher
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      if (Test-Path @paramTestPath)
      {
         $paramCopyItem = @{
            Path          = $ClickShareLauncher
            Destination   = $BasePath
            Force         = $true
            Confirm       = $false
            ErrorAction   = $SCT
            WarningAction = $SCT
         }
         $null = (Copy-Item @paramCopyItem)
      }

      $paramRemoveItem = @{
         Path          = $FolderPath
         Recurse       = $true
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (Remove-Item @paramRemoveItem)
   }
   #endregion Barco

   #region CMake
   $FolderName = '\CMake'
   $FolderPath = ($BasePath + $FolderName)

   $paramTestPath = @{
      Path          = $FolderPath
      PathType      = 'Container'
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if (Test-Path @paramTestPath)
   {
      $paramCopyItem = @{
         Path          = ($FolderPath + '\CMake (cmake-gui).lnk')
         Destination   = $BasePath
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (Copy-Item @paramCopyItem)

      $paramRemoveItem = @{
         Path          = $FolderPath
         Recurse       = $true
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (Remove-Item @paramRemoveItem)
   }
   #endregion CMake

   #region Cyberduck
   $FolderName = '\Cyberduck'
   $FolderPath = ($BasePath + $FolderName)

   $paramTestPath = @{
      Path          = $FolderPath
      PathType      = 'Container'
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if (Test-Path @paramTestPath)
   {
      $paramCopyItem = @{
         Path          = ($FolderPath + '\Cyberduck.lnk')
         Destination   = $BasePath
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (Copy-Item @paramCopyItem)

      $paramRemoveItem = @{
         Path          = $FolderPath
         Recurse       = $true
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (Remove-Item @paramRemoveItem)
   }
   #endregion Cyberduck

   #region Git
   $FolderName = '\Git'
   $FolderPath = ($BasePath + $FolderName)

   $paramTestPath = @{
      Path          = $FolderPath
      PathType      = 'Container'
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if (Test-Path @paramTestPath)
   {
      $paramCopyItem = @{
         Path          = ($FolderPath + '\Git GUI.lnk')
         Destination   = $BasePath
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (Copy-Item @paramCopyItem)

      $paramRemoveItem = @{
         Path          = $FolderPath
         Recurse       = $true
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (Remove-Item @paramRemoveItem)
   }
   #endregion Git

   #region HPHelpAndSupport
   $FolderName = '\HP Help and Support'
   $FolderPath = ($BasePath + $FolderName)

   $paramTestPath = @{
      Path          = $FolderPath
      PathType      = 'Container'
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if (Test-Path @paramTestPath)
   {
      $paramCopyItem = @{
         Path          = ($FolderPath + '\HP Support Assistant.lnk')
         Destination   = $BasePath
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (Copy-Item @paramCopyItem)

      $paramRemoveItem = @{
         Path          = $FolderPath
         Recurse       = $true
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (Remove-Item @paramRemoveItem)
   }
   #endregion HPHelpAndSupport

   #region KeePassXC
   $FolderName = '\KeePassXC'
   $FolderPath = ($BasePath + $FolderName)

   $paramTestPath = @{
      Path          = $FolderPath
      PathType      = 'Container'
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if (Test-Path @paramTestPath)
   {
      $paramCopyItem = @{
         Path          = ($FolderPath + '\KeePassXC.lnk')
         Destination   = $BasePath
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (Copy-Item @paramCopyItem)

      $paramRemoveItem = @{
         Path          = $FolderPath
         Recurse       = $true
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (Remove-Item @paramRemoveItem)
   }
   #endregion KeePassXC

   #region LockHunter
   $FolderName = '\LockHunter'
   $FolderPath = ($BasePath + $FolderName)

   $paramTestPath = @{
      Path          = $FolderPath
      PathType      = 'Container'
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if (Test-Path @paramTestPath)
   {
      $paramCopyItem = @{
         Path          = ($FolderPath + '\LockHunter.lnk')
         Destination   = $BasePath
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (Copy-Item @paramCopyItem)

      $paramRemoveItem = @{
         Path          = $FolderPath
         Recurse       = $true
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (Remove-Item @paramRemoveItem)
   }
   #endregion LockHunter

   #region MicrosoftIntuneManagementExtension
   $FolderName = '\Microsoft Intune Management Extension'
   $FolderPath = ($BasePath + $FolderName)

   $paramTestPath = @{
      Path          = $FolderPath
      PathType      = 'Container'
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if (Test-Path @paramTestPath)
   {
      $paramRemoveItem = @{
         Path          = $FolderPath
         Recurse       = $true
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (Remove-Item @paramRemoveItem)
   }
   #endregion MicrosoftIntuneManagementExtension

   #region MicrosoftSilverlight
   $FolderName = '\Microsoft Silverlight'
   $FolderPath = ($BasePath + $FolderName)

   $paramTestPath = @{
      Path          = $FolderPath
      PathType      = 'Container'
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if (Test-Path @paramTestPath)
   {
      $paramRemoveItem = @{
         Path          = $FolderPath
         Recurse       = $true
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (Remove-Item @paramRemoveItem)
   }
   #endregion MicrosoftSilverlight

   #region Python
   $FolderName = '\Python 3.9'
   $FolderPath = ($BasePath + $FolderName)

   $paramTestPath = @{
      Path          = $FolderPath
      PathType      = 'Container'
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if (Test-Path @paramTestPath)
   {
      $paramRemoveItem = @{
         Path          = $FolderPath
         Recurse       = $true
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (Remove-Item @paramRemoveItem)
   }
   #endregion Python

   #region Node.js
   $FolderName = '\Node.js'
   $FolderPath = ($BasePath + $FolderName)

   $paramTestPath = @{
      Path          = $FolderPath
      PathType      = 'Container'
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if (Test-Path @paramTestPath)
   {
      $paramCopyItem = @{
         Path          = ($FolderPath + '\Node.js.lnk')
         Destination   = $BasePath
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (Copy-Item @paramCopyItem)

      $paramRemoveItem = @{
         Path          = $FolderPath
         Recurse       = $true
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (Remove-Item @paramRemoveItem)
   }
   #endregion Node.js

   #region VideoLAN
   $FolderName = '\VideoLAN'
   $FolderPath = ($BasePath + $FolderName)

   $paramTestPath = @{
      Path          = $FolderPath
      PathType      = 'Container'
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if (Test-Path @paramTestPath)
   {
      $paramCopyItem = @{
         Path          = ($FolderPath + '\VLC media player.lnk')
         Destination   = $BasePath
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (Copy-Item @paramCopyItem)

      $paramRemoveItem = @{
         Path          = $FolderPath
         Recurse       = $true
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (Remove-Item @paramRemoveItem)
   }
   #endregion VideoLAN

   #region WinMerge
   $FolderName = '\WinMerge'
   $FolderPath = ($BasePath + $FolderName)

   $paramTestPath = @{
      Path          = $FolderPath
      PathType      = 'Container'
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if (Test-Path @paramTestPath)
   {
      $paramCopyItem = @{
         Path          = ($FolderPath + '\WinMerge.lnk')
         Destination   = $BasePath
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (Copy-Item @paramCopyItem)

      $paramRemoveItem = @{
         Path          = $FolderPath
         Recurse       = $true
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (Remove-Item @paramRemoveItem)
   }
   #endregion WinMerge

   #region Yubico
   $Yubico = '\Yubico'
   $YubicoPath = ($BasePath + $Yubico)
   $YubicoAuthenticator = '\Yubico Authenticator'
   $YubicoAuthenticatorPath = ($BasePath + $YubicoAuthenticator)

   $paramTestYubicoPath = @{
      Path          = $YubicoPath
      PathType      = 'Container'
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   $paramTestYubicoAuthenticatorPath = @{
      Path          = $YubicoAuthenticatorPath
      PathType      = 'Container'
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if ((Test-Path @paramTestYubicoPath ) -and (Test-Path @paramTestYubicoAuthenticatorPath))
   {
      # Move the Yubico Authenticator to the Yubico directory
      $paramMoveItem = @{
         Path          = $YubicoAuthenticatorPath
         Destination   = $YubicoPath
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (Move-Item @paramMoveItem)

      # Remove some links
      $paramRemoveItem = @{
         Path          = ($YubicoPath + '\Yubikey Manager\Uninstall YubiKey Manager.lnk')
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (Remove-Item @paramRemoveItem)

      $paramRemoveItem = @{
         Path          = ($YubicoPath + '\YubiKey Personalization Tool\Uninstall.lnk')
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (Remove-Item @paramRemoveItem)

      $paramRemoveItem = @{
         Path          = ($YubicoPath + '\YubiKey Personalization Tool\Yubico Web page.url')
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (Remove-Item @paramRemoveItem)

      $paramRemoveItem = @{
         Path          = ($YubicoPath + '\YubiKey PIV Manager\Uninstall YubiKey PIV Manager.lnk')
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (Remove-Item @paramRemoveItem)
   }
   #endregion Yubico

   #region Structure
   #region Dev
   $RegionName = 'Dev'
   $RegionNamePath = ($BasePath + '\' + $RegionName)

   $paramTestPath = @{
      Path          = $RegionNamePath
      PathType      = 'Container'
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if (-not ((Test-Path @paramTestPath)))
   {
      $paramNewItem = @{
         Path          = ($BasePath)
         Name          = $RegionName
         ItemType      = 'Directory'
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (New-Item @paramNewItem)
   }

   $MoveItems = @(
      'CMake (cmake-gui)'
      'Git GUI'
      'Node.js'
      'WinMerge'
   )

   foreach ($MoveItem in $MoveItems)
   {
      $MoveItemPath = ($BasePath + '\' + $MoveItem + '.lnk')

      $paramTestPath = @{
         Path          = $MoveItemPath
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      if (Test-Path @paramTestPath)
      {
         $paramMoveItem = @{
            Path          = $MoveItemPath
            Destination   = $RegionNamePath
            Force         = $true
            Confirm       = $false
            ErrorAction   = $SCT
            WarningAction = $SCT
         }
         $null = (Move-Item @paramMoveItem)
      }
   }
   #endregion Dev

   #region Tools
   $RegionName = 'Tools'
   $RegionNamePath = ($BasePath + '\' + $RegionName)

   $paramTestPath = @{
      Path          = $RegionNamePath
      PathType      = 'Container'
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if (-not ((Test-Path @paramTestPath)))
   {
      $paramNewItem = @{
         Path          = ($BasePath)
         Name          = $RegionName
         ItemType      = 'Directory'
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (New-Item @paramNewItem)
   }

   $MoveItems = @(
      '7-Zip File Manager'
      'Chocolatey Cleaner'
      'Chocolatey GUI'
      'ClickShare Launcher'
      'ClickShare'
      'Cyberduck'
      'KeePass 2'
      'KeePassXC'
      'LockHunter'
      'Make Me Admin'
      'paint.net'
      'PowerToys (Preview)'
      'VLC media player'
      'WinSCP'
   )

   foreach ($MoveItem in $MoveItems)
   {
      $MoveItemPath = ($BasePath + '\' + $MoveItem + '.lnk')

      $paramTestPath = @{
         Path          = $MoveItemPath
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      if (Test-Path @paramTestPath)
      {
         $paramMoveItem = @{
            Path          = $MoveItemPath
            Destination   = $RegionNamePath
            Force         = $true
            Confirm       = $false
            ErrorAction   = $SCT
            WarningAction = $SCT
         }
         $null = (Move-Item @paramMoveItem)
      }
   }
   #endregion Tools

   #region Browser
   $RegionName = 'Browser'
   $RegionNamePath = ($BasePath + '\' + $RegionName)

   $paramTestPath = @{
      Path          = $RegionNamePath
      PathType      = 'Container'
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if (-not ((Test-Path @paramTestPath)))
   {
      $paramNewItem = @{
         Path          = ($BasePath)
         Name          = $RegionName
         ItemType      = 'Directory'
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (New-Item @paramNewItem)
   }

   $MoveItems = @(
      'Chromium'
      'Firefox'
      'Google Chrome'
      'Microsoft Edge Beta'
      'Microsoft Edge'
   )

   foreach ($MoveItem in $MoveItems)
   {
      $MoveItemPath = ($BasePath + '\' + $MoveItem + '.lnk')

      $paramTestPath = @{
         Path          = $MoveItemPath
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      if (Test-Path @paramTestPath)
      {
         $paramMoveItem = @{
            Path          = $MoveItemPath
            Destination   = $RegionNamePath
            Force         = $true
            Confirm       = $false
            ErrorAction   = $SCT
            WarningAction = $SCT
         }
         $null = (Move-Item @paramMoveItem)
      }
   }
   #endregion Browser

   #region Office
   $RegionName = 'Microsoft Office'
   $RegionNamePath = ($BasePath + '\' + $RegionName)

   $paramTestPath = @{
      Path          = $RegionNamePath
      PathType      = 'Container'
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if (-not ((Test-Path @paramTestPath)))
   {
      $paramNewItem = @{
         Path          = ($BasePath)
         Name          = $RegionName
         ItemType      = 'Directory'
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (New-Item @paramNewItem)
   }

   $MoveItems = @(
      'Excel'
      'OneNote 2016'
      'Outlook'
      'PowerPoint'
      'Project'
      'Visio'
      'Word'
   )

   foreach ($MoveItem in $MoveItems)
   {
      $MoveItemPath = ($BasePath + '\' + $MoveItem + '.lnk')

      $paramTestPath = @{
         Path          = $MoveItemPath
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      if (Test-Path @paramTestPath)
      {
         $paramMoveItem = @{
            Path          = $MoveItemPath
            Destination   = $RegionNamePath
            Force         = $true
            Confirm       = $false
            ErrorAction   = $SCT
            WarningAction = $SCT
         }
         $null = (Move-Item @paramMoveItem)
      }
   }
   #endregion Office
   #endregion Structure
}

end
{
   exit (0)
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
