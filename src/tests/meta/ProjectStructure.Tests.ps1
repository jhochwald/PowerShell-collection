
<#
    This meta tests verify, if the PowerShell module project structure is
    adhered to the best practices.
#>

$ModulePath = Resolve-Path -Path "$PSScriptRoot\..\..\Modules" | ForEach-Object Path
$ModuleName = Get-ChildItem -Path $ModulePath | Select-Object -First 1 -ExpandProperty BaseName

Remove-Module -Name $ModuleName -Force -ErrorAction SilentlyContinue
Import-Module -Name "$ModulePath\$ModuleName" -Force

Describe 'Meta Project Structure' {

    $rootPath  = Resolve-Path -Path "$PSScriptRoot\..\.." | ForEach-Object Path

    Context 'Folders' {

        $requiredFolders = @(
            '\Scripts'
            '\Modules'
            "\Modules\$ModuleName"
            "\Modules\$ModuleName\en-US"
            "\Modules\$ModuleName\Functions"
            "\Modules\$ModuleName\Resources"
            '\Tests'
            '\Tests\Meta'
            '\Tests\Unit'
        )

        $optionalFolders = @(
            "\Modules\$ModuleName\Helpers"
            '\Sources'
            "\Sources\$ModuleName"
            '\Tests\Integration'
        )

        foreach ($requiredFolder in $requiredFolders)
        {
            It "should contain the folder $requiredFolder" {

                Test-Path -Path "$rootPath$requiredFolder" | Should Be $true
            }
        }

        foreach ($optionalFolder in $optionalFolders)
        {
            It "can contain the folder $optionalFolder" {

                if ((Test-Path -Path "$rootPath$optionalFolder"))
                {
                    Test-Path -Path "$rootPath$optionalFolder" | Should Be $true
                }
                else
                {
                    Set-TestInconclusive -Message "Optional folder $optionalFolder not found!"
                }
            }
        }
    }

    Context 'Files' {

        $requiredFiles = @(
            '\appveyor.yml'
            '\LICENSE'
            '\README.md'
            '\Scripts\build.ps1'
            '\Scripts\debug.default.ps1'
            '\Scripts\release.ps1'
            '\Scripts\test.ps1'
            "\Modules\$ModuleName\en-US\about_$ModuleName.help.txt"
            "\Modules\$ModuleName\Resources\$ModuleName.Formats.ps1xml"
            "\Modules\$ModuleName\Resources\$ModuleName.Types.ps1xml"
            "\Modules\$ModuleName\$ModuleName.psd1"
            "\Modules\$ModuleName\$ModuleName.psm1"
            '\Tests\Meta\Autoload.Tests.ps1'
        )

        $optionalFiles = @(
            "\Sources\$ModuleName.sln"
        )

        foreach ($requiredFile in $requiredFiles)
        {
            It "should contain the file $requiredFile" {

                Test-Path -Path "$rootPath\$requiredFile" | Should Be $true
            }
        }

        foreach ($optionalFile in $optionalFiles)
        {
            It "can contain the file $optionalFile" {

                if ((Test-Path -Path "$rootPath$optionalFile"))
                {
                    Test-Path -Path "$rootPath$optionalFile" | Should Be $true
                }
                else
                {
                    Set-TestInconclusive -Message "Optional file $optionalFile not found!"
                }
            }
        }
    }

    Context 'Version' {

        # Arrange
        $requiredVersion = (Import-PowerShellDataFile -Path "$rootPath\Modules\$ModuleName\$ModuleName.psd1")['ModuleVersion']

        It "should have version $requiredVersion in README.md" {

            # Act
            $versionHeadline = @(Get-Content -Path "$rootPath\README.md" | Where-Object { $_ -eq "### $requiredVersion" })

            # Assert
            $versionHeadline.Count | Should Be 1
            $versionHeadline[0] | Should BeExactly "### $requiredVersion"
        }

        It "should have version $requiredVersion in $ModuleName.psd1" {

            # Act
            $moduleDefinition = Import-PowerShellDataFile -Path "$rootPath\Modules\$ModuleName\$ModuleName.psd1"

            # Assert
            $moduleDefinition.ModuleVersion | Should Be $requiredVersion
        }

        if ((Test-Path -Path "$rootPath\Sources\$ModuleName"))
        {
            It "should have version $requiredVersion in $ModuleName.dll" {

                if ((Test-Path -Path "$rootPath\Modules\$ModuleName\$ModuleName.dll"))
                {
                    # Act
                    $moduleAssembly = Get-Item -Path "$rootPath\Modules\$ModuleName\$ModuleName.dll"

                    # Assert
                    $moduleAssembly.VersionInfo.ProductVersion | Should Be $requiredVersion
                    $moduleAssembly.VersionInfo.FileVersion    | Should Be $requiredVersion
                }
                else
                {
                    Set-TestInconclusive -Message "$ModuleName.dll file was not found!"
                }
            }
        }
    }
}
