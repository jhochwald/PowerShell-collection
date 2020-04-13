#requires -Version 2.0 -Modules BitLocker
#requires -RunAsAdministrator

<#
      .SYNOPSIS
      Create a new BitLocker Recovery Key

      .DESCRIPTION
      Create a new BitLocker Recovery Key
      We will just create a new one, but we will not show it.
      You should store it into the AzureAD, or a least in the Active Directory

      .EXAMPLE
      PS C:\> .\New-BitlockerRecoveryKey.ps1

      .NOTES
      Quick and relativ dirty solution for a challange I had in the last couple of days
      By the way: Only the Boot Drive is supported by default.

      .LINK
      Add-BitLockerKeyProtector

      .LINK
      http://hochwald.net
#>
[CmdletBinding(ConfirmImpact = 'Low')]
param ()

begin
{
   # Defaults
   $LogName = 'Application'
   $STP = 'Stop'
   $SCT = 'SilentlyContinue'
   $LogSource = 'enAutomate'

   # Register the event log source
   $null = (New-EventLog -LogName $LogName -Source $LogSource -ErrorAction $SCT)
}

process
{
   # Get BitLocker Volume info
   $BitLockerVolumeInfo = (Get-BitLockerVolume | Where-Object -FilterScript {
         $_.VolumeType -eq 'OperatingSystem'
   })

   # Get the Mount Point
   $BootDrive = $BitLockerVolumeInfo.MountPoint

   # Get the Key
   $KeyProtectors = $BitLockerVolumeInfo.KeyProtector

   # Check if the Boot Drive is encrypted
   if (($BitLockerVolumeInfo.VolumeStatus -eq 'FullyDecrypted') -or ($BitLockerVolumeInfo.ProtectionStatus -eq 'Off') -or (-not ($KeyProtectors)))
   {
      Write-Warning -Message ('Please Exceute: "Enable-BitLocker -MountPoint  {0}"' -f $BootDrive)
      break
   }
   else
   {
      foreach ($KeyProtector in $KeyProtectors)
      {
         if ($KeyProtector.KeyProtectorType -eq 'RecoveryPassword')
         {
            try
            {
               # Remove the existing Recovery Password
               $null = (Remove-BitLockerKeyProtector -MountPoint $BootDrive -KeyProtectorId $KeyProtector.KeyProtectorId -ErrorAction $STP)

               # Just add a new Recovery Password without showing it here. We store than in the AzureAD anyway!
               $null = (Add-BitLockerKeyProtector -MountPoint $BootDrive -RecoveryPasswordProtector -WarningAction SilentlyContinue)

               # If we get this far, eveything has worked, write a success to the event log
               $InfoText = 'Changed the BitLocker Recovery Password for ' + $BootDrive + ' successfully'
               Write-EventLog -LogName $LogName -Source $LogSource -EntryType Information -EventId 1000 -Message $InfoText
               Write-Output -InputObject $InfoText
            }
            catch
            {
               #region ErrorHandler
               # Get error record
               [Management.Automation.ErrorRecord]$e = $_

               # retrieve information about runtime error
               $info = @{
                  Exception = $e.Exception.Message
                  Reason    = $e.CategoryInfo.Reason
                  Target    = $e.CategoryInfo.TargetName
                  Script    = $e.InvocationInfo.ScriptName
                  Line      = $e.InvocationInfo.ScriptLineNumber
                  Column    = $e.InvocationInfo.OffsetInLine
               }

               # Error Stack
               $info | Out-String | Write-Verbose

               # Save to the Event Log
               $null = (Write-EventLog -LogName $LogName -Source $LogSource -EntryType Error -EventId 1001 -Message ($info.Exception) -ErrorAction $SCT)

               # Just display the info on continue with the rest of the list
               $paramWriteError = @{
                  Message       = ($info.Exception)
                  Exception     = $info.Exception
                  TargetObject  = $info.Target
                  ErrorAction   = $STP
                  WarningAction = 'Continue'
               }
               Write-Error @paramWriteError
            }
         }
      }
   }
}