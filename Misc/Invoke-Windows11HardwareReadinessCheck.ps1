#requires -Version 3.0 -Modules CimCmdlets, SecureBoot, TrustedPlatformModule

function Invoke-Windows11HardwareReadinessCheck
{
   <#
         .SYNOPSIS
         Is this Computer Ready for Windows 11?

         .DESCRIPTION
         Is this Computer Ready for Windows 11?

         .PARAMETER RequiredSystemDriveSize
         Minimum Diskspace in GB for the Boot Drive
         Minimum required by Microsoft is 64GB! We recommend 80, or more

         .PARAMETER RequiredMemorySize
         Minimum amount of RAM in GB?
         Minimum required by Microsoft is 4GB! We recommend 8GB, or more

         .PARAMETER RequiredClockSpeedMHz
         Minimum required CPU Clock Speed in MHz?
         Minimum required by Microsoft is 1.000MHz! More is better

         .PARAMETER RequiredLogicalCores
         Minimum required logical CPU cores?
         Minimum required by Microsoft is 2! More is better

         .PARAMETER RequiredAddressWidth
         Required address set?
         Plain english: 64 = 64Bit, and you should use 64Bit

         .EXAMPLE
         PS C:\> Invoke-Windows11HardwareReadinessCheck

         Is this Computer Ready for Windows 11?

         .LINK
         https://support.microsoft.com/en-us/windows/windows-11-system-requirements-86c11283-ea52-4782-9efd-7674389a7ba3

         .NOTES
         Prototype (PoC) to check the Windows 11 readiness
         You must run this with admin permission within an elevated shell, otherwise the result will be reported wrong!
   #>
   [CmdletBinding(ConfirmImpact = 'Low')]
   [OutputType([string])]
   param
   (
      [Parameter(ValueFromPipeline,
         ValueFromPipelineByPropertyName)]
      [ValidateNotNullOrEmpty()]
      [Alias('MinSystemDriveSize')]
      [int]
      $RequiredSystemDriveSize = 64,
      [Parameter(ValueFromPipeline,
         ValueFromPipelineByPropertyName)]
      [ValidateNotNullOrEmpty()]
      [Alias('MinMemorySize', 'MinMemSize')]
      [int]
      $RequiredMemorySize = 8,
      [Parameter(ValueFromPipeline,
         ValueFromPipelineByPropertyName)]
      [ValidateNotNullOrEmpty()]
      [Alias('MinClockSpeedMHz', 'MinClockSpeed')]
      [int]
      $RequiredClockSpeedMHz = 1000,
      [Parameter(ValueFromPipeline,
         ValueFromPipelineByPropertyName)]
      [ValidateNotNullOrEmpty()]
      [Alias('RequiredCores', 'MinLogicalCores', 'MinCores')]
      [int]
      $RequiredLogicalCores = 2,
      [Parameter(ValueFromPipelineByPropertyName,
         ValueFromRemainingArguments = $true)]
      [ValidateNotNullOrEmpty()]
      [int]
      $RequiredAddressWidth = 64
   )

   process
   {
      #region SystemDriveSize
      $paramGetCimInstance = @{
         ClassName   = 'Win32_OperatingSystem'
         ErrorAction = 'SilentlyContinue'
      }
      $InfoSystemDrive = (Get-CimInstance @paramGetCimInstance | Select-Object -ExpandProperty SystemDrive)

      $paramGetCimInstance = @{
         ClassName   = 'Win32_LogicalDisk'
         Filter      = ('DeviceID=''{0}''' -f $InfoSystemDrive)
         ErrorAction = 'SilentlyContinue'
      }
      $InfoSystemDriveSize = (Get-CimInstance @paramGetCimInstance | Select-Object -Property @{
            Name       = 'SizeGB'
            Expression = {
               $_.Size / 1GB -as [int]
            }
         })

      if ($InfoSystemDriveSize.SizeGB -gt $RequiredSystemDriveSize)
      {
         Write-Verbose -Message ('{0} has {1}GB free Space on {2}, more then the required {3}GB for a Boot drive' -f $env:COMPUTERNAME, $InfoSystemDriveSize.SizeGB, $InfoSystemDrive, $RequiredSystemDriveSize)
      }
      else
      {
         Write-Warning -Message ('{0} has {1}GB free Space on {2}, that is below the required {3}GB for a Boot drive' -f $env:COMPUTERNAME, $InfoSystemDriveSize.SizeGB, $InfoSystemDrive, $RequiredSystemDriveSize)
      }
      #endregion SystemDriveSize

      #region SystemMemory
      $paramGetCimInstance = @{
         ClassName   = 'Win32_PhysicalMemory'
         ErrorAction = 'SilentlyContinue'
      }
      $InfoSystemMemory = (Get-CimInstance @paramGetCimInstance | Measure-Object -Property Capacity -Sum | Select-Object -Property @{
            Name       = 'SizeGB'
            Expression = {
               $_.Sum / 1GB -as [int]
            }
         })

      if ($InfoSystemMemory.SizeGB -ge $RequiredMemorySize)
      {
         Write-Verbose -Message ('{0} has {1}GB RAM - More then the required {2}GB' -f $env:COMPUTERNAME, $InfoSystemMemory.SizeGB, $RequiredMemorySize)
      }
      else
      {
         Write-Warning -Message ('{0} has {1}GB RAM - Below the required {2}GB' -f $env:COMPUTERNAME, $InfoSystemMemory.SizeGB, $RequiredMemorySize)
      }
      #endregion SystemMemory

      #region TPM
      if ((Get-Tpm -ErrorAction SilentlyContinue).ManufacturerVersionFull20)
      {
         if (-not (Get-Tpm -ErrorAction SilentlyContinue).ManufacturerVersionFull20.Contains('not supported'))
         {
            Write-Verbose -Message ('{0} fullfill the TPM requirements' -f $env:COMPUTERNAME)
         }
         else
         {
            Write-Warning -Message ('{0} does not fullfill the TPM requirements' -f $env:COMPUTERNAME)
         }
      }
      else
      {
         Write-Warning -Message ('{0} might not fullfill the TPM requirements' -f $env:COMPUTERNAME)
      }
      #endregion TPM

      #region
      $cpuDetails = @(Get-CimInstance -ClassName Win32_Processor)[0]

      if (($null -eq $cpuDetails.AddressWidth) -or ($cpuDetails.AddressWidth -ne $RequiredAddressWidth))
      {
         Write-Warning -Message ('{0} reports {1} - This does NOT match the required {2}' -f $env:COMPUTERNAME, $cpuDetails.AddressWidth, $RequiredAddressWidth)
      }
      else
      {
         Write-Verbose -Message ('{0} fullfills the AddressWidth requirements' -f $env:COMPUTERNAME)
      }

      if (($null -eq $cpuDetails.MaxClockSpeed) -or ($cpuDetails.MaxClockSpeed -le $RequiredClockSpeedMHz))
      {
         Write-Warning -Message ('{0} reports {1}MHz - This does NOT match the required {2}MHz (In plain english: To slow)' -f $env:COMPUTERNAME, $cpuDetails.MaxClockSpeed, $RequiredClockSpeedMHz)
      }
      else
      {
         Write-Verbose -Message ('{0} reports {1}MHz - More then the required {2}MHz' -f $env:COMPUTERNAME, $cpuDetails.MaxClockSpeed, $RequiredClockSpeedMHz)
      }

      if (($null -eq $cpuDetails.NumberOfLogicalProcessors) -or ($cpuDetails.NumberOfLogicalProcessors -lt $RequiredLogicalCores))
      {
         Write-Warning -Message ('{0} reports {1} Cores - This does NOT match the required {2} Cores (In plain english: Not enough CPU Cores)' -f $env:COMPUTERNAME, $cpuDetails.NumberOfLogicalProcessors, $RequiredLogicalCores)
      }
      else
      {
         Write-Verbose -Message ('{0} reports {1} Cores - More then the required {2} Cores' -f $env:COMPUTERNAME, $cpuDetails.NumberOfLogicalProcessors, $RequiredLogicalCores)
      }
      #endregion

      #region
      try
      {
         if (Confirm-SecureBootUEFI -ErrorAction Stop)
         {
            Write-Verbose -Message ('Secure Boot is enabled on {0}' -f $env:COMPUTERNAME)
         }
         else
         {
            Write-Verbose -Message ('Secure Boot is not enabled on {0}' -f $env:COMPUTERNAME)
         }
      }
      catch
      {
         Write-Verbose -Message ('Secure Boot migh not be enabled on {0}' -f $env:COMPUTERNAME)
      }
      #endregion
   }
}
Invoke-Windows11HardwareReadinessCheck