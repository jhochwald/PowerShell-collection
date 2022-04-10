#requires -Version 5.0 -Modules Storage -RunAsAdministrator
<#
   .SYNOPSIS
   Log4j vulnerabilities affected version scanner

   .DESCRIPTION
   Scan for CVE-2021-44228 and/or CVE-2021-45046 effected versions of Log4j

   .PARAMETER AutoFix
   Apply mitigation by removing the affected class from JAR archive file?

   PLEASE ENSURE ON YOUR OWN THAT THIS WILL NOT BREAK YOUR APPLICATION!!!
   PLEASE ENSURE THAT YOU HAVE BACKUPS OR SNAPSHOTS YOU CAN RELY ON!!!
   DON'T BLAME THE AUTHOR(S) IF IT BREAKS YOUR SYSTEM!!!

   .PARAMETER WorkDirectory
   Where to store working files.
   Default: 'C:\temp\log4j-vscan'

   .EXAMPLE
   PS C:\> .\Find-Log4jVulnerabilities.ps1

   .LINK
   https://hochwald.net

   .LINK
   https://www.hellstorm.de/index.php/de/4-log4j-exploit-scanner-und-entferner%C3%BC

   .NOTES
   Reworked version of the .\Find-Log4j.ps1 file from hellstorm.de
   It is based on Version 1.2 of Hellstorm.De's great work

   Copyright (c) 2021 by hellstorm.de
