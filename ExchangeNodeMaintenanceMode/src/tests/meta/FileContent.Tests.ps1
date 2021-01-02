
<#
    This meta tests verify, if the PowerShell module core project file have a
    valid content.
#>

$ModulePath = Resolve-Path -Path "$PSScriptRoot\..\..\Modules" | ForEach-Object Path
$ModuleName = Get-ChildItem -Path $ModulePath | Select-Object -First 1 -ExpandProperty BaseName

Remove-Module -Name $ModuleName -Force -ErrorAction SilentlyContinue
Import-Module -Name "$ModulePath\$ModuleName" -Force

Describe 'Meta File Content' {

    $rootPath  = Resolve-Path -Path "$PSScriptRoot\..\.." | ForEach-Object Path

    Context '\README.md' {

        $content = Get-Content -Path "$rootPath\README.md"

        It 'should have 4 badges at the top' {

            # Arrange
            $expectAppVeyorMaster    = "[![AppVeyor - master](https://img.shields.io/appveyor/ci/claudiospizzi/$ModuleName/master.svg)](https://ci.appveyor.com/project/claudiospizzi/$ModuleName/branch/master)"
            $expectAppVeyorMaster    = "[![AppVeyor - dev](https://img.shields.io/appveyor/ci/claudiospizzi/$ModuleName/dev.svg)](https://ci.appveyor.com/project/claudiospizzi/$ModuleName/branch/dev)"
            $expectGitHubRelease     = "[![GitHub - Release](https://img.shields.io/github/release/claudiospizzi/$ModuleName.svg)](https://github.com/claudiospizzi/$ModuleName/releases)"
            $expectPowerShellGallery = "[![PowerShell Gallery - $ModuleName](https://img.shields.io/badge/PowerShell_Gallery-$ModuleName-0072C6.svg)](https://www.powershellgallery.com/packages/$ModuleName)"

            # Act
            $actualAppVeyorMaster    = $content[0]
            $actualAppVeyorMaster    = $content[1]
            $actualGitHubRelease     = $content[2]
            $actualPowerShellGallery = $content[3]

            # Assert
            $actualAppVeyorMaster    | Should BeExactly $expectAppVeyorMaster
            $actualAppVeyorMaster    | Should BeExactly $expectAppVeyorMaster
            $actualGitHubRelease     | Should BeExactly $expectGitHubRelease
            $actualPowerShellGallery | Should BeExactly $expectPowerShellGallery
        }

        It 'should have one main title' {

            # Arrange
            $expectCount = 1
            $expectTitle = "# $ModuleName PowerShell Module"

            # Act
            $actualTitle = @()
            $isCodeBlock = $false
            foreach ($line in $content)
            {
                if ($line -like '``````*')
                {
                    $isCodeBlock = -not $isCodeBlock
                }
                if (($line -like '# *') -and (-not $isCodeBlock))
                {
                    $actualTitle += $line
                }
            }

            # Assert
            $actualTitle.Count | Should Be $expectCount
            $actualTitle[0]    | Should BeExactly $expectTitle
        }

        It 'should have a all subtitles' {

            # Arrange
            $expectCount     = 6
            $expectSubtitles = "## Introduction", "## Requirements", "## Installation", "## Features", "## Versions", "## Contribute"

            # Act
            $actualSubtitles = @($content | Where-Object { $_ -like '## *' })

            # Assert
            $actualSubtitles.Count | Should Be $expectCount
            $actualSubtitles[0] | Should BeExactly $expectSubtitles[0]
            $actualSubtitles[1] | Should BeExactly $expectSubtitles[1]
            $actualSubtitles[2] | Should BeExactly $expectSubtitles[2]
            $actualSubtitles[3] | Should BeExactly $expectSubtitles[3]
            $actualSubtitles[4] | Should BeExactly $expectSubtitles[4]
            $actualSubtitles[5] | Should BeExactly $expectSubtitles[5]
        }

        It 'should cover every function in the features capture' {

            # Arrange
            $expectFunctions = @(Get-ChildItem -Path "$ModulePath\$ModuleName\Functions" | ForEach-Object { '* **' + $_.BaseName + '**  ' } | Sort-Object)

            # Act
            $actualFunctions = @($content | Where-Object { $_ -like '`* `*`**`*`*  ' } | Sort-Object)

            # Assert
            $actualFunctions.Count | Should Not Be 0
            $actualFunctions.Count | Should Be $expectFunctions.Count
            for ($i = 0; $i -lt $expectFunctions.Count; $i++)
            {
                $actualFunctions[$i] | Should BeExactly $expectFunctions[$i]
            }
        }

        It 'should contain an installation capture' {

            # Arrange
            $expectLines = @(
                'With PowerShell 5.0, the new [PowerShell Gallery] was introduced. Additionally,'
                'the new module [PowerShellGet] was added to the default WMF 5.0 installation.'
                'With the cmdlet `Install-Module`, a published module from the PowerShell Gallery'
                'can be downloaded and installed directly within the PowerShell host, optionally'
                'with the scope definition:'
                ''
                '```powershell'
                "Install-Module $ModuleName [-Scope {CurrentUser | AllUsers}]"
                '```'
                ''
                'Alternatively, download the latest release from GitHub and install the module'
                'manually on your local system:'
                ''
                '1. Download the latest release from GitHub as a ZIP file: [GitHub Releases]'
                '2. Extract the module and install it: [Installing a PowerShell Module]'
            )

            # Act
            $lineIndex = $content.IndexOf($expectLines[0])

            # Assert
            $lineIndex | Should Not Be -1
            for ($i = 0; $i -lt $expectLines.Count; $i++)
            {
                $actual = '{{{0}}}{1}' -f $i, $content[$i + $lineIndex]
                $expect = '{{{0}}}{1}' -f $i, $expectLines[$i]

                $actual | Should BeExactly $expect
            }
        }

        It 'should contain an contribute capture' {

            # Arrange
            $expectLines = @(
                '## Contribute'
                ''
                'Please feel free to contribute by opening new issues or providing pull requests.'
                'For the best development experience, open this project as a folder in Visual'
                'Studio Code and ensure that the PowerShell extension is installed.'
                ''
                '* [Visual Studio Code]'
                '* [PowerShell Extension]'
                ''
                'This module is tested with the PowerShell testing framework Pester. To run all'
                'tests, just start the included test script `.\Scripts\test.ps1` or invoke Pester'
                'directly with the `Invoke-Pester` cmdlet. The tests will automatically download'
                'the latest meta test from the claudiospizzi/PowerShellModuleBase repository.'
                ''
                'To debug the module, just copy the existing `.\Scripts\debug.default.ps1` file'
                'to `.\Scripts\debug.ps1`, which is ignored by git. Now add the command to the'
                'debug file and start it.'
            )

            # Act
            $lineIndex = $content.IndexOf($expectLines[0])

            # Assert
            $lineIndex | Should Not Be -1
            for ($i = 0; $i -lt $expectLines.Count; $i++)
            {
                $actual = '{{{0}}}{1}' -f $i, $content[$i + $lineIndex]
                $expect = '{{{0}}}{1}' -f $i, $expectLines[$i]

                $actual | Should BeExactly $expect
            }
        }
    }

    Context '\.gitignore' {

        $content = Get-Content -Path "$rootPath\.gitignore"

        It 'should have entries for all test and debug files' {

            # Arrange
            $expect = @(
                'Scripts/debug.ps1'
                'Tests/Meta/FileContent.Tests.ps1'
                'Tests/Meta/FileEncoding.Tests.ps1'
                'Tests/Meta/FileFormatting.Tests.ps1'
                'Tests/Meta/ProjectStructure.Tests.ps1'
                'Tests/Meta/ScriptAnalyzer.Tests.ps1'
            )

            # Act

            # Assert
            foreach ($expectLine in $expect)
            {
                $content -contains $expectLine | Should Be $true
            }
        }
    }

    Context ".\Modules\$ModuleName\$ModuleName.psd1" {

        $data = Import-PowerShellDataFile -Path "$rootPath\Modules\$ModuleName\$ModuleName.psd1"

        It 'should have a valid RootModule value' {

            # Arrange
            $expect = "$ModuleName.psm1"

            # Act
            $actual = $data.RootModule

            # Assert
            $actual | Should BeExactly $expect
        }

        It 'should have a valid ModuleVersion value' {

            # Arrange
            $expect = '*.*.*'

            # Act
            $actual = $data.ModuleVersion

            # Assert
            $actual | Should BeLike $expect
        }

        It 'should have a valid GUID value' {

            # Arrange
            $expect = '????????-????-????-????-????????????'

            # Act
            $actual = $data.GUID

            # Assert
            $actual | Should BeLike $expect
        }

        It 'should have a valid Author value' {

            # Arrange
            $expect = 'Claudio Spizzi'

            # Act
            $actual = $data.Author

            # Assert
            $actual | Should BeExactly $expect
        }

        It 'should have a valid Copyright value' {

            # Arrange

            # Act
            $actual = $data.Copyright

            # Assert
            $actual | Should Not BeNullOrEmpty
        }

        It 'should have a valid Description value' {

            # Arrange

            # Act
            $actual = $data.Description

            # Assert
            $actual | Should Not BeNullOrEmpty
        }

        It 'should have a valid PowerShellVersion value' {

            # Arrange

            # Act
            $actual = $data.PowerShellVersion

            # Assert
            $actual | Should Not BeNullOrEmpty
        }

        It 'should have valid TypesToProcess values' {

            # Arrange
            $expect = @(
                "Resources\$ModuleName.Types.ps1xml"
            )

            # Act
            $actual = $data.TypesToProcess

            # Assert
            $actual.Count | Should Be 1
            $actual[0] | Should BeExactly $expect[0]
        }

        It 'should have valid FormatsToProcess values' {

            # Arrange
            $expect = @(
                "Resources\$ModuleName.Formats.ps1xml"
            )

            # Act
            $actual = $data.FormatsToProcess

            # Assert
            $actual.Count | Should Be 1
            $actual[0] | Should BeExactly $expect[0]
        }

        It 'should have valid FunctionsToExport values' {

            # Arrange
            $expect = @(Get-ChildItem -Path "$ModulePath\$ModuleName\Functions" | ForEach-Object BaseName | Sort-Object)

            # Act
            $actual = @($data.FunctionsToExport | Sort-Object)

            # Assert
            $actual.Count | Should Be $expect.Count
            for ($i = 0; $i -lt $expect.Count; $i++)
            {
                $actual[$i] | Should BeExactly $expect[$i]
            }
        }

        It 'should have valid PrivateData hash table' {

            # Arrange
            $expectLicenseUri = "https://raw.githubusercontent.com/claudiospizzi/$ModuleName/master/LICENSE"
            $expectProjectUri = "https://github.com/claudiospizzi/$ModuleName"

            # Act
            $actual = $data.PrivateData

            # Assert
            $actual.PSData.Tags -contains 'PSModule' | Should Be $true
            $actual.PSData.LicenseUri | Should BeExactly $expectLicenseUri
            $actual.PSData.ProjectUri | Should BeExactly $expectProjectUri
        }
    }
}
