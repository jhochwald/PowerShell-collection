<#
      .SYNOPSIS
      Change the Google Chrome config to some defaults

      .DESCRIPTION
      Change the Google Chrome config to some defaults.
      Chromium or any other Chromium based browsers are not yet supported.

      .PARAMETER Profile
      Name of the Google Chrome Profile.
      The default is Default

      .EXAMPLE
      PS C:\> .\Set-ChromeDefaultPreferences.ps1

      Change the Google Chrome config to some defaults.
      We use the default profile (Default)

      .EXAMPLE
      PS C:\> .\Set-ChromeDefaultPreferences.ps1 -Profile 'Work'

      Change the Google Chrome config to some defaults
      We use the profile Work and not the default one

      .NOTES
      Chromium or any other Chromium based browsers are not yet supported.

      I created this to tweak the existing Google Chrome configuration.

      This is open-source software, if you find an issue try to fix it yourself.
      There is no support and/or warranty in any kind

      .LINK
      http://www.enatec.io

      .LINK
      Get-Process

      .LINK
      Stop-Process

      .LINK
      ConvertFrom-Json

      .LINK
      Test-Path

      .LINK
      Get-Content

      .LINK
      Where-Object

      .LINK
      Add-Member

      .LINK
      ConvertTo-Json

      .LINK
      Set-Content
