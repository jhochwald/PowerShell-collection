#requires -Version 5.0
<#
      .SYNOPSIS
      Enable Photo Viewer

      .DESCRIPTION
      Enable Photo Viewer for all image types

      .NOTES
      Designed to run in Microsoft Endpoint Manager (Intune)
#>
[CmdletBinding(ConfirmImpact = 'None')]
param ()

#region ARM64Handling
# Restart Process using PowerShell 64-bit
if ($ENV:PROCESSOR_ARCHITEW6432 -eq 'AMD64')
{
   try
   {
      &"$ENV:WINDIR\SysNative\WindowsPowershell\v1.0\PowerShell.exe" -File $PSCOMMANDPATH
   }
   catch
   {
      throw ('Failed to start {0}' -f $PSCOMMANDPATH)
   }

   exit
}
#endregion ARM64Handling

try
{
   if (-not (Test-Path -LiteralPath 'HKCU:\SOFTWARE\Classes\.bmp' -ErrorAction SilentlyContinue))
   {
      'NOT FOUND'
      exit 1
   }

   if (-not (Test-Path -LiteralPath 'HKCU:\SOFTWARE\Classes\.gif' -ErrorAction SilentlyContinue))
   {
      'NOT FOUND'
      exit 1
   }

   if (-not (Test-Path -LiteralPath 'HKCU:\SOFTWARE\Classes\.ico' -ErrorAction SilentlyContinue))
   {
      'NOT FOUND'
      exit 1
   }

   if (-not (Test-Path -LiteralPath 'HKCU:\SOFTWARE\Classes\.jpeg' -ErrorAction SilentlyContinue))
   {
      'NOT FOUND'
      exit 1
   }

   if (-not (Test-Path -LiteralPath 'HKCU:\SOFTWARE\Classes\.jpg' -ErrorAction SilentlyContinue))
   {
      'NOT FOUND'
      exit 1
   }

   if (-not (Test-Path -LiteralPath 'HKCU:\SOFTWARE\Classes\.png' -ErrorAction SilentlyContinue))
   {
      'NOT FOUND'
      exit 1
   }

   if (-not (Test-Path -LiteralPath 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.gif\OpenWithProgids' -ErrorAction SilentlyContinue))
   {
      'NOT FOUND'
      exit 1
   }

   if (-not (Test-Path -LiteralPath 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.ico\OpenWithProgids' -ErrorAction SilentlyContinue))
   {
      'NOT FOUND'
      exit 1
   }

   if (-not (Test-Path -LiteralPath 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jpeg\OpenWithProgids' -ErrorAction SilentlyContinue))
   {
      'NOT FOUND'
      exit 1
   }

   if (-not (Test-Path -LiteralPath 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.bmp\OpenWithProgids' -ErrorAction SilentlyContinue))
   {
      'NOT FOUND'
      exit 1
   }

   if (-not (Test-Path -LiteralPath 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jpg\OpenWithProgids' -ErrorAction SilentlyContinue))
   {
      'NOT FOUND'
      exit 1
   }

   if (-not (Test-Path -LiteralPath 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.png\OpenWithProgids' -ErrorAction SilentlyContinue))
   {
      'NOT FOUND'
      exit 1
   }

   if (-not ((Get-ItemPropertyValue -LiteralPath 'HKCU:\SOFTWARE\Classes\.bmp' -Name '(default)' -ErrorAction SilentlyContinue) -eq 'PhotoViewer.FileAssoc.Tiff'))
   {
      'NOT FOUND'
      exit 1
   }

   if (-not ((Get-ItemPropertyValue -LiteralPath 'HKCU:\SOFTWARE\Classes\.gif' -Name '(default)' -ErrorAction SilentlyContinue) -eq 'PhotoViewer.FileAssoc.Tiff'))
   {
      'NOT FOUND'
      exit 1
   }

   if (-not ((Get-ItemPropertyValue -LiteralPath 'HKCU:\SOFTWARE\Classes\.ico' -Name '(default)' -ErrorAction SilentlyContinue) -eq 'PhotoViewer.FileAssoc.Tiff'))
   {
      'NOT FOUND'
      exit 1
   }

   if (-not ((Get-ItemPropertyValue -LiteralPath 'HKCU:\SOFTWARE\Classes\.jpeg' -Name '(default)' -ErrorAction SilentlyContinue) -eq 'PhotoViewer.FileAssoc.Tiff'))
   {
      'NOT FOUND'
      exit 1
   }

   if (-not ((Get-ItemPropertyValue -LiteralPath 'HKCU:\SOFTWARE\Classes\.jpg' -Name '(default)' -ErrorAction SilentlyContinue) -eq 'PhotoViewer.FileAssoc.Tiff'))
   {
      'NOT FOUND'
      exit 1
   }

   if (-not ((Get-ItemPropertyValue -LiteralPath 'HKCU:\SOFTWARE\Classes\.png' -Name '(default)' -ErrorAction SilentlyContinue) -eq 'PhotoViewer.FileAssoc.Tiff'))
   {
      'NOT FOUND'
      exit 1
   }

   try
   {
      if (-not ((Get-ItemPropertyValue -LiteralPath 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.gif\OpenWithProgids' -Name 'PhotoViewer.FileAssoc.Tiff ' -ErrorAction SilentlyContinue).length -eq 0))
      {
         exit 1
      }
   }
   catch
   {
      Write-Error -Message $_ -ErrorAction Stop

      exit 1
   }

   try
   {
      if (-not ((Get-ItemPropertyValue -LiteralPath 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.ico\OpenWithProgids' -Name 'PhotoViewer.FileAssoc.Tiff ' -ErrorAction SilentlyContinue).length -eq 0))
      {
         exit 1
      }
   }
   catch
   {
      Write-Error -Message $_ -ErrorAction Stop

      exit 1
   }

   try
   {
      if (-not ((Get-ItemPropertyValue -LiteralPath 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jpeg\OpenWithProgids' -Name 'PhotoViewer.FileAssoc.Tiff ' -ErrorAction SilentlyContinue).length -eq 0))
      {
         exit 1
      }
   }
   catch
   {
      Write-Error -Message $_ -ErrorAction Stop

      exit 1
   }

   try
   {
      if (-not ((Get-ItemPropertyValue -LiteralPath 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.bmp\OpenWithProgids' -Name 'PhotoViewer.FileAssoc.Tiff ' -ErrorAction SilentlyContinue).length -eq 0))
      {
         exit 1
      }
   }
   catch
   {
      Write-Error -Message $_ -ErrorAction Stop

      exit 1
   }

   try
   {
      if (-not ((Get-ItemPropertyValue -LiteralPath 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jpg\OpenWithProgids' -Name 'PhotoViewer.FileAssoc.Tiff ' -ErrorAction SilentlyContinue).length -eq 0))
      {
         exit 1
      }
   }
   catch
   {
      Write-Error -Message $_ -ErrorAction Stop

      exit 1
   }

   try
   {
      if (-not ((Get-ItemPropertyValue -LiteralPath 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.png\OpenWithProgids' -Name 'PhotoViewer.FileAssoc.Tiff ' -ErrorAction SilentlyContinue).length -eq 0))
      {
         exit 1
      }
   }
   catch
   {
      Write-Error -Message $_ -ErrorAction Stop
      exit 1
   }
}
catch
{
   Write-Error -Message $_ -ErrorAction Stop

   exit 1
}

exit 0