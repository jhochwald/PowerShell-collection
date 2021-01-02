
<#
    Verify that the file content if formatted property. It will verify the
    following criterias: Use spaces instead of tabs for indentation, no trailing
    spaces for lines and should end with a new line.
#>

$ModulePath = Resolve-Path -Path "$PSScriptRoot\..\..\Modules" | ForEach-Object Path
$ModuleName = Get-ChildItem -Path $ModulePath | Select-Object -First 1 -ExpandProperty BaseName

Remove-Module -Name $ModuleName -Force -ErrorAction SilentlyContinue
Import-Module -Name "$ModulePath\$ModuleName" -Force

Describe 'Meta File Formatting' {

    $fileExtensions = '.ps1', '.psm1', '.psd1', '.ps1xml', '.txt', '.xml',
                      '.cmd', '.json', '.md', '.csv', '.yml', '.log',
                      '.gitignore', '.gitattributes'

    $rootPath  = Resolve-Path -Path "$PSScriptRoot\..\.." | ForEach-Object Path
    $textFiles = Get-ChildItem -Path $rootPath -File -Recurse |
                     Where-Object { -not $_.FullName.StartsWith("$rootPath\Sources\") } |
                         Where-Object { $fileExtensions -contains $_.Extension } |
                             ForEach-Object { $_.FullName.Replace($rootPath, '') }

    Context 'Space Indentation' {

        foreach ($textFile in $textFiles)
        {
            It "should use spaces and not tabs for indentation in $textFile" {

                $errorLines = @()

                $content = @(Get-Content -Path "$rootPath$textFile")

                for ($line = 0; $line -lt $content.Length; $line++)
                {
                    if(($content[$line] | Select-String "`t" | Measure-Object).Count -ne 0)
                    {
                        $errorLines += $line + 1

                        Write-Warning "There are tabs instead of spaces in $textFile`:$($line + 1)"
                    }
                }

                $errorLines.Count | Should Be 0
            }
        }
    }

    Context 'No Trailing Spaces' {

        # Do not test markdown files for trailing spaces.
        $textFilesFiltered = $textFiles | Where-Object { $_ -notlike '*.md' }

        foreach ($textFile in $textFilesFiltered)
        {
            It "should not have trailing spaces in $textFile" {

                $errorLines = @()

                $content = @(Get-Content -Path "$rootPath$textFile")

                for ($line = 0; $line -lt $content.Length; $line++)
                {
                    if($content[$Line].ToString().TrimEnd() -ne $content[$Line])
                    {
                        $errorLines += $line + 1

                        Write-Warning "There are trailing spaces in $textFile`:$($line + 1)"
                    }
                }

                $errorLines.Count | Should Be 0
            }
        }
    }

    Context 'New Line Termination' {

        # Do not test files in .vscode for trailing spaces.
        $textFilesFiltered = $textFiles | Where-Object { $_ -notlike '*\.vscode\*' }

        foreach ($textFile in $textFilesFiltered)
        {

            It "should terminate with a new line in $textFile" {

                $content = Get-Content -Path "$rootPath$textFile" -Raw

                $content.Length | Should Not Be 0
                $content[-1]    | Should Be "`n"
            }
        }
    }
}
