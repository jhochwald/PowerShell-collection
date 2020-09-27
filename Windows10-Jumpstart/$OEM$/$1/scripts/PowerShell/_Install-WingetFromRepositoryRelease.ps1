#requires -Version 3.0 -Modules Appx
<#
.SYNOPSIS
Install the latest WinGet Version from the projects repository

.DESCRIPTION
Install the latest WinGet Version from the projects repository

.EXAMPLE
PS C:\> .\Install-WingetFromRepositoryRelease.ps1

.NOTES
Based on the Work of Adriano Cahete <https://adrianocahete.dev/>
#>
[CmdletBinding(ConfirmImpact = 'Low',
   SupportsShouldProcess)]
param ()

begin
{
   #region Defaults
   $DefaultErrorMessage = "`nWinGet is not installed. Try to install from MS Store instead`n"
   $SCT = 'SilentlyContinue'
   $STP = 'Stop'
   $RootLocation = "$env:HOMEDRIVE\install\"
   $FilesPath = ($RootLocation + '\files\')
   # Where to download the latest release
   $Repo = 'https://api.github.com/repos/microsoft/winget-cli/releases/latest'
   #endregion Defaults
}

process
{
   try
   {
      # Query the API to get the url of the zip
      $paramInvokeRestMethod = @{
         Method      = 'Get'
         Uri         = $Repo
         ErrorAction = $STP
      }
      $APIResponse = (Invoke-RestMethod @paramInvokeRestMethod)

      $FileUrl = ($APIResponse.assets.browser_download_url)

      # Download the file to the current location
      $fileName = ($APIResponse.name.Replace(' ', '_').appxbundle)
      $OutputPath = ($FilesPath + $fileName)

      $paramTestPath = @{
         Path = $FilesPath
      }
      if (-not (Test-Path @paramTestPath))
      {
         $paramNewItem = @{
            Path        = $FilesPath
            ItemType    = 'Directory'
            Force       = $true
            Confirm     = $false
            ErrorAction = $STP
         }
         $null = (New-Item @paramNewItem)
      }

      $paramPushLocation = @{
         Path        = $FilesPath
         ErrorAction = $SCT
      }
      $null = (Push-Location @paramPushLocation)

      Write-Verbose -Message ("Downloading {0}`n" -f $fileName)

      $paramInvokeRestMethod = @{
         Method      = 'Get'
         Uri         = $FileUrl
         OutFile     = $OutputPath
         ErrorAction = $STP
      }
      $null = (Invoke-RestMethod @paramInvokeRestMethod)

      $paramTestPath = @{
         Path        = $OutputPath
         ErrorAction = $SCT
      }
      if (Test-Path @paramTestPath)
      {
         Write-Verbose -Message ("`nInstalling {0}`n" -f $fileName)

         $paramAddAppxPackage = @{
            Path                           = $OutputPath
            ForceTargetApplicationShutdown = $true
            InstallAllResources            = $true
            Confirm                        = $false
            ErrorAction                    = $STP
         }
         $null = (Add-AppxPackage @paramAddAppxPackage)

         $paramPopLocation = @{
            ErrorAction = $SCT
         }
         $null = (Pop-Location @paramPopLocation)

         $paramGetCommand = @{
            Name        = 'Update-SessionEnvironment'
            ErrorAction = $SCT
         }
         $paramTestPath = @{
            Path        = "$env:ChocolateyInstall\bin\refreshenv.cmd"
            ErrorAction = $SCT
         }
         if (Get-Command @paramGetCommand)
         {
            $null = (Update-SessionEnvironment)
         }
         elseif (Test-Path @paramTestPath)
         {
            $null = (& "$env:ChocolateyInstall\bin\refreshenv.cmd")
         }
         else
         {
            Write-Verbose -Message 'No refresh, good luck!'
         }

         $paramTestPath = @{
            Path        = "$env:LOCALAPPDATA\microsoft\windowsapps\winget.exe"
            ErrorAction = $SCT
         }
         if (Test-Path @paramTestPath)
         {
            try
            {
               $WinGetVersion = (& "$env:LOCALAPPDATA\microsoft\windowsapps\winget.exe" --version)

               Write-Output -InputObject ('WinGet version is: {0}' -f $WinGetVersion)
               Write-Output -InputObject "`nWinGet is installed. Try to run the 'winget' command.`n"
            }
            catch
            {
               $paramWriteError = @{
                  Message     = $DefaultErrorMessage
                  ErrorAction = $STP
               }
               Write-Error @paramWriteError
            }
         }
      }
      else
      {
         $paramWriteError = @{
            Message     = $DefaultErrorMessage
            ErrorAction = $STP
         }
         Write-Error @paramWriteError
      }
   }
   catch
   {
      $paramWriteError = @{
         Message     = $DefaultErrorMessage
         ErrorAction = $STP
      }
      Write-Error @paramWriteError
   }
}

<#
      # =============================================================
      # Copyright 2020 Adriano Cahete <https://adrianocahete.dev/>
      # TODO: Add License
      #
      # Unless required by applicable law or agreed to in writing, software
      # distributed under the License is distributed on an "AS IS" BASIS,
      # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
      # See the License for the specific language governing permissions and
      # limitations under the License.
      # =============================================================

      # Install WinGet
      # TODO: Check windows version
      # TODO: Check if it's easier to get from repository or MS Store
      # TODO: Check if Sideloading is enabled - https://docs.microsoft.com/en-us/windows/uwp/get-started/enable-your-device-for-development
      # TODO: Do the option to enable sideloading from PS console (I don't know even it's possible)
      # TODO: Clear old files before start
#>