#Requires -Modules Pester

<#
    This pester test verifies the PowerShell module manifest file has valid content that will be required to 
    upload to the PowerShell Gallary.

    .EXAMPLE
    PS> Invoke-Pester -Script @{Path = '.\src\tests\ModuleManifest.Tests.ps1'; Parameters = @{ ManifestPath = 'C:\Users\zloeber\Dropbox\Zach_Docs\Projects\Git\PSAD'; Author = 'Zachary Loeber'; Website = 'https://github.com/zloeber/PSAD'; Tags = @('ADSI', 'Active_Directory', 'DC') }}

    Runs some standard tests and a few manual validations (Tags, Author, and Website).
    .EXAMPLE
    PS> Invoke-Pester -Script @{Path = '.\src\tests\ModuleManifest.Tests.ps1'; Parameters = @{ ManifestPath = '.\PSAD.psd1'}}

    Runs several generic tests against the PSAD.psd1 manifest to ensure all required values for uploading to the PowerShell Gallery simply exist.
#>

[CmdLetBinding(DefaultParameterSetName='Default')]
Param(
    [Parameter(Mandatory = $True, ParameterSetName='Default')]
    [Parameter(Mandatory = $True, ParameterSetName='Manual')]
    [Parameter(Mandatory = $True, ParameterSetName='ModuleBuild')]
    [string]$ManifestPath,
    [Parameter(Mandatory = $True, ParameterSetName='ModuleBuild')]
    [string]$ModuleBuildJSONPath,
    [Parameter(ParameterSetName='Manual')]
    [string]$Author,
    [Parameter(ParameterSetName='Manual')]
    [string]$Copyright,
    [Parameter(ParameterSetName='Manual')]
    [string]$Website,
    [Parameter(ParameterSetName='Manual')]
    [string]$LicenseURI,
    [Parameter(ParameterSetName='Manual')]
    [string]$Version,
    [Parameter(ParameterSetName='Manual')]
    [string[]]$Tags
)

