#requires -Version 2.0 -Modules Appx -RunAsAdministrator

<#
      .SYNOPSIS
      Install the New Teams Client on Windows 365 VM

      .DESCRIPTION
      Install the New Teams Client on Windows 365 VM

      .EXAMPLE
      PS C:\> .\Invoke-InstallNewTeamsClientOnWindows365.ps1

      Install the New Teams Client on Windows 365 VM

      .LINK
      https://learn.microsoft.com/en-us/microsoftteams/new-teams-vdi-requirements-deploy#windows-365

      .NOTES
      It should work on Azure Virtual Desktop (AVD) host as well, but I haven't tested it yet
      You must run this elevated, because we need to install new software on the Windows 365 VM

      Not supported by Microsoft (MSFT)
#>
[CmdletBinding(ConfirmImpact = 'Low')]
[OutputType([string])]
param ()

process
{
   # Set IsWVDEnvironment
   $RegPath = 'HKLM:\SOFTWARE\Microsoft\Teams'

   # Check if the registry path exists
   $paramTestPath = @{
      LiteralPath = $RegPath
      ErrorAction = 'SilentlyContinue'
   }
   if ((Test-Path @paramTestPath) -ne $true)
   {
      $paramNewItem = @{
         Path          = $RegPath
         Force         = $true
         Confirm       = $false
         ErrorAction   = 'SilentlyContinue'
         WarningAction = 'SilentlyContinue'
      }
      $null = (New-Item @paramNewItem)
   }

   # Set IsWVDEnvironment to 1 in HKLM:\SOFTWARE\Microsoft\Teams
   $paramNewItemProperty = @{
      LiteralPath   = $RegPath
      Name          = 'IsWVDEnvironment'
      Value         = 1
      PropertyType  = 'DWord'
      Force         = $true
      Confirm       = $false
      ErrorAction   = 'SilentlyContinue'
      WarningAction = 'SilentlyContinue'
   }
   $null = (New-ItemProperty @paramNewItemProperty)

   # Allow side-loading for trusted apps
   $RegPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Appx'

   # Check if the registry path exists
   $paramTestPath = @{
      LiteralPath   = $RegPath
      ErrorAction   = 'SilentlyContinue'
      WarningAction = 'SilentlyContinue'
   }
   if ((Test-Path @paramTestPath) -ne $true)
   {
      $paramNewItem = @{
         Path          = $RegPath
         Force         = $true
         Confirm       = $false
         ErrorAction   = 'SilentlyContinue'
         WarningAction = 'SilentlyContinue'
      }
      $null = (New-Item @paramNewItem)
   }

   <#
         This is an optional step, but I recommended to set it anyway
   #>
   # Set AllowDeploymentInSpecialProfiles to 1 in HKLM:\SOFTWARE\Policies\Microsoft\Windows\Appx
   $paramNewItemProperty = @{
      LiteralPath   = $RegPath
      Name          = 'AllowDeploymentInSpecialProfiles'
      Value         = 1
      PropertyType  = 'DWord'
      Force         = $true
      Confirm       = $false
      ErrorAction   = 'SilentlyContinue'
      WarningAction = 'SilentlyContinue'
   }
   $null = (New-ItemProperty @paramNewItemProperty)

   # Set AllowAllTrustedApps to 1 in HKLM:\SOFTWARE\Policies\Microsoft\Windows\Appx
   $paramNewItemProperty = @{
      LiteralPath   = $RegPath
      Name          = 'AllowAllTrustedApps'
      Value         = 1
      PropertyType  = 'DWord'
      Force         = $true
      Confirm       = $false
      ErrorAction   = 'SilentlyContinue'
      WarningAction = 'SilentlyContinue'
   }
   $null = (New-ItemProperty @paramNewItemProperty)

   # Set AllowDevelopmentWithoutDevLicense to 1 in HKLM:\SOFTWARE\Policies\Microsoft\Windows\Appx
   $paramNewItemProperty = @{
      LiteralPath   = $RegPath
      Name          = 'AllowDevelopmentWithoutDevLicense'
      Value         = 1
      PropertyType  = 'DWord'
      Force         = $true
      Confirm       = $false
      ErrorAction   = 'SilentlyContinue'
      WarningAction = 'SilentlyContinue'
   }
   $null = (New-ItemProperty @paramNewItemProperty)

   # Check if WebView2 is installed
   $WebView2 = $null
   $paramGetAppxPackage = @{
      AllUsers      = $true
      ErrorAction   = 'SilentlyContinue'
      WarningAction = 'SilentlyContinue'
   }
   $WebView2 = (Get-AppxPackage @paramGetAppxPackage | Where-Object {
         $_.Name -eq 'Microsoft.Win32WebViewHost'
   })

   if (!($WebView2))
   {
      <#
            Should be installed on an Windows 365 VM
            Something that might not be installed on a plain Azure Virtual Desktop (AVD) host
            https://learn.microsoft.com/en-us/microsoft-edge/webview2/concepts/distribution
      #>
      $WebView2InstallerPath = ('{0}\WebView2.exe' -f $env:temp)

      # Clean-up
      $paramRemoveItem = @{
         Path          = $WebView2InstallerPath
         ErrorAction   = 'SilentlyContinue'
         WarningAction = 'SilentlyContinue'
      }
      $null = (Remove-Item @paramRemoveItem)

      # Download the latest WebView2 installer / System.Net.WebClient is fast, so...
      $paramNewObject = @{
         TypeName      = 'System.Net.WebClient'
         ErrorAction   = 'Stop'
         WarningAction = 'SilentlyContinue'
      }
      $null = (New-Object @paramNewObject).DownloadFile('https://go.microsoft.com/fwlink/p/?LinkId=2124703', $WebView2InstallerPath)

      # Now start the downloaded installer in silent mode
      # https://silentinstallhq.com/microsoft-edge-webview2-runtime-silent-install-how-to-guide/
      $paramStartProcess = @{
         FilePath      = $WebView2InstallerPath
         Wait          = $true
         ArgumentList  = '/silent /install'
         PassThru      = $true
         ErrorAction   = 'SilentlyContinue'
         WarningAction = 'SilentlyContinue'
      }
      $WebView2Installer = (Start-Process @paramStartProcess)

      # Clean-up
      $null = (Remove-Item @paramRemoveItem)

      # Just for debugging purposes
      Write-Verbose -Message ('WebView2 installer ExitCode was: {0}' -f $WebView2Installer.ExitCode)
   }

   # Check if the new Microsoft Teams Client is installed
   $MSTeamsInstalled = $null
   $paramGetAppxPackage = @{
      AllUsers      = $true
      ErrorAction   = 'SilentlyContinue'
      WarningAction = 'SilentlyContinue'
   }
   $MSTeamsInstalled = (Get-AppxPackage @paramGetAppxPackage | Where-Object {
         $_.Name -eq 'MSTeams'
   })

   # Do we have a Microsoft Teams Client is installed?
   if (!($MSTeamsInstalled))
   {
      # Download and install the Microsoft Teams Client for this host
      $TeamsBootstrapperInstallerPath = ('{0}\TeamsBootstrapper.exe' -f $env:temp)

      # Clean-up
      $paramRemoveItem = @{
         Path          = $TeamsBootstrapperInstallerPath
         ErrorAction   = 'SilentlyContinue'
         WarningAction = 'SilentlyContinue'
      }
      $null = (Remove-Item @paramRemoveItem)

      # Download the latest TeamsBootstrapper installer / System.Net.WebClient is fast, so...
      # https://learn.microsoft.com/en-us/microsoftteams/new-teams-bulk-install-client
      $paramNewObject = @{
         TypeName      = 'System.Net.WebClient'
         ErrorAction   = 'Stop'
         WarningAction = 'SilentlyContinue'
      }
      $null = (New-Object @paramNewObject).DownloadFile('https://go.microsoft.com/fwlink/?linkid=2243204', $TeamsBootstrapperInstallerPath)

      # Now start the downloaded installer in silent mode
      $paramStartProcess = @{
         FilePath      = $TeamsBootstrapperInstallerPath
         Wait          = $true
         ArgumentList  = '-p'
         PassThru      = $true
         ErrorAction   = 'SilentlyContinue'
         WarningAction = 'SilentlyContinue'
      }
      $TeamsBootstrapperInstaller = (Start-Process @paramStartProcess)

      # Clean-up
      $null = (Remove-Item @paramRemoveItem)

      # Just for debugging purposes
      Write-Verbose -Message ('TeamsBootstrapper installer ExitCode was: {0}' -f $TeamsBootstrapperInstaller.ExitCode)
   }
}