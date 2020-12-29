#requires -Version 3.0 -Modules BitsTransfer -RunAsAdministrator
<#
      .SYNOPSIS
      Download, install, and Tweak System and Apps for Terminal Server use

      .DESCRIPTION
      Download, install, and Tweak System and Apps for Terminal Server (WVD/VDI/WDS) use

      .NOTES
      Early testing release - Future releases might get some parameters

      Changelog:
      1.0.0: Initial Release

      Version 1.0.0

      .LINK
      http://beyond-datacenter.com
#>
[CmdletBinding(ConfirmImpact = 'Low',
   SupportsShouldProcess)]
param ()

begin
{
   Write-Output -InputObject 'Download, install, and Tweak System and Apps for Terminal Server use'

   # Default URL (Assume we use 64Bit)
   [string]$FSLogixUrl = 'https://aka.ms/fslogix_download'

   #region PossibleParameters
   # Where to Store it
   [string]$Target = ($env:Temp)

   # File Name
   [string]$TargetName = 'fslogix.zip'

   # Install Switch
   [string]$Arguments = '/install /quiet /norestart'
   #endregion PossibleParameters

   #region Defaults
   # Set the full path of the downloaded installer
   [string]$InstallerPackage = ($Target + '\' + $TargetName)

   [string]$InstallerDestination = (($InstallerPackage).Replace('.zip', ''))
   [string]$InstallerExecutable = ($InstallerDestination + '\x64\Release\FSLogixAppsSetup.exe')
   $SCT = 'SilentlyContinue'
   $STP = 'Stop'
   #endregion Defaults
}

process
{
   Write-Verbose -Message ('Downloading {0} to {1}' -f $TargetName, $InstallerPackage)

   # Use BitsTransfer to download the latest installer
   $paramStartBitsTransfer = @{
      Source         = $FSLogixUrl
      Destination    = $InstallerPackage
      Priority       = 'High'
      TransferPolicy = 'Always'
      ErrorAction    = $STP
   }
   $null = (Start-BitsTransfer @paramStartBitsTransfer)

   # Expand FSLogix Installer
   $paramTestPath = @{
      Path        = $InstallerPackage
      ErrorAction = $SCT
   }
   if (Test-Path @paramTestPath)
   {
      $paramTestPath = @{
         Path        = $InstallerDestination
         ErrorAction = $SCT
      }
      if (-not (Test-Path @paramTestPath))
      {
         $paramNewItem = @{
            Path        = $InstallerDestination
            Force       = $true
            Confirm     = $false
            ItemType    = 'Directory'
            ErrorAction = $SCT
         }
         $null = (New-Item @paramNewItem)
      }

      try
      {
         # Expand-Archive is to buggy!
         $null = (Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction $STP)
         $null = ([IO.Compression.ZipFile]::ExtractToDirectory($InstallerPackage, $InstallerDestination))
      }
      catch
      {
         # OK! That is crappy, but it still works well as a fallback.
         $shellApp = (New-Object -ComObject Shell.Application -ErrorAction $STP)
         $shellZip = $shellApp.NameSpace([String]$InstallerPackage)
         $shellDest = $shellApp.NameSpace($InstallerDestination)
         $shellDest.CopyHere($shellZip.items())
      }
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

   # Install FSLogix
   $paramTestPath = @{
      Path        = $InstallerExecutable
      ErrorAction = $SCT
   }
   if (Test-Path @paramTestPath)
   {
      $paramGetItemProperty = @{
         Path        = $InstallerExecutable
         ErrorAction = $SCT
      }
      $InstallerVersion = ((Get-ItemProperty @paramGetItemProperty).VersionInfo.ProductVersion)

      Write-Verbose -Message ('Running FSLogix installer version  {0}' -f $InstallerVersion)

      $paramStartProcess = @{
         FilePath     = $InstallerExecutable
         ArgumentList = $Arguments
         Wait         = $true
         PassThru     = $true
         ErrorAction  = $STP
      }
      $InstallerProcess = (Start-Process @paramStartProcess)

      if (($InstallerProcess | Select-Object -ExpandProperty ExitCode) -eq 0)
      {
         Write-Verbose -Message ('Installed FSLogix version  {0}' -f $InstallerVersion)
      }
      else
      {
         Write-Warning -Message ('Installer exit code  {0}.' -f $InstallerProcess.ExitCode)
      }

      Write-Verbose -Message ('Removing file: {0}' -f $InstallerPackage)

      # Remove the downloaded Installaer Package
      $paramRemoveItem = @{
         Path        = $InstallerPackage
         Confirm     = $false
         Force       = $true
         ErrorAction = $SCT
      }
      $null = (Remove-Item @paramRemoveItem)

      # Install the expanded stuff
      $paramRemoveItem = @{
         Path        = $InstallerDestination
         Recurse     = $true
         Confirm     = $false
         Force       = $true
         ErrorAction = $SCT
      }
      $null = (Remove-Item @paramRemoveItem)

      # Legacy HKLM Path for WVD/VDI/WDS Environment
      $paramNewItem = @{
         Path        = 'HKLM:\SOFTWARE\Citrix\PortICA'
         Confirm     = $false
         Force       = $true
         ErrorAction = $SCT
      }
      $null = (New-Item @paramNewItem)

      # Ensure that the registry path exists
      $paramNewItem = @{
         Path        = 'HKLM:\SOFTWARE\Microsoft\Teams'
         Confirm     = $false
         Force       = $true
         ErrorAction = $SCT
      }
      $null = (New-Item @paramNewItem)

      # Tell Microsoft Teams that it runs in an WVD/VDI/WDS Environment
      # Source: https://docs.microsoft.com/en-us/azure/virtual-desktop/teams-on-wvd
      $paramNewItemProperty = @{
         Path         = 'HKLM:\SOFTWARE\Microsoft\Teams'
         Name         = 'IsWVDEnvironment'
         PropertyType = 'DWORD'
         Value        = 1
         Confirm      = $false
         Force        = $true
         ErrorAction  = $SCT
      }
      $null = (New-ItemProperty @paramNewItemProperty)

      # Ensure that the registry path exists
      $paramNewItem = @{
         Path        = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run32'
         Confirm     = $false
         Force       = $true
         ErrorAction = $SCT
      }
      $null = (New-Item @paramNewItem)

      # Do not start Microsoft Teams after Login
      $paramNewItemProperty = @{
         Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run32'
         Name         = 'Teams'
         PropertyType = 'Binary'
         Value        = ([byte[]](0x01, 0x00, 0x00, 0x00, 0x1a, 0x19, 0xc3, 0xb9, 0x62, 0x69, 0xd5, 0x01))
         Confirm      = $false
         Force        = $true
         ErrorAction  = $SCT
      }
      $null = (New-ItemProperty @paramNewItemProperty)
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
