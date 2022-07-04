#requires -Version 2.0
# C:\ProgramData\chocolatey\bin\choco.exe

#region Defaults
$SCT = 'SilentlyContinue'
#endregion Defaults

#region InstallChocolatey
if (-not (Get-Command -Name 'choco.exe' -ErrorAction $SCT -WarningAction $SCT))
{
   $null = (Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force -Confirm:$false -ErrorAction $SCT)
   $null = (Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser -Force -Confirm:$false -ErrorAction $SCT)
   # TODO: Check (Grab from script base)
   [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072
   Invoke-Expression -Command ((New-Object -TypeName System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}
#endregion InstallChocolatey

#region UpdateSessionEnvironment
$paramGetCommand = @{
   Name          = 'Update-SessionEnvironment'
   WarningAction = $SCT
   ErrorAction   = $SCT
}
$paramTestPath = @{
   Path          = "$env:ChocolateyInstall\bin\refreshenv.cmd"
   WarningAction = $SCT
   ErrorAction   = $SCT
}
if (Get-Command @paramGetCommand)
{
   $null = (Update-SessionEnvironment -WarningAction $SCT -ErrorAction $SCT)
}
elseif (Test-Path @paramTestPath)
{
   $null = (& "$env:ChocolateyInstall\bin\refreshenv.cmd")
}
else
{
   # Something is wrong and we reinstall Chocolatey!
   $null = (Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force -Confirm:$false -ErrorAction $SCT)
   $null = (Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser -Force -Confirm:$false -ErrorAction $SCT)
   # TODO: Check (Grab from script base)
   [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072
   Invoke-Expression -Command ((New-Object -TypeName System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}
#endregion  UpdateSessionEnvironment

#region ChocolateyInstallPathVar
if (-not $env:ChocolateyInstall)
{
   $env:ChocolateyInstall = 'C:\ProgramData\chocolatey'
}
#endregion ChocolateyInstallPathVar

#region ChocoCacheLocation
$ChocoCacheLocation = "$env:HOMEDRIVE\temp\choco\"
$paramTestPath = @{
   Path          = $ChocoCacheLocation
   ErrorAction   = $SCT
   WarningAction = $SCT
}
if (-not (Test-Path @paramTestPath))
{
   $paramNewItem = @{
      Path          = $ChocoCacheLocation
      ItemType      = 'directory'
      Force         = $true
      Confirm       = $false
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   $null = (New-Item @paramNewItem)
}
#endregion ChocoCacheLocation

#region  UpdateSessionEnvironment
$paramGetCommand = @{
   Name          = 'Update-SessionEnvironment'
   WarningAction = $SCT
   ErrorAction   = $SCT
}
$paramTestPath = @{
   Path          = "$env:ChocolateyInstall\bin\refreshenv.cmd"
   WarningAction = $SCT
   ErrorAction   = $SCT
}
if (Get-Command @paramGetCommand)
{
   $null = (Update-SessionEnvironment -WarningAction $SCT -ErrorAction $SCT)
}
elseif (Test-Path @paramTestPath)
{
   $null = (& "$env:ChocolateyInstall\bin\refreshenv.cmd")
}
#endregion  UpdateSessionEnvironment

#region EnableChocoFeatures
Write-Verbose -Message 'Enable some Choco features'

# As the Intune commands are in preview, ensure you enable the allowPreviewFeatures feature
$null = (& "$env:ChocolateyInstall\bin\choco.exe" feature enable -n=allowPreviewFeatures)
# Checksum files when pulled in from internet (based on package).
$null = (& "$env:ChocolateyInstall\bin\choco.exe" feature enable -n=checksumFiles)
# Uninstall from programs and features without requiring an explicit uninstall script.
$null = (& "$env:ChocolateyInstall\bin\choco.exe" feature enable -n=autoUninstaller)
# Prompt for confirmation in scripts or bypass.
$null = (& "$env:ChocolateyInstall\bin\choco.exe" feature enable -n=allowGlobalConfirmation)
# Allow packages to have empty/missing checksums for downloaded resources from secure locations (HTTPS).
$null = (& "$env:ChocolateyInstall\bin\choco.exe" feature enable -n=allowEmptyChecksumsSecure)
# Use Chocolatey's built-in PowerShell host.
$null = (& "$env:ChocolateyInstall\bin\choco.exe" feature enable -n=powershellHost)
# Ignore Invalid Options/Switches
$null = (& "$env:ChocolateyInstall\bin\choco.exe" feature enable -n=ignoreInvalidOptionsSwitches)
# Use Package Exit Codes
$null = (& "$env:ChocolateyInstall\bin\choco.exe" feature enable -n=usePackageExitCodes)
# Use Enhanced Exit Codes
$null = (& "$env:ChocolateyInstall\bin\choco.exe" feature enable -n=useEnhancedExitCodes)
# Show Non-Elevated Warnings
$null = (& "$env:ChocolateyInstall\bin\choco.exe" feature enable -n=showNonElevatedWarnings)
# Show Download Progress'
$null = (& "$env:ChocolateyInstall\bin\choco.exe" feature enable -n=showDownloadProgress)
# Use Remembered Arguments For Upgrades
$null = (& "$env:ChocolateyInstall\bin\choco.exe" feature enable -n=useRememberedArgumentsForUpgrades)
# Log validation results on warnings
$null = (& "$env:ChocolateyInstall\bin\choco.exe" feature enable -n=logValidationResultsOnWarnings)
# Use Package Repository Optimizations
$null = (& "$env:ChocolateyInstall\bin\choco.exe" feature enable -n=usePackageRepositoryOptimizations)
# Remove Stored Package Information On Uninstall
$null = (& "$env:ChocolateyInstall\bin\choco.exe" feature enable -n=removePackageInformationOnUninstall)
#endregion EnableChocoFeatures

#region DisableChocoFeatures
Write-Verbose -Message 'Disable some Choco features'

# Fail if automatic uninstaller fails.
$null = (& "$env:ChocolateyInstall\bin\choco.exe" feature disable -n=failOnAutoUninstaller)
# Fail if install provider writes to stderr.
$null = (& "$env:ChocolateyInstall\bin\choco.exe" feature disable -n=failOnStandardError)
# Allow packages to have empty/missing checksums for downloaded resources from non-secure locations (HTTP, FTP).
$null = (& "$env:ChocolateyInstall\bin\choco.exe" feature disable -n=allowEmptyChecksums)
# Log Environment Values
$null = (& "$env:ChocolateyInstall\bin\choco.exe" feature disable -n=logEnvironmentValues)
# Perform virus checking on downloaded files.
$null = (& "$env:ChocolateyInstall\bin\choco.exe" feature disable -n=virusCheck)
# Exit On Reboot Detected
$null = (& "$env:ChocolateyInstall\bin\choco.exe" feature disable -n=exitOnRebootDetected)
# Fail On Invalid Or Missing License
$null = (& "$env:ChocolateyInstall\bin\choco.exe" feature disable -n=failOnInvalidOrMissingLicense)
# Use FIPS Compliant Checksums
$null = (& "$env:ChocolateyInstall\bin\choco.exe" feature disable -n=useFipsCompliantChecksums)
# Stop On First Package Failure
$null = (& "$env:ChocolateyInstall\bin\choco.exe" feature disable -n=stopOnFirstPackageFailure)
# Ignore Unfound Packages On Upgrade Outdated
$null = (& "$env:ChocolateyInstall\bin\choco.exe" feature disable -n=ignoreUnfoundPackagesOnUpgradeOutdated)
# Skip Packages Not Installed During Upgrade
$null = (& "$env:ChocolateyInstall\bin\choco.exe" feature disable -n=skipPackageUpgradesWhenNotInstalled)
# Do not show colorization in logging output.
$null = (& "$env:ChocolateyInstall\bin\choco.exe" feature disable -n=logWithoutColor)
#endregion DisableChocoFeatures

#region SetChocoConfig
Write-Verbose -Message 'Set some Choco config values'

$null = (& "$env:ChocolateyInstall\bin\choco.exe" config set --name="'cacheLocation'" --value="'C:\temp\chococache'")
$null = (& "$env:ChocolateyInstall\bin\choco.exe" config set --name="'containsLegacyPackageInstalls'" --value="'true'")
$null = (& "$env:ChocolateyInstall\bin\choco.exe" config set --name="'commandExecutionTimeoutSeconds'" --value="'14400'")
$null = (& "$env:ChocolateyInstall\bin\choco.exe" config set --name="'webRequestTimeoutSeconds'" --value="'60'")
$null = (& "$env:ChocolateyInstall\bin\choco.exe" config set --name="'proxyBypassOnLocal'" --value="'true'")
#endregion SetChocoConfig

#region UnsetChocoConfig
Write-Verbose -Message 'Unset some Choco config values'

$null = (& "$env:ChocolateyInstall\bin\choco.exe" config unset --name="'upgradeAllExceptions'" --value="''")
$null = (& "$env:ChocolateyInstall\bin\choco.exe" config unset --name="'proxy'" --value="")
$null = (& "$env:ChocolateyInstall\bin\choco.exe" config unset --name="'proxyUser'" --value="''")
$null = (& "$env:ChocolateyInstall\bin\choco.exe" config unset --name="'proxyPassword'" --value="''")
$null = (& "$env:ChocolateyInstall\bin\choco.exe" config unset --name="'proxyBypassList'" --value="''")
$null = (& "$env:ChocolateyInstall\bin\choco.exe" config unset --name="'centralManagementServiceUrl'" --value="''")
$null = (& "$env:ChocolateyInstall\bin\choco.exe" config unset --name="'centralManagementReportPackagesTimerIntervalInSeconds'" --value="''")
$null = (& "$env:ChocolateyInstall\bin\choco.exe" config unset --name="'centralManagementReceiveTimeoutInSeconds'" --value="''")
$null = (& "$env:ChocolateyInstall\bin\choco.exe" config unset --name="'centralManagementSendTimeoutInSeconds'" --value="''")
$null = (& "$env:ChocolateyInstall\bin\choco.exe" config unset --name="'centralManagementCertificateValidationMode'" --value="''")
$null = (& "$env:ChocolateyInstall\bin\choco.exe" config unset --name="'centralManagementMaxReceiveMessageSizeInBytes'" --value="''")
$null = (& "$env:ChocolateyInstall\bin\choco.exe" config unset --name="'centralManagementDeploymentCheckTimerIntervalInSeconds'" --value="''")
$null = (& "$env:ChocolateyInstall\bin\choco.exe" config unset --name="'centralManagementClientCommunicationSaltAdditivePassword'" --value="''")
$null = (& "$env:ChocolateyInstall\bin\choco.exe" config unset --name="'centralManagementServiceCommunicationSaltAdditivePassword'" --value="''")
$null = (& "$env:ChocolateyInstall\bin\choco.exe" config unset --name="'maximumDownloadRateBitsPerSecond'" --value="''")
$null = (& "$env:ChocolateyInstall\bin\choco.exe" config unset --name="'serviceInstallsDefaultUserName'" --value="''")
$null = (& "$env:ChocolateyInstall\bin\choco.exe" config unset --name="'serviceInstallsDefaultUserPassword'" --value="''")
$null = (& "$env:ChocolateyInstall\bin\choco.exe" config unset --name="'backgroundServiceAllowedCommands'" --value="''")
$null = (& "$env:ChocolateyInstall\bin\choco.exe" config unset --name="'virusCheckMinimumPositives'" --value="''")
$null = (& "$env:ChocolateyInstall\bin\choco.exe" config unset --name="'virusScannerType'" --value="''")
$null = (& "$env:ChocolateyInstall\bin\choco.exe" config unset --name="'genericVirusScannerPath'" --value="''")
$null = (& "$env:ChocolateyInstall\bin\choco.exe" config unset --name="'genericVirusScannerArgs'" --value="''")
$null = (& "$env:ChocolateyInstall\bin\choco.exe" config unset --name="'genericVirusScannerValidExitCodes'" --value="''")
$null = (& "$env:ChocolateyInstall\bin\choco.exe" config unset --name="'genericVirusScannerTimeoutInSeconds'" --value="''")
$null = (& "$env:ChocolateyInstall\bin\choco.exe" config unset --name="'centralManagementReceiveTimeoutInSeconds'" --value="''")
$null = (& "$env:ChocolateyInstall\bin\choco.exe" config unset --name="'centralManagementSendTimeoutInSeconds'" --value="''")
$null = (& "$env:ChocolateyInstall\bin\choco.exe" config unset --name="'genericVirusScannerTimeoutInSeconds'" --value="''")
#endregion UnsetChocoConfig

#region chocolateyUseWindowsCompression
if (-not ($env:chocolateyUseWindowsCompression -eq $true))
{
   Write-Verbose -Message 'Set the chocolateyUseWindowsCompression variable'
   
   $env:chocolateyUseWindowsCompression = 'true'
}
#endregion chocolateyUseWindowsCompression

#region
$RequiredExtensions = @(
   'chocolatey-dotnetfx.extension'
   'chocolatey-font-helpers.extension'
   'chocolatey-misc-helpers.extension'
)

[String[]]$InstalledChocoPackes = (& "$env:ChocolateyInstall\bin\choco.exe" list --local --limitoutput --local --idonly)

foreach ($RequiredExtension in $RequiredExtensions)
{
   if ($InstalledChocoPackes -notcontains $RequiredExtension)
   {
      Write-Verbose -Message ('The Extension {0} is missing.' -f $RequiredExtension)
      
      try {
         $null = (& "$env:ChocolateyInstall\bin\choco.exe" install $RequiredExtension --acceptlicense --limitoutput --no-progress --yes --force --params 'ALLUSERS=1')

         Write-Verbose -Message ('The Extension {0} is installed.' -f $RequiredExtension)
      }
      catch
      {
         Write-Verbose -Message ('Unable to install the Extension {0}' -f $RequiredExtension)
      }
   }
}
#endregion
