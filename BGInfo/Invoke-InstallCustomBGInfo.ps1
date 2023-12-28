#requires -Version 5.0 -Modules BitsTransfer

<#
      .SYNOPSIS
      Download an install the latest BGInfo

      .DESCRIPTION
      Download an install the latest BGInfo on an internal server

      .EXAMPLE
      PS C:\> .\Invoke-InstallCustomBGInfo.ps1
      Download an install the latest BGInfo on an internal server

      .NOTES
      Basic idea was found here: https://wmatthyssen.com/2019/09/09/powershell-bginfo-automation-script-for-windows-server-2016-2019/
      Another good implementation: https://github.com/FlorianSLZ/scloud/tree/main/BGInfo

      We refactored the code from the implementations above and changed the BGInfo binary to X64,
      Most of this code was taken and refactored from the script of Florian Salzmann (@FlorianSLZ)
#>
[CmdletBinding(ConfirmImpact = 'Low')]
param ()

begin
{
   #region Variables
   $bgInfoFolder = ('{0}\BgInfo' -f $env:programfiles)
   $bgInfoFolderContent = ('{0}\*' -f $bgInfoFolder)
   $itemType = 'Directory'
   $bgInfoUrl = 'https://download.sysinternals.com/files/BGInfo.zip'
   $logonBgiUrl = 'https://github.com/jhochwald/PowerShell-collection/raw/main/BGInfo/enserver.bgi' # We use a intranet only link here instead!
   $bgInfoZip = ('{0}\BgInfo.zip' -f $bgInfoFolder)
   $bgInfoEula = ('{0}\Eula.txt' -f $bgInfoFolder)
   $logonBgiFile = ('{0}\logon.bgi' -f $bgInfoFolder)
   $bgInfoRegPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run'
   $bgInfoRegkey = 'BgInfo'
   $bgInfoRegType = 'String'
   $bgInfoRegkeyValue = """$bgInfoFolder\Bginfo64.exe"" ""$bgInfoFolder\logon.bgi"" /timer:0 /nolicprompt"
   #endregion Variables
}

process
{
   #region DirectoryCheck
   # Create BgInfo folder on C: if it not exists, else delete it's content
   if (!(Test-Path -Path $bgInfoFolder))
   {
      $paramNewItem = @{
         ItemType = $itemType
         Force    = $true
         Confirm  = $false
         Path     = $bgInfoFolder
      }
      $null = (New-Item @paramNewItem)
   }
   else
   {
      $paramRemoveItem = @{
         Path        = $bgInfoFolderContent
         Force       = $true
         Confirm     = $false
         Recurse     = $true
         ErrorAction = 'SilentlyContinue'
      }
      $null = (Remove-Item @paramRemoveItem)
   }
   #endregion DirectoryCheck
   
   #region DownloadBgInfo
   $paramStartBitsTransfer = @{
      Source      = $bgInfoUrl
      Destination = $bgInfoZip
      ErrorAction = 'Stop'
   }
   $null = (Start-BitsTransfer @paramStartBitsTransfer)
   
   # Check if the download worked
   if (!(Test-Path -Path $bgInfoZip -ErrorAction SilentlyContinue))
   {
      $paramWriteError = @{
         Exception    = 'BgInfo not found'
         Message      = 'The latest BgInfo was NOT found!'
         Category     = 'ObjectNotFound'
         TargetObject = $bgInfoZip
         ErrorAction  = 'Stop'
      }
      Write-Error @paramWriteError
   }
   #endregion DownloadBgInfo
   
   #region ExtractBgInfo
   try
   {
      $paramExpandArchive = @{
         Path            = $bgInfoZip
         DestinationPath = $bgInfoFolder
         Force           = $true
         Confirm         = $false
         ErrorAction     = 'Stop'
      }
      $null = (Expand-Archive @paramExpandArchive)
   }
   catch
   {
      # Try a fallback method
      $null = (Add-Type -AssemblyName System.IO.Compression.FileSystem)
      [IO.Compression.ZipFile]::ExtractToDirectory($bgInfoZip, $bgInfoFolder)
   }
   #endregion ExtractBgInfo

   #region DirectoryCleanup
   $paramRemoveItem = @{
      Force       = $true
      Confirm     = $false
      ErrorAction = 'SilentlyContinue'
   }
   $null = (Remove-Item -Path $bgInfoZip @paramRemoveItem)
   $null = (Remove-Item -Path $bgInfoEula @paramRemoveItem)
   #endregion DirectoryCleanup

   #region DownloadCustomBGInfoFile
   $paramInvokeWebRequest = @{
      Uri              = $logonBgiUrl
      OutFile          = $logonBgiFile
      DisableKeepAlive = $true
      ErrorAction      = 'Stop'
   }
   $null = (Invoke-WebRequest @paramInvokeWebRequest)
   
   # Check if the download worked
   if (!(Test-Path -Path $logonBgiFile -ErrorAction SilentlyContinue))
   {
      $paramWriteError = @{
         Exception    = 'Custom bgi file not found'
         Message      = 'The Custom bgi file was NOT found!'
         Category     = 'ObjectNotFound'
         TargetObject = $logonBgiFile
         ErrorAction  = 'Stop'
      }
      Write-Error @paramWriteError
   }
   #endregion DownloadCustomBGInfoFile
   
   #region BGInfoCheck
   if (!(Test-Path -Path ('{0}\Bginfo64.exe' -f $bgInfoFolder) -ErrorAction SilentlyContinue))
   {
      # We should NEVER reach this point!
      $paramWriteError = @{
         Exception    = 'BGInfo was not found'
         Message      = 'BGInfo was NOT found!'
         Category     = 'ObjectNotFound'
         TargetObject = ('{0}\Bginfo64.exe' -f $bgInfoFolder)
         ErrorAction  = 'Stop'
      }
      Write-Error @paramWriteError
   }
   #endregion BGInfoCheck
   
   #region AutoStartEntry
   $paramGetItemProperty = @{
      Path        = $bgInfoRegPath
      Name        = $bgInfoRegkey
      ErrorAction = 'SilentlyContinue'
   }
   if (Get-ItemProperty @paramGetItemProperty)
   {
      # Cleanup
      $paramRemoveItemProperty = @{
         Path        = $bgInfoRegPath
         Name        = $bgInfoRegkey
         Force       = $true
         Confirm     = $false
         ErrorAction = 'SilentlyContinue'
      }
      $null = (Remove-ItemProperty @paramRemoveItemProperty)
   }
   
   # Create BgInfo Registry Key to AutoStart
   $paramNewItemProperty = @{
      Path         = $bgInfoRegPath
      Name         = $bgInfoRegkey
      Value        = $bgInfoRegkeyValue
      PropertyType = $bgInfoRegType
      Force        = $true
      Confirm      = $false
      ErrorAction  = 'SilentlyContinue'
   }
   $null = (New-ItemProperty @paramNewItemProperty)
   #endregion AutoStartEntry
}

end
{
   #region RunBGInfoInitial
   $paramStartProcess = @{
      FilePath     = ('{0}\Bginfo64.exe' -f $bgInfoFolder)
      ArgumentList = """$bgInfoFolder\logon.bgi"" /timer:0 /nolicprompt"
   }
   $null = (Start-Process @paramStartProcess)
   #endregion RunBGInfoInitial
}