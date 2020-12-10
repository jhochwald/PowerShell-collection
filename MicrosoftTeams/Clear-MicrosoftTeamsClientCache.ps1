<#
      .SYNOPSIS
      Cleanup Microsoft Teams Client
	
      .DESCRIPTION
      Cleanup Microsoft Teams Client by deleting several local cache files
	
      .EXAMPLE
      PS C:\> .\Clear-MicrosoftTeamsClientCache.ps1

      Cleanup Microsoft Teams Client by deleting several local cache files

      .EXAMPLE
      PS C:\> .\Clear-MicrosoftTeamsClientCache.ps1 -Verbose

      Cleanup Microsoft Teams Client by deleting several local cache files, but be verbose while doing it

      .EXAMPLE
      PS C:\> .\Clear-MicrosoftTeamsClientCache.ps1 -WhatIf
      Cleanup Microsoft Teams Client by deleting several local cache files - Dry Run!!!

      .NOTES
      Due to some issues, Windows is not supported at this time!
#>
[CmdletBinding(ConfirmImpact = 'Medium',
SupportsShouldProcess)]
param ()

if ($IsMacOS -eq $true)
{
   $AppDataBasePath = '~/Library/Application Support/Microsoft/Teams/'
}
else
{
   Write-Warning -Message 'Due to some issues, Windows is not supported at this time!'
	
   exit 1
	
   $AppDataBasePath = ($env:APPDATA + '\Microsoft\teams\')
}

#region BoundParameters
if (($PSCmdlet.MyInvocation.BoundParameters['Verbose']).IsPresent)
{
   $VerboseValue = $true
}
else
{
   $VerboseValue = $false
}

if (($PSCmdlet.MyInvocation.BoundParameters['Debug']).IsPresent)
{
   $DebugValue = $true
}
else
{
   $DebugValue = $false
}

if (($PSCmdlet.MyInvocation.BoundParameters['WhatIf']).IsPresent)
{
   $WhatIfValue = $true
}
else
{
   $WhatIfValue = $false
}
#endregion BoundParameters

#region
$paramGetChildItem = @{
   Verbose     = $VerboseValue
   Debug       = $DebugValue
   Recurse     = $true
   ErrorAction = 'SilentlyContinue'
}

$paramRemoveItem = @{
   Verbose     = $VerboseValue
   Debug       = $DebugValue
   WhatIf      = $WhatIfValue
   Confirm     = $false
   Force       = $true
   Recurse     = $true
   ErrorAction = 'SilentlyContinue'
}
#endregion

#region
if ($PSCmdlet.ShouldProcess('Microsoft Teams Client', 'Hard Kill'))
{
   $null = (Get-Process -Name Teams -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue)
   Start-Sleep -Seconds 2
}
#endregion

Get-ChildItem -Path ($AppDataBasePath + 'blob_storage') @paramGetChildItem -Verbose -Debug | ForEach-Object -Process {
   Remove-Item -Path $_.FullName @paramRemoveItem -WhatIf
}

Get-ChildItem -Path ($AppDataBasePath + 'databases') @paramGetChildItem | ForEach-Object -Process {
   Remove-Item -Path $_.FullName @paramRemoveItem
}

Get-ChildItem -Path ($AppDataBasePath + 'Cache') @paramGetChildItem | ForEach-Object -Process {
   Remove-Item -Path $_.FullName @paramRemoveItem
}

Get-ChildItem -Path ($AppDataBasePath + 'gpucache') @paramGetChildItem | ForEach-Object -Process {
   Remove-Item -Path $_.FullName @paramRemoveItem
}

Get-ChildItem -Path ($AppDataBasePath + 'IndexedDB') @paramGetChildItem | ForEach-Object -Process {
   Remove-Item -Path $_.FullName -Confirm:$false -Force -Recurse -ErrorAction SilentlyContinue
}

Get-ChildItem -Path ($AppDataBasePath + 'Local Storage') @paramGetChildItem | ForEach-Object -Process {
   Remove-Item -Path $_.FullName @paramRemoveItem
}

Get-ChildItem -Path ($AppDataBasePath + 'tmp') @paramGetChildItem | ForEach-Object -Process {
   Remove-Item -Path $_.FullName @paramRemoveItem
}

Get-ChildItem -Path $AppDataBasePath -Include 'old_logs_*.txt', 'logs.txt', 'in_progress_download_metadata_store' @paramGetChildItem | ForEach-Object -Process {
   Remove-Item -Path $_.FullName @paramRemoveItem
}

if (Test-Path -Path ($AppDataBasePath + 'installTime.txt'))
{
   $InstallDateInput = (Get-Content -Path ($AppDataBasePath + 'installTime.txt'))
   $Culture = (New-Object -TypeName System.Globalization.CultureInfo -ArgumentList ('de-DE'))
   $InstallDate = (Get-Date -Date $InstallDateInput -Format ($Culture.DateTimeFormat.ShortDatePattern))
	
   Write-Output -InputObject ('Latest Version of Microsoft Teams from: {0}' -f $InstallDate)
}
