#requires -Version 2.0 -Modules ScheduledTasks, SecureBoot -RunAsAdministrator

<#
      Secure Boot 2023 certificate remediation
      Remediation-UEFICA2023
#>

try
{
   $paramGetSecureBootUEFI = @{
      Name          = 'db'
      ErrorAction   = 'Stop'
      WarningAction = 'SilentlyContinue'
   }
   if (!([Text.Encoding]::ASCII.GetString((Get-SecureBootUEFI @paramGetSecureBootUEFI).Bytes) -match 'UEFI CA 2023'))
   {
      # Remediation kick in
      $paramNewItemProperty = @{
         Path          = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot'
         Name          = 'AvailableUpdates'
         Value         = 0x5944
         PropertyType  = 'DWord'
         Force         = $true
         Confirm       = $false
         ErrorAction   = 'Stop'
         WarningAction = 'SilentlyContinue'
      }
      $null = (New-ItemProperty @paramNewItemProperty)
      $paramNewItemProperty = $null
      
      $paramScheduledTask = @{
         TaskName      = 'Secure-Boot-Update'
         TaskPath      = '\Microsoft\Windows\PI\'
         WarningAction = 'SilentlyContinue'
      }
      
      if (Get-ScheduledTask @paramScheduledTask -ErrorAction SilentlyContinue)
      {
         $null = (Start-ScheduledTask @paramScheduledTask -ErrorAction Stop)
      }
      
      exit 0
   }
}
catch
{
   exit 1
}

# Default
exit 0
