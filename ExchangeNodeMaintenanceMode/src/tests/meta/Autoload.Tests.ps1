
<#
    Use this tests to verify, if the latest meta tests are available in this
    repository, compared to the claudiospizzi/PowerShellModuleBase repository.
#>

Describe 'Meta Autoload' {

    $baseApi = 'https://api.github.com/repos/claudiospizzi/PowerShellModuleBase/contents/Tests/Meta'

    $files = Invoke-RestMethod -Method Get -Uri $baseApi

    foreach ($file in $files)
    {
        if ($file.name -ne 'Autoload.Tests.ps1')
        {
            It "should download the latest version of \$($file.path.Replace('/', '\'))" {

                { Invoke-WebRequest -Uri $file.download_url -OutFile "$PSScriptRoot\$($file.name)" -Headers @{ 'Cache-Control' = 'no-cache' } -UseBasicParsing -ErrorAction Stop } | Should Not Throw
            }
        }
    }
}