#>
[CmdletBinding(ConfirmImpact = 'Low')]
param
(
   [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
   [Alias('Fix')]
   [switch]
   $AutoFix,
   [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
   [ValidateNotNullOrEmpty()]
   [Alias('TempDirectory')]
   [string]
   $WorkDirectory = 'C:\temp\log4j-vscan'
)

begin
{
   # Generate random temp directory
   $RandomString = [IO.Path]::GetRandomFileName()

   $TempDirectory = ('temp-{0}' -f ($RandomString))

   # Create working directory if not exist
   if (-not (Test-Path -Path $WorkDirectory -ErrorAction SilentlyContinue))
   {
      $null = (New-Item -Path $WorkDirectory -ItemType 'directory' -Force -Confirm:$false -ErrorAction SilentlyContinue)
   }

   # Create temp dir
   if (-not (Test-Path -Path (Join-Path -Path $WorkDirectory -ChildPath $TempDirectory) -ErrorAction SilentlyContinue))
   {
      $null = (New-Item -Path $WorkDirectory -Name $TempDirectory -ItemType 'directory' -Force -Confirm:$false -ErrorAction SilentlyContinue)
   }

   # Working files/dir, can be, but shouldn't be changed
   $TeampArchive = ('{0}\{1}\tmp.zip' -f ($WorkDirectory), ($TempDirectory))
   $FiedArchive = ('{0}\{1}\new.zip' -f ($WorkDirectory), ($TempDirectory))
   $UnpackedDirectory = ('{0}\{1}\unpacked' -f ($WorkDirectory), ($TempDirectory))

   # Logging file, normally stored in workdir
   $LogFile = ('{0}\Log4j-Scann-Results-{1}.txt' -f ($WorkDirectory), (Get-Date -Format 'MM-dd-yyyy_HH-mm-ss'))
}

process
{
   # Get all local disk drives
   $AllFixedDisks = (Get-Volume -ErrorAction SilentlyContinue | Where-Object -FilterScript {
         (($PSItem.DriveType -eq 'Fixed') -and ($PSItem.DriveLetter -ne $null))
      })

   foreach ($FixedDisk in $AllFixedDisks.DriveLetter)
   {
      Write-Verbose -Message ('Scanning drive {0}...' -f $FixedDisk)

      # Search all local drives for log4j* files
      Get-ChildItem -Path ('{0}:\' -f $FixedDisk) -Filter 'log4j*.jar' -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object -Process {
         $isclean = $false
         $JARArchiveFile = $PSItem.FullName

         Write-Verbose -Message ('Scann {0}' -f $JARArchiveFile)

         # if a JAR archive is found, copy to temp directiry
         Copy-Item -Path $JARArchiveFile -Destination $TeampArchive

         # Uncompress the JAR archive
         Expand-Archive -Path $TeampArchive -DestinationPath $UnpackedDirectory

         # Get version from Manifest file
         (Get-Content -Path ('{0}\META-INF\MANIFEST.MF' -f ($UnpackedDirectory)) -ErrorAction SilentlyContinue | ForEach-Object -Process {
            if ($_ -match 'Implementation-Version')
            {
               $ver = $_ -replace '^.*: ', ''
            }
         })

         # Split version string into separate numbers to compare them
         $vertok = $ver -split '\.'

         # Guess it is unsave until we know better
         $unsafe = $true

         # Handle CVE-2021-44228 and CVE-2021-45046
         if (($vertok[0].ToInt32($null) -eq 2) -and ($vertok[1].ToInt32($null) -le 15))
         {
            # CVE-2021-44228
            Write-Verbose -Message ('Potential CVE-2021-44228 effected Version found: {0}' -f ($ver))
         }
         elseif (($vertok[0].ToInt32($null) -eq 2) -and ($vertok[1].ToInt32($null) -le 16))
         {
            # CVE-2021-45046
            Write-Verbose -Message ('Potential CVE-2021-45046 effected Version found: {0}' -f ($ver))
         }
         elseif ($vertok[0].ToInt32($null) -eq 1)
         {
            # Legacy warning
            Write-Verbose -Message ('Outdated Version: {0}' -f ($ver))
         }
         else
         {
            # Any other version
            Write-Verbose -Message ('Safe Version: {0}' -f ($ver))

            # Skip the next steps
            $unsafe = $false
         }

         # If we found a potentially risky CVE-2021-44228 and/or CVE-2021-45046 version
         if ($unsafe)
         {
            # Look for JndiLookup class and notify user/logfile
            Get-ChildItem -Path $UnpackedDirectory -Filter 'JndiLookup.class' -Recurse -ErrorAction SilentlyContinue | ForEach-Object -Process {
               Write-Verbose -Message ('POTENTIAL EXPLOIT:  Found in {0}' -f $PSItem.FullName)

               ('POTENTIAL AFFECTED: {0}' -f ($JARArchiveFile)) | Out-File -Append -FilePath $LogFile

               Write-Verbose -Message 'You should download Log4j 2.17.0 (or later): https://logging.apache.org/log4j/2.x/download.html'
            }

            # Delete JndiLookup class if $fix is $true
            if ($AutoFix)
            {
               Get-ChildItem -Path $UnpackedDirectory -Filter 'JndiLookup.class' -Recurse -ErrorAction SilentlyContinue | ForEach-Object -Process {
                  Write-Verbose -Message ('Removing {0}...' -f $PSItem.FullName)

                  $null = (Remove-Item -Path $($PSItem.FullName) -Force -Confirm:$false -ErrorAction SilentlyContinue)

                  ('REMOVED: {0}' -f $PSItem.FullName) | Out-File -Append -FilePath $LogFile
               }

               # Write new JAR archive file
               (Compress-Archive -Path ('{0}\*' -f ($UnpackedDirectory)) -DestinationPath $FiedArchive -Force -Confirm:$false -ErrorAction SilentlyContinue)

               # Restore the new JAR archive
               (Copy-Item -Path $FiedArchive -Destination $JARArchiveFile -Force -Confirm:$false)

               # cleanup
               $null = (Remove-Item -Path $FiedArchive -Force -Confirm:$false -ErrorAction SilentlyContinue)
            }
         }

         # Further cleanup
         $null = (Remove-Item -Path $TeampArchive -Force -Confirm:$false -ErrorAction SilentlyContinue)
         $null = (Remove-Item -Recurse -Path $UnpackedDirectory -Force -Confirm:$false -ErrorAction SilentlyContinue)
      }
   }
}

end
{
   # Final Cleanup
   $null = (Remove-Item -Recurse -Path ('{0}\{1}' -f ($WorkDirectory), ($TempDirectory)) -Force -Confirm:$false -ErrorAction SilentlyContinue)
}
