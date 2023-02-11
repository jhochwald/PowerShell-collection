#requires -Version 2.0 -RunAsAdministrator
<#
   .SYNOPSIS
   Clean-up my test VM for further testing

   .DESCRIPTION
   Clean-up my test VM for further testing

   Very simple, but brutal, clean-up script!

   .EXAMPLE
   PS C:\> .\Invoke-CleanupTestVM.ps1

   Clean-up my test VM for further testing

   .NOTES
   Nothing fancy, no real error handling, just a straight foreword clean-up
   A bit brutal, but effective

   Some stuff is still using native command-line tools, because I still need to fix some and because sometimes they a much faster (or way simpler to use)

   Please review this script carefully and do NOT just execute it. It IS very brutal, you have been warned!!!
#>
[CmdletBinding(ConfirmImpact = 'Low')]
[OutputType([string])]
param ()

process
{
   # Stop VMware App Volumes service
   $paramStopService = @{
      Force       = $true
      Confirm     = $false
      ErrorAction = 'SilentlyContinue'
   }
   $null = (Get-Service -Name svservice -ErrorAction SilentlyContinue | Stop-Service @paramStopService)

   # Stop and disable Windows update service
   $null = (Get-Service -Name wuauserv -ErrorAction SilentlyContinue | Stop-Service @paramStopService)
   $paramSetService = @{
      Name        = 'wuauserv'
      StartupType = 'Disabled'
      Confirm     = $false
      ErrorAction = 'SilentlyContinue'
   }
   $null = (Set-Service @paramSetService)

   # Delete any existing shadow copies
   $null = (& "$env:windir\system32\vssadmin.exe" delete shadows /All /Quiet)

   # Delete files in c:\Windows\SoftwareDistribution\Download\
   $paramRemoveItem = @{
      Recurse     = $true
      Force       = $true
      Confirm     = $false
      ErrorAction = 'SilentlyContinue'
   }

   $paramGetChildItem = @{
      Path        = ('{0}\SoftwareDistribution\Download\' -f $env:windir)
      ErrorAction = 'SilentlyContinue'
   }
   $null = ((Get-ChildItem @paramGetChildItem ).FullName | Remove-Item @paramRemoveItem)

   # Delete prefetch files
   $paramGetChildItem = @{
      Path        = ('{0}\Prefetch\' -f $env:windir)
      ErrorAction = 'SilentlyContinue'
   }
   $null = ((Get-ChildItem @paramGetChildItem ).FullName | Remove-Item @paramRemoveItem)

   # Run Disk clean-up to remove temp files, empty recycle bin and remove other unneeded files
   $null = (& "$env:windir\system32\cleanmgr.exe" /sagerun:1)

   # Force .NET Native Image recompile (taken from here https://github.com/jhochwald/PowerShell-collection/blob/main/Misc/Invoke-dotNETNativeImageGeneratorRecompile.ps1)
   $NETPath = @(
      ('{0}\Microsoft.NET\Framework' -f $env:windir)
      ('{0}\Microsoft.NET\Framework64' -f $env:windir)
      ('{0}\Microsoft.NET\FrameworkArm64' -f $env:windir)
   )

   foreach ($NETPathItem in $NETPath)
   {
      if (Test-Path -Path $NETPathItem -ErrorAction SilentlyContinue)
      {
         $paramGetChildItem = @{
            Path        = $NETPathItem
            Filter      = 'v*.*'
            ErrorAction = 'SilentlyContinue'
         }
         (Get-ChildItem @paramGetChildItem ).FullName | ForEach-Object -Process {
            $null = (Push-Location -Path $_)

            if (Test-Path -Path '.\ngen.exe' -ErrorAction SilentlyContinue)
            {
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

   # Clean-up the base image with DISM
   $null = (& "$env:windir\system32\dism.exe" /online /cleanup-image /startcomponentcleanup /resetbase)

   # CompactOS
   $null = (& "$env:windir\system32\compact.exe" /compactos:always)

   # Defragment the boot disk
   $paramSetService = @{
      Name        = 'defragsvc'
      StartupType = 'Automatic'
      Confirm     = $false
      ErrorAction = 'SilentlyContinue'
   }
   $null = (Set-Service @paramSetService)
   $paramStartService = @{
      Name        = 'defragsvc'
      Confirm     = $false
      ErrorAction = 'SilentlyContinue'
   }
   $null = (Start-Service @paramStartService)
   $null = (& "$env:windir\system32\defrag.exe" c: /U /V)
   $null = (Stop-Service -Name defragsvc @paramStopService)
   $paramSetService = @{
      Name        = 'defragsvc'
      StartupType = 'Disabled'
      Confirm     = $false
      ErrorAction = 'SilentlyContinue'
   }
   $null = (Set-Service @paramSetService)

   # Clear all event logs (wevtutil is blazing fast)
   $null = (& "$env:windir\system32\wevtutil.exe" el | ForEach-Object -Process {
      $null = (& "$env:windir\system32\wevtutil.exe" cl $_)
   })

   # Release IP address
   $null = (& "$env:windir\system32\ipconfig.exe" /release)

   # Flush DNS
   $null = (& "$env:windir\system32\ipconfig.exe" /flushdns)

   # Shutdown
   Stop-Computer -Force -Confirm:$false
}
