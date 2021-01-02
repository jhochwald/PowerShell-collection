function Get-BuildEnvironment {
    <#
    .SYNOPSIS
    Retrieves all the stored settings in a buildenvironment.json file.

    .DESCRIPTION
    Retrieves all the stored settings in a buildenvironment.json file.

    .PARAMETER Path
    Specifies the path to a buildenvironment.json file.

    .LINK
    https://github.com/zloeber/ModuleBuild

    .EXAMPLE
    Get-buildenvironment

    If a buildenvironment.json file exists in .\build then the settings within it will be displayed on the screen. Otherwise nothing happens.
    #>

    [CmdletBinding()]
    param(
        [parameter(Position = 0, ValueFromPipeline = $TRUE)]
        [String]$Path
    )
    begin {
        if ($script:ThisModuleLoaded -eq $true) {
            Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        }
    }
    process {
        # If no path was specified take a few guesses
        if ([string]::IsNullOrEmpty($Path)) {
            $Path = (Get-ChildItem -File -Filter "*.buildenvironment.json" -Path '.\','..\','.\build\' | select -First 1).FullName

            if ([string]::IsNullOrEmpty($Path)) {
                throw 'Unable to locate a *.buildenvironment.json file to parse!'
            }
        }
        if (-not (Test-Path $Path)) {
            throw "Unable to find the file: $Path"
        }

        try {
            $LoadedEnv = Get-Content $Path | ConvertFrom-Json
            $LoadedEnv | Add-Member -Name 'Path' -Value ((Resolve-Path $Path).ToString()) -MemberType 'NoteProperty'
            $LoadedEnv
        }
        catch {
            throw "Unable to load the build file in $Path"
        }
    }
}