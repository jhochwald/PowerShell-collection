# Current script path
[string]$ModulePath = Split-Path (get-variable myinvocation -scope script).value.Mycommand.Definition -Parent

# Module Pre-Load code
. (Join-Path $ModulePath 'src\other\PreLoad.ps1') @ProfilePathArg

# Private and other methods and variables
Get-ChildItem (Join-Path $ModulePath 'src\private') -Recurse -Filter "*.ps1" -File | Sort-Object Name | ForEach-Object {
    Write-Verbose "Dot sourcing private script file: $($_.Name)"
    . $_.FullName
}

# Load and export public methods
Get-ChildItem (Join-Path $ModulePath 'src\public') -Recurse -Filter "*.ps1" -File | Sort-Object Name | ForEach-Object {
    Write-Verbose "Dot sourcing public script file: $($_.Name)"
    . $_.FullName

    # Find all the functions defined no deeper than the first level deep and export it.
    # This looks ugly but allows us to not keep any uneeded variables in memory that are not related to the module.
    ([System.Management.Automation.Language.Parser]::ParseInput((Get-Content -Path $_.FullName -Raw), [ref]$null, [ref]$null)).FindAll({ $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $false) | ForEach-Object {
        Export-ModuleMember $_.Name
    }
}

# Module Post-Load code
. (Join-Path $ModulePath 'src\other\PostLoad.ps1')
