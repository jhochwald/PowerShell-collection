#requires -Version 5.0 -RunAsAdministrator

<#
   .SYNOPSIS
   Enable BitLocker with both TPM and recovery password key protectors on Windows 10 devices.

   .DESCRIPTION
   Enable BitLocker with both TPM and recovery password key protectors on Windows 10 devices.

   .PARAMETER EncryptionMethod
   Define the encryption method to be used when enabling BitLocker.

   .PARAMETER OperationalMode
   Set the operational mode of this script.

   .PARAMETER CompanyName
   Set the company name to be used as registry root when running in Backup mode.

   .NOTES
   Version 1.0.1

   Adopted version of Enable-BitLockerEncryption.ps1 from Nickolaj Andersen (@NickolajA)
#>
[CmdletBinding(SupportsShouldProcess)]
param (
   [ValidateNotNullOrEmpty()]
   [ValidateSet('Aes128', 'Aes256', 'XtsAes128', 'XtsAes256')]
   [string]
   $EncryptionMethod = 'XtsAes256',
   [ValidateNotNullOrEmpty()]
   [ValidateSet('Encrypt', 'Backup')]
   [string]
   $OperationalMode = 'Encrypt',
   [ValidateNotNullOrEmpty()]
   [string]
   $CompanyName = 'enabling Technology'
)

