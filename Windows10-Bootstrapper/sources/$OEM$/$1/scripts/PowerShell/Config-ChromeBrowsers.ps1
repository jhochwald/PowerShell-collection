#requires -Version 3.0

<#
      .SYNOPSIS
      Create a JSON based configuration for Chromium based Browsers

      .DESCRIPTION
      Create and deploy a JSON based configuration for Chromium based Browsers

      .NOTES
      For now, Chromium, Google Chrome, Microsoft Edge, and Microsoft Edge Beta are supported

      Version 1.0.0

      .LINK
      http://enatec.io
#>
[CmdletBinding(ConfirmImpact = 'Low')]
param ()

begin
{
   Write-Output -InputObject 'Create and deploy a JSON based configuration for Chromium based Browsers'

   #region Defaults
   $SCT = 'SilentlyContinue'
   #endregion Defaults

   #region Variables
   $DefaultHome = 'http://www.google.com/ig'
   $BrowserPath = $null
   $MasterPreferenceFile = 'master_preferences'
   #endregion Variables

   #region ChromePreferences
   $ChromePreferences = [PSCustomObject]@{ }
   $ChromePreferences | Add-Member -NotePropertyName homepage -NotePropertyValue $DefaultHome
   $ChromePreferences | Add-Member -NotePropertyName homepage_is_newtabpage -NotePropertyValue $false
   $ChromePreferences | Add-Member -NotePropertyName browser -NotePropertyValue ([PSCustomObject]@{ })
   $ChromePreferences.browser | Add-Member -NotePropertyName show_home_button -NotePropertyValue $true
   $ChromePreferences | Add-Member -NotePropertyName session -NotePropertyValue ([PSCustomObject]@{ })
   $ChromePreferences.session | Add-Member -NotePropertyName restore_on_startup -NotePropertyValue 4
   $ChromePreferences.session | Add-Member -NotePropertyName startup_urls -NotePropertyValue (@($DefaultHome))
   $ChromePreferences | Add-Member -NotePropertyName bookmark_bar -NotePropertyValue ([PSCustomObject]@{ })
   $ChromePreferences.bookmark_bar | Add-Member -NotePropertyName show_on_all_tabs -NotePropertyValue $true
   $ChromePreferences | Add-Member -NotePropertyName sync_promo -NotePropertyValue ([PSCustomObject]@{ })
   $ChromePreferences.sync_promo | Add-Member -NotePropertyName show_on_first_run_allowed -NotePropertyValue $false
   $ChromePreferences | Add-Member -NotePropertyName distribution -NotePropertyValue ([PSCustomObject]@{ })
   $ChromePreferences.distribution | Add-Member -NotePropertyName skip_first_run_ui -NotePropertyValue $true
   $ChromePreferences.distribution | Add-Member -NotePropertyName import_bookmarks -NotePropertyValue $false
   $ChromePreferences.distribution | Add-Member -NotePropertyName import_history -NotePropertyValue $false
   $ChromePreferences.distribution | Add-Member -NotePropertyName import_search_engine -NotePropertyValue $true
   $ChromePreferences.distribution | Add-Member -NotePropertyName suppress_first_run_bubble -NotePropertyValue $true
   $ChromePreferences.distribution | Add-Member -NotePropertyName create_all_shortcuts -NotePropertyValue $false
   $ChromePreferences.distribution | Add-Member -NotePropertyName do_not_launch_chrome -NotePropertyValue $true
   $ChromePreferences.distribution | Add-Member -NotePropertyName do_not_register_for_update_launch -NotePropertyValue $true
   $ChromePreferences.distribution | Add-Member -NotePropertyName do_not_create_desktop_shortcut -NotePropertyValue $true
   $ChromePreferences.distribution | Add-Member -NotePropertyName do_not_create_quick_launch_shortcut -NotePropertyValue $true
   $ChromePreferences.distribution | Add-Member -NotePropertyName do_not_create_taskbar_shortcut -NotePropertyValue $false
   $ChromePreferences.distribution | Add-Member -NotePropertyName make_chrome_default -NotePropertyValue $false
   $ChromePreferences.distribution | Add-Member -NotePropertyName ping_delay -NotePropertyValue 60
   $ChromePreferences.distribution | Add-Member -NotePropertyName make_chrome_default_for_user -NotePropertyValue $false
   $ChromePreferences.distribution | Add-Member -NotePropertyName suppress_first_run_default_browser_prompt -NotePropertyValue $true
   $ChromePreferences.distribution | Add-Member -NotePropertyName system_level -NotePropertyValue $true
   $ChromePreferences.distribution | Add-Member -NotePropertyName verbose_logging -NotePropertyValue $false
   $ChromePreferences.distribution | Add-Member -NotePropertyName allow_downgrade -NotePropertyValue $false
   $ChromePreferences | Add-Member -NotePropertyName first_run_tabs -NotePropertyValue ([PSObject]@($DefaultHome))
   $paramConvertToJson = @{
      Depth         = 10
      Compress      = $false
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   $ChromePreferencesJson = ($ChromePreferences | ConvertTo-Json @paramConvertToJson)
   #endregion ChromePreferences

   #region EdgePreferences
   $EdgePreferences = [PSCustomObject]@{ }
   $EdgePreferences | Add-Member -NotePropertyName homepage_is_newtabpage -NotePropertyValue $false
   $EdgePreferences | Add-Member -NotePropertyName browser -NotePropertyValue ([PSCustomObject]@{ })
   $EdgePreferences.browser | Add-Member -NotePropertyName show_home_button -NotePropertyValue $true
   $EdgePreferences | Add-Member -NotePropertyName session -NotePropertyValue ([PSCustomObject]@{ })
   $EdgePreferences.session | Add-Member -NotePropertyName restore_on_startup -NotePropertyValue 4
   $EdgePreferences | Add-Member -NotePropertyName bookmark_bar -NotePropertyValue ([PSCustomObject]@{ })
   $EdgePreferences.bookmark_bar | Add-Member -NotePropertyName show_on_all_tabs -NotePropertyValue $true
   $EdgePreferences | Add-Member -NotePropertyName sync_promo -NotePropertyValue ([PSCustomObject]@{ })
   $EdgePreferences.sync_promo | Add-Member -NotePropertyName show_on_first_run_allowed -NotePropertyValue $false
   $EdgePreferences | Add-Member -NotePropertyName distribution -NotePropertyValue ([PSCustomObject]@{ })
   $EdgePreferences.distribution | Add-Member -NotePropertyName skip_first_run_ui -NotePropertyValue $true
   $EdgePreferences.distribution | Add-Member -NotePropertyName import_bookmarks -NotePropertyValue $false
   $EdgePreferences.distribution | Add-Member -NotePropertyName import_history -NotePropertyValue $false
   $EdgePreferences.distribution | Add-Member -NotePropertyName import_search_engine -NotePropertyValue $true
   $EdgePreferences.distribution | Add-Member -NotePropertyName suppress_first_run_bubble -NotePropertyValue $true
   $EdgePreferences.distribution | Add-Member -NotePropertyName create_all_shortcuts -NotePropertyValue $false
   $EdgePreferences.distribution | Add-Member -NotePropertyName do_not_launch_chrome -NotePropertyValue $true
   $EdgePreferences.distribution | Add-Member -NotePropertyName do_not_register_for_update_launch -NotePropertyValue $true
   $EdgePreferences.distribution | Add-Member -NotePropertyName do_not_create_desktop_shortcut -NotePropertyValue $true
   $EdgePreferences.distribution | Add-Member -NotePropertyName do_not_create_quick_launch_shortcut -NotePropertyValue $true
   $EdgePreferences.distribution | Add-Member -NotePropertyName do_not_create_taskbar_shortcut -NotePropertyValue $false
   $EdgePreferences.distribution | Add-Member -NotePropertyName make_chrome_default -NotePropertyValue $false
   $EdgePreferences.distribution | Add-Member -NotePropertyName ping_delay -NotePropertyValue 60
   $EdgePreferences.distribution | Add-Member -NotePropertyName make_chrome_default_for_user -NotePropertyValue $false
   $EdgePreferences.distribution | Add-Member -NotePropertyName suppress_first_run_default_browser_prompt -NotePropertyValue $true
   $EdgePreferences.distribution | Add-Member -NotePropertyName system_level -NotePropertyValue $true
   $EdgePreferences.distribution | Add-Member -NotePropertyName verbose_logging -NotePropertyValue $false
   $EdgePreferences.distribution | Add-Member -NotePropertyName allow_downgrade -NotePropertyValue $false
   $paramConvertToJson = @{
      Depth         = 10
      Compress      = $false
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   $EdgePreferencesJson = ($EdgePreferences | ConvertTo-Json @paramConvertToJson)
   #endregion EdgePreferences
}

process
{
   #region Chromium
   $BrowserPath = "$env:ProgramW6432\Chromium\Application\"

   $paramTestPath = @{
      Path          = $BrowserPath
      PathType      = 'Container'
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if (Test-Path @paramTestPath )
   {
      Write-Verbose -Message 'Configure Chromium X64'

      $paramTestPath = @{
         Path          = ($BrowserPath + $MasterPreferenceFile)
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      if (Test-Path @paramTestPath )
      {
         $paramRemoveItem = @{
            Path          = ($BrowserPath + $MasterPreferenceFile)
            Force         = $true
            Confirm       = $false
            WarningAction = $SCT
            ErrorAction   = $SCT
         }
         $null = (Remove-Item @paramRemoveItem)
      }

      $paramNewItem = @{
         Path          = $BrowserPath
         Name          = $MasterPreferenceFile
         Value         = $ChromePreferencesJson
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (New-Item @paramNewItem)
   }

   $BrowserPath = "${env:ProgramFiles(x86)}\Chromium\Application\"

   $paramTestPath = @{
      Path          = $BrowserPath
      PathType      = 'Container'
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if (Test-Path @paramTestPath )
   {
      Write-Verbose -Message 'Configure Chromium X86'

      $paramTestPath = @{
         Path          = ($BrowserPath + $MasterPreferenceFile)
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      if (Test-Path @paramTestPath )
      {
         $paramRemoveItem = @{
            Path          = ($BrowserPath + $MasterPreferenceFile)
            Force         = $true
            Confirm       = $false
            WarningAction = $SCT
            ErrorAction   = $SCT
         }
         $null = (Remove-Item @paramRemoveItem)
      }

      $paramNewItem = @{
         Path          = $BrowserPath
         Name          = $MasterPreferenceFile
         Value         = $ChromePreferencesJson
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (New-Item @paramNewItem)
   }
   #endregion Chromium

   #region GoogleChrome
   $BrowserPath = "$env:ProgramW6432\Google\Chrome\Application\"

   $paramTestPath = @{
      Path          = $BrowserPath
      PathType      = 'Container'
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if (Test-Path @paramTestPath )
   {
      Write-Verbose -Message 'Configure Google Chrome X64'

      $paramTestPath = @{
         Path          = ($BrowserPath + $MasterPreferenceFile)
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      if (Test-Path @paramTestPath )
      {
         $paramRemoveItem = @{
            Path          = ($BrowserPath + $MasterPreferenceFile)
            Force         = $true
            Confirm       = $false
            WarningAction = $SCT
            ErrorAction   = $SCT
         }
         $null = (Remove-Item @paramRemoveItem)
      }

      $paramNewItem = @{
         Path          = $BrowserPath
         Name          = $MasterPreferenceFile
         Value         = $ChromePreferencesJson
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (New-Item @paramNewItem)
   }

   $BrowserPath = "${env:ProgramFiles(x86)}\Google\Chrome\Application\"

   $paramTestPath = @{
      Path          = $BrowserPath
      PathType      = 'Container'
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if (Test-Path @paramTestPath )
   {
      Write-Verbose -Message 'Configure Google Chrome X86'

      $paramTestPath = @{
         Path          = ($BrowserPath + $MasterPreferenceFile)
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      if (Test-Path @paramTestPath )
      {
         $paramRemoveItem = @{
            Path          = ($BrowserPath + $MasterPreferenceFile)
            Force         = $true
            Confirm       = $false
            WarningAction = $SCT
            ErrorAction   = $SCT
         }
         $null = (Remove-Item @paramRemoveItem)
      }

      $paramNewItem = @{
         Path          = $BrowserPath
         Name          = $MasterPreferenceFile
         Value         = $ChromePreferencesJson
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (New-Item @paramNewItem)
   }
   #endregion GoogleChrome

   #region MicrosoftEdge
   $BrowserPath = "$env:ProgramW6432\Microsoft\Edge\Application\"

   $paramTestPath = @{
      Path          = $BrowserPath
      PathType      = 'Container'
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if (Test-Path @paramTestPath )
   {
      Write-Verbose -Message 'Configure Microsoft Edge Release X64'

      $paramTestPath = @{
         Path          = ($BrowserPath + $MasterPreferenceFile)
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      if (Test-Path @paramTestPath )
      {
         $paramRemoveItem = @{
            Path          = ($BrowserPath + $MasterPreferenceFile)
            Force         = $true
            Confirm       = $false
            WarningAction = $SCT
            ErrorAction   = $SCT
         }
         $null = (Remove-Item @paramRemoveItem)
      }

      $paramNewItem = @{
         Path          = $BrowserPath
         Name          = $MasterPreferenceFile
         Value         = $EdgePreferencesJson
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (New-Item @paramNewItem)
   }

   $BrowserPath = "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\"

   $paramTestPath = @{
      Path          = $BrowserPath
      PathType      = 'Container'
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if (Test-Path @paramTestPath )
   {
      Write-Verbose -Message 'Configure Microsoft Edge Release X86'

      $paramTestPath = @{
         Path          = ($BrowserPath + $MasterPreferenceFile)
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      if (Test-Path @paramTestPath )
      {
         $paramRemoveItem = @{
            Path          = ($BrowserPath + $MasterPreferenceFile)
            Force         = $true
            Confirm       = $false
            WarningAction = $SCT
            ErrorAction   = $SCT
         }
         $null = (Remove-Item @paramRemoveItem)
      }

      $paramNewItem = @{
         Path          = $BrowserPath
         Name          = $MasterPreferenceFile
         Value         = $EdgePreferencesJson
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (New-Item @paramNewItem)
   }
   #endregion MicrosoftEdge

   #region MicrosoftEdgeBeta
   $BrowserPath = "$env:ProgramW6432\Microsoft\Edge Beta\Application\"

   $paramTestPath = @{
      Path          = $BrowserPath
      PathType      = 'Container'
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if (Test-Path @paramTestPath )
   {
      Write-Verbose -Message 'Configure Microsoft Edge Beta X64'

      $paramTestPath = @{
         Path          = ($BrowserPath + $MasterPreferenceFile)
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      if (Test-Path @paramTestPath )
      {
         $paramRemoveItem = @{
            Path          = ($BrowserPath + $MasterPreferenceFile)
            Force         = $true
            Confirm       = $false
            WarningAction = $SCT
            ErrorAction   = $SCT
         }
         $null = (Remove-Item @paramRemoveItem)
      }

      $paramNewItem = @{
         Path          = $BrowserPath
         Name          = $MasterPreferenceFile
         Value         = $EdgePreferencesJson
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (New-Item @paramNewItem)
   }

   $BrowserPath = "${env:ProgramFiles(x86)}\Microsoft\Edge Beta\Application\"

   $paramTestPath = @{
      Path          = $BrowserPath
      PathType      = 'Container'
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if (Test-Path @paramTestPath )
   {
      Write-Verbose -Message 'Configure Microsoft Edge Beta X86'

      $paramTestPath = @{
         Path          = ($BrowserPath + $MasterPreferenceFile)
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      if (Test-Path @paramTestPath )
      {
         $paramRemoveItem = @{
            Path          = ($BrowserPath + $MasterPreferenceFile)
            Force         = $true
            Confirm       = $false
            WarningAction = $SCT
            ErrorAction   = $SCT
         }
         $null = (Remove-Item @paramRemoveItem)
      }

      $paramNewItem = @{
         Path          = $BrowserPath
         Name          = $MasterPreferenceFile
         Value         = $EdgePreferencesJson
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (New-Item @paramNewItem)
   }
   #endregion MicrosoftEdgeBeta
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
