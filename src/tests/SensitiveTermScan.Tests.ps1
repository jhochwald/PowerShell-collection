#Requires -Modules Pester
<#
    This pester test verifies the files in the specified path do not contain sensitive information.

    Example:
    Invoke-Pester -Script @{Path = '.\src\tests\SensitiveTermScan.Tests.ps1'; Parameters = @{ Path = 'C:\Users\zloeber\Dropbox\Zach_Docs\Projects\Git\PSAD'; Terms = @('mydomainname.com', 'myservername') }}
#>

[CmdletBinding()]
Param(
    [Parameter(HelpMessage = 'Path to the files to scan.')]
    [string]$Path,
    [Parameter(HelpMessage = 'Terms to scan for.')]
    [string[]]$Terms
)

if (Test-Path $Path) {
    Describe 'Scan for sensitive terms.' {
        foreach ($Term in $Terms) {
            $TermSearch = @(Get-ChildItem -Recurse -Path $Path | Select-String -Pattern $Term)
            Context "Files in $Path" {
                It "should not contain the term $Term" {
                    $TermSearch.Count -gt 0 | Should Be $false
                }
            }
        }
    }
}