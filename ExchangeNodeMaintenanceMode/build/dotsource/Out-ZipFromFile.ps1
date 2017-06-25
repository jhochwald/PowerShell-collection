function Script:Out-ZipFromFile {
    [cmdletbinding()]
    param (
        [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
        [string[]]$Files,
        [Parameter(Position=1, Mandatory=$true)]
        [string]$ZipFile,
        [Parameter(Position=2)]
        [switch]$overwrite
    )
    begin {
        #Prepare zip file
        if (($Overwrite) -and (test-path($ZipFile)) ) {
            try {
                Remove-Item -Path $ZipFile -Force
            }
            catch {
                throw
            }
        }
        if (-not (test-path($ZipFile))) {
            try {
                set-content $ZipFile ("PK" + [char]5 + [char]6 + ("$([char]0)" * 18))
                $ThisZipFile = Get-ChildItem $ZipFile
                $ThisZipFile.IsReadOnly = $false
            }
            catch {
                throw
            }
        }

        $shellApplication = new-object -com shell.application
        $zipPackage = $shellApplication.NameSpace($ThisZipFile.FullName)
        $AllFiles = @()
    }
    process {
        $AllFiles += $Files
    }
    end {
        foreach($file in $AllFiles) {
            $ThisFile = Get-ChildItem -Path $File -File
            $zipPackage.CopyHere($ThisFile.FullName)
            while($zipPackage.Items().Item($ThisFile.name) -eq $null){
                Start-sleep -seconds 1
            }
        }
    }
}