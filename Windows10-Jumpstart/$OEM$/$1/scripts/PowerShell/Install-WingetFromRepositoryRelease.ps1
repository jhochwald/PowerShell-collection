#requires -Version 3.0 -RunAsAdministrator

<#
.SYNOPSIS
   Download and install the latest WinGet release from GitHub

   .DESCRIPTION
   Download and install the latest WinGet release from GitHub

   .NOTES
   Original Script by Adriano Cahete <https://adrianocahete.dev/>
#>
[CmdletBinding(ConfirmImpact = 'Low',
   SupportsShouldProcess)]
param ()

begin {
   $BaseDirectory = 'c:\install\files\'

   # Download latest release from GitHub
   $Repo = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
}

process {
   # Query the API to get the url of the zip
   $APIResponse = (Invoke-RestMethod -Method Get -Uri $Repo)
   $FileUrl = $APIResponse.assets.browser_download_url

   # Download the file to the current location
   $fileName = "$($APIResponse.name.Replace(" ","_")).appxbundle"
   $OutputPath = ($BaseDirectory + $fileName)

   if (-not (Test-Path -Path $BaseDirectory -ErrorAction SilentlyContinue)) {
      $null = (New-Item -Path $BaseDirectory -ItemType Directory -Force -Confirm:$false -ErrorAction SilentlyContinue)
   }

   $null = (Push-Location -Path $BaseDirectory -ErrorAction SilentlyContinue)

   Write-Verbose -Message "Downloading $fileName ...`n"

   $null = (Invoke-RestMethod -Method Get -Uri $FileUrl -OutFile $OutputPath)

   if (Test-Path -Path $OutputPath) {
      Write-Verbose -Message "`nInstalling $fileName ...`n"

      $null = (Add-AppxPackage -Path $OutputPath -ForceTargetApplicationShutdown -InstallAllResources -Confirm:$false -ErrorAction SilentlyContinue)

      $null = (Pop-Location)

      # TODO: Check
      if (Test-Path -Path 'C:\ProgramData\chocolatey\bin\RefreshEnv.cmd') {
         C:\ProgramData\chocolatey\bin\RefreshEnv.cmd
      }

      try {
         $WinGetVersion = (winget --version)
         Write-Output "WinGet version is:  $WinGetVersion"
         Write-Output "`WinGet is installed. Try to run the 'winget' command.`n"
      }
      catch {
         Write-Error -Message "`WinGet is not installed. Try to install from MS Store instead`n" -ErrorAction Stop
      }
   }
   else {
      Write-Error -Message "`WinGet Installer not found. Try to install from MS Store instead`n" -ErrorAction Stop
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

