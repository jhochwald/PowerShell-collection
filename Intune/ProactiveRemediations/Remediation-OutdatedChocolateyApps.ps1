# Remediation for outdated Chocolatey apps

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

# Attempt to update each app
if ($apps -gt 0)
{
   foreach ($app in $apps)
   {
      Write-Host -Object ('{0} installed and out of date.  Attempting to update...' -f ($app))

      try
      {
         & "$env:ChocolateyInstall\bin\choco.exe" upgrade $app -y
         Write-Host -Object ('{0} successfully updated to latest version.' -f ($app))
      }
      catch
      {
         $message = $_
         Write-Host -Object ('Error updating {0}: {1}' -f ($app), $message)
      }
   }
}
else
{
   Write-Host -Object 'All apps are up to date'
}
