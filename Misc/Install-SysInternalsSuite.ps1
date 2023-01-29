function Install-SysInternalsSuite
{
   <#
         .SYNOPSIS
         Install or update your SysInternals Suite using PowerShell

         .DESCRIPTION
         Install or update your SysInternals Suite using PowerShell

         .PARAMETER InstallPath
         Target (where to install)

         .EXAMPLE
         Install-SysInternalsSuite -InstallPath "$env:ProgramW6432\SysInterals Suite"

         Install or update your SysInternals Suite using PowerShell

         .EXAMPLE
         Install-SysInternalsSuite -InstallPath "${env:ProgramFiles(x86)}\SysInterals Suite"

         Install or update your SysInternals Suite using PowerShell

         .NOTES
         Original Author: Harm Veenstra (@HarmVeenstra)

         .LINK
         https://powershellisfun.com/2023/01/27/install-or-update-your-sysinternals-suite-using-powershell/
   #>
   [CmdletBinding(ConfirmImpact = 'Low',
   SupportsShouldProcess)]
   [OutputType([string])]
   param
   (
      [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
      [ValidateNotNullOrEmpty()]
      [Alias('Path')]
      [string]
      $InstallPath = ('{0}\SysInterals Suite' -f $env:ProgramW6432)
   )

   begin
   {
      $DownloadDirectory = ('{0}\SysInternalsSuite' -f $env:temp)
      $DownloadFile = ('{0}\SysInternalsSuite.zip' -f $env:temp)
   }

   process
   {
      if ($pscmdlet.ShouldProcess($InstallPath, 'Install or update your SysInternals Suite'))
      {
         # Create the installation folder if not already present
         if (-not (Test-Path -Path $InstallPath -ErrorAction Stop))
         {
            try
            {
               $paramNewItem = @{
                  ItemType    = 'Directory'
                  Path        = $InstallPath
                  Force       = $true
                  Confirm     = $false
                  ErrorAction = 'Stop'
               }
               $null = (New-Item @paramNewItem)
            }
            catch
            {
               # Get error record
               [Management.Automation.ErrorRecord]$e = $_

               # Retrieve information about runtime error
               $info = [PSCustomObject]@{
                  Exception = $e.Exception.Message
                  Reason    = $e.CategoryInfo.Reason
                  Target    = $e.CategoryInfo.TargetName
                  Script    = $e.InvocationInfo.ScriptName
                  Line      = $e.InvocationInfo.ScriptLineNumber
                  Column    = $e.InvocationInfo.OffsetInLine
               }

               # Output information
               $info | Out-String | Write-Verbose
               $_ | Write-Error -ErrorAction Stop
               exit 1
            }
         }

         # Check if the previous download folder is present. Remove it first if it is
         if (Test-Path -Path $DownloadDirectory -ErrorAction SilentlyContinue)
         {
            try
            {
               $paramRemoveItem = @{
                  Path        = $DownloadDirectory
                  Force       = $true
                  Confirm     = $false
                  Recurse     = $true
                  ErrorAction = 'Stop'
               }
               $null = (Remove-Item @paramRemoveItem)
            }
            catch
            {
               # Get error record
               [Management.Automation.ErrorRecord]$e = $_

               # Retrieve information about runtime error
               $info = [PSCustomObject]@{
                  Exception = $e.Exception.Message
                  Reason    = $e.CategoryInfo.Reason
                  Target    = $e.CategoryInfo.TargetName
                  Script    = $e.InvocationInfo.ScriptName
                  Line      = $e.InvocationInfo.ScriptLineNumber
                  Column    = $e.InvocationInfo.OffsetInLine
               }

               # Output information
               $info | Out-String | Write-Verbose
               $_ | Write-Error -ErrorAction Stop
               exit 1
            }
         }

         # Download and extract the latest version
         try
         {
            $ProgressPreference = 'SilentlyContinue'
            $DownloadURI = 'https://download.sysinternals.com/files/SysinternalsSuite.zip'
            $paramInvokeWebRequest = @{
               Uri         = $DownloadURI
               OutFile     = $DownloadFile
               ErrorAction = 'Stop'
            }
            $null = (Invoke-WebRequest @paramInvokeWebRequest)
            $paramExpandArchive = @{
               LiteralPath     = $DownloadFile
               DestinationPath = $DownloadDirectory
               Force           = $true
               ErrorAction     = 'Stop'
            }
            $null = (Expand-Archive @paramExpandArchive)
         }
         catch
         {
            # Get error record
            [Management.Automation.ErrorRecord]$e = $_

            # Retrieve information about runtime error
            $info = [PSCustomObject]@{
               Exception = $e.Exception.Message
               Reason    = $e.CategoryInfo.Reason
               Target    = $e.CategoryInfo.TargetName
               Script    = $e.InvocationInfo.ScriptName
               Line      = $e.InvocationInfo.ScriptLineNumber
               Column    = $e.InvocationInfo.OffsetInLine
            }

            # Output information
            $info | Out-String | Write-Verbose
            $_ | Write-Error -ErrorAction Stop
            exit 1
         }

         foreach ($file in (Get-ChildItem -Path $DownloadDirectory))
         {
            if ((Test-Path -Path ('{0}\{1}' -f ($InstallPath), $file.Name) -ErrorAction SilentlyContinue) -and (Test-Path -Path ('{0}\SysInternalsSuite\{1}' -f ($env:temp), $file.name) -ErrorAction SilentlyContinue))
            {
               if ((((Get-Item -Path ('{0}\{1}' -f ($InstallPath), $file.Name)).VersionInfo).ProductVersion) -lt (((Get-Item -Path ('{0}\SysInternalsSuite\{1}' -f ($env:temp), $file.name)).VersionInfo).ProductVersion))
               {
                  try
                  {
                     $paramCopyItem = @{
                        LiteralPath = ('{0}\SysInternalsSuite\{1}' -f ($env:temp), $file.name)
                        Destination = ('{0}\{1}' -f ($InstallPath), $file.Name)
                        Force       = $true
                        Confirm     = $false
                        ErrorAction = 'Stop'
                     }
                     $null = (Copy-Item @paramCopyItem)
                  }
                  catch
                  {
                     Write-Warning -Message ('Error overwriting {0}, please check permissions or perhaps the file is in use?' -f $file.name)
                  }
               }
            }
            else
            {
               try
               {
                  $paramCopyItem = @{
                     LiteralPath = ('{0}\SysInternalsSuite\{1}' -f ($env:temp), $file.name)
                     Destination = ('{0}\{1}' -f ($InstallPath), $file.Name)
                     Force       = $true
                     Confirm     = $false
                     ErrorAction = 'Stop'
                  }
                  $null = (Copy-Item @paramCopyItem)
               }
               catch
               {
                  Write-Warning -Message ('Error copying {0}, please check permissions' -f $file.name)
               }
            }
         }

         # Add installation folder to Path for easy access if not already present
         $RegistryPath = 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment'
         if (((Get-ItemProperty -Path $RegistryPath -Name PATH).Path) -split ';' -notcontains $InstallPath)
         {
            $paramSetItemProperty = @{
               Path        = $RegistryPath
               Name        = 'PATH'
               Value       = (((Get-ItemProperty -Path $RegistryPath -Name PATH -ErrorAction SilentlyContinue).Path) + (';{0}' -f ($InstallPath)))
               Force       = $true
               Confirm     = $false
               ErrorAction = 'Continue'
            }
            $null = (Set-ItemProperty @paramSetItemProperty)
         }

         # Cleanup files
         if (Test-Path -Path $DownloadDirectory -ErrorAction SilentlyContinue)
         {
            $paramRemoveItem = @{
               Path        = $DownloadDirectory
               Force       = $true
               Confirm     = $false
               Recurse     = $true
               ErrorAction = 'SilentlyContinue'
            }
            $null = (Remove-Item @paramRemoveItem)
         }

         if (Test-Path -Path $DownloadFile -ErrorAction SilentlyContinue)
         {
            $paramRemoveItem = @{
               Path        = $DownloadFile
               Force       = $true
               Confirm     = $false
               ErrorAction = 'SilentlyContinue'
            }
            $null = (Remove-Item @paramRemoveItem)
         }
      }
   }

   end
   {
      #region GarbageCollection
      [GC]::Collect()
      [GC]::WaitForPendingFinalizers()
      #endregion GarbageCollection
   }
}
