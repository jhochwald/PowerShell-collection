#requires -Version 3.0 -Modules BitsTransfer
<#
      .SYNOPSIS
      Download and install latest version of Microsoft Teams

      .DESCRIPTION
      Force the download and installion latest version of Microsoft Teams for the used OS architecture

      .NOTES
      Early testing release - Future releases might get some parameters

      Changelog:
      1.0.3: Removed the Firewall Rule creation (Now part of Invoke-TweakTeamsClientFirewall.ps1)
      1.0.2: Removed the WMI call to find OS architecture - Replaced with native .Net type System.IntPtr
      1.0.1: Use BitsTransfer instad of Invoke-WebRequest
      1.0.0: Initial Release

      Version 1.0.3

      .LINK
      http://beyond-datacenter.com
#>
[CmdletBinding(ConfirmImpact = 'Low',
SupportsShouldProcess)]
param ()

begin
{
   Write-Output -InputObject 'Download and install latest version of Microsoft Teams'

   # Default URL (Assume we use 64Bit)
   [string]$Teams64BitUrl = 'https://teams.microsoft.com/downloads/DesktopUrl?env=production&plat=windows&arch=x64'

   #region PossibleParameters
   # Where to Store it
   [string]$Target = ($env:Temp)

   # Regex to make sure we have the correct redirect and this contains a valid URL
   [regex]$HttpRegEx = '^((http[s]?|ftp):\/)?\/?([^:\/\s]+)((\/\w+)*\/)([\w\-\.]+[^#?\s]+)(.*)?(#[\w\-]+)?$'

   # Install Switch
   [string]$Arguments = '--silent'
   #endregion PossibleParameters

   #region Defaults
   $SCT = 'SilentlyContinue'
   $STP = 'Stop'
   #endregion Defaults
}

process
{
   # Processor architecture will set the installer (64Bit is the default)
   switch ([IntPtr]::Size)
   {
      4
      {
         Write-Warning -Message 'You have a 32-bit processor - This is no longer supported by enabling Technology!' -WarningAction Continue

         $Url = 'https://teams.microsoft.com/downloads/DesktopUrl?env=production&plat=windows&arch=x86'
      }
      Default
      {
         Write-Verbose -Message 'Use the default: 64-bit processor'

         $Url = $Teams64BitUrl
      }
   }

   # Use a basic webrequest to get the real download URL
   $paramInvokeWebRequest = @{
      Uri             = $Url
      ErrorAction     = $STP
      UseBasicParsing = $true
   }
   $RequestContent = ((Invoke-WebRequest @paramInvokeWebRequest) | Select-Object -ExpandProperty Content)

   # use the Regex to make sure we have the correct redirect and this contains a valid URL
   if ($RequestContent -match $HttpRegEx)
   {
      # Get the full path of the downloaded installer
      $paramSplitPath = @{
         Path = $RequestContent
         Leaf = $true
      }
      $Installer = ($Target + '\' + (Split-Path @paramSplitPath))

      Write-Verbose -Message ('Downloading {0} to {1}' -f $RequestContent, $Installer)

      # Use BitsTransfer to download the latest installer
      $paramStartBitsTransfer = @{
         Source         = $RequestContent
         Destination    = $Installer
         Priority       = 'High'
         TransferPolicy = 'Always'
         ErrorAction    = $STP
      }
      $null = (Start-BitsTransfer @paramStartBitsTransfer)
   }
   else
   {
      Write-Verbose -Message ('Content returned was: {0}' -f $RequestContent)

      Write-Error -Message 'Content returned from the Teams download site is not a valid URL.' -ErrorAction $STP

      # We are done
      break
   }

   # Install the Microsoft Teams client
   $paramTestPath = @{
      Path        = $Installer
      ErrorAction = $SCT
   }
   if (Test-Path @paramTestPath)
   {
      $paramGetItemProperty = @{
         Path        = $Installer
         ErrorAction = $SCT
      }
      $InstallerVersion = ((Get-ItemProperty @paramGetItemProperty).VersionInfo.ProductVersion)

      Write-Verbose -Message ('Running installer Microsoft Teams version  {0}' -f $InstallerVersion)

      $paramStartProcess = @{
         FilePath     = $Installer
         ArgumentList = $Arguments
         Wait         = $true
         PassThru     = $true
         ErrorAction  = $STP
      }
      $InstallerProcess = (Start-Process @paramStartProcess)

      if (($InstallerProcess | Select-Object -ExpandProperty ExitCode) -eq 0)
      {
         Write-Verbose -Message ('Installed Microsoft Teams version  {0}' -f $InstallerVersion)
      }
      else
      {
         Write-Warning -Message ('Installer exit code  {0}.' -f $InstallerProcess.ExitCode)
      }

      Write-Verbose -Message ('Removing file: {0}' -f $Installer)

      $null = (Remove-Item -Path $Installer -Confirm:$false -Force -ErrorAction $SCT)
   }
   else
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
      $info | Out-String | Write-Verbose

      $paramWriteError = @{
         Message      = $e.Exception.Message
         ErrorAction  = $STP
         Exception    = $e.Exception
         TargetObject = $e.CategoryInfo.TargetName
      }
      Write-Error @paramWriteError

      # We are done
      break
   }
}
