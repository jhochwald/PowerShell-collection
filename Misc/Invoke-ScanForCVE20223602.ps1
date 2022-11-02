
<#
      .SYNOPSIS
      Scan for CVE-2022-3602 vulnerable versions of OpenSSL
   
      .DESCRIPTION
      Scan for CVE-2022-3602 vulnerable versions of OpenSSL
   
      .PARAMETER All
      Scan for all versions or just for vulnerable versions of OpenSSL
   
      .EXAMPLE
      PS C:\> .\Invoke-ScanForCVE20223602.ps1
   
      .NOTES
      Additional information about the file.
#>
[CmdletBinding(ConfirmImpact = 'Low')]
[OutputType([string])]
param
(
   [Parameter(ValueFromPipeline,
   ValueFromPipelineByPropertyName)]
   [Alias('AllVersions', 'ScanAll')]
   [bool]
   $All = $false
)

begin
{
   if ($All -eq $true)
   {
      # All Versions
      $OpensslRegex = 'OpenSSL\s*[0-9]\.[0-9]\.[0-9]'
   }
   else
   {
      # Scan for vulnerable versions only?
      $OpensslRegex = 'OpenSSL\s*3\.0\.[0-6]'
   }
}

process
{
   # Get all Drives
   $AllDrives = ((Get-PSDrive -PSProvider FileSystem).Root)

   foreach ($DriveToScan in $AllDrives)
   {
      Write-Output -InputObject ('Start Scan on {1} on {0}' -f $env:COMPUTERNAME, $DriveToScan)
   
      try
      {
         Get-ChildItem -Path $DriveToScan -Include libcrypto*.dll, libssl*.dll -File -Recurse -ErrorAction SilentlyContinue | ForEach-Object -Process {
            # use RegEx to parse the dll strings for an OpenSSL Version Number
            $OpensslVersion = (Select-String -Path $_ -Pattern $OpensslRegex -AllMatches | ForEach-Object -Process {
                  $_.Matches
               } | ForEach-Object -Process {
                  $_.Value
            })
            if ($OpensslVersion) 
            {
               # Print OpenSSL version number followed by file name
               Write-Warning -Message ('{0} - {1} ' -f $OpensslVersion, $_)
            }
         }
      }
      catch
      {
         $_ | Write-Verbose
      }

      Write-Output -InputObject ('Done Scan on {1} on {0}' -f $env:COMPUTERNAME, $DriveToScan)
   }
}