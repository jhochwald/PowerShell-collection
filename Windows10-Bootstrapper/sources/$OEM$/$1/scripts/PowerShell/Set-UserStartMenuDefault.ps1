#requires -Version 1.0

<#
      .SYNOPSIS
      Setup the default enaTec Start Menu for the User

      .DESCRIPTION
      Setup the default enaTec Start Menu for the User

      .EXAMPLE
      PS C:\> .\Set-UserStartMenuDefault.ps1

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
   Write-Output -InputObject 'Setup the default enaTec Start Menu for the User'

   #region Defaults
   $SCT = 'SilentlyContinue'
   $BasePath = ("$env:HOMEDRIVE\Users\" + $env:USERNAME + '\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\')
   #endregion Defaults
}

process
{
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

   #region Fiddler
   $FiddlerPath = ($BasePath + '\Fiddler 4.lnk')

   $paramTestPath = @{
      Path          = $FiddlerPath
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if (Test-Path @paramTestPath)
   {
      $paramMoveItem = @{
         Path          = $FiddlerPath
         Destination   = $RegionNamePath
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (Move-Item @paramMoveItem)
   }

   $FiddlerScriptEditorPath = ($BasePath + '\Fiddler ScriptEditor.lnk')

   $paramTestPath = @{
      Path          = $FiddlerScriptEditorPath
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if (Test-Path @paramTestPath)
   {
      $paramMoveItem = @{
         Path          = $FiddlerScriptEditorPath
         Destination   = $RegionNamePath
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }

      $null = (Move-Item @paramMoveItem)
   }
   #endregion Fiddler

   #region GitHubInc
   $GitHubIncPath = ($BasePath + '\GitHub, Inc\GitHub Desktop.lnk')

   $paramTestPath = @{
      Path          = $GitHubIncPath
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if (Test-Path @paramTestPath)
   {
      $paramMoveItem = @{
         Path          = $GitHubIncPath
         Destination   = $RegionNamePath
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (Move-Item @paramMoveItem)
   }

   $GitHubIncPath = ($BasePath + '\GitHub, Inc\')

   $paramTestPath = @{
      Path          = $GitHubIncPath
      PathType      = 'Container'
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if (Test-Path @paramTestPath)
   {
      $paramRemoveItem = @{
         Path          = $GitHubIncPath
         Recurse       = $true
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (Remove-Item @paramRemoveItem)
   }
   #endregion GitHubInc

   #region Postman
   $PostmanPath = ($BasePath + '\Postman\Postman.lnk')

   $paramTestPath = @{
      Path          = $PostmanPath
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if (Test-Path @paramTestPath)
   {
      $paramMoveItem = @{
         Path          = $PostmanPath
         Destination   = $RegionNamePath
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (Move-Item @paramMoveItem)
   }

   $PostmanPath = ($BasePath + '\Postman')

   $paramTestPath = @{
      Path          = $PostmanPath
      PathType      = 'Container'
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if (Test-Path @paramTestPath)
   {
      $paramRemoveItem = @{
         Path          = $PostmanPath
         Recurse       = $true
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (Remove-Item @paramRemoveItem)
   }
   #endregion Postman

   #region MarkPad
   $MarkPadPath = ($BasePath + '\MarkPad\MarkPad.lnk')

   $paramTestPath = @{
      Path          = $MarkPadPath
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if (Test-Path @paramTestPath)
   {
      $paramMoveItem = @{
         Path          = $MarkPadPath
         Destination   = $RegionNamePath
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (Move-Item @paramMoveItem)
   }

   $MarkPadPath = ($BasePath + '\MarkPad')

   $paramTestPath = @{
      Path          = $MarkPadPath
      PathType      = 'Container'
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if (Test-Path @paramTestPath)
   {
      $paramRemoveItem = @{
         Path          = $MarkPadPath
         Recurse       = $true
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (Remove-Item @paramRemoveItem)
   }
   #endregion MarkPad
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

   #region AutoDarkMode
   $AutoDarkModePath = ($BasePath + '\Auto Dark Mode.lnk')

   $paramTestPath = @{
      Path          = $AutoDarkModePath
      ErrorAction   = $SCT
      WarningAction = $SCT
   }

   if (Test-Path @paramTestPath)
   {
      $paramMoveItem = @{
         Path          = $AutoDarkModePath
         Destination   = $RegionNamePath
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (Move-Item @paramMoveItem)
   }
   #endregion AutoDarkMode

   #region MarkText
   $MarkTextPath = ($BasePath + '\Mark Text.lnk')

   $paramTestPath = @{
      Path          = $MarkTextPath
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if (Test-Path @paramTestPath)
   {
      $paramMoveItem = @{
         Path          = $MarkTextPath
         Destination   = $RegionNamePath
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (Move-Item @paramMoveItem)
   }
   #endregion MarkText

   #region Graphviz
   $paramGetItem = @{
      Path          = ($BasePath + '\Graphviz*')
      Force         = $true
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   $GraphvizBasePath = (Get-Item @paramGetItem | Select-Object -ExpandProperty Name)

   if ($GraphvizBasePath)
   {
      $paramTestPath = @{
         Path          = ($BasePath + '\' + $GraphvizBasePath + '\gvedit.exe.lnk')
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      if (Test-Path @paramTestPath)
      {
         $paramCopyItem = @{
            Path          = ($BasePath + '\' + $GraphvizBasePath + '\gvedit.exe.lnk')
            Destination   = ($RegionNamePath + '\Graphviz.lnk')
            Force         = $true
            Confirm       = $false
            ErrorAction   = $SCT
            WarningAction = $SCT
         }
         $null = (Copy-Item @paramCopyItem)
      }

      $paramRemoveItem = @{
         Path          = ($BasePath + '\' + $GraphvizBasePath)
         Recurse       = $true
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (Remove-Item @paramRemoveItem)
   }

   $MarkTextPath = ($BasePath + '\Mark Text.lnk')

   $paramTestPath = @{
      Path          = $MarkTextPath
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if (Test-Path @paramTestPath)
   {
      $paramMoveItem = @{
         Path          = $MarkTextPath
         Destination   = $RegionNamePath
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (Move-Item @paramMoveItem)
   }
   #endregion Graphviz
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

   #region Brave
   $BravePath = ($BasePath + '\Brave.lnk')

   $paramTestPath = @{
      Path          = $BravePath
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if (Test-Path @paramTestPath)
   {
      $paramMoveItem = @{
         Path          = $BravePath
         Destination   = $RegionNamePath
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (Move-Item @paramMoveItem)
   }
   #endregion Brave
   #endregion Browser

   #region Office
   $RegionName = 'Office'
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

   #region MicrosoftTeams
   $MicrosoftTeamsPath = ($BasePath + '\Microsoft Teams.lnk')

   $paramTestPath = @{
      Path          = $MicrosoftTeamsPath
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if (Test-Path @paramTestPath)
   {
      $paramMoveItem = @{
         Path          = $MicrosoftTeamsPath
         Destination   = $RegionNamePath
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (Move-Item @paramMoveItem)
   }
   #endregion MicrosoftTeams

   #region OneDrive
   $OneDrivePath = ($BasePath + '\OneDrive.lnk')

   $paramTestPath = @{
      Path          = $OneDrivePath
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if (Test-Path @paramTestPath)
   {
      $paramMoveItem = @{
         Path          = $OneDrivePath
         Destination   = $RegionNamePath
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (Move-Item @paramMoveItem)
   }
   #endregion OneDrive
   #endregion Office
   #endregion Structure

   #region UninstallPIVManager
   $UninstallPIVManagerPath = ($BasePath + '\Yubico\Yubikey PIV Manager\Uninstall PIV Manager.lnk')

   $paramTestPath = @{
      Path          = $UninstallPIVManagerPath
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if (Test-Path @paramTestPath)
   {
      $paramRemoveItem = @{
         Path          = $UninstallPIVManagerPath
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (Remove-Item @paramRemoveItem)
   }
   #endregion UninstallPIVManager
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
