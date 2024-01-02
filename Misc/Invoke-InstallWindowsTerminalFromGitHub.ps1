#requires -Version 3.0 -Modules Appx, BitsTransfer, CimCmdlets -RunAsAdministrator

<#
      .SYNOPSIS
      Install Microsoft Windows Terminal from GitHub

      .DESCRIPTION
      Install the latest Microsoft Windows Terminal directly from GitHub

      .EXAMPLE
      PS C:\> .\Invoke-InstallWindowsTerminalFromGitHub.ps1

      Install the latest Microsoft Windows Terminal directly from GitHub

      .EXAMPLE
      PS C:\> .\Invoke-InstallWindowsTerminalFromGitHub.ps1 -Verbose

      Install the latest Microsoft Windows Terminal directly from GitHub (with verbose output)

      .NOTES
      If WinGet is not installed, e.g., on a server, whis can be handy
      Even when I can not recommend to add to much addidional software on a Server,
      because that can increase the attack surface and should therefore be avoided.

      It will install the latest Version directly from GitHub,
      only if there is no other verion installed.

      It will not update an existing installation!!! Might come in a later version.
      Admin access is required, therefore it must be calles within an elevated shell!
#>
[CmdletBinding(ConfirmImpact = 'Low')]
[OutputType([string])]
param ()

begin
{
   $paramGetCimInstance = @{
      ClassName   = 'Win32_ComputerSystem'
      ErrorAction = 'SilentlyContinue'
   }
   switch ((Get-CimInstance @paramGetCimInstance ).SystemType)
   {
      'x64-based PC'
      {
         [string]$Arch = 'x64'
      }
      'ARM64-based PC'
      {
         [string]$Arch = 'arm64'
      }
      'x86-based PC'
      {
         [string]$Arch = 'x86'
      }
      default
      {
         $paramWriteError = @{
            Exception         = 'Unknown Architecture'
            Message           = 'Unable to figure out what architecture this computer has'
            Category          = 'InvalidResult'
            RecommendedAction = 'Check with ''Get-CimInstance -ClassName Win32_ComputerSystem'''
            ErrorAction       = 'Stop'
         }
         Write-Error @paramWriteError
         exit 1
      }
   }
}

