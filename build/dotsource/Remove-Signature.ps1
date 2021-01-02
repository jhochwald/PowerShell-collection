#requires -Version 2
function Script:Remove-Signature
{
    <#
    .SYNOPSIS
    Finds all signed ps1 and psm1 files recursively from the current  or defined path and removes any digital signatures attached to them.
    .DESCRIPTION
    Finds all signed ps1 and psm1 files recursively from the current  or defined path and removes any digital signatures attached to them.
    .PARAMETER Path
    Path you want to parse for digital signatures.
    .PARAMETER Recurse
    Recurse through all subdirectories of the path provided.
    .EXAMPLE
    PS> Remove-Signature -Recurse

    Removes all digital signatures from ps1/psm1 files found in the current path.

    .NOTES
    Author: Zachary Loeber
    .LINK
    http://www.the-little-things.net
    #>

    [CmdletBinding( SupportsShouldProcess = $true )]
    Param (
        [Parameter(ValueFromPipeline = $True,ValueFromPipelineByPropertyName = $True)]
        [Alias('FilePath')]
        [string]$Path = $(Get-Location).Path,
        [Parameter()]
        [switch]$Recurse
    )
    Begin {
        $RecurseParam = @{}
        if ($Recurse) {
            $RecurseParam.Recurse = $true
        }
    }

    Process {
        $FilesToProcess = Get-ChildItem -Path $Path -File -Include '*.psm1','*.ps1','*.psd1','*.ps1xml' @RecurseParam
        
        $FilesToProcess | ForEach-Object -Process {
            $SignatureStatus = (Get-AuthenticodeSignature $_).Status
            $ScriptFileFullName = $_.FullName
            if ($SignatureStatus -ne 'NotSigned') {
                try {
                    $Content = Get-Content $ScriptFileFullName -ErrorAction Stop
                    $StringBuilder = New-Object -TypeName System.Text.StringBuilder -ErrorAction Stop

                    Foreach ($Line in $Content) {
                        if ($Line -match '^# SIG # Begin signature block|^<!-- SIG # Begin signature block -->') {
                            Break
                        }
                        else {
                            $null = $StringBuilder.AppendLine($Line)
                        }
                    }
                    if ($pscmdlet.ShouldProcess( "$ScriptFileFullName")) {
                        Set-Content -Path  $ScriptFileFullName -Value $StringBuilder.ToString()
                        Write-Output "$ScriptFileFullName -> Removed Signature!"
                    }
                }
                catch {
                    Write-Output "$ScriptFileFullName -> Unable to process signed file!"
                    Write-Error -Message $_.Exception.Message
                }
            }
            else {
                Write-Verbose "$ScriptFileFullName -> No signature, nothing done."
            }
        }
    }
}