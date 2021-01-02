#Requires -version 5
function Script:Upload-ProjectToPSGallery {
    <#
        .SYNOPSIS
            Upload module project to Powershell Gallery
        .DESCRIPTION
            Upload module project to Powershell Gallery
        .PARAMETER Name
            Path to module to upload.
        .PARAMETER Repository
            Destination gallery (default is PSGallery)
        .PARAMETER NuGetApiKey
            API key for the powershellgallery.com site.
        .EXAMPLE
            .\Upload-ProjectToPSGallery.ps1
        .NOTES
        Author: Zachary Loeber
        Site: http://www.the-little-things.net/
        #>
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true, HelpMessage='Name of the module to upload.')]
        [string]$Name,
        [parameter(HelpMessage='Destination gallery (default is PSGallery)')]
        [string]$Repository = 'PSGallery',
        [parameter(HelpMessage='API key for the powershellgallery.com site.')]
        [string]$NuGetApiKey
    )
    # if no API key is defined then look for psgalleryapi.txt in the local profile directory and try to use it instead.
    if ([string]::IsNullOrEmpty($NuGetApiKey)) {
        $psgalleryapipath = "$(Split-Path $Profile)\psgalleryapi.txt"
        Write-Verbose "No PSGallery API key specified. Attempting to load one from the following location: $($psgalleryapipath)"
        if (-not (test-path $psgalleryapipath)) {
            Write-Error "$psgalleryapipath wasn't found and there was no defined API key, please rerun script with a defined APIKey parameter."
            return
        }
        else {
            $NuGetApiKey = get-content -raw $psgalleryapipath
        }
    }

    Publish-Module -Name $Name -NuGetApiKey $NuGetApiKey -Repository $Repository
}