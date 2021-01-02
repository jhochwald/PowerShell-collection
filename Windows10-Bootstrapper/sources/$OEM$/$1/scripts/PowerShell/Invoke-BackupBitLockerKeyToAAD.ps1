#requires -Version 2.0 -RunAsAdministrator

<#
   .SYNOPSIS
   Backup all BitLocker Recovery Key to AzureAD

   .DESCRIPTION
   Backup all BitLocker Recovery Key to AzureAD

   .EXAMPLE
   PS C:\> .\Invoke-BackupBitLockerKeyToAAD.ps1

   .NOTES
   Version 1.0.0

   The multiple recovery passwords part is still unstable
#>
[CmdletBinding(ConfirmImpact = 'None')]
param ()

begin
{
   Write-Output -InputObject 'Backup all BitLocker Recovery Key to AzureAD'

   $SCT = 'SilentlyContinue'
   $STP = 'Stop'

   if (Get-Command -Name 'Set-MpPreference' -ErrorAction $SCT)
   {
      $null = (Set-MpPreference -EnableControlledFolderAccess Disabled -Force -ErrorAction $SCT)
   }

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
         $paramGetBitLockerVolume = @{
            MountPoint    = $env:systemdrive
            ErrorAction   = $STP
            WarningAction = $SCT
         }
         $keyID = (Get-BitLockerVolume @paramGetBitLockerVolume | Select-Object -ExpandProperty keyprotector | Where-Object -FilterScript {
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
               $paramBackupToAADBitLockerKeyProtector = @{
                  KeyProtectorId = $keyID.KeyProtectorId[$i]
                  MountPoint     = $env:systemdrive
                  ErrorAction    = $STP
                  WarningAction  = $SCT
               }
               $null = (BackupToAAD-BitLockerKeyProtector @paramBackupToAADBitLockerKeyProtector)

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
         $paramBackupToAADBitLockerKeyProtector = @{
            KeyProtectorId = $keyID.KeyProtectorId
            MountPoint     = $env:systemdrive
            ErrorAction    = $STP
            WarningAction  = $SCT
         }
         $null = (BackupToAAD-BitLockerKeyProtector @paramBackupToAADBitLockerKeyProtector)

         Write-Verbose -Message 'Done Backup BitLockerKey'
      }
      catch
      {
         Write-Warning -Message 'Unable to Backup BitLockerKey'
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

#region LICENSE
<#
   BSD 3-Clause License

   Copyright (c) 2021, enabling Technology
   All rights reserved.

   Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
   1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
   2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
   3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>
#endregion LICENSE

#region DISCLAIMER
<#
   DISCLAIMER:
   - Use at your own risk, etc.
   - This is open-source software, if you find an issue try to fix it yourself. There is no support and/or warranty in any kind
   - This is a third-party Software
   - The developer of this Software is NOT sponsored by or affiliated with Microsoft Corp (MSFT) or any of its subsidiaries in any way
   - The Software is not supported by Microsoft Corp (MSFT)
   - By using the Software, you agree to the License, Terms, and any Conditions declared and described above
   - If you disagree with any of the Terms, and any Conditions declared: Just delete it and build your own solution
#>
#endregion DISCLAIMER
