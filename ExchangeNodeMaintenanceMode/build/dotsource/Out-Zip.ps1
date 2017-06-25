function Script:Out-Zip {
    param (
        [Parameter(Position=0, Mandatory=$true)]
        [string] $Directory,
        [Parameter(Position=1, Mandatory=$true)]
        [string] $FileName,
        [Parameter(Position=2)]
        [switch] $overwrite
    )
    Add-Type -Assembly System.IO.Compression.FileSystem
    $compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal
    if (-not $FileName.EndsWith('.zip')) {$FileName += '.zip'} 
    if ($overwrite) {
        if (Test-Path $FileName) {
            Remove-Item $FileName
        }
    }
    [System.IO.Compression.ZipFile]::CreateFromDirectory($Directory, $FileName, $compressionLevel, $false)
}