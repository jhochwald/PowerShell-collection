#requires -Version 3.0 -Modules AzureAD

<#
      .SYNOPSIS
      Remove all AzureAD devices without an assigned owner

      .DESCRIPTION
      Remove all AzureAD devices without an assigned owner

      .EXAMPLE
      PS C:\> .\Remove-AzureADDevicesWithNoOwner.ps1

      Remove all AzureAD devices without an assigned owner

      .LINK
      Get-AzureADDevice

      .LINK
      Set-AzureADDevice

      .LINK
      Remove-AzureADDevice

      .NOTES
      Cleanup stuff
#>
[CmdletBinding(ConfirmImpact = 'Low')]
param ()

process
{
   $paramGetAzureADDevice = @{
      All           = $true
      ErrorAction   = 'SilentlyContinue'
      WarningAction = 'SilentlyContinue'
   }
   $null = ((Get-AzureADDevice @paramGetAzureADDevice) | ForEach-Object -Process {
         $paramGetAzureADDevice = @{
            ObjectId      = $PSItem.ObjectId
            ErrorAction   = 'SilentlyContinue'
            WarningAction = 'SilentlyContinue'
         }
         $paramGetAzureADDeviceRegisteredOwner = @{
            ErrorAction   = 'SilentlyContinue'
            WarningAction = 'SilentlyContinue'
         }
         if (-not (Get-AzureADDevice @paramGetAzureADDevice | Get-AzureADDeviceRegisteredOwner @paramGetAzureADDeviceRegisteredOwner))
         {
            # OK, this device does NOT have an owner assigned
            try
            {
               # OPTIONAL: Disable the device (just to make it correct)
               $paramSetAzureADDevice = @{
                  ObjectId       = $PSItem.ObjectId
                  AccountEnabled = $false
                  IsCompliant    = $false
                  IsManaged      = $false
                  Verbose        = $true
                  ErrorAction    = 'SilentlyContinue'
                  WarningAction  = 'SilentlyContinue'
               }
               $null = (Set-AzureADDevice @paramSetAzureADDevice)
            }
            catch
            {
               # AzureAD commands seems to ignore the ErrorAction parameter
               Write-Verbose -Message 'OK'
            }

            try
            {
               # Remove the device to get a clean device list
               $paramRemoveAzureADDevice = @{
                  ObjectId      = $PSItem.ObjectId
                  Verbose       = $true
                  ErrorAction   = 'SilentlyContinue'
                  WarningAction = 'SilentlyContinue'
               }
               $null = (Remove-AzureADDevice @paramRemoveAzureADDevice)
            }
            catch
            {
               # AzureAD commands seems to ignore the ErrorAction parameter
               Write-Verbose -Message 'OK'
            }
         }
      })
}