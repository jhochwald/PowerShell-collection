# Detection-PSModuleUpdate
$Repository = 'PSGallery'

# Sets up log file
$TranscriptPath = ('{0}\Microsoft\IntuneManagementExtension\Logs' -f $env:ProgramData)
$TranscriptName = 'Detection-PSModuleUpdate.log'

# Creates log directory (if necessary)
$null = (New-Item -Path $TranscriptPath -ItemType Directory -Force -Confirm:$false -ErrorAction SilentlyContinue)

# Stops orphaned transcripts
try
{
   $null = (Stop-Transcript -ErrorAction SilentlyContinue)
}
catch
{
   Write-Verbose -Message $_
}

# Starts new transcription
$null = (Start-Transcript -Path ('{0}\{1}' -f $TranscriptPath, $TranscriptName) -Append -Force -Confirm:$false -ErrorAction Stop)

foreach ($InstalledModule in (Get-InstalledModule -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | Where-Object -FilterScript {
         ($_.Repository -eq $Repository)
}))
{
   Write-Verbose -Message ('Check if updates exist for ''{0}''' -f $InstalledModule.Name)

   if ([version]((Find-Module -Name $InstalledModule.Name -Repository $Repository -ErrorAction Stop).Version) -gt [version]$InstalledModule.Version)
   {
      Write-Output -InputObject ('Update exist for ''{0}''' -f $InstalledModule.Name)
      try
      {
         $null = (Stop-Transcript -ErrorAction SilentlyContinue)
      }
      finally
      {
         exit 1
      }
   }
}

# Cleanup
$InstalledModule = $null

try
{
   $null = (Stop-Transcript -ErrorAction SilentlyContinue)
}
finally
{
   exit 0
}
