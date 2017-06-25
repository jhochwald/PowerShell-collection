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
    TBD
    #>

    [CmdletBinding()]
    param(
        [parameter(Position = 0, ValueFromPipeline = $TRUE)]
        [String]$Path
    )

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
            $LoadedBuildEnv = Get-Content $Path | ConvertFrom-Json
            $LoadedBuildEnv
        }
        catch {
            throw "Unable to load the build file in $Path"
        }
    }
}