#>
[CmdletBinding(ConfirmImpact = 'Low')]
param
(
   [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
   [AllowEmptyCollection()]
   [AllowEmptyString()]
   [AllowNull()]
   [Alias('ChromeProfile', 'ChromeProfileName', 'ProfileName')]
   [string]
   $Profile = 'Default'
)

begin
{
   #region Cleanup
   $NewConfig = $null
   $ChromePreferencesValues = $null
   $DefaultConfigValues = $null
   $Property = $null
   #endregion Cleanup

   #region Defaults
   if ($Profile)
   {
      # We have an command line parameter, so we use this
      $ChromeProfile = $Profile
   }
   else
   {
      # We do NOT have an command line parameter, so we add a default
      $ChromeProfile = 'Default'
   }

   $Encoding = 'UTF8'
   $STP = 'Stop'

   # Create the new object
   $NewConfig = @{
   }
   #endregion Defaults

   #region PSEdition
   if ($PSVersionTable.PSEdition -eq 'Desktop')
   {
      # Desktop Edition - Windows
      $BaseChromeProfilePath = "$env:LOCALAPPDATA\Google\Chrome\User Data\"

      #region KillChrome
      #region Splat
      $paramGetProcess = @{
         Name        = 'chrome'
         ErrorAction = 'SilentlyContinue'
      }

      $paramStopProcess = @{
         Force       = $true
         ErrorAction = 'SilentlyContinue'
      }
      #endregion Splat

      # Kill Chrome
      $null = (Get-Process @paramGetProcess | Stop-Process @paramStopProcess)
      #endregion KillChrome
   }
   elseif ($PSVersionTable.PSEdition -eq 'Core')
   {
      #region PowerShellCoreHandling
      if ($IsLinux -eq $true)
      {
         # Core Edition - Linux/Unix
         #region Splat
         $paramWriteWarning = @{
            Message = 'PowerShell Core on Linux/Unix is not yet tested or supported'
         }
         #endregion Splat

         Write-Warning @paramWriteWarning

         #region Splat
         $paramWriteError = @{
            Message     = 'Sorry, Linux is not yet supüported'
            Category    = 'OperationStopped'
            ErrorAction = $STP
         }
         #endregion Splat

         Write-Error @paramWriteError
      }
      elseif ($IsMacOS -eq $true)
      {
         # Core Edition - macOS or Mac OSX
         $BaseChromeProfilePath = "$env:HOME/Library/Application Support/Google/Chrome/"

         #region KillChrome
         #region Splat
         $paramGetProcess = @{
            Name        = 'Google Chrome*'
            ErrorAction = 'SilentlyContinue'
         }

         $paramStopProcess = @{
            Force       = $true
            ErrorAction = 'SilentlyContinue'
         }
         #endregion Splat

         # Kill Chrome
         $null = (Get-Process @paramGetProcess | Stop-Process @paramStopProcess)
         #endregion KillChrome
      }
      elseif ($IsWindows -eq $true)
      {
         # Core Edition - Windows
         $BaseChromeProfilePath = "$env:LOCALAPPDATA\Google\Chrome\User Data\"
      }
      else
      {
         #region Splat
         $paramWriteError = @{
            Message     = 'Unknown PowerShell Core installation'
            Category    = 'NotEnabled'
            ErrorAction = $STP
         }
         #endregion Splat

         Write-Error @paramWriteError
      }
      #endregion PowerShellCoreHandling
   }
   else
   {
      #region Splat
      $paramWriteError = @{
         Message     = 'Unknown PowerShell Edition'
         Category    = 'InvalidOperation'
         ErrorAction = $STP
      }
      #endregion Splat

      Write-Error @paramWriteError
   }
   #endregion PSEdition

   #region DefaultConfig
   #region DefaultConfigJson
   <#
         Could be an external file, but embedded is easier to handle.
         Looks crappy, but it works fine!
   #>
   $DefaultConfigJson = '{
      "credentials_enable_autosignin": false,
      "credentials_enable_service": false,
      "enable_do_not_track": true,
      "default_apps": "noinstall",
      "alternate_error_pages": {
      "enabled": false
      },
      "distribution": {
      "import_bookmarks": false,
      "make_chrome_default": false,
      "make_chrome_default_for_user": false,
      "verbose_logging": true,
      "skip_first_run_ui": true,
      "create_all_shortcuts": true,
      "suppress_first_run_default_browser_prompt": true
      },
      "autofill": {
      "enabled": false,
      "credit_card_enabled": false,
      "profile_enabled": false,
      "use_mac_address_book": false
      },
      "bookmark_bar": {
      "show_apps_shortcut": false,
      "show_on_all_tabs": true
      },
      "browser": {
      "show_home_button": true,
      "has_seen_welcome_page": true,
      "check_default_browser": false
      },
      "custom_handlers": {
      "enabled": false,
      "ignored_protocol_handlers": [],
      "registered_protocol_handlers": []
      },
      "intl": {
      "accept_languages": "en-US,en,de-DE,de"
      },
      "net": {
      "network_prediction_options": 2
      },
      "profile": {
      "block_third_party_cookies": false,
      "password_manager_enabled": false,
      "default_content_setting_values": {
      "geolocation": 1,
      "media_stream_camera": 2,
      "media_stream_mic": 2,
      "notifications": 2,
      "plugins": 2,
      "popups": 2,
      "ppapi_broker": 2,
      "midi_sysex": 2,
      "payment_handler": 2
      }
      },
      "safebrowsing": {
      "enabled": true,
      "scout_reporting_enabled": false
      },
      "search": {
      "suggest_enabled": false
      },
      "signin": {
      "allowed": false,
      "allowed_on_next_startup": false
      },
      "spellcheck": {
      "use_spelling_service": false
      },
      "tranSplate": {
      "enabled": false
      },
      "tranSplate_blocked_languages": [
      "en",
      "de"
      ],
      "dns_prefetching": {
      "enabled": false
      },
      "payments": {
      "can_make_payment_enabled": false
      },
      "webkit": {
      "webprefs": {
      "tabs_to_links": true
      }
      }
   }'
   #endregion DefaultConfigJson

   #region Splat
   $paramConvertFromJson = @{
      InputObject = $DefaultConfigJson
      ErrorAction = $STP
   }
   #endregion Splat

   # The real work: Import the embedded JSON Data
   $DefaultConfig = (ConvertFrom-Json @paramConvertFromJson)
   #endregion DefaultConfig
}

process
{
   #region ExistingConfig
   #region Splat
   $paramTestPath = @{
      Path        = ($BaseChromeProfilePath + $ChromeProfile + '\Preferences')
      ErrorAction = 'SilentlyContinue'
   }
   #endregion Splat

   if (Test-Path @paramTestPath)
   {
      # Import the existing config
      try
      {
         #region Splat
         $paramGetContent = @{
            Path        = ($BaseChromeProfilePath + $ChromeProfile + '\Preferences')
            Raw         = $true
            ErrorAction = $STP
            Encoding    = $Encoding
            Force       = $true
         }

         $paramConvertFromJson = @{
            InputObject = (Get-Content @paramGetContent )
            ErrorAction = $STP
         }
         #endregion Splat

         # The real work: Import the JSON Data
         $ChromePreferences = (ConvertFrom-Json @paramConvertFromJson)
      }
      catch
      {
         #region Splat
         $paramWriteError = @{
            Message     = 'Unable to load the configuration file'
            Category    = 'ReadError'
            ErrorAction = $STP
         }
         #endregion Splat

         Write-Error @paramWriteError
      }
   }
   else
   {
      <#
            No existing config found
            Create en empty object
      #>
      $ChromePreferences = @{
      }
   }
   #endregion ExistingConfig

   #region ValueVariables
   # The existing configuration
   $ChromePreferencesValues = ($ChromePreferences.psobject.Properties | Where-Object -FilterScript {
         $PSItem.MemberType -eq 'NoteProperty'
      })

   # The recommended configuration
   $DefaultConfigValues = ($DefaultConfig.psobject.Properties | Where-Object -FilterScript {
         $PSItem.MemberType -eq 'NoteProperty'
      })
   #endregion ValueVariables

   #region RecommendedValues
   # Fill in the new Defaults
   foreach ($Property in $DefaultConfigValues)
   {
      try
      {
         #region Splat
         $paramAddMember = @{
            MemberType  = 'NoteProperty'
            Name        = $Property.Name
            Value       = $Property.Value
            ErrorAction = $STP
         }
         #endregion Splat

         # Add the configuration value
         $null = ($NewConfig | Add-Member @paramAddMember)
      }
      catch
      {
         #region Splat
         $paramWriteWarning = @{
            Message = ('Unable to set recommended value for {0}' -f $Property.Name)
         }
         #endregion Splat

         Write-Warning @paramWriteWarning
      }
   }
   #endregion RecommendedValues

   #region ExistingValues
   # Add the old config values
   foreach ($Property in $ChromePreferencesValues)
   {
      try
      {
         #region Splat
         $paramAddMember = @{
            MemberType  = 'NoteProperty'
            Name        = $Property.Name
            Value       = $Property.Value
            ErrorAction = $STP
         }
         #endregion Splat

         # Add the configuration value
         $null = ($NewConfig | Add-Member @paramAddMember)
      }
      catch
      {
         #region Splat
         $paramWriteVerbose = @{
            Message = ('The value of {0} was replaced' -f $Property.Name)
         }
         #endregion Splat

         Write-Verbose @paramWriteVerbose
      }
   }
   #endregion ExistingValues
}

end
{
   if ($pscmdlet.ShouldProcess(($BaseChromeProfilePath + $ChromeProfile + '\Preferences'), 'Save'))
   {
      #region SaveTheNewPreferences
      # Save the Preferences
      try
      {
         #region Splat
         $paramConvertToJson = @{
            Depth    = 100
            Compress = $true
         }

         $paramSetContent = @{
            Path        = ($BaseChromeProfilePath + $ChromeProfile + '\Preferences')
            Value       = ($NewConfig | ConvertTo-Json @paramConvertToJson )
            Force       = $true
            Encoding    = $Encoding
            ErrorAction = $STP
         }
         #endregion Splat

         # Save the new Chrome configuration file
         $null = (Set-Content @paramSetContent)
      }
      catch
      {
         #region Splat
         $paramWriteError = @{
            Message     = 'Unable to save the new configuration file'
            Category    = 'WriteError'
            ErrorAction = $STP
         }
         #endregion Splat

         Write-Error @paramWriteError
      }
      #endregion SaveTheNewPreferences
   }
}

#region LICENSE
<#
   BSD 3-Clause License

   Copyright (c) 2022, enabling Technology
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
   - If you disagree with any of the terms, and any conditions declared: Just delete it and build your own solution
#>
#endregion DISCLAIMER
