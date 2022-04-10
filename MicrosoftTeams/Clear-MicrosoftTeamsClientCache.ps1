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
   Remove-Item -Path $PSItem.FullName @paramRemoveItem -WhatIf
}

Get-ChildItem -Path ($AppDataBasePath + 'databases') @paramGetChildItem | ForEach-Object -Process {
   Remove-Item -Path $PSItem.FullName @paramRemoveItem
}

Get-ChildItem -Path ($AppDataBasePath + 'Cache') @paramGetChildItem | ForEach-Object -Process {
   Remove-Item -Path $PSItem.FullName @paramRemoveItem
}

Get-ChildItem -Path ($AppDataBasePath + 'gpucache') @paramGetChildItem | ForEach-Object -Process {
   Remove-Item -Path $PSItem.FullName @paramRemoveItem
}

Get-ChildItem -Path ($AppDataBasePath + 'IndexedDB') @paramGetChildItem | ForEach-Object -Process {
   Remove-Item -Path $PSItem.FullName -Confirm:$false -Force -Recurse -ErrorAction SilentlyContinue
}

Get-ChildItem -Path ($AppDataBasePath + 'Local Storage') @paramGetChildItem | ForEach-Object -Process {
   Remove-Item -Path $PSItem.FullName @paramRemoveItem
}

Get-ChildItem -Path ($AppDataBasePath + 'tmp') @paramGetChildItem | ForEach-Object -Process {
   Remove-Item -Path $PSItem.FullName @paramRemoveItem
}

Get-ChildItem -Path $AppDataBasePath -Include 'old_logs_*.txt', 'logs.txt', 'in_progress_download_metadata_store' @paramGetChildItem | ForEach-Object -Process {
   Remove-Item -Path $PSItem.FullName @paramRemoveItem
}

if (Test-Path -Path ($AppDataBasePath + 'installTime.txt'))
{
   $InstallDateInput = (Get-Content -Path ($AppDataBasePath + 'installTime.txt'))
   $Culture = (New-Object -TypeName System.Globalization.CultureInfo -ArgumentList ('de-DE'))
   $InstallDate = (Get-Date -Date $InstallDateInput -Format ($Culture.DateTimeFormat.ShortDatePattern))

   Write-Output -InputObject ('Latest Version of Microsoft Teams from: {0}' -f $InstallDate)
}

#region LICENSE
<#
   BSD 3-Clause License

   Copyright (c) 2022, enabling Technology
   All rights reserved.

   Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

   1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
   2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
   3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>
#endregion LICENSE

#region DISCLAIMER
<#
   DISCLAIMER:
   - Use at your own risk, etc.
   - This is open-source software, if you find an issue try to fix it yourself. There is no support and/or warranty in any kind
   - This is a third-party Software
   - The developer of this Software is NOT sponsored by or affiliated with Microsoft Corp (MSFT) or any of its subsidiaries in any way
   - The Software is not supported by Microsoft Corp (MSFT)
   - By using the Software, you agree to the License, Terms, and any Conditions declared and described above
   - If you disagree with any of the terms, and any conditions declared: Just delete it and build your own solution
#>
#endregion DISCLAIMER
