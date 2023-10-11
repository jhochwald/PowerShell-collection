function Get-BadFontPaths
{
   <#
         .SYNOPSIS
         Get a List of blocked Font Files

         .DESCRIPTION
         Get a List of blocked Font Files, can be the case if files are downloaded
         Downloaded Files might have Zone 3 (Internet) and might then be blocked

         .PARAMETER Fix
         Try to fix (unblock) all blocked Font files found?

         .EXAMPLE
         PS C:\> Get-BadFontPaths

         Get a List of blocked Font Files

         .EXAMPLE
         PS C:\> Get-BadFontPaths -Verbose -Fix

         Unblock all blocked Font Files - You need admin permission to Fix blocked files in C:\Windows\Fonts\

         .EXAMPLE
         PS C:\> Get-BadFontPaths -Verbose -Fix -Verbose

         Unblock all blocked Font Files - You need admin permission to Fix blocked files in C:\Windows\Fonts\
         Same as abobe, but try to be verbose

         .EXAMPLE
         PS C:\> Get-BadFontPaths | ForEach-Object { Unblock-File -Path $_ -Confirm:$false }

         Unblock all blocked Font Files - You need admin permission to Fix blocked files in C:\Windows\Fonts\
         Old School way with a ForEach loop and the usage of Unblock-File

         .NOTES
         Here are some well known zones:
         0. Local Machine
         1. Local Intranet
         2. Trusted Sites
         3. Internet
         4. Restricted Sites

         You can also filter for specific zones, if you like to.

         .LINK
         https://github.com/File-New-Project/TroubleshootingPacks/blob/master/FixBlockedFonts/Functions.ps1

         .LINK
         https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-fscc/6e3f7352-d11c-4d76-8c39-2516a9df36e8
   #>

   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([string])]
   param
   (
      [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
      [Alias('AutoFix')]
      [switch]
      $Fix
   )

   begin
   {
      $SearchLocations = @(
         # User font location
         ("{0}\Microsoft\Windows\Fonts" -f $env:LocalAppData),
         # System wide font location
         ("{0}\Fonts" -f $env:SystemRoot)
      )
   }

   process
   {
      $SearchLocations | ForEach-Object -Process {
         Write-Verbose -Message ('Scanning {0}' -f $_)

         Get-ChildItem -Recurse -Filter *.ttf -Path $_ | ForEach-Object -Process {
            $Stream = ('{0}:Zone.Identifier' -f $_.FullName)
            $ZoneId = (Get-Content -Path $Stream -ErrorAction SilentlyContinue)

            if ($ZoneId -like '*ZoneTransfer*')
            {
               if ($Fix.IsPresent)
               {
                  # Try to unlock
                  Write-Verbose -Message ('Try to unklock {0}' -f $_.FullName)

                  Unblock-File -Path $_.FullName -Confirm:$false
               }
               else
               {
                  # Just dump it
                  $_.FullName
               }
            }
         }
      }
   }
}
