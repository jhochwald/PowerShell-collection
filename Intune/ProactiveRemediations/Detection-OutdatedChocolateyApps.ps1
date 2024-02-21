# Detection for outdated Chocolatey apps

# Don't display the progress bar
$ProgressPreference = 'SilentlyContinue'

# Config console output encoding
$null = & "$env:ComSpec" /c '' # <- Workaround for Windows PowerShell ISE "Exception setting "OutputEncoding": "The handle is invalid.""
$Script:OutputEncoding = [Console]::InputEncoding = [Console]::OutputEncoding = [Text.UTF8Encoding]::new()

#region CheckIfChocolateyIsInstalled
$choco = 'C:\ProgramData\chocolatey'

Write-Host -Object "Checking if Chocolatey is installed on $($env:COMPUTERNAME)..."

if (!(Test-Path -Path $choco -ErrorAction SilentlyContinue))
{
   Write-Host -Object 'Chocolatey was not found. We install it now!'
   Invoke-Expression -Command ((New-Object -TypeName System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
   Write-Host -Object 'Chocolatey was successfully installed.'
}
else
{
   Write-Verbose -Message 'Chocolatey already installed.'
}
#endregion CheckIfChocolateyIsInstalled

$outdated = & "$env:ChocolateyInstall\bin\choco.exe" outdated
$counter = 0
$apps = @()

foreach ($x in $outdated)
{
   if ($counter -lt 4)
   {
      $counter += 1
      continue
   }

   if ($x.Trim() -eq '')
   {
      break
   }

   $apps += $x.Split('|')[0]
}

if ($apps -gt 0)
{
   Write-Host -Object 'Out of date choco packages found'
   exit 1 # upgrade available, remediation needed
}
else
{
   Write-Host -Object 'All choco packages are up to date.'
   exit 0 # no upgrade, no action needed
}
