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
      Quick and relative dirty solution for a challange I had in the last couple of days
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
         $PSItem.VolumeType -eq 'OperatingSystem'
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

#region LICENSE
<#
   BSD 3-Clause License

   Copyright (c) 2022, enabling Technology
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
   - If you disagree with any of the terms, and any conditions declared: Just delete it and build your own solution
#>
#endregion DISCLAIMER
