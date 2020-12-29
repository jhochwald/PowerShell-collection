#requires -Version 2.0 -Modules BitLocker -RunAsAdministrator

<#
      .SYNOPSIS
      Backup all BitLocker Recovery Key to AzureAD

      .DESCRIPTION
      Backup all BitLocker Recovery Key to AzureAD

      .EXAMPLE
      PS C:\> .\Invoke-BackupBitLockerKeyToAAD.ps1

      .NOTES
      Early Beta

      The multiple recovery passwords part is still unstable
#>
[CmdletBinding(ConfirmImpact = 'None')]
param ()

begin
{
   Write-Output -InputObject 'Backup all BitLocker Recovery Key to AzureAD'

   $SCT = 'SilentlyContinue'
   $STP = 'Stop'

   $keyID = $null
	
   $paramGetBitLockerVolume = @{
      MountPoint    = $env:systemdrive
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   $keyID = (Get-BitLockerVolume @paramGetBitLockerVolume | Select-Object -ExpandProperty keyprotector | Where-Object -FilterScript {
         $_.KeyProtectorType -eq 'RecoveryPassword'
   })
}

process
{
   try
   {
      if (-not $keyID)
      {
         # In case there is no Recovery Password, lets create new one
         $paramAddBitLockerKeyProtector = @{
            MountPoint                = $env:systemdrive
            RecoveryPasswordProtector = $true
            ErrorAction               = $STP
            WarningAction             = $SCT
            Confirm                   = $false
         }
         $null = (Add-BitLockerKeyProtector @paramAddBitLockerKeyProtector)

         $paramGetBitLockerVolume = @{
            MountPoint    = $env:systemdrive
            ErrorAction   = $SCT
            WarningAction = $SCT
         }
         $keyID = (Get-BitLockerVolume -MountPoint $env:systemdrive -ErrorAction $STP -WarningAction $SCT | Select-Object -ExpandProperty keyprotector | Where-Object -FilterScript {
               $_.KeyProtectorType -eq 'RecoveryPassword'
         })
      }
   }
   catch
   {
      throw
      break
   }
	
   $paramBackupToAADBitLockerKeyProtector = @{
      MountPoint    = $env:systemdrive
      ErrorAction   = $STP
      WarningAction = $SCT
   }
	
   if ($keyID.Count -cgt 1) 
   {
      for ($i = 0; $i -le $keyID.Count; $i++)
      {
         if ($keyID[$i])
         {
            Write-Verbose -Message ('Start Backup BitLockerKey {0}' -f $i)

            try
            {
               $null = (BackupToAAD-BitLockerKeyProtector -KeyProtectorId $keyID.KeyProtectorId[$i] @paramBackupToAADBitLockerKeyProtector)

               Write-Verbose -Message ('Done Backup BitLockerKey {0}' -f $i)
            }
            catch
            {
               Write-Warning -Message ('Unable to Backup BitLockerKey {0}' -f $i)
            }
         }
      }
   }
   else 
   {
      Write-Verbose -Message 'Start Backup BitLockerKey'

      try
      {
         $null = (BackupToAAD-BitLockerKeyProtector -KeyProtectorId $keyID.KeyProtectorId @paramBackupToAADBitLockerKeyProtector)

         Write-Verbose -Message 'Done Backup BitLockerKey'
      }
      catch
      {
         Write-Warning -Message 'Unable to Backup BitLockerKey'
      }
   }
}
