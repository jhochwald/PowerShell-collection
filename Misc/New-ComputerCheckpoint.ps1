function New-ComputerCheckpoint
{
   <#
         .SYNOPSIS
         Creates a system restore point on the local computer

         .DESCRIPTION
         Creates a system restore point on the local computer for the boot drive

         .PARAMETER Interval
         Set system restore to 720 minutes (12 hour)
         The default is 1440 minutes (24 hours)
         If you do a lot of changes, you might want to decrease that, e.g. to 360 minutes (6 hours), or even lower!!!

         .PARAMETER Description
         Specifies a descriptive name for the restore point.

         .PARAMETER Type
         Specifies the type of restore point.
         The default is MODIFY_SETTINGS

         .PARAMETER WhatIf
         The WhatIf switch instructs the command to which it is applied to run but only to display the objects that would be affected by running the command and what changes would be made to those objects. The switch does not actually change any of those objects.
         When you use the WhatIf switch, you can see whether the changes that would be made to those objects match your expectations, without the worry of modifying those objects.

         .PARAMETER Confirm
         The Confirm switch instructs the command to which it is applied to stop processing before any changes are made.
         The command then prompts you to acknowledge each action before it continues.
         When you use the Confirm switch, you can step through changes to objects to make sure that changes are made only to the specific objects that you want to change.

         .EXAMPLE
         PS C:\> New-ComputerCheckpoint

         Creates a system restore point on the local computer

         .EXAMPLE
         PS C:\> New-ComputerCheckpoint -Confirm:$false

         Enforce to create a system restore point on the local computer

         .EXAMPLE
         PS C:\> New-ComputerCheckpoint -WhatIf

         Simmulate to create a system restore point on the local computer


         .EXAMPLE
         PS C:\> New-ComputerCheckpoint -Description 'Pre update installation'

         Creates a system restore point on the local computer

         .EXAMPLE
         PS C:\> New-ComputerCheckpoint -Description 'Pre 7Zip installation' -Type 'APPLICATION_INSTALL'

         Creates a system restore point on the local computer

         .EXAMPLE
         PS C:\> Get-ComputerRestorePoint | Select-Object -Property @{Name='Sequence'; Expression={$_.SequenceNumber}}, $(@{Label='Creation Date'; Expression={$_.ConvertToDateTime($_.CreationTime)}}), @{Name='Description of the Restore Point'; Expression={$_.Description}}

         See all system restore points on the local computer

         .NOTES
         Internal Helper
   #>
   [CmdletBinding(ConfirmImpact = 'Low',
   SupportsShouldProcess)]
   [OutputType([string])]
   param
   (
      [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
      [ValidateNotNullOrEmpty()]
      [Alias('AutoRestorePointInterval')]
      [int]
      $Interval = 720,
      [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
      [ValidateNotNullOrEmpty()]
      [Alias('RestorePointDescription')]
      [string]
      $Description = 'Manual RestorePoint',
      [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
      [ValidateNotNullOrEmpty()]
      [ValidateSet('APPLICATION_INSTALL', 'APPLICATION_UNINSTALL', 'DEVICE_DRIVER_INSTALL', 'MODIFY_SETTINGS', 'CANCELLED_OPERATION')]
      [Alias('RestorePointType')]
      [string]
      $Type = 'MODIFY_SETTINGS'
   )

   begin
   {
      #region
      function Invoke-DisableComputerRestore
      {
         <#
               .SYNOPSIS
               Helper/Wrapper for Disable-ComputerRestore

               .DESCRIPTION
               Helper/Wrapper for Disable-ComputerRestore

               .PARAMETER Drive
               Specifies the file system drives. Enter one or more file system drive letters,
               each followed by a colon and a backslash and enclosed in quotation marks, such as C:\ or D:

               .EXAMPLE
               PS C:\> Invoke-DisableComputerRestore

               .NOTES
               Helper/Wrapper
         #>

         [CmdletBinding(ConfirmImpact = 'Low',
         SupportsShouldProcess)]
         [OutputType([string])]
         param
         (
            [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName)]
            [ValidateNotNullOrEmpty()]
            [string]
            $Drive = $env:SystemDrive
         )

         process
         {
            if ($pscmdlet.ShouldProcess($Drive, 'Invoke Disable-ComputerRestore'))
            {
               $paramDisableComputerRestore = @{
                  Drive         = $Drive
                  Confirm       = $false
                  ErrorAction   = 'SilentlyContinue'
                  WarningAction = 'SilentlyContinue'
               }
               $null = (Disable-ComputerRestore @paramDisableComputerRestore)
            }
         }
      }

      function Invoke-EnableComputerRestore
      {
         <#
               .SYNOPSIS
               Helper/Wrapper for Enable-ComputerRestore

               .DESCRIPTION
               Helper/Wrapper for Enable-ComputerRestore

               .PARAMETER Drive
               Specifies the file system drives. Enter one or more file system drive letters,
               each followed by a colon and a backslash and enclosed in quotation marks, such as C:\ or D:

               .EXAMPLE
               PS C:\> Invoke-EnableComputerRestore

               .NOTES
               Helper/Wrapper
         #>
         [CmdletBinding(ConfirmImpact = 'Low',
         SupportsShouldProcess)]
         [OutputType([string])]
         param
         (
            [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName)]
            [ValidateNotNullOrEmpty()]
            [string]
            $Drive = $env:SystemDrive
         )

         process
         {
            if ($pscmdlet.ShouldProcess($Drive, 'Invoke Enable-ComputerRestore'))
            {
               $paramEnableComputerRestore = @{
                  Drive         = $Drive
                  Confirm       = $false
                  ErrorAction   = 'SilentlyContinue'
                  WarningAction = 'SilentlyContinue'
               }
               $null = (Enable-ComputerRestore @paramEnableComputerRestore)
            }
         }
      }
      #endregion
   }

   process
   {
      if ($pscmdlet.ShouldProcess("$env:SystemDrive on $env:COMPUTERNAME", 'Creates a system restore point'))
      {
         # Disable any RestorePoint settings for the main drive. To make the next setting work without a reboot
         $null = (Invoke-DisableComputerRestore -Confirm:$false)

         # Set system restore to never skip creating a restore point
         $paramNewItemProperty = @{
            Path         = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore'
            Name         = 'SystemRestorePointCreationFrequency'
            Value        = '0'
            PropertyType = 'Dword'
            Force        = $true
            ErrorAction  = 'SilentlyContinue'
         }
         $null = (New-ItemProperty @paramNewItemProperty)

         # Now we enable the RestorePoint for the main drive
         $null = (Invoke-EnableComputerRestore -Confirm:$false)

         $paramCheckpointComputer = @{
            Description      = 'Block Telemetry'
            RestorePointType = 'MODIFY_SETTINGS'
            ErrorAction      = 'SilentlyContinue'
            WarningAction    = 'SilentlyContinue'
         }
         $null = (Checkpoint-Computer @paramCheckpointComputer)

         # Disable any RestorePoint settings for the main drive. To make the next setting work without a reboot
         $null = (Invoke-DisableComputerRestore -Confirm:$false)

         $paramNewItemProperty = @{
            Path         = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore'
            Name         = 'SystemRestorePointCreationFrequency'
            Value        = $Interval
            PropertyType = 'Dword'
            Force        = $true
            ErrorAction  = 'SilentlyContinue'
         }
         $null = (New-ItemProperty @paramNewItemProperty)

         # Now we enable the RestorePoint for the main drive
         $null = (Invoke-EnableComputerRestore -Confirm:$false)
      }
   }
}
New-ComputerCheckpoint -Description 'Manual CheckPoint' -Type MODIFY_SETTINGS