begin
{
   Write-Output -InputObject 'Enable BitLocker with both TPM and recovery password key protectors'

   #region
   $STP = 'Stop'
   $SCT = 'SilentlyContinue'
   #endregion

   if (Get-Command -Name 'Set-MpPreference' -ErrorAction $SCT)
   {
      $null = (Set-MpPreference -EnableControlledFolderAccess Disabled -Force -ErrorAction $SCT)
   }

   #region
   function Write-LogEntry
   {
      <#
         .SYNOPSIS
         Describe purpose of "Write-LogEntry" in 1-2 sentences.

         .DESCRIPTION
         Add a more complete description of what the function does.

         .PARAMETER Value
         Describe parameter -Value.

         .PARAMETER Severity
         Describe parameter -Severity.

         .EXAMPLE
         Write-LogEntry -Value Value -Severity Value
         Describe what this call does

         .NOTES
         Place additional notes here.

         .LINK
         URLs to related sites
         The first link is opened by Get-Help -Online Write-LogEntry

         .INPUTS
         List of input types that are accepted by this function.

         .OUTPUTS
         List of output types produced by this function.
      #>
      param (
         [parameter(Mandatory, HelpMessage = 'Value added to the log file.')]
         [ValidateNotNullOrEmpty()]
         [string]
         $Value,
         [parameter(Mandatory, HelpMessage = 'Severity for the log entry. 1 for Informational, 2 for Warning and 3 for Error.')]
         [ValidateNotNullOrEmpty()]
         [ValidateSet('1', '2', '3')]
         [string]
         $Severity
      )
      begin
      {
         $SCT = 'SilentlyContinue'
      }

      process
      {
         # Determine log file location
         $paramJoinPath = @{
            Path        = (Join-Path -Path $env:windir -ChildPath 'Temp' -ErrorAction $SCT)
            ChildPath   = 'Enable-BitLockerEncryption.log'
            ErrorAction = $SCT
         }
         $LogFilePath = (Join-Path @paramJoinPath)

         # Construct time stamp for log entry
         $paramTestPath = @{
            Path        = 'variable:global:TimezoneBias'
            ErrorAction = $SCT
         }
         if (-not (Test-Path @paramTestPath))
         {
            [string]$global:TimezoneBias = [TimeZoneInfo]::Local.GetUtcOffset((Get-Date)).TotalMinutes

            if ($TimezoneBias -match '^-')
            {
               $TimezoneBias = $TimezoneBias.Replace('-', '+')
            }
            else
            {
               $TimezoneBias = '-' + $TimezoneBias
            }
         }

         $Time = -join @((Get-Date -Format 'HH:mm:ss.fff'), $TimezoneBias)

         # Construct date for log entry
         $Date = (Get-Date -Format 'MM-dd-yyyy')

         # Construct context for log entry
         $Context = $([Security.Principal.WindowsIdentity]::GetCurrent().Name)

         # Construct final log entry
         $LogText = "<![LOG[$($Value)]LOG]!><time=""$($Time)"" date=""$($Date)"" component=""BitLockerEncryption"" context=""$($Context)"" type=""$($Severity)"" thread=""$($PID)"" file="""">"

         # Add value to log file
         try
         {
            $paramOutFile = @{
               Append      = $true
               NoClobber   = $true
               Encoding    = 'Default'
               FilePath    = $LogFilePath
               ErrorAction = 'Stop'
            }
            $null = ($LogText | Out-File @paramOutFile)
         }
         catch
         {
            Write-Warning -Message "Unable to append log entry to Enable-BitLockerEncryption.log file. Error message at line $($_.InvocationInfo.ScriptLineNumber): $($_.Exception.Message)"
         }
      }
   }

   function Invoke-Executable
   {
      <#
         .SYNOPSIS
         Describe purpose of "Invoke-Executable" in 1-2 sentences.

         .DESCRIPTION
         Add a more complete description of what the function does.

         .PARAMETER FilePath
         Describe parameter -FilePath.

         .PARAMETER Arguments
         Describe parameter -Arguments.

         .EXAMPLE
         Invoke-Executable -FilePath Value -Arguments Value
         Describe what this call does

         .NOTES
         Place additional notes here.

         .LINK
         URLs to related sites
         The first link is opened by Get-Help -Online Invoke-Executable

         .INPUTS
         List of input types that are accepted by this function.

         .OUTPUTS
         List of output types produced by this function.
      #>
      param (
         [parameter(Mandatory, HelpMessage = 'Specify the file name or path of the executable to be invoked, including the extension')]
         [ValidateNotNullOrEmpty()]
         [string]
         $FilePath,
         [ValidateNotNull()]
         [string]
         $Arguments
      )

      process
      {
         # Construct a hash-table for default parameter splatting
         $SplatArgs = @{
            FilePath               = $FilePath
            NoNewWindow            = $true
            Passthru               = $true
            RedirectStandardOutput = 'null.txt'
            ErrorAction            = 'Stop'
         }

         # Add ArgumentList param if present
         if (-not ([string]::IsNullOrEmpty($Arguments)))
         {
            $SplatArgs.Add('ArgumentList', $Arguments)
         }

         # Invoke executable and wait for process to exit
         try
         {
            $Invocation = (Start-Process @SplatArgs)
            $Handle = $Invocation.Handle
            $Invocation.WaitForExit()

            # Remove redirected output file
            $paramRemoveItem = @{
               Path  = (Join-Path -Path $PSScriptRoot -ChildPath 'null.txt' -ErrorAction Continue)
               Force = $true
            }
            $null = (Remove-Item @paramRemoveItem)
         }
         catch
         {
            Write-Warning -Message $_.Exception.Message
            break
         }

         return $Invocation.ExitCode
      }
   }

   function Test-RegistryValue
   {
      <#
         .SYNOPSIS
         Describe purpose of "Test-RegistryValue" in 1-2 sentences.

         .DESCRIPTION
         Add a more complete description of what the function does.

         .PARAMETER Path
         Describe parameter -Path.

         .PARAMETER Name
         Describe parameter -Name.

         .EXAMPLE
         Test-RegistryValue -Path Value -Name Value
         Describe what this call does

         .NOTES
         Place additional notes here.

         .LINK
         URLs to related sites
         The first link is opened by Get-Help -Online Test-RegistryValue

         .INPUTS
         List of input types that are accepted by this function.

         .OUTPUTS
         List of output types produced by this function.
      #>
      param (
         [parameter(Mandatory, HelpMessage = 'Add help message for user')]
         [ValidateNotNullOrEmpty()]
         [string]
         $Path,
         [ValidateNotNullOrEmpty()]
         [string]
         $Name
      )

      begin
      {
         # If item property value exists return True, else catch the failure and return False
         $STP = 'Stop'
      }

      process
      {
         try
         {
            if ($PSBoundParameters['Name'])
            {
               $paramGetItemProperty = @{
                  Path        = $Path
                  ErrorAction = $STP
               }
               $Existence = (Get-ItemProperty @paramGetItemProperty | Select-Object -ExpandProperty $Name -ErrorAction $STP)
            }
            else
            {
               $paramGetItemProperty = @{
                  Path        = $Path
                  ErrorAction = $STP
               }
               $Existence = (Get-ItemProperty @paramGetItemProperty)
            }

            if ($Existence)
            {
               return $true
            }
         }
         catch
         {
            return $false
         }
      }
   }

   function Set-RegistryValue
   {
      <#
         .SYNOPSIS
         Describe purpose of "Set-RegistryValue" in 1-2 sentences.

         .DESCRIPTION
         Add a more complete description of what the function does.

         .PARAMETER Path
         Describe parameter -Path.

         .PARAMETER Name
         Describe parameter -Name.

         .PARAMETER Value
         Describe parameter -Value.

         .EXAMPLE
         Set-RegistryValue -Path Value -Name Value -Value Value
         Describe what this call does

         .NOTES
         Place additional notes here.

         .LINK
         URLs to related sites
         The first link is opened by Get-Help -Online Set-RegistryValue

         .INPUTS
         List of input types that are accepted by this function.

         .OUTPUTS
         List of output types produced by this function.
      #>
      param (
         [parameter(Mandatory, HelpMessage = 'Add help message for user')]
         [ValidateNotNullOrEmpty()]
         [string]
         $Path,
         [parameter(Mandatory, HelpMessage = 'Add help message for user')]
         [ValidateNotNullOrEmpty()]
         [string]
         $Name,
         [parameter(Mandatory, HelpMessage = 'Add help message for user')]
         [ValidateNotNullOrEmpty()]
         [string]
         $Value
      )
      begin
      {
         $SCT = 'SilentlyContinue'
         $STP = 'Stop'
      }

      process
      {
         try
         {
            $paramGetItemProperty = @{
               Path        = $Path
               Name        = $Name
               ErrorAction = $SCT
            }
            $RegistryValue = (Get-ItemProperty @paramGetItemProperty)

            if ($RegistryValue)
            {
               $paramSetItemProperty = @{
                  Path        = $Path
                  Name        = $Name
                  Value       = $Value
                  Force       = $true
                  ErrorAction = $STP
               }
               $null = (Set-ItemProperty @paramSetItemProperty)
            }
            else
            {
               $paramNewItemProperty = @{
                  Path         = $Path
                  Name         = $Name
                  PropertyType = 'String'
                  Value        = $Value
                  Force        = $true
                  ErrorAction  = $STP
               }
               $null = (New-ItemProperty @paramNewItemProperty)
            }
         }
         catch
         {
            Write-LogEntry -Value "Failed to create or update registry value '$($Name)' in '$($Path)'. Error message: $($_.Exception.Message)" -Severity 3
         }
      }
   }
   #endregion
}

process
{
   # Check if we're running as a 64-bit process or not
   if (-not [Environment]::Is64BitProcess)
   {
      # Get the sysnative path for powershell.exe
      $paramJoinPath = @{
         Path      = ($PSHOME.ToLower().Replace('syswow64', 'sysnative'))
         ChildPath = 'powershell.exe'
      }
      $SysNativePowerShell = (Join-Path @paramJoinPath)

      # Construct new ProcessStartInfo object to restart powershell.exe as a 64-bit process and re-run scipt
      $ProcessStartInfo = (New-Object -TypeName System.Diagnostics.ProcessStartInfo)
      $ProcessStartInfo.FileName = $SysNativePowerShell
      $ProcessStartInfo.Arguments = "-ExecutionPolicy Bypass -File ""$($PSCommandPath)"""
      $ProcessStartInfo.RedirectStandardOutput = $true
      $ProcessStartInfo.RedirectStandardError = $true
      $ProcessStartInfo.UseShellExecute = $false
      $ProcessStartInfo.WindowStyle = 'Hidden'
      $ProcessStartInfo.CreateNoWindow = $true

      # Instatiate the new 64-bit process
      $Process = [Diagnostics.Process]::Start($ProcessStartInfo)

      # Read standard error output to determine if the 64-bit script process somehow failed
      $ErrorOutput = $Process.StandardError.ReadToEnd()

      if ($ErrorOutput)
      {
         Write-Error -Message $ErrorOutput
      }
   }
   else
   {
      try
      {
         # Define the company registry root key
         $RegistryRootPath = "HKLM:\SOFTWARE\$($CompanyName)"

         if (-not (Test-RegistryValue -Path $RegistryRootPath))
         {
            Write-LogEntry -Value 'Attempting to create registry root path for recovery password escrow results' -Severity 1

            $paramNewItem = @{
               Path        = $RegistryRootPath
               ItemType    = 'Directory'
               Force       = $true
               ErrorAction = $STP
            }
            $null = (New-Item @paramNewItem)
         }
      }
      catch
      {
         Write-LogEntry -Value "An error occurred while creating registry root item '$($RegistryRootPath)'. Error message: $($_.Exception.Message)" -Severity 3
      }

      # Switch execution context depending on selected operational mode for the script as parameter input
      switch ($OperationalMode)
      {
         'Encrypt'
         {
            Write-LogEntry -Value "Current operational mode for script: $($OperationalMode)" -Severity 1

            try
            {
               try
               {
                  # Check if TPM chip is currently owned, if not take ownership
                  $paramGetWmiObject = @{
                     Namespace = 'root\cimv2\Security\MicrosoftTPM'
                     Class     = 'Win32_TPM'
                  }
                  $TPMClass = (Get-WmiObject @paramGetWmiObject)
                  $IsTPMOwned = $TPMClass.IsOwned().IsOwned

                  if ($IsTPMOwned -eq $false)
                  {
                     Write-LogEntry -Value "TPM chip is currently not owned, value from WMI class method 'IsOwned' was: $($IsTPMOwned)" -Severity 1

                     # Generate a random pass phrase to be used when taking ownership of TPM chip
                     $NewPassPhrase = (New-Guid).Guid.Replace('-', '').SubString(0, 14)

                     # Construct owner auth encoded string
                     $NewOwnerAuth = $TPMClass.ConvertToOwnerAuth($NewPassPhrase).OwnerAuth

                     # Attempt to take ownership of TPM chip
                     $Invocation = $TPMClass.TakeOwnership($NewOwnerAuth)

                     if ($Invocation.ReturnValue -eq 0)
                     {
                        Write-LogEntry -Value 'TPM chip ownership was successfully taken' -Severity 1
                     }
                     else
                     {
                        Write-LogEntry -Value "Failed to take ownership of TPM chip, return value from invocation: $($Invocation.ReturnValue)" -Severity 3
                     }
                  }
                  else
                  {
                     Write-LogEntry -Value 'TPM chip is currently owned, will not attempt to take ownership' -Severity 1
                  }
               }
               catch
               {
                  Write-LogEntry -Value "An error occurred while taking ownership of TPM chip. Error message: $($_.Exception.Message)" -Severity 3
               }

               try
               {
                  # Retrieve the current encryption status of the operating system drive
                  Write-LogEntry -Value 'Attempting to retrieve the current encryption status of the operating system drive' -Severity 1

                  $paramGetBitLockerVolume = @{
                     MountPoint  = $env:SystemRoot
                     ErrorAction = $STP
                  }
                  $BitLockerOSVolume = (Get-BitLockerVolume @paramGetBitLockerVolume)

                  if ($BitLockerOSVolume)
                  {
                     # Determine whether BitLocker is turned on or off
                     if (($BitLockerOSVolume.VolumeStatus -like 'FullyDecrypted') -or ($BitLockerOSVolume.KeyProtector.Count -eq 0))
                     {
                        Write-LogEntry -Value "Current encryption status of the operating system drive was detected as: $($BitLockerOSVolume.VolumeStatus)" -Severity 1

                        try
                        {
                           # Enable BitLocker with TPM key protector
                           Write-LogEntry -Value "Attempting to enable BitLocker protection with TPM key protector for mount point: $($env:SystemRoot)" -Severity 1

                           $paramEnableBitLocker = @{
                              MountPoint       = $BitLockerOSVolume.MountPoint
                              TpmProtector     = $true
                              UsedSpaceOnly    = $true
                              EncryptionMethod = $EncryptionMethod
                              SkipHardwareTest = $true
                              ErrorAction      = $STP
                           }
                           $null = (Enable-BitLocker @paramEnableBitLocker)
                        }
                        catch
                        {
                           Write-LogEntry -Value "An error occurred while enabling BitLocker with TPM key protector for mount point '$($env:SystemRoot)'. Error message: $($_.Exception.Message)" -Severity 3
                        }

                        try
                        {
                           # Enable BitLocker with recovery password key protector
                           Write-LogEntry -Value "Attempting to enable BitLocker protection with recovery password key protector for mount point: $($env:SystemRoot)" -Severity 1

                           $paramEnableBitLocker = @{
                              MountPoint                = $BitLockerOSVolume.MountPoint
                              RecoveryPasswordProtector = $true
                              UsedSpaceOnly             = $true
                              EncryptionMethod          = $EncryptionMethod
                              SkipHardwareTest          = $true
                              ErrorAction               = $STP
                           }
                           $null = (Enable-BitLocker @paramEnableBitLocker)
                        }
                        catch
                        {
                           Write-LogEntry -Value "An error occurred while enabling BitLocker with recovery password key protector for mount point '$($env:SystemRoot)'. Error message: $($_.Exception.Message)" -Severity 3
                        }
                     }
                     elseif (($BitLockerOSVolume.VolumeStatus -like 'FullyEncrypted') -or ($BitLockerOSVolume.VolumeStatus -like 'UsedSpaceOnly'))
                     {
                        Write-LogEntry -Value "Current encryption status of the operating system drive was detected as: $($BitLockerOSVolume.VolumeStatus)" -Severity 1
                        Write-LogEntry -Value 'Validating that all desired key protectors are enabled' -Severity 1

                        # Validate that not only the TPM protector is enabled, add recovery password protector
                        if ($BitLockerOSVolume.KeyProtector.Count -lt 2)
                        {
                           if ($BitLockerOSVolume.KeyProtector.KeyProtectorType -like 'Tpm')
                           {
                              Write-LogEntry -Value 'Recovery password key protector is not present' -Severity 1

                              try
                              {
                                 # Enable BitLocker with TPM key protector
                                 Write-LogEntry -Value "Attempting to enable BitLocker protection with recovery password key protector for mount point: $($env:SystemRoot)" -Severity 1

                                 $paramEnableBitLocker = @{
                                    MountPoint                = $BitLockerOSVolume.MountPoint
                                    RecoveryPasswordProtector = $true
                                    UsedSpaceOnly             = $true
                                    EncryptionMethod          = $EncryptionMethod
                                    SkipHardwareTest          = $true
                                    ErrorAction               = $STP
                                 }
                                 $null = (Enable-BitLocker @paramEnableBitLocker)
                              }
                              catch
                              {
                                 Write-LogEntry -Value "An error occurred while enabling BitLocker with TPM key protector for mount point '$($env:SystemRoot)'. Error message: $($_.Exception.Message)" -Severity 3
                              }
                           }

                           if ($BitLockerOSVolume.KeyProtector.KeyProtectorType -like 'RecoveryPassword')
                           {
                              Write-LogEntry -Value 'TPM key protector is not present' -Severity 1

                              try
                              {
                                 # Add BitLocker recovery password key protector
                                 Write-LogEntry -Value "Attempting to enable BitLocker protection with TPM key protector for mount point: $($env:SystemRoot)" -Severity 1

                                 $paramEnableBitLocker = @{
                                    MountPoint       = $BitLockerOSVolume.MountPoint
                                    TpmProtector     = $true
                                    UsedSpaceOnly    = $true
                                    EncryptionMethod = $EncryptionMethod
                                    SkipHardwareTest = $true
                                    ErrorAction      = $STP
                                 }
                                 $null = (Enable-BitLocker @paramEnableBitLocker)
                              }
                              catch
                              {
                                 Write-LogEntry -Value "An error occurred while enabling BitLocker with recovery password key protector for mount point '$($env:SystemRoot)'. Error message: $($_.Exception.Message)" -Severity 3
                              }
                           }
                        }
                        else
                        {
                           # BitLocker is in wait state
                           Invoke-Executable -FilePath 'manage-bde.exe' -Arguments "-On $($BitLockerOSVolume.MountPoint) -UsedSpaceOnly"
                        }
                     }
                     else
                     {
                        Write-LogEntry -Value "Current encryption status of the operating system drive was detected as: $($BitLockerOSVolume.VolumeStatus)" -Severity 1
                     }

                     # Validate that previous configuration was successful and all key protectors have been enabled and encryption is on
                     $paramGetBitLockerVolume = @{
                        MountPoint = $env:SystemRoot
                     }
                     $BitLockerOSVolume = (Get-BitLockerVolume @paramGetBitLockerVolume)

                     # Wait for encryption to complete
                     if ($BitLockerOSVolume.VolumeStatus -like 'EncryptionInProgress')
                     {
                        do
                        {
                           $paramGetBitLockerVolume = @{
                              MountPoint = $env:SystemRoot
                           }
                           $BitLockerOSVolume = (Get-BitLockerVolume @paramGetBitLockerVolume)

                           Write-LogEntry -Value "Current encryption percentage progress: $($BitLockerOSVolume.EncryptionPercentage)" -Severity 1
                           Write-LogEntry -Value 'Waiting for BitLocker encryption progress to complete, sleeping for 15 seconds' -Severity 1

                           Start-Sleep -Seconds 15
                        }
                        until ($BitLockerOSVolume.EncryptionPercentage -eq 100)

                        Write-LogEntry -Value 'Encryption of operating system drive has now completed' -Severity 1
                     }

                     if (($BitLockerOSVolume.VolumeStatus -like 'FullyEncrypted') -and ($BitLockerOSVolume.KeyProtector.Count -eq 2))
                     {
                        try
                        {
                           # Attempt to backup recovery password to Azure AD device object
                           Write-LogEntry -Value 'Attempting to backup recovery password to Azure AD device object' -Severity 1

                           $RecoveryPasswordKeyProtector = $BitLockerOSVolume.KeyProtector | Where-Object {
                              $_.KeyProtectorType -like 'RecoveryPassword'
                           }

                           if ($RecoveryPasswordKeyProtector)
                           {
                              $paramBackupToAADBitLockerKeyProtector = @{
                                 MountPoint     = $BitLockerOSVolume.MountPoint
                                 KeyProtectorId = $RecoveryPasswordKeyProtector.KeyProtectorId
                                 ErrorAction    = $STP
                              }
                              $null = (BackupToAAD-BitLockerKeyProtector @paramBackupToAADBitLockerKeyProtector)

                              Write-LogEntry -Value 'Successfully backed up recovery password details' -Severity 1
                           }
                           else
                           {
                              Write-LogEntry -Value 'Unable to determine proper recovery password key protector for backing up of recovery password details' -Severity 2
                           }
                        }
                        catch
                        {
                           Write-LogEntry -Value "An error occurred while attempting to backup recovery password to Azure AD. Error message: $($_.Exception.Message)" -Severity 3

                           # Copy executing script to system temporary directory
                           Write-LogEntry -Value 'Attempting to copy executing script to system temporary directory' -Severity 1

                           $paramJoinPath = @{
                              Path      = $env:SystemRoot
                              ChildPath = 'Temp'
                           }
                           $SystemTemp = (Join-Path @paramJoinPath)

                           $paramTestPath = @{
                              Path     = (Join-Path -Path $SystemTemp -ChildPath "$($MyInvocation.MyCommand.Name)")
                              PathType = 'Leaf'
                           }
                           if (-not (Test-Path @paramTestPath))
                           {
                              try
                              {
                                 # Copy executing script
                                 Write-LogEntry -Value 'Copying executing script to staging folder for scheduled task usage' -Severity 1

                                 $paramCopyItem = @{
                                    Path        = $MyInvocation.MyCommand.Definition
                                    Destination = $SystemTemp
                                    ErrorAction = $STP
                                 }
                                 $null = (Copy-Item @paramCopyItem)

                                 try
                                 {
                                    # Create escrow scheduled task to backup recovery password to Azure AD at a later time
                                    $paramNewScheduledTaskAction = @{
                                       Execute     = 'powershell.exe'
                                       Argument    = "-ExecutionPolicy Bypass -NoProfile -File $($SystemTemp)\$($MyInvocation.MyCommand.Name) -OperationalMode Backup"
                                       ErrorAction = $STP
                                    }
                                    $TaskAction = (New-ScheduledTaskAction @paramNewScheduledTaskAction)

                                    $paramNewScheduledTaskTrigger = @{
                                       AtLogOn     = $true
                                       ErrorAction = $STP
                                    }
                                    $TaskTrigger = (New-ScheduledTaskTrigger @paramNewScheduledTaskTrigger)

                                    $paramNewScheduledTaskSettingsSet = @{
                                       AllowStartIfOnBatteries    = $true
                                       Hidden                     = $true
                                       DontStopIfGoingOnBatteries = $true
                                       Compatibility              = 'Win8'
                                       RunOnlyIfNetworkAvailable  = $true
                                       MultipleInstances          = 'IgnoreNew'
                                       ErrorAction                = $STP
                                    }
                                    $TaskSettings = (New-ScheduledTaskSettingsSet @paramNewScheduledTaskSettingsSet)

                                    $paramNewScheduledTaskPrincipal = @{
                                       UserId      = 'NT AUTHORITY\SYSTEM'
                                       LogonType   = 'ServiceAccount'
                                       RunLevel    = 'Highest'
                                       ErrorAction = $STP
                                    }
                                    $TaskPrincipal = (New-ScheduledTaskPrincipal @paramNewScheduledTaskPrincipal)

                                    $paramNewScheduledTask = @{
                                       Action      = $TaskAction
                                       Principal   = $TaskPrincipal
                                       Settings    = $TaskSettings
                                       Trigger     = $TaskTrigger
                                       ErrorAction = $STP
                                    }
                                    $ScheduledTask = (New-ScheduledTask @paramNewScheduledTask)

                                    $paramRegisterScheduledTask = @{
                                       InputObject = $ScheduledTask
                                       TaskName    = 'Backup BitLocker Recovery Password to Azure AD'
                                       TaskPath    = '\Microsoft'
                                       ErrorAction = $STP
                                    }
                                    $null = (Register-ScheduledTask @paramRegisterScheduledTask)

                                    try
                                    {
                                       # Attempt to create BitLocker recovery password escrow registry value
                                       $paramTestRegistryValue = @{
                                          Path = $RegistryRootPath
                                          Name = 'BitLockerEscrowResult'
                                       }
                                       if (-not (Test-RegistryValue @paramTestRegistryValue))
                                       {
                                          Write-LogEntry -Value "Setting initial 'BitLockerEscrowResult' registry value to: None" -Severity 1

                                          $paramSetRegistryValue = @{
                                             Path  = $RegistryRootPath
                                             Name  = 'BitLockerEscrowResult'
                                             Value = 'None'
                                          }
                                          $null = (Set-RegistryValue @paramSetRegistryValue)
                                       }
                                    }
                                    catch
                                    {
                                       Write-LogEntry -Value "Unable to register scheduled task for backup of recovery password. Error message: $($_.Exception.Message)" -Severity 3
                                    }
                                 }
                                 catch
                                 {
                                    Write-LogEntry -Value "Unable to register scheduled task for backup of recovery password. Error message: $($_.Exception.Message)" -Severity 3
                                 }
                              }
                              catch
                              {
                                 Write-LogEntry -Value "Unable to stage script in system temporary directory for scheduled task. Error message: $($_.Exception.Message)" -Severity 3
                              }
                           }
                        }
                     }
                     else
                     {
                        Write-LogEntry -Value 'Validation of current encryption status for operating system drive was not successful' -Severity 2
                        Write-LogEntry -Value "Current volume status for mount point '$($BitLockerOSVolume.MountPoint)': $($BitLockerOSVolume.VolumeStatus)" -Severity 2
                        Write-LogEntry -Value "Count of enabled key protectors for volume: $($BitLockerOSVolume.KeyProtector.Count)" -Severity 2
                     }
                  }
                  else
                  {
                     Write-LogEntry -Value 'Current encryption status query returned an empty result, this was not expected at this point' -Severity 2
                  }
               }
               catch
               {
                  Write-LogEntry -Value "An error occurred while retrieving the current encryption status of operating system drive. Error message: $($_.Exception.Message)" -Severity 3
               }
            }
            catch
            {
               Write-LogEntry -Value "An error occurred while importing the BitLocker module. Error message: $($_.Exception.Message)" -Severity 3
            }
         }
         'Backup'
         {
            Write-LogEntry -Value "Current operational mode for script: $($OperationalMode)" -Severity 1

            # Retrieve the current encryption status of the operating system drive
            $paramGetBitLockerVolume = @{
               MountPoint = $env:SystemRoot
            }
            $BitLockerOSVolume = (Get-BitLockerVolume @paramGetBitLockerVolume)

            # Attempt to backup recovery password to Azure AD device object if volume is encrypted
            if (($BitLockerOSVolume.VolumeStatus -like 'FullyEncrypted') -and ($BitLockerOSVolume.KeyProtector.Count -eq 2))
            {
               try
               {
                  $paramGetItemPropertyValue = @{
                     Path        = $RegistryRootPath
                     Name        = 'BitLockerEscrowResult'
                     ErrorAction = $STP
                  }
                  $BitLockerEscrowResultsValue = (Get-ItemPropertyValue @paramGetItemPropertyValue)

                  if ($BitLockerEscrowResultsValue -match 'None|False')
                  {
                     try
                     {
                        Write-LogEntry -Value 'Attempting to backup recovery password to Azure AD device object' -Severity 1

                        $RecoveryPasswordKeyProtector = $BitLockerOSVolume.KeyProtector | Where-Object {
                           $_.KeyProtectorType -like 'RecoveryPassword'
                        }

                        if ($RecoveryPasswordKeyProtector)
                        {
                           $paramBackupToAADBitLockerKeyProtector = @{
                              MountPoint     = $BitLockerOSVolume.MountPoint
                              KeyProtectorId = $RecoveryPasswordKeyProtector.KeyProtectorId
                              ErrorAction    = $STP
                           }
                           $null = (BackupToAAD-BitLockerKeyProtector @paramBackupToAADBitLockerKeyProtector)

                           $paramSetRegistryValue = @{
                              Path  = $RegistryRootPath
                              Name  = 'BitLockerEscrowResult'
                              Value = 'True'
                           }
                           $null = (Set-RegistryValue @paramSetRegistryValue)

                           Write-LogEntry -Value 'Successfully backed up recovery password details' -Severity 1
                        }
                        else
                        {
                           Write-LogEntry -Value 'Unable to determine proper recovery password key protector for backing up of recovery password details' -Severity 2
                        }
                     }
                     catch
                     {
                        Write-LogEntry -Value "An error occurred while attempting to backup recovery password to Azure AD. Error message: $($_.Exception.Message)" -Severity 3

                        $paramSetRegistryValue = @{
                           Path  = $RegistryRootPath
                           Name  = 'BitLockerEscrowResult'
                           Value = 'False'
                        }
                        $null = (Set-RegistryValue @paramSetRegistryValue)
                     }
                  }
                  else
                  {
                     Write-LogEntry -Value "Value for 'BitLockerEscrowResults' was '$($BitLockerEscrowResultsValue)', will not attempt to backup recovery password once more" -Severity 1

                     try
                     {
                        # Disable scheduled task
                        $paramGetScheduledTask = @{
                           TaskName    = 'Backup BitLocker Recovery Password to Azure AD'
                           ErrorAction = $STP
                        }
                        $ScheduledTask = (Get-ScheduledTask @paramGetScheduledTask)

                        $paramDisableScheduledTask = @{
                           InputObject = $ScheduledTask
                           ErrorAction = $STP
                        }
                        $null = (Disable-ScheduledTask @paramDisableScheduledTask)

                        Write-LogEntry -Value "Successfully disabled scheduled task named 'Backup BitLocker Recovery Password to Azure AD'" -Severity 1
                     }
                     catch
                     {
                        Write-LogEntry -Value "An error occurred while disabling scheduled task to backup recovery password. Error message: $($_.Exception.Message)" -Severity 3
                     }
                  }
               }
               catch
               {
                  Write-LogEntry -Value "An error occurred while reading 'BitLockerEscrowResults' registry value. Error message: $($_.Exception.Message)" -Severity 3
               }
            }
         }
      }
   }
}

end
{
   if (Get-Command -Name 'Set-MpPreference' -ErrorAction $SCT)
   {
      $null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction $SCT)
   }
}
