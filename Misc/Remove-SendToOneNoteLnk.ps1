<#
      .SYNOPSIS
      Removes the Send to OneNote Autostart

      .DESCRIPTION
      Removes the Send to OneNote Autostart, if it exists

      .EXAMPLE
      PS C:\> .\Remove-SendToOneNoteLnk.ps1

      Removes the Send to OneNote Autostart, if it exists

      .NOTES
      Simple Helper
#>
[CmdletBinding(ConfirmImpact = 'None',
               SupportsShouldProcess)]
[OutputType([string])]
param ()

process
{
   $SendToOneNoteLnk = ("{0}\Microsoft\Windows\Start Menu\Programs\Startup\Send to OneNote.lnk" -f $env:APPDATA)
   
   if (Test-Path -Path $SendToOneNoteLnk -ErrorAction SilentlyContinue)
   {
      if ($pscmdlet.ShouldProcess($SendToOneNoteLnk, 'Remove'))
      {
         $paramRemoveItem = @{
            Path        = $SendToOneNoteLnk
            Force       = $true
            Confirm     = $false
            ErrorAction = 'SilentlyContinue'
         }
         $null = (Remove-Item @paramRemoveItem)
      }
   }
}