if (($ManifestPath.EndsWith('psd1')) -and (Test-Path $ManifestPath)) {
    # Grab the short module name
    $ModuleName =  (Split-Path $ManifestPath -Leaf).Split('.')[0]

    Describe 'Module Manifest - Standard Tests' {
        Context "Testing $ManifestPath" {
            It 'should be a valid module manifest file' {
                { 
                    $Script:Manifest = Test-ModuleManifest -Path $ManifestPath -ErrorAction Stop -WarningAction SilentlyContinue
                } |  Should Not Throw
            }

            It 'should have a valid RootModule value' {
                $Script:Manifest.RootModule | Should Be "$ModuleName.psm1"
            }

            It 'should have a valid GUID' {
                ($Script:Manifest.Guid).Guid | Should BeLike '????????-????-????-????-????????????'
            }

            It 'should have a valid PowerShellVersion value' {
                $Script:Manifest.PowerShellVersion | Should Not BeNullOrEmpty
            }
        }
    }

    switch ($PSCmdlet.ParameterSetName) {
        'Default' {
            # Passed just a module manifest file name with no other information to validate
            # This will check for several entries that they simply exist.
            Describe 'Module Manifest - Generic Tests' {
                Context "Testing $ManifestPath" {
                    It 'should have a valid Module version' {
                        ($Script:Manifest.Version).ToString() -as [Version] | Should Not BeNullOrEmpty
                    }

                    It 'should have a valid module description' {
                        $Script:Manifest.Description | Should Not BeNullOrEmpty
                    }

                    It 'should have a valid module author' {
                        $Script:Manifest.Author | Should Not BeNullOrEmpty
                    }

                    It 'should have a valid module project website' {
                        $Script:Manifest.ProjectUri.OriginalString | Should Not BeNullOrEmpty
                    }

                    It 'should have a valid license URL' {
                        $Script:Manifest.LicenseUri | Should Not BeNullOrEmpty
                    }

                    It 'should have some tags' {
                        @($Script:Manifest.PrivateData.PSData.Tags).Count -gt 0 | Should Be $true
                    }
                }
            }
        }
        'Manual' {
            # Passed a manifest name and several manual entries to validate
            Describe 'Module Manifest - Manual Tests' {
                Context "Testing $ManifestPath" {
                    if (-not [string]::IsNullOrEmpty($Version)) {
                        It "should be module version '$Version'" {
                            ($Script:Manifest.Version).ToString() -as [Version] | Should Be $Version
                        }
                    }
                    if (-not [string]::IsNullOrEmpty($Description)) {
                        It "should have a module description of '$Description'" {  
                            $Script:Manifest.Description | Should Be $Description
                        }
                    }

                    if (-not [string]::IsNullOrEmpty($Author)) {
                        It "should have the module author of '$Author'" {
                            $Script:Manifest.Author | Should Be $Author
                        }
                    }
                    
                    if (-not [string]::IsNullOrEmpty($Copyright)) {
                        It "should have a Copyright of '$Copyright'" {
                            $Script:Manifest.Copyright | Should Be $Copyright
                        }
                    }
                    
                    if (-not [string]::IsNullOrEmpty($Website)) {
                        It "should have the project website of '$Website'" {
                            $Script:Manifest.ProjectUri.OriginalString | Should Be $Website
                        }
                    }

                    if (-not [string]::IsNullOrEmpty($LicenseURI)) {
                        It "should have the license URI of '$LicenseURI'" {
                            $Script:Manifest.LicenseUri  | Should Be $LicenseURI
                        }
                    }
                    if ($Tags.Count -gt 0) {
                        It "should have these tags: $($Tags -join ',')" {
                            Compare-Object $Script:Manifest.PrivateData.PSData.Tags $Tags | Should Be $Null
                        }
                    }
                }
            }
        }
        'ModuleBuild' {
            # Passed a manifest name and a ModuleBuild json configuration file to validate
            if (($ModuleBuildJSONPath.EndsWith('psd1')) -and (Test-Path $ModuleBuildJSONPath)) {
                try {
                    $ModuleInfo = get-content $ModuleBuildJSONPath | ConvertFrom-Json
                }
                catch {
                    throw "$ModuleBuildJSONPath either does not exist or is not a json file!"
                }
            }
            else {
                throw "$ModuleBuildJSONPath either does not exist or is not a json file!"
            }
            # Passed a manifest name and several manual entries to validate
            Describe 'Module Manifest - ModuleBuild Tests' {
                Context "Testing $ManifestPath" {
                    if (-not [string]::IsNullOrEmpty($Version)) {
                        It "should be module version '$Version'" {
                            ($Script:Manifest.Version).ToString() -as [Version] | Should Be $ModuleInfo.ModuleVersion
                        }
                    }
                    if (-not [string]::IsNullOrEmpty($Description)) {
                        It "should have a module description of '$Description'" {  
                            $Script:Manifest.Description | Should Be $ModuleInfo.ModuleDescription
                        }
                    }

                    if (-not [string]::IsNullOrEmpty($Author)) {
                        It "should have the module author of '$Author'" {
                            $Script:Manifest.Author | Should Be $ModuleInfo.ModuleAuthor
                        }
                    }
                    
                    if (-not [string]::IsNullOrEmpty($Copyright)) {
                        It "should have a Copyright of '$Copyright'" {
                            $Script:Manifest.Copyright | Should Be $ModuleInfo.ModuleCopyright
                        }
                    }
                    
                    if (-not [string]::IsNullOrEmpty($Website)) {
                        It "should have the project website of '$Website'" {
                            $Script:Manifest.ProjectUri.OriginalString | Should Be $ModuleInfo.ModuleWebsite
                        }
                    }

                    if (-not [string]::IsNullOrEmpty($LicenseURI)) {
                        It "should have the license URI of '$LicenseURI'" {
                            $Script:Manifest.LicenseUri  | Should Be $ModuleInfo.ModuleLicenseURI
                        }
                    }
                    if ($Tags.Count -gt 0) {
                        It "should have these tags: $($ModuleInfo.ModuleTags -join ',')" {
                            Compare-Object $Script:Manifest.PrivateData.PSData.Tags $ModuleInfo.ModuleTags | Should Be $Null
                        }
                    }
                }
            }
        }
    }
}
else {
    Write-Error "$ManifestPath was not found!"
}