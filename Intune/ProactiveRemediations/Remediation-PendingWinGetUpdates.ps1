<#
.SYNOPSIS
Remediation-PendingWinGetUpdates

.DESCRIPTION
Remediation-PendingWinGetUpdates

.EXAMPLE
PS C:\> .\Remediation-PendingWinGetUpdates.ps1

.LINK
https://github.com/Romanitho/Winget-AutoUpdate

.NOTES
Additional information about the file.
#>
[CmdletBinding(ConfirmImpact = 'None')]
[OutputType([string])]
param ()

begin
{
   #region
   class Software {
      [string]$Name
      [string]$Id
      [string]$Version
      [string]$AvailableVersion
   }
   #endregion
   
   #region Exludes
   $ExcludedApps = @(
      'Microsoft.Edge'
   )
   #endregion Exludes
   
   #region EnsureTLS
   [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072
   #endregion EnsureTLS
   
   # Workaround for ARM64 (Access Denied / Win32 internal Server error)
   $script:ProgressPreference = 'SilentlyContinue'
}

process
{
   try
   {
      $WingetPath = $null
      $WingetPath = ((Resolve-Path -Path (Join-Path -Path (Join-Path -Path $env:ProgramFiles -ChildPath 'WindowsApps' -ErrorAction Stop) -ChildPath 'Microsoft.DesktopAppInstaller*64*' -ErrorAction Stop) -ErrorAction Stop).Path)
      
      if ($WingetPath)
      {
         $Winget = ('{0}\winget.exe' -f $WingetPath)
         
         if (Test-Path -Path $Winget -ErrorAction Stop)
         {
            # Get a list of updates
            $upgradeResult = (& $Winget upgrade --source winget --accept-source-agreements | Out-String)
            
            # Start Convertion of winget format to an array. Check if "-----" exists (Winget Error Handling)
            if (!($upgradeResult -match '-----'))
            {
               return ("An unusual thing happened (maybe all apps are upgraded):`n{0}" -f $upgradeResult)
            }
            
            # Split winget output to lines
            $lines = $upgradeResult.Split([Environment]::NewLine) | Where-Object -FilterScript {
               ($_ -and $_ -notmatch '--include-unknown')
            }
            
            # Find the line that starts with "------"
            $fl = 0
            
            while (-not $lines[$fl].StartsWith('-----'))
            {
               $fl++
            }
            
            # Get header line
            $fl = $fl - 1
            
            # Get header titles
            $index = $lines[$fl] -split '\s+'
            
            # Line $fl has the header, we can find char where we find ID and Version
            $idStart = $lines[$fl].IndexOf($index[1])
            $versionStart = $lines[$fl].IndexOf($index[2])
            $availableStart = $lines[$fl].IndexOf($index[3])
            
            # Now cycle in real package and split accordingly
            $upgradeList = @()
            
            for ($i = $fl + 2; $i -lt $lines.Length - 1; $i++)
            {
               $line = $lines[$i]
               
               if ($line)
               {
                  $software = [Software]::new()
                  $software.Name = $line.Substring(0, $idStart).TrimEnd()
                  $software.Id = $line.Substring($idStart, $versionStart - $idStart).TrimEnd()
                  $software.Version = $line.Substring($versionStart, $availableStart - $versionStart).TrimEnd()
                  $software.AvailableVersion = $line.Substring($availableStart).TrimEnd()
                  $upgradeList += $software
                  
                  # Use our excludes
                  $upgradeList = $upgradeList | Where-Object -FilterScript {
                     ($ExcludedApps -notcontains $_.Id)
                  }
                  
                  if ($upgradeList.Count -ge 1)
                  {
                     foreach ($SingleUpdate in $upgradeList)
                     {
                        $null = (& $Winget upgrade --source winget --accept-source-agreements --silent --force --disable-interactivity --exact --id $($SingleUpdate.Id) | Out-String)
                     }
                  }
                  else
                  {
                     exit 0
                  }
               }
            }
         }
         else
         {
            exit 1
         }
      }
      else
      {
         exit 1
      }
   }
   catch
   {
      # Get error record
      [Management.Automation.ErrorRecord]$e = $_
      
      # Retrieve information about runtime error
      $info = [PSCustomObject]@{
         Exception = $e.Exception.Message
         Reason    = $e.CategoryInfo.Reason
         Target    = $e.CategoryInfo.TargetName
         Script    = $e.InvocationInfo.ScriptName
         Line      = $e.InvocationInfo.ScriptLineNumber
         Column    = $e.InvocationInfo.OffsetInLine
      }
      
      $info | Out-String | Write-Verbose
      
      exit 1
   }
}