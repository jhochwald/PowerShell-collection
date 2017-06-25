#Requires -Modules Pester
<#
    This pester test verifies the files in the specified path do not contain sensitive information.

    Example:
    Invoke-Pester -Script @{Path = '.\src\tests\ScriptAnalyzer.Tests.ps1'; Parameters = @{ Path = 'C:\Users\zloeber\Dropbox\Zach_Docs\Projects\Git\PSAD' }}
#>

[CmdletBinding()]
Param(
    [Parameter(HelpMessage = 'Path to the files to scan.')]
    [string]$Path
)

if (-not (Get-Item $Path -ErrorAction:SilentlyContinue).PSIsContainer) {
    throw "Either $Path is not a directory or does not exist"
}

Describe 'Testing against PSSA rules' {
    Context 'PSSA Standard Rules' {
        $analysis = Invoke-ScriptAnalyzer -Path  $Path
        $scriptAnalyzerRules = Get-ScriptAnalyzerRule
        forEach ($rule in $scriptAnalyzerRules) {
            It "Should pass $rule" {
                If ($analysis.RuleName -contains $rule) {
                    $analysis | Where RuleName -EQ $rule -outvariable failures | Out-Default
                    $failures.Count | Should Be 0
                }
            }
        }
    }
}