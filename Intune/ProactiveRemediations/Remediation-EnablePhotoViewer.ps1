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

#region Defaults
$STP = 'Stop'
$SCT = 'SilentlyContinue'
#endregion Defaults

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
   if ((Test-Path -LiteralPath 'HKCU:\SOFTWARE\Classes\.bmp' -ErrorAction $SCT) -ne $true)
   {
      $null = (New-Item -Path 'HKCU:\SOFTWARE\Classes\.bmp' -Force -Confirm:$false -ErrorAction $STP)
   }

   if ((Test-Path -LiteralPath 'HKCU:\SOFTWARE\Classes\.gif' -ErrorAction $SCT) -ne $true)
   {
      $null = (New-Item -Path 'HKCU:\SOFTWARE\Classes\.gif' -Force -Confirm:$false -ErrorAction $STP)
   }

   if ((Test-Path -LiteralPath 'HKCU:\SOFTWARE\Classes\.ico' -ErrorAction $SCT) -ne $true)
   {
      $null = (New-Item -Path 'HKCU:\SOFTWARE\Classes\.ico' -Force -Confirm:$false -ErrorAction $STP)
   }

   if ((Test-Path -LiteralPath 'HKCU:\SOFTWARE\Classes\.jpeg' -ErrorAction $SCT) -ne $true)
   {
      $null = (New-Item -Path 'HKCU:\SOFTWARE\Classes\.jpeg' -Force -Confirm:$false -ErrorAction $STP)
   }

   if ((Test-Path -LiteralPath 'HKCU:\SOFTWARE\Classes\.jpg' -ErrorAction $SCT) -ne $true)
   {
      $null = (New-Item -Path 'HKCU:\SOFTWARE\Classes\.jpg' -Force -Confirm:$false -ErrorAction $STP)
   }

   if ((Test-Path -LiteralPath 'HKCU:\SOFTWARE\Classes\.png' -ErrorAction $SCT) -ne $true)
   {
      $null = (New-Item -Path 'HKCU:\SOFTWARE\Classes\.png' -Force -Confirm:$false -ErrorAction $STP)
   }

   if ((Test-Path -LiteralPath 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.gif\OpenWithProgids' -ErrorAction $SCT) -ne $true)
   {
      $null = (New-Item -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.gif\OpenWithProgids' -Force -Confirm:$false -ErrorAction $STP)
   }

   if ((Test-Path -LiteralPath 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.ico\OpenWithProgids' -ErrorAction $SCT) -ne $true)
   {
      $null = (New-Item -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.ico\OpenWithProgids' -Force -Confirm:$false -ErrorAction $STP)
   }

   if ((Test-Path -LiteralPath 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jpeg\OpenWithProgids' -ErrorAction $SCT) -ne $true)
   {
      $null = (New-Item -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jpeg\OpenWithProgids' -Force -Confirm:$false -ErrorAction $STP)
   }

   if ((Test-Path -LiteralPath 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.bmp\OpenWithProgids' -ErrorAction $SCT) -ne $true)
   {
      $null = (New-Item -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.bmp\OpenWithProgids' -Force -Confirm:$false -ErrorAction $STP)
   }

   if ((Test-Path -LiteralPath 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jpg\OpenWithProgids' -ErrorAction $SCT) -ne $true)
   {
      $null = (New-Item -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jpg\OpenWithProgids' -Force -Confirm:$false -ErrorAction $STP)
   }

   if ((Test-Path -LiteralPath 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.png\OpenWithProgids' -ErrorAction $SCT) -ne $true)
   {
      $null = (New-Item -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.png\OpenWithProgids' -Force -Confirm:$false -ErrorAction $STP)
   }

   $null = (New-ItemProperty -LiteralPath 'HKCU:\SOFTWARE\Classes\.bmp' -Name '(default)' -Value 'PhotoViewer.FileAssoc.Tiff' -PropertyType String -Force -Confirm:$false -ErrorAction $STP)
   $null = (New-ItemProperty -LiteralPath 'HKCU:\SOFTWARE\Classes\.gif' -Name '(default)' -Value 'PhotoViewer.FileAssoc.Tiff' -PropertyType String -Force -Confirm:$false -ErrorAction $STP)
   $null = (New-ItemProperty -LiteralPath 'HKCU:\SOFTWARE\Classes\.ico' -Name '(default)' -Value 'PhotoViewer.FileAssoc.Tiff' -PropertyType String -Force -Confirm:$false -ErrorAction $STP)
   $null = (New-ItemProperty -LiteralPath 'HKCU:\SOFTWARE\Classes\.jpeg' -Name '(default)' -Value 'PhotoViewer.FileAssoc.Tiff' -PropertyType String -Force -Confirm:$false -ErrorAction $STP)
   $null = (New-ItemProperty -LiteralPath 'HKCU:\SOFTWARE\Classes\.jpg' -Name '(default)' -Value 'PhotoViewer.FileAssoc.Tiff' -PropertyType String -Force -Confirm:$false -ErrorAction $STP)
   $null = (New-ItemProperty -LiteralPath 'HKCU:\SOFTWARE\Classes\.png' -Name '(default)' -Value 'PhotoViewer.FileAssoc.Tiff' -PropertyType String -Force -Confirm:$false -ErrorAction $STP)
   $null = (New-ItemProperty -LiteralPath 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.gif\OpenWithProgids' -Name 'PhotoViewer.FileAssoc.Tiff' -Value (New-Object -TypeName Byte[] -ArgumentList 0) -PropertyType None -Force -Confirm:$false -ErrorAction $STP)
   $null = (New-ItemProperty -LiteralPath 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.ico\OpenWithProgids' -Name 'PhotoViewer.FileAssoc.Tiff' -Value (New-Object -TypeName Byte[] -ArgumentList 0) -PropertyType None -Force -Confirm:$false -ErrorAction $STP)
   $null = (New-ItemProperty -LiteralPath 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jpeg\OpenWithProgids' -Name 'PhotoViewer.FileAssoc.Tiff' -Value (New-Object -TypeName Byte[] -ArgumentList 0) -PropertyType None -Force -Confirm:$false -ErrorAction $STP)
   $null = (New-ItemProperty -LiteralPath 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.bmp\OpenWithProgids' -Name 'PhotoViewer.FileAssoc.Tiff' -Value (New-Object -TypeName Byte[] -ArgumentList 0) -PropertyType None -Force -Confirm:$false -ErrorAction $STP)
   $null = (New-ItemProperty -LiteralPath 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jpg\OpenWithProgids' -Name 'PhotoViewer.FileAssoc.Tiff' -Value (New-Object -TypeName Byte[] -ArgumentList 0) -PropertyType None -Force -Confirm:$false -ErrorAction $STP)
   $null = (New-ItemProperty -LiteralPath 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.png\OpenWithProgids' -Name 'PhotoViewer.FileAssoc.Tiff' -Value (New-Object -TypeName Byte[] -ArgumentList 0) -PropertyType None -Force -Confirm:$false -ErrorAction $STP)
}
catch
{
   Write-Error -Message $_ -ErrorAction $STP

   exit 1
}