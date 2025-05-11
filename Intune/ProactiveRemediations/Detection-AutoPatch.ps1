# Detection-AutoPatch
# https://techcommunity.microsoft.com/t5/windows-it-pro-blog/windows-autopatch-auto-remediation-with-powershell-scripts/ba-p/4228854

# Defines log location and name
$TranscriptPath = ('{0}\Microsoft\IntuneManagementExtension\Logs' -f $env:ProgramData)
$TranscriptName = 'Detection-AutoPatch.log'

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

# Creates registry key array
[PsObject[]]$regkeys = @()

# Populates array with target keys
$regkeys += [PsObject]@{
   Name = 'DoNotConnectToWindowsUpdateInternetLocations'
   Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\'
}
$regkeys += [PsObject]@{
   Name = 'DisableWindowsUpdateAccess'
   Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\'
}
$regkeys += [PsObject]@{
   Name = 'NoAutoUpdate'
   Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU\'
}

# Populates array with key information
foreach ($setting in $regkeys)
{
   Write-Output -InputObject ('Checking {0}' -f $setting.Name)

   # Checks registry settings
   if (((Get-Item -Path $setting.Path -ErrorAction SilentlyContinue).Property)  -contains $setting.Name)
   {
      Write-Output -InputObject ('{0} is not correct' -f $setting.Name)

      $RemediationNeeded = $true
   }
}

# Logs and exits based on findings
if ($RemediationNeeded -eq $true)
{
   Write-Output -InputObject 'Registry settings are incorrect'

   try
   {
      $null = (Stop-Transcript -ErrorAction SilentlyContinue)
   }
   finally
   {
      exit 1
   }
}
else 
{
   Write-Output -InputObject 'Registry settings are correct'

   try
   {
      $null = (Stop-Transcript -ErrorAction SilentlyContinue)
   }
   finally
   {
      exit 0
   }
}
