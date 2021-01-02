#Requires -Modules Pester
<#
    This pester test verifies the module's public functions all have proper comment based help required for building documentation via PlatyPS.

    Example:
    PS> Invoke-Pester -Script @{Path = '.\src\tests\FuncitonCBH.Tests.ps1'; Parameters = @{ ModuleName = MyModule}}
#>

[CmdletBinding()]
Param(
    [Parameter(HelpMessage = 'Module to scan.')]
    [string]$ModuleName
)

If (($ModuleName -like '*.psd1') -and (test-path $ModuleName)) {
    $Module = (Split-Path $ModuleName -Leaf) -replace '.psd1',''
}
else {
    $Module = $ModuleName
}

if (-not (Get-Module $Module)) {
    try {
        Import-Module $ModuleName -force
    }
    catch {
        throw "$Module is not loaded."
    }
}

Describe "Comment Based Help tests for $Module" -Tags Build {
    
    $functions = Get-Command -Module $Module -CommandType Function
    foreach($Function in $Functions){
        $help = Get-Help $Function.name
        Context $help.name {
            it "Has a HelpUri" {
                $Function.HelpUri | Should Not BeNullOrEmpty
            }
            It "Has related Links" {
                $help.relatedLinks.navigationLink.uri.count | Should BeGreaterThan 0
            }
            it "Has a description" {
                $help.description | Should Not BeNullOrEmpty
            }
            it "Has an example" {
                 $help.examples | Should Not BeNullOrEmpty
            }
            foreach($parameter in $help.parameters.parameter)
            {
                if($parameter -notmatch 'whatif|confirm')
                {
                    it "Has a Parameter description for '$($parameter.name)'" {
                        $parameter.Description.text | Should Not BeNullOrEmpty
                    }
                }
            }
        }
    }
}