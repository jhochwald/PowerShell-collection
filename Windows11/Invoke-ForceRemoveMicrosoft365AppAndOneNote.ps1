#requires -Version 2.0 -RunAsAdministrator

<#
.SYNOPSIS
Remove all Microsoft 365 Apps and OneNote Apps

.DESCRIPTION
Some OEM's preload Windows with Microsoft 365 and OneNote in different languages!
We want our own installation, so we remove this crap.

.EXAMPLE
PS C:\> .\Invoke-ForceRemoveMicrosoft365AppAndOneNote.ps1
Remove all Microsoft 365 Apps and OneNote Apps

.NOTES
We want our own Intune deployment package, not the multi-ligual preload crap
#>
[CmdletBinding(ConfirmImpact = 'Low')]
[OutputType([string])]
param ()

process
{
   # Remove Microsoft 365 Apps. all languages
   foreach ($UninstallString in (Get-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction SilentlyContinue | Where-Object -FilterScript {
            ($_.DisplayName -like '*Microsoft 365*')
         } | Select-Object -ExpandProperty UninstallString))
   {
      # Get the uninstaller executable
      [string]$UninstallEXE = ($UninstallString -split '"')[1]
      # Get the uninstaller arguments
      [string]$UninstallArg = ($UninstallString -split '"')[2] + ' DisplayLevel=False'

      try
      {
         $paramStartProcess = @{
            FilePath      = $UninstallEXE
            ArgumentList  = $UninstallArg
            Wait          = $true
            ErrorAction   = 'SilentlyContinue'
            WarningAction = 'SilentlyContinue'
         }
         $null = (Start-Process @paramStartProcess)
         $paramStartProcess = $null
      }
      catch
      {
         Write-Verbose -Message 'That is unexpected, but we continue!'
      }
   }
   
   # Remove OneNote Apps. all languages
   foreach ($UninstallString in (Get-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction SilentlyContinue | Where-Object -FilterScript {
            ($_.DisplayName -like '*Microsoft OneNote*')
         } | Select-Object -ExpandProperty UninstallString))
   {
      # Get the uninstaller executable
      [string]$UninstallEXE = ($UninstallString -split '"')[1]
      # Get the uninstaller arguments
      [string]$UninstallArg = ($UninstallString -split '"')[2] + ' DisplayLevel=False'

      try
      {
         $paramStartProcess = @{
            FilePath      = $UninstallEXE
            ArgumentList  = $UninstallArg
            Wait          = $true
            ErrorAction   = 'SilentlyContinue'
            WarningAction = 'SilentlyContinue'
         }
         $null = (Start-Process @paramStartProcess)
         $paramStartProcess = $null
      }
      catch
      {
         Write-Verbose -Message 'That is unexpected, but we continue!'
      }
   }
}
