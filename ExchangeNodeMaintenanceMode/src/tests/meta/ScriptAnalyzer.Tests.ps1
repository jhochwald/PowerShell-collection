
<#
    Check all scripts files in the sources folder against all script analyzer
    rules. It should comply with all rules.
#>

$ModulePath = Resolve-Path -Path "$PSScriptRoot\..\..\Modules" | ForEach-Object Path
$ModuleName = Get-ChildItem -Path $ModulePath | Select-Object -First 1 -ExpandProperty BaseName

Remove-Module -Name $ModuleName -Force -ErrorAction SilentlyContinue
Import-Module -Name "$ModulePath\$ModuleName" -Force

Describe 'Meta Script Analyzer' {

    foreach ($severity in 'Information', 'Warning', 'Error')
    {
        Context "$severity Rules" {

            $scriptAnalyzerRules = Get-ScriptAnalyzerRule -Severity $severity

            foreach ($scriptAnalyzerRule in $scriptAnalyzerRules)
            {
                It "should conform the rule $($scriptAnalyzerRule.RuleName)" {

                    $scriptAnalyzerResults = @(Invoke-ScriptAnalyzer -Path $ModulePath -IncludeRule $scriptAnalyzerRule -Recurse)

                    foreach ($scriptAnalyzerResult in $scriptAnalyzerResults)
                    {
                        Write-Warning ('{0}, line {1}: {2}' -f $scriptAnalyzerResult.ScriptPath.Replace("$ModulePath", 'Modules'), $scriptAnalyzerResult.Line, $scriptAnalyzerResult.Message)
                    }

                    $scriptAnalyzerResults.Count | Should Be 0
                }
            }
        }
    }
}
