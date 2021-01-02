param (
    [Parameter(HelpMessage = 'If you are initializing this file or want to force overwrite the persistent export data use this flag.')]
    [switch]$ForcePersist
)
<#
 Update $Script:BuildEnv to suit your PowerShell module build. These variables get dot sourced into
 the build at every run and are exported to an external xml file for persisting through possible build
 engine upgrades.
#>

# If the variable is already defined then essentially do nothing.
# Otherwise we create a baseline variable first in case this is a first time run, then
# check for an exported .xml file with persistent settings for any run thereafter
if ((Get-Variable 'BuildEnv' -ErrorAction:SilentlyContinue) -eq $null) {
    $Script:BuildEnv = New-Object -TypeName PSObject -Property @{
        FirstRun = $True
        Encoding = 'utf8'
        ModuleToBuild = 'ExchangeNodeMaintenanceMode'
        ModuleVersion = '1.0.0.10'
        ModuleWebsite = 'https://github.com/jhochwald/ExchangeNodeMaintenanceMode'
        ModuleCopyright = "(c) $((get-date).Year.ToString()) Enabling Technology. All rights reserved."
        ModuleLicenseURI = 'https://github.com/jhochwald/ExchangeNodeMaintenanceMode/blob/master/license.md'
        ModuleTags = 'Exchange,ExchangeServer,ExchangeCluster,Maintenance' -split ','
        ModuleAuthor = 'Joerg Hochwald'
        ModuleDescription = 'Exchange Cluster Node Maintenance Mode Utilities'

        # Options - These affect how your eventual build will be run.
        OptionAnalyzeCode = $True
        OptionCombineFiles = $True
        OptionTranscriptEnabled = $false
        OptionTranscriptLogFile = 'BuildTranscript.Log'

        # PlatyPS has been the cause of most of my build failures. This can help you isolate which function's CBH is causing you grief.
        OptionRunPlatyPSVerbose = $false

        # If you want to prescan and fail a build upon finding any proprietary strings
        # enable this option and define some strings.
        OptionSanitizeSensitiveTerms = $False
        OptionSensitiveTerms = @($env:username, $env:userdomain, $env:userdnsdomain)
        OptionSensitiveTermsInitialized = $false

        # Additional paths in the source module which should be copied over to the final build release
        AdditionalModulePaths = @()
        # Generate a yml file in the root folder of this project for readthedocs.org integration
        OptionGenerateReadTheDocs = $True
        # Most of the following options you probably don't need to change
        BaseSourceFolder = 'src'        # Base source path
        PublicFunctionSource = "src\public"         # Public functions (to be exported by file name as the function name)
        PrivateFunctionSource = "src\private"        # Private function source
        OtherModuleSource = "src\other"        # Other module source
        BaseReleaseFolder = 'release'        # Releases directory.
        BuildToolFolder = 'build'        # Build tool path (these scripts are dot sourced)
        ScratchFolder = 'temp'        # Scratch path - this is where all our scratch work occurs. It will be cleared out at every run.

        # If you will be publishing to the PowerShell Gallery you will need a Nuget API key (can get from the website)
        # You should not actually enter this key here but should manually enter it in the ExchangeNodeMaintenanceMode.buildenvironment.json file

        NugetAPIKey  = $null
    }

    ########################################
    # !! Please leave anything below this line alone !!
    ########################################
    $PersistentBuildFile = join-path $PSScriptRoot "ExchangeNodeMaintenanceMode.buildenvironment.json"

    # Load any persistent data (overrides anything in BuildEnv if the hash element exists)
    if ((Test-Path $PersistentBuildFile)) {
        try {
            $LoadedBuildEnv = Get-Content $PersistentBuildFile | ConvertFrom-Json
        }
        catch {
            throw "Unable to load $PersistentBuildFile"
        }
        $BaseSettings = ($Script:BuildEnv | Get-Member -Type 'NoteProperty').Name
        $BuildSettings = ($LoadedBuildEnv | Get-Member -Type 'NoteProperty').Name
        ForEach ($Key in $BuildSettings) {
            if ($BaseSettings -contains $Key) {
                Write-Verbose "Updating profile setting '$key' from $PersistentBuildFile"
                ($Script:BuildEnv).$Key = $LoadedBuildEnv.$Key
            }
            else {
                Write-Verbose "Adding profile setting '$key' from $PersistentBuildFile"
                Add-Member -InputObject $Script:BuildEnv -TypeName 'NoteProperty' -Name $Key -Value $LoadedBuildEnv.$Key
            }
        }

        # Look for any settings in the base settings that are not in the saved configuration and
        # force a persist if found.
        ForEach ($BaseSetting in $BaseSettings) {
            if ($BuildSettings -notcontains $BaseSetting) {
                Write-Verbose "  Base setting to be added to json configuration file: $BaseSetting"
                $BuildExport = $True
            }
        }
    }
    else {
        # No persistent file was found so we are going to create one
        $BuildExport = $True
    }

    # We create this helper function here as a quasi private function which can be used without loading the modulebuild module
    function Script:Save-BuildData {
        $Script:BuildEnv | ConvertTo-Json | Out-File -FilePath $PersistentBuildFile -Encoding $Script:BuildEnv.Encoding -Force
    }

    # If we don't have a persistent file, we are forcing a persist, or properties were not the same between
    # the loaded json and our defined BuildEnv file then push a new persistent file export.
    if ((-not (Test-path $PersistentBuildFile)) -or $BuildExport -or $ForcePersist -or ($Script:BuildEnv.FirstRun)) {
        $Script:BuildEnv.FirstRun = $false
        Write-Verbose "Exporting the BuildEnv data!"
        $Script:BuildEnv | ConvertTo-Json | Out-File -FilePath $PersistentBuildFile -Encoding $Script:BuildEnv.Encoding -Force
    }

    $RequiredModules = @('PlatyPS', 'Pester')

    # Some optional modules
    if ($Script:BuildEnv.OptionAnalyzeCode) {
        $RequiredModules += 'PSScriptAnalyzer'
    }

    if ($Script:BuildEnv.OptionGenerateReadTheDocs) {
        $RequiredModules += 'Powershell-YAML'
    }

}