process
{
   #region
   $paramGetAppxPackage = @{
      AllUsers    = $true
      ErrorAction = 'SilentlyContinue'
   }
   if (!(Get-AppxPackage @paramGetAppxPackage | Where-Object {
            (($_.Name -like '*VCLibs*desktop*') -and ($_.Architecture -eq $Arch))
   }))
   {
      [string]$AppXUri = ('https://aka.ms/Microsoft.VCLibs.{0}.14.00.Desktop.appx' -f $Arch)
      [string]$AppXName = ('{0}\Microsoft.VCLibs.{1}.14.00.Desktop.appx' -f $env:TEMP, $Arch)
      
      if (Test-Path -Path $AppXName -ErrorAction SilentlyContinue)
      {
         $paramRemoveItem = @{
            Path        = $AppXName
            Force       = $true
            Confirm     = $false
            ErrorAction = 'SilentlyContinue'
         }
         $null = (Remove-Item @paramRemoveItem)
      }
      
      # Download prerequisites
      $paramStartBitsTransfer = @{
         Source      = $AppXUri
         Destination = $AppXName
         Confirm     = $false
         ErrorAction = 'Stop'
      }
      $null = (Start-BitsTransfer @paramStartBitsTransfer)
      
      # Install prerequisites
      $paramAddAppxPackage = @{
         Path        = $AppXName
         Confirm     = $false
         ErrorAction = 'Stop'
      }
      $null = (Add-AppxPackage @paramAddAppxPackage)
      
      $paramTestPath = @{
         Path        = $AppXName
         ErrorAction = 'SilentlyContinue'
      }
      if (Test-Path @paramTestPath)
      {
         $paramRemoveItem = @{
            Path        = $AppXName
            Force       = $true
            Confirm     = $false
            ErrorAction = 'SilentlyContinue'
         }
         $null = (Remove-Item @paramRemoveItem)
      }
   }
   #endregion
   
   #region
   $paramGetAppxPackage = @{
      AllUsers    = $true
      ErrorAction = 'SilentlyContinue'
   }
   if (!(Get-AppxPackage @paramGetAppxPackage | Where-Object {
            (($_.Name -eq 'Microsoft.WindowsTerminal') -and ($_.Architecture -eq $Arch))
   }))
   {
      # GitHub url where we can find the latest release of Windows Terminal
      [string]$GitHubUrl = 'https://api.github.com/repos/microsoft/terminal/releases/latest'
      
      # The headers and API version for the GitHub API
      [hashtable]$GithubHeaders = @{
         'Accept'             = 'application/vnd.github.v3+json'
         'X-GitHub-Api-Version' = '2022-11-28'
      }
      # Collecting information from GitHub regarding latest version of Windows Terminal
      try
      {
         $paramInvokeRestMethod = @{
            Uri         = $GitHubUrl
            Method      = 'Get'
            Headers     = $GithubHeaders
            TimeoutSec  = 10
            ErrorAction = 'Stop'
         }
         [Object]$GithubInfoRestData = (Invoke-RestMethod @paramInvokeRestMethod | Select-Object -Property assets, tag_name)
         [string]$latestVersion = $GithubInfoRestData.tag_name.Substring(1)
         # The next object looks a bit crappy, but this is fine! We store some infos in there...
         [Object]$GitHubInfo = [PSCustomObject]@{
            Tag         = $latestVersion
            DownloadUrl = (($GithubInfoRestData.assets | Where-Object -FilterScript {
                     ($_.name -like '*.msixbundle')
            }).browser_download_url)
            OutFile     = ('{0}\{1}' -f $env:TEMP, (($GithubInfoRestData.assets | Where-Object -FilterScript {
                        ($_.name -like '*.msixbundle')
            }).name))
         }
      }
      catch
      {
         # get error record
         [Management.Automation.ErrorRecord]$e = $_
         
         # retrieve information about runtime error
         $info = [PSCustomObject]@{
            Exception = $e.Exception.Message
            Reason    = $e.CategoryInfo.Reason
            Target    = $e.CategoryInfo.TargetName
            Script    = $e.InvocationInfo.ScriptName
            Line      = $e.InvocationInfo.ScriptLineNumber
            Column    = $e.InvocationInfo.OffsetInLine
         }
         
         # output information. Post-process collected info, and log info (optional)
         $info | Write-Error -ErrorAction Stop
         exit 1
      }
      
      if ($GitHubInfo)
      {
         $paramTestPath = @{
            Path        = $GitHubInfo.OutFile
            ErrorAction = 'SilentlyContinue'
         }
         if (Test-Path @paramTestPath)
         {
            $paramRemoveItem = @{
               Path        = $GitHubInfo.OutFile
               Force       = $true
               Confirm     = $false
               ErrorAction = 'SilentlyContinue'
            }
            $null = (Remove-Item @paramRemoveItem)
         }
         
         # Download Windows Terminal
         $paramStartBitsTransfer = @{
            Source      = $GitHubInfo.DownloadUrl
            Destination = $GitHubInfo.OutFile
            Confirm     = $false
            ErrorAction = 'Stop'
         }
         $null = (Start-BitsTransfer @paramStartBitsTransfer)
      }
      
      $paramAddAppxPackage = @{
         Path        = $GitHubInfo.OutFile
         Confirm     = $false
         ErrorAction = 'Stop'
      }
      $null = (Add-AppxPackage @paramAddAppxPackage)
      
      $paramTestPath = @{
         Path        = $GitHubInfo.OutFile
         ErrorAction = 'SilentlyContinue'
      }
      if (Test-Path @paramTestPath)
      {
         $paramRemoveItem = @{
            Path        = $GitHubInfo.OutFile
            Force       = $true
            Confirm     = $false
            ErrorAction = 'SilentlyContinue'
         }
         $null = (Remove-Item @paramRemoveItem)
      }
   }
   #endregion
}