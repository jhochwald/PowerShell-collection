#requires -Version 3.0 -RunAsAdministrator

<#
   .SYNOPSIS
   Download and install the latest WinGet release from GitHub

   .DESCRIPTION
   Download and install the latest WinGet release from GitHub

   .NOTES
   Version 1.0.1

   Original Script by Adriano Cahete <https://adrianocahete.dev/>
#>
[CmdletBinding(ConfirmImpact = 'Low',
   SupportsShouldProcess)]
param ()

begin
{
   $SCT = 'SilentlyContinue'

   if (Get-Command -Name 'Set-MpPreference' -ErrorAction $SCT)
   {
      $null = (Set-MpPreference -EnableControlledFolderAccess Disabled -Force -ErrorAction $SCT)
   }

   $BaseDirectory = 'c:\install\files\'

   # Download latest release from GitHub
   $Repo = 'https://api.github.com/repos/microsoft/winget-cli/releases/latest'
}

process
{
   # Query the API to get the url of the zip
   $paramInvokeRestMethod = @{
      Method      = 'Get'
      Uri         = $Repo
      ErrorAction = 'Stop'
   }
   $APIResponse = (Invoke-RestMethod @paramInvokeRestMethod)
   $FileUrl = $APIResponse.assets.browser_download_url

   # Download the file to the current location
   $fileName = "$($APIResponse.name.Replace(' ', '_')).appxbundle"
   $OutputPath = ($BaseDirectory + $fileName)

   $paramTestPath = @{
      Path        = $BaseDirectory
      ErrorAction = $SCT
   }
   if (-not (Test-Path @paramTestPath))
   {
      $paramNewItem = @{
         Path        = $BaseDirectory
         ItemType    = 'Directory'
         Force       = $true
         Confirm     = $false
         ErrorAction = $SCT
      }
      $null = (New-Item @paramNewItem)
   }

   $paramPushLocation = @{
      Path        = $BaseDirectory
      ErrorAction = $SCT
   }
   $null = (Push-Location @paramPushLocation)

   Write-Verbose -Message "Downloading $fileName ...`n"

   $paramInvokeRestMethod = @{
      Method      = 'Get'
      Uri         = $FileUrl
      OutFile     = $OutputPath
      ErrorAction = 'Stop'
   }
   $null = (Invoke-RestMethod @paramInvokeRestMethod)

   $paramTestPath = @{
      Path        = $OutputPath
      ErrorAction = $SCT
   }
   if (Test-Path @paramTestPath)
   {
      Write-Verbose -Message "`nInstalling $fileName ...`n"

      $paramAddAppxPackage = @{
         Path                           = $OutputPath
         ForceTargetApplicationShutdown = $true
         InstallAllResources            = $true
         Confirm                        = $false
         ErrorAction                    = $SCT
      }
      $null = (Add-AppxPackage @paramAddAppxPackage)

      $null = (Pop-Location -ErrorAction $SCT)

      # TODO: Check
      if (Test-Path -Path 'C:\ProgramData\chocolatey\bin\RefreshEnv.cmd' -ErrorAction $SCT)
      {
         C:\ProgramData\chocolatey\bin\RefreshEnv.cmd
      }

      try
      {
         $WinGetVersion = (winget.exe --version)
         Write-Output -InputObject "WinGet version is:  $WinGetVersion"
         Write-Output -InputObject "`WinGet is installed. Try to run the 'winget' command.`n"
      }
      catch
      {
         Write-Error -Message "`WinGet is not installed. Try to install from MS Store instead`n" -ErrorAction Stop
      }
   }
   else
   {
      Write-Error -Message "`WinGet Installer not found. Try to install from MS Store instead`n" -ErrorAction Stop
   }
}

end
{
   if (Get-Command -Name 'Set-MpPreference' -ErrorAction $SCT)
   {
      $null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction $SCT)
   }
}

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

# Install Winget
# TODO: Check windows version
# TODO: Check if it's easier to get from repository or MS Store
# TODO: Check if Sideloading is enabled - https://docs.microsoft.com/en-us/windows/uwp/get-started/enable-your-device-for-development
# TODO: Do the option to enable sideloading from PS console (I don't know even it's possible)
# TODO: Clear old files before start
