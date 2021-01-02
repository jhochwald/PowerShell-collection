
<#
    Check if the encoding of all text files in the PowerShell module is valid,
    this means no Unicode or UTF-8 with BOM files.
#>

$ModulePath = Resolve-Path -Path "$PSScriptRoot\..\..\Modules" | ForEach-Object Path
$ModuleName = Get-ChildItem -Path $ModulePath | Select-Object -First 1 -ExpandProperty BaseName

Remove-Module -Name $ModuleName -Force -ErrorAction SilentlyContinue
Import-Module -Name "$ModulePath\$ModuleName" -Force

Describe 'Meta File Encoding' {

    $fileExtensions = '.ps1', '.psm1', '.psd1', '.ps1xml', '.txt', '.xml',
                      '.cmd', '.json', '.md', '.csv', '.yml', '.log',
                      '.gitignore', '.gitattributes'

    $rootPath  = Resolve-Path -Path "$PSScriptRoot\..\.." | ForEach-Object Path
    $textFiles = Get-ChildItem -Path $rootPath -File -Recurse |
                     Where-Object { -not $_.FullName.StartsWith("$rootPath\Sources\") } |
                         Where-Object { $fileExtensions -contains $_.Extension } |
                             ForEach-Object { $_.FullName.Replace($rootPath, '') }

    Context 'No Unicode encoding' {

        foreach ($textFile in $textFiles)
        {
            # To check, if the file is encoded in Unicode, check for 0x00 byte
            # characters. In a Unicode file, every second charcter is normally
            # a 0x00 character, because to majority of chars don't use more than
            # the first byte.
            It "should not use Unicode encoding for $textFile" {

                @([System.IO.File]::ReadAllBytes("$rootPath\$textFile") -eq 0).Length -eq 0 | Should Be $true
            }
        }
    }

    Context 'No UTF-8 with BOM encoding' {

        foreach ($textFile in $textFiles)
        {
            # We use UTF-8 encoding with byte order mask (BOM). Therefore we
            # check if the file starts with the bytes 0xEF, 0xBB, 0xBF.
            It "should not use BOM for UTF-8 encoding for $textFile" {

                $bytes = [System.IO.File]::ReadAllBytes("$rootPath\$textFile")

                ($bytes.Length -ge 3 -and $bytes[0] -eq 239 -and $bytes[1] -eq 187 -and $bytes[2] -eq 191) | Should Be $false
            }
        }
    }
}
