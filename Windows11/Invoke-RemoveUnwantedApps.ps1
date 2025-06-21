#requires -Version 2.0

<#
      .SYNOPSIS
      Remove a few apps we don't like to have installed any longer

      .DESCRIPTION
      Remove a few apps we don't like to have installed any longer, we use WinGet to do so

      .EXAMPLE
      PS C:\> .\Invoke-RemoveUnwantedApps.ps1
      Remove a few apps we don't like to have installed any longer

      .NOTES
      WinGet must be installed! Makes sense, right?
#>
[CmdletBinding(ConfirmImpact = 'Low')]
[OutputType([string])]
param ()

begin
{
   $AppsToRemote = @(
      '9P7BP5VNWKX5' # Quick Assist - We don't use it anyway
      '9NHT9RB2F4HD' # Microsoft Copilot - Useless app
      '9MT60QV066RP' # ModernFlyouts (Preview) - No longer required
      '9WZDNCRFHVJL' # OneNote for Windows 10 (Legacy) - Legacy, replaces by OneNote
      '9NV4BS3L1H4S' # QuickLook - We have PowerToys
   )
   
   [string]$WinGetExe = ((Get-Command -Name 'winget.exe' -ErrorAction SilentlyContinue).Source)
}

process
{
   if ($WinGetExe)
   {
      # Ensure we accept source agreements once
      $null = (& "$WinGetExe" list --accept-source-agreements)
      
      foreach ($AppToRemote in $AppsToRemote)
      {
         try
         {
            $null = (& "$WinGetExe" uninstall --exact --silent --force --nowarn --disable-interactivity --accept-source-agreements --id $AppToRemote)
         }
         catch
         {
            Write-Verbose -Message 'Catched an error from the Winget execution, we do not care at this point...'
         }
      }
   }
   else
   {
      Write-Warning -Message 'WinGet was not found' -WarningAction Continue
   }
}
