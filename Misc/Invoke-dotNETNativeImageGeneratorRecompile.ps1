#requires -Version 2.0 -RunAsAdministrator

<#
      .SYNOPSIS
      Force .NET Native Image recompile

      .DESCRIPTION
      Force .NET Native Image recompile, and do NOT wait until the pending queue is processed in the background
      Just a wrapper for the CLR Native Image Generator (ngen.exe)

      .EXAMPLE
      PS C:\> .\Invoke-dotNETNativeImageGeneratorRecompile.ps1

      .NOTES
      Please execute within an elevated shell, be patient

      This can become handy, after updates

      But it will take time and generates load on the system, you might hear your fan's
      Mostly because Defender (e.g., MsMpEng.exe and/or MsSense.exe) also realizes that something is going on

      If you see "Failed to load dependency" errors, that can be ignored (at least for this wrapper)
      Same applied for messages like this: "Specify the input as a .EXE for ngen to pick up the config-file"
#>
[CmdletBinding()]
[OutputType([string])]
param ()

process
{
   # Did I miss anything?
   $NETPath = @(
      ('{0}\Microsoft.NET\Framework' -f $env:windir)
      ('{0}\Microsoft.NET\Framework64' -f $env:windir)
      ('{0}\Microsoft.NET\FrameworkArm64' -f $env:windir)
   )

   foreach ($NETPathItem in $NETPath)
   {
      if (Test-Path -Path $NETPathItem -ErrorAction SilentlyContinue)
      {
         # There are several versions on a regular system, we try to cover all of them! Just in case...
         # Mostly not the case on ARM64 systems, because all the legacy crap is not there (at least not on the native side)
         (Get-ChildItem -Path $NETPathItem -Filter 'v*.*' -ErrorAction SilentlyContinue).FullName | ForEach-Object {
            $null = (Push-Location -Path $_)

            # Do we have the CLR Native Image Generator within this directory?
            if (Test-Path -Path '.\ngen.exe' -ErrorAction SilentlyContinue)
            {
               <#
                  If you want to see more details, remove the /silent in the "ArgumentList"

                  If (whyever) you want to see the version details of each CLR,
                  remove the /nologo in the "ArgumentList"
               #>

               <#
                  Update native images that have become invalid
                  All the compilation jobs are queued up
               #>
               $paramStartProcess = @{
                  FilePath         = '.\ngen.exe'
                  ArgumentList     = 'update /queue /nologo /silent'
                  WorkingDirectory = $_
                  NoNewWindow      = $true
                  Wait             = $true
                  ErrorAction      = 'SilentlyContinue'
                  WarningAction    = 'SilentlyContinue'
               }
               $null = (Start-Process @paramStartProcess)

               # Executes ALL the queued compilation jobs
               $paramStartProcess = @{
                  FilePath         = '.\ngen.exe'
                  ArgumentList     = 'executeQueuedItems /nologo /silent'
                  WorkingDirectory = $_
                  NoNewWindow      = $true
                  Wait             = $true
                  ErrorAction      = 'SilentlyContinue'
                  WarningAction    = 'SilentlyContinue'
               }
               $null = (Start-Process @paramStartProcess)
            }

            $null = (Pop-Location)
         }
      }
   }
}