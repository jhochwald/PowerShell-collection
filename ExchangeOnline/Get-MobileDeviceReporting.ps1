#requires -Version 3.0 -Modules ExchangeOnlineManagement
<#
   .SYNOPSIS
      Get a basic report of Mobile Devices

   .DESCRIPTION
      Get a basic report of Mobile Devices connected to the Microsoft 365 Tenant

   .EXAMPLE
      PS C:\> .\Get-MobileDeviceReporting.ps1

   .LINK
      Connect-ExchangeOnline

   .LINK
      Get-MobileDevice

   .LINK
      Get-MobileDeviceStatistics

   .NOTES
      Nothing fancy! Only a basic report as CSV
#>
[CmdletBinding(ConfirmImpact = 'None')]
param ()

begin
{
   # Cleanup
   $Stats = $null
   $DeviceStats = $null
   $Report = $null
   $MobileDeviceList = $null

   # Garbage Collection
   [GC]::Collect()

   try
   {
      $paramConnectExchangeOnline = @{
         ShowBanner              = $true
         BypassMailboxAnchoring  = $true
         ExchangeEnvironmentName = 'O365Default'
         ErrorAction             = 'SilentlyContinue'
      }
      $null = (Connect-ExchangeOnline @paramConnectExchangeOnline)
   }
   catch
   {
      #region ErrorHandler
      # get error record
      [Management.Automation.ErrorRecord]$e = $_

      # retrieve information about runtime error
      $info = [PSCustomObject]@{
         Exception = $e.Exception.Message
         Reason    = $e.CategoryInfo.Reason
         Target    = $e.CategoryInfo.TargetName
         Script    = $e.InvocationInfo.ScriptName
         Line      = $e.InvocationInfo.ScriptLineNumber
         Column    = $e.InvocationInfo.OffsetInLine
      }

      # output information. Post-process collected info, and log info (optional)
      $info | Out-String | Write-Verbose

      $paramWriteError = @{
         Message      = $e.Exception.Message
         ErrorAction  = 'Stop'
         Exception    = $e.Exception
         TargetObject = $e.CategoryInfo.TargetName
      }
      Write-Error @paramWriteError

      # Only here to catch a global ErrorAction overwrite
      exit 1
      #endregion ErrorHandler
   }

   # Create new object
   $Report = @()
}


process
{
   # Get all mobile devices in the Microsoft 365 tenant
   <#
      Option: -ActiveSync
      Description: The ActiveSync switch filters the results by Exchange ActiveSync devices.
      Source: https://docs.microsoft.com/en-us/powershell/module/exchange/get-mobiledevice?view=exchange-ps
   #>
   try
   {
      $paramGetMobileDevice = @{
         ResultSize  = 'unlimited'
         ErrorAction = 'Stop'
      }
      $MobileDeviceList = (Get-MobileDevice @paramGetMobileDevice)
   }
   catch
   {
      #region ErrorHandler
      # get error record
      [Management.Automation.ErrorRecord]$e = $_

      # retrieve information about runtime error
      $info = [PSCustomObject]@{
         Exception = $e.Exception.Message
         Reason    = $e.CategoryInfo.Reason
         Target    = $e.CategoryInfo.TargetName
         Script    = $e.InvocationInfo.ScriptName
         Line      = $e.InvocationInfo.ScriptLineNumber
         Column    = $e.InvocationInfo.OffsetInLine
      }

      # output information. Post-process collected info, and log info (optional)
      $info | Out-String | Write-Verbose

      $paramWriteError = @{
         Message      = $e.Exception.Message
         ErrorAction  = 'Stop'
         Exception    = $e.Exception
         TargetObject = $e.CategoryInfo.TargetName
      }
      Write-Error @paramWriteError

      # Only here to catch a global ErrorAction overwrite
      exit 1
      #endregion ErrorHandler
   }

   # Loop over the List
   foreach ($Device in $MobileDeviceList)
   {
      $Stats = $null
      $DeviceStats = $null

      try
      {
         $paramGetMobileDeviceStatistics = @{
            Identity    = $Device.Guid.toString()
            ErrorAction = 'Stop'
         }
         $Stats = (Get-MobileDeviceStatistics @paramGetMobileDeviceStatistics)

         $DeviceStats = [PSCustomObject]@{
            Identity             = $Device.Identity -replace '\\.+'
            DeviceType           = $Device.DeviceType
            DeviceOS             = $Device.DeviceOS
            DeviceUserAgent      = $Stats.DeviceUserAgent
            DeviceModel          = $Stats.DeviceModel
            ClientType           = $Stats.ClientType
            FirstSyncTime        = $Stats.FirstSyncTime
            LastSuccessSync      = $Stats.LastSuccessSync
            LastSyncAttemptTime  = $Stats.LastSyncAttemptTime
            LastPolicyUpdateTime = $Stats.LastPolicyUpdateTime
            LastPingHeartbeat    = $Stats.LastPingHeartbeat
         }

         $Report += $DeviceStats
      }
      catch
      {
         #region ErrorHandler
         # get error record
         [Management.Automation.ErrorRecord]$e = $_

         # retrieve information about runtime error
         $info = [PSCustomObject]@{
            Exception = $e.Exception.Message
            Reason    = $e.CategoryInfo.Reason
            Target    = $e.CategoryInfo.TargetName
            Script    = $e.InvocationInfo.ScriptName
            Line      = $e.InvocationInfo.ScriptLineNumber
            Column    = $e.InvocationInfo.OffsetInLine
         }

         # output information. Post-process collected info, and log info (optional)
         $info | Out-String | Write-Verbose

         Write-Warning -Message $info.Exception
         #endregion ErrorHandler
      }
   }

   # Create a Timestamp (check if this is OK for you)
   $TimeStamp = (Get-Date -Format yyyyMMdd_HHmmss)

   # Export the CSV Report
   try
   {
      $paramExportCsv = @{
         Path              = ('.\MobileDeviceReport' + $TimeStamp + '.csv')
         Force             = $true
         Encoding          = 'UTF8'
         Delimiter         = ';'
         NoTypeInformation = $true
         ErrorAction       = 'Stop'
      }
      ($Report | Export-Csv @paramExportCsv)
   }
   catch
   {
      #region ErrorHandler
      # get error record
      [Management.Automation.ErrorRecord]$e = $_

      # retrieve information about runtime error
      $info = [PSCustomObject]@{
         Exception = $e.Exception.Message
         Reason    = $e.CategoryInfo.Reason
         Target    = $e.CategoryInfo.TargetName
         Script    = $e.InvocationInfo.ScriptName
         Line      = $e.InvocationInfo.ScriptLineNumber
         Column    = $e.InvocationInfo.OffsetInLine
      }

      # output information. Post-process collected info, and log info (optional)
      $info | Out-String | Write-Verbose

      $paramWriteError = @{
         Message      = $e.Exception.Message
         ErrorAction  = 'Stop'
         Exception    = $e.Exception
         TargetObject = $e.CategoryInfo.TargetName
      }
      Write-Error @paramWriteError
      #endregion ErrorHandler
   }
   finally
   {
      # Disconnect from Exchange Online
      $paramDisconnectExchangeOnline = @{
         Confirm     = $false
         ErrorAction = 'SilentlyContinue'
      }
      $null = (Disconnect-ExchangeOnline @paramDisconnectExchangeOnline)

      # Cleanup
      $Stats = $null
      $DeviceStats = $null
      $Report = $null
      $MobileDeviceList = $null

      # Garbage Collection
      [GC]::Collect()
   }
}

#region LICENSE
<#
      BSD 3-Clause License
      Copyright (c) 2021,  enabling Technology
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
