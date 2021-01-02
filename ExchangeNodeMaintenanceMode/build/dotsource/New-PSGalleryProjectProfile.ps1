#Requires -version 5
function Script:New-PSGalleryProjectProfile {
    <#
        .SYNOPSIS
            Create a powershell Gallery module upload profile
        .DESCRIPTION
            Create a powershell Gallery module upload profile. Some items (like Name) are inferred from the module manifest and are left out.
        .PARAMETER Path
            Path of module project files to upload.
        .PARAMETER ProjectUri
            Module project website.
        .PARAMETER Tags
            Tags used to search for the module (separated by commas)
        .PARAMETER Repository
            Destination gallery (default is PSGallery)
        .PARAMETER ReleaseNotes
            Release notes.
        .PARAMETER LicenseUri
            License website.
        .PARAMETER IconUri
            Icon web path.
        .PARAMETER NuGetApiKey
            API key for the powershellgallery.com site. 
        .PARAMETER OutputFile
            OutputFile (default is .psgallery)

        .EXAMPLE
        .NOTES
        Author: Zachary Loeber
        Site: http://www.the-little-things.net/
        Version History
        1.0.0 - Initial release
        #>
    [CmdletBinding()]
    param(
        [parameter(Position=0, Mandatory=$true, HelpMessage='Path of module project files to upload.')]
        [string]$Path,
        [parameter(Position=1, HelpMessage='Module project website.')]
        [string]$ProjectUri = '',
        [parameter(Position=2, HelpMessage='Tags used to search for the module (separated by commas)')]
        [string]$Tags = '',
        [parameter(Position=3, HelpMessage='Destination gallery (default is PSGallery)')]
        [string]$Repository = 'PSGallery',
        [parameter(Position=4, HelpMessage='Release notes.')]
        [string]$ReleaseNotes = '',
        [parameter(Position=5, HelpMessage=' License website.')]
        [string]$LicenseUri = '',
        [parameter(Position=6, HelpMessage='Icon web path.')]
        [string]$IconUri = '',
        [parameter(Position=7, HelpMessage='NugetAPI key for the powershellgallery.com site.')]
        [string]$NuGetApiKey = '',
        [parameter(Position=8, HelpMessage='OutputFile (default is .psgallery)')]
        [string]$OutputFile = '.psgallery'
    )

    $PublishParams = @{
        Path = $Path
        NuGetApiKey = $NuGetApiKey
        ProjectUri = $ProjectUri
        Tags = $Tags
        Repository = $Repository
        ReleaseNotes = $ReleaseNotes
        LicenseUri = $LicenseUri
        IconUri = $IconUri
    }

    if (Test-Path $OutputFile) {
        $PublishParams | Export-Clixml -Path $OutputFile -confirm
    }
    else {
        $PublishParams | Export-Clixml -Path $OutputFile
    }
}