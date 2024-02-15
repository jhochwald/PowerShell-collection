# Detection for outdated WinGet apps

# Config console output encoding
$null = & "$env:ComSpec" /c '' # <- Workaround for Windows PowerShell ISE "Exception setting "OutputEncoding": "The handle is invalid.""
$Script:OutputEncoding = [Console]::InputEncoding = [Console]::OutputEncoding = [Text.UTF8Encoding]::new()

#region FindWinGetCli
# Find directory
$WingetDirectory = [string](
   $(
      if ([Security.Principal.WindowsIdentity]::GetCurrent().'User'.'Value' -eq 'S-1-5-18')
      {
         ((Get-Item -Path ('{0}\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe' -f $env:ProgramW6432)).'FullName' | Select-Object -First 1)
      }
      else
      {
         ('{0}\Microsoft\WindowsApps' -f $env:LOCALAPPDATA)
      }
   )
)

# Find file name
$WingetCliFileName = ([string](
      $(
         [string[]](
            'AppInstallerCLI.exe',
            'winget.exe'
         )
      ).Where{
         [IO.File]::Exists(
            ('{0}\{1}' -f $WingetDirectory, $_)
         )
      } | Select-Object -First 1
))

# Combine and file name
$WingetCliPath = ([string] '{0}\{1}' -f $WingetDirectory, $WingetCliFileName)


# Check if $WingetCli exists
if (-not ([IO.File]::Exists($WingetCliPath)))
{
   Write-Error -Exception 'WinGet Binary not found' -Message 'Did not find WinGet Binary.' -Category NotInstalled -TargetObject 'winget.exe' -RecommendedAction 'Install WinGet (From the Microsoft Store or GitHub)' -ErrorAction Stop

   Exit 1
}
#endregion FindWinGetCli

$upgradeResult = & $WingetCliPath upgrade --source winget --accept-source-agreements | Out-String
# Split winget output to lines
$lines = $upgradeResult.Split([Environment]::NewLine) | Where-Object -FilterScript {
   $_
}

# Find the line that starts with "------"
$fl = 0

try
{
   while (-not $lines[$fl].StartsWith('-----'))
   {
      $fl++
   }
}
catch
{
   # Prevent any "You cannot call a method on a null-valued expression." errors
   Write-Verbose 'No matching line found'
}

#Get header line
$fl = $fl - 1

#Get header titles [without remove seperator]
$index = $lines[$fl] -split '(?<=\s)(?!\s)'

# Line $fl has the header, we can find char where we find ID and Version [and manage non latin characters]
$idStart = $($index[0] -replace '[\u4e00-\u9fa5]', '**').Length

# Now cycle in real package and split accordingly
$upgradeList = @()

$NamesToIgnore = @(
'Python 3.11.3 (64-bit)'
)

For ($i = $fl + 2; $i -lt $lines.Length; $i++)
{
   $line = $lines[$i] -replace '[\u2026]', ' ' #Fix "..." in long names

   if ($line.StartsWith('-----'))
   {
      # Get header line
      $fl = $i - 1

      # Get header titles [without remove seperator]
      $index = $lines[$fl] -split '(?<=\s)(?!\s)'

      # Line $fl has the header, we can find char where we find ID and Version [and manage non latin characters]
      $idStart = $($index[0] -replace '[\u4e00-\u9fa5]', '**').Length
   }

   if ($line -match '\w\.\w')
   {
      #Manage non latin characters
      $nameDeclination = $($line.Substring(0, $idStart) -replace '[\u4e00-\u9fa5]', '**').Length - $line.Substring(0, $idStart).Length
      $OutdatedPackage = ($line.Substring(0, $idStart - $nameDeclination).TrimEnd())
      
      if ($OutdatedPackage -notcontains $NamesToIgnore)
      {
         $upgradeList += $OutdatedPackage
      }
   }
}

if ($upgradeList)
{
   Write-Host -Object ('Upgrade(s) available: {0}' -f $upgradeList)
   exit 1 # upgrade available, remediation needed
}
else
{
   Write-Host -Object 'No Upgrade available'
   exit 0 # no upgrade, no action needed
}
