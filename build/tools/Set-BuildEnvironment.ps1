
. .\Get-BuildEnvironment.ps1
. .\New-DynamicParameter.ps1

function Set-BuildEnvironment {
    <#
    .SYNOPSIS
    Sets a stored setting in a buildenvironment.json file.

    .DESCRIPTION
    Sets the stored setting in a buildenvironment.json file.

    .PARAMETER Path
    Specifies the path to a buildenvironment.json file.

    .LINK
    https://github.com/zloeber/ModuleBuild

    .EXAMPLE
    Set-BuildEnvironment -OptionSensitiveTerms @('myapikey','myname','password')
    #>

    [CmdletBinding()]
    param(
        [parameter(Position = 0, ValueFromPipeline = $TRUE)]
        [String]$Path
    )
    DynamicParam {
        # Create dictionary
        $DynamicParameters = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        if ([String]::isnullorempty($Path)) {
            $BuildPath = (Get-ChildItem -File -Filter "*.buildenvironment.json" -Path '.\','..\','.\build\' | select -First 1).FullName
        }
        else {
            $BuildPath = $Path
        }

        if ((Test-Path $BuildPath) -and ($BuildPath -like "*.buildenvironment.json")) {
            try {
                $LoadedBuildEnv = Get-Content $BuildPath | ConvertFrom-Json
                $NewParams = (Get-Member -Type 'NoteProperty' -InputObject $LoadedBuildEnv).Name
                $NewParams | ForEach-Object {

                    $NewParamSettings = @{
                        Name = $_
                        Type = $LoadedBuildEnv.$_.gettype().Name.toString()
                        ValueFromPipeline = $TRUE
                        HelpMessage = "Update the setting for $($_)"
                    }

                    # Add new dynamic parameter to dictionary
                    New-DynamicParameter @NewParamSettings -Dictionary $DynamicParameters
                }
            }
            catch {
                #throw "Unable to load the build file in $BuildPath"
            }
        }

        # Return dictionary with dynamic parameters
        $DynamicParameters
    }

    begin {
        if ($script:ThisModuleLoaded -eq $true) {
            Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        }
        if ([String]::isnullorempty($Path)) {
            $BuildPath = (Get-ChildItem -File -Filter "*.buildenvironment.json" -Path '.\','..\','.\build\' | select -First 1).FullName
        }
        else {
            $BuildPath = $Path
        }

        Write-Verbose "Using build file: $BuildPath"
    }
    process {
        New-DynamicParameter -CreateVariables -BoundParameters $PSBoundParameters

        if ((Test-Path $BuildPath) -and ($BuildPath -like "*.buildenvironment.json")) {
            try {
                $LoadedBuildEnv = Get-BuildEnvironment -Path $BuildPath
                Foreach ($ParamKey in ($PSBoundParameters.Keys | Where-Object {$_ -ne 'Path'})) {
                    $LoadedBuildEnv.$ParamKey = $PSBoundParameters[$ParamKey]
                    Write-Output "Updating $ParamKey to be $($PSBoundParameters[$ParamKey])"
                }
                $LoadedBuildEnv.PSObject.Properties.remove('Path')
                $LoadedBuildEnv | ConvertTo-Json | Out-File -FilePath $BuildPath -Encoding:utf8 -Force
                Write-Output "Saved configuration file - $BuildPath"
            }
            catch {
                throw "Unable to load the build file in $BuildPath"
            }
        }
        else {
            Write-Error "Unable to find or process a buildenvironment.json file!"
        }
    }
}