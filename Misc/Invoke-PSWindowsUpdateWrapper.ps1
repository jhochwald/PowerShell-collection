#requires -Version 3.0 -RunAsAdministrator

<#
      .SYNOPSIS
      Installing Microsoft updates

      .DESCRIPTION
      Installing Microsoft updates using PSWindowsUpdate

      .PARAMETER Reboot
      Reboot handling

      Valid values are:
      Soft
      Hard
      None
      Delayed

      The default is 'Soft', and the PSWindowsUpdate also set this for us (if needed)

      .PARAMETER RebootTimeout
      If the Reboot value is set to 'Delayed', this is the time to wait until the reboot is enforced.
      Any other value in the Reboot parameter will ignore this value.

      .LINK
      https://github.com/mtniehaus/UpdateOS/blob/main/UpdateOS/UpdateOS.ps1

      .LINK
      https://oofhours.com/2023/10/23/installing-updates-during-autopilot-windows-11-edition-revisited/

      .EXAMPLE
      PS C:\> .\Invoke-PSWindowsUpdateWrapper.ps1

      Installing Microsoft updates using PSWindowsUpdate

      .EXAMPLE
      PS C:\> .\Invoke-PSWindowsUpdateWrapper.ps1 -Reboot Delayed

      Installing Microsoft updates using PSWindowsUpdate, use the delayed timeout flag

      .EXAMPLE
      PS C:\> .\Invoke-PSWindowsUpdateWrapper.ps1 -Reboot Hard

      Installing Microsoft updates using PSWindowsUpdate, use the delayed timeout flag

      .NOTES
      Idea and base script is stolen from MICHAEL NIEHAUS.

      I adopted it a bit, can be used during the Windows Autopilot process and interactive (kind of hybrid, right?)
      And because we also support Autopilot Write-Host is used, what I try to avoid normaly!
      But the Intune logging might miss some info if we use Write-Host (At least this is what I found)
#>
[CmdletBinding(ConfirmImpact = 'Low')]
param
(
   [Parameter(ValueFromPipeline,
   ValueFromPipelineByPropertyName)]
   [ValidateSet('Soft', 'Hard', 'None', 'Delayed', IgnoreCase = $true)]
   [String]
   $Reboot = 'Soft',
   [Parameter(ValueFromPipeline,
   ValueFromPipelineByPropertyName)]
   [ValidateNotNullOrEmpty()]
   [int]
   $RebootTimeout = 120
)

begin
{
   #region SetDefaults
   $needReboot = $False
   $TimeStampFormat = 'yyyy/MM/dd hh:mm:ss tt'
   $WUSMServiceID = '7971f918-a847-4430-9279-4a52d1efe18d'
   #endregion

   #region CheckForPSWindowsUpdateModule
   if (!(Get-Module -ListAvailable -Name PSWindowsUpdate))
   {
      $TimeStamp = (Get-Date -Format $TimeStampFormat)
      Write-Host -Object ('{0} Start the installation of the required PSWindowsUpdate module' -f $TimeStamp)

      $paramInstallPackageProvider = @{
         Name        = 'NuGet'
         Force       = $true
         ErrorAction = 'Stop'
      }
      $null = (Install-PackageProvider @paramInstallPackageProvider)
      $paramInstallModule = @{
         Force              = $true
         Scope              = 'AllUsers'
         SkipPublisherCheck = $true
         AllowClobber       = $true
         Name               = 'PSWindowsUpdate'
         ErrorAction        = 'Stop'
      }
      $null = (Install-Module @paramInstallModule)
      $paramImportModule = @{
         Name        = 'PSWindowsUpdate'
         Force       = $true
         ErrorAction = 'Stop'
      }
      $null = (Import-Module @paramImportModule)

      $TimeStamp = (Get-Date -Format $TimeStampFormat)
      Write-Host -Object ('{0} Done with the installation of the required PSWindowsUpdate module' -f $TimeStamp)
   }
   #endregion

   #region SetupPSWindowsUpdate
   if (!(Get-WUServiceManager -ServiceID $WUSMServiceID -ErrorAction SilentlyContinue | Where-Object -FilterScript {
            ($_.IsDefaultAUService -eq $true)
   }))
   {
      $TimeStamp = (Get-Date -Format $TimeStampFormat)
      Write-Host -Object ('{0} Start the WUServiceManager Setup' -f $TimeStamp)

      $paramAddWUServiceManager = @{
         ServiceID      = $WUSMServiceID
         AddServiceFlag = 7
         Confirm        = $False
         ErrorAction    = 'Stop'
         WarningAction  = 'SilentlyContinue'
      }
      $null = (Add-WUServiceManager @paramAddWUServiceManager)

      $TimeStamp = (Get-Date -Format $TimeStampFormat)
      Write-Host -Object ('{0} Done with the WUServiceManager Setup' -f $TimeStamp)


      $needReboot = (Get-WURebootStatus -Silent)
   }
   #endregion
}

process
{
   # Install all available updates
   $TimeStamp = (Get-Date -Format $TimeStampFormat)
   Write-Host -Object ('{0} Start the Microsoft Update process' -f $TimeStamp)

   # Now PSWindowsUpdate will do the real work for us
   $paramGetWindowsUpdate = @{
      MicrosoftUpdate = $true
      AcceptAll       = $true
      IgnoreReboot    = $true
      Confirm         = $False
      ErrorAction     = 'Stop'
      WarningAction   = 'SilentlyContinue'
   }
   (Get-WindowsUpdate @paramGetWindowsUpdate | Select-Object -Property Title, KB, Result)

   # Check if the update process set a pending reboot
   $needReboot = (Get-WURebootStatus -Silent)

   $TimeStamp = (Get-Date -Format $TimeStampFormat)
   Write-Host -Object ('{0} Done with the Microsoft Update process' -f $TimeStamp)
}

end
{
   #region PSWindowsUpdateRebootHandler
   # Get a new Time-Stamp
   $TimeStamp = (Get-Date -Format $TimeStampFormat)

   # Specify return code
   if ($needReboot)
   {
      Write-Host -Object ('{0} PSWindowsUpdate indicated that a reboot is needed' -f $TimeStamp)

      # Just to make sure we do the right thing here
      if ($null -eq $Reboot)
      {
         # OK, we tell Intune that we need a soft reboot
         if ($Reboot -eq 'None')
         {
            $Reboot = 'Soft'
         }
      }
   }
   else
   {
      Write-Host -Object ('{0} PSWindowsUpdate indicated that no reboot is required' -f $TimeStamp)

      # OK, in this case we skip the reboot! No need to jings it, right?
      $Reboot = 'None'
   }
   #endregion

   #region IntuneRebootHandler
   # Get a new Time-Stamp
   $TimeStamp = (Get-Date -Format $TimeStampFormat)

   if ($Reboot -eq 'Hard')
   {
      Write-Host -Object ('{0} Exiting with return code 1641 to indicate a hard reboot is needed' -f $TimeStamp)
      exit 1641
   }
   elseif ($Reboot -eq 'Soft')
   {
      Write-Host -Object ('{0} Exiting with return code 3010 to indicate a soft reboot is needed' -f $TimeStamp)
      exit 3010
   }
   elseif ($Reboot -eq 'Delayed')
   {
      Write-Host -Object ('{0} Rebooting with a {1} second delay' -f $TimeStamp, $RebootTimeout)
      & "$env:windir\system32\shutdown.exe" /r /t $RebootTimeout /c 'Rebooting to complete the installation of Microsoft updates'
      exit 0
   }
   else
   {
      Write-Host -Object ('{0} Skipping reboot based on Reboot parameter (None), or because no reboot is required' -f $TimeStamp)
      exit 0
   }
   #endregion
}