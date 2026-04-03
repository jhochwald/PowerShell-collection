#requires -Version 2.0 -Modules SecureBoot -RunAsAdministrator

<#
      Secure Boot 2023 certificate remediation
      Detection-UEFICA2023
#>

try
{
   $paramGetSecureBootUEFI = @{
      Name          = 'db'
      ErrorAction   = 'Stop'
      WarningAction = 'SilentlyContinue'
   }
   if ([Text.Encoding]::ASCII.GetString((Get-SecureBootUEFI @paramGetSecureBootUEFI).Bytes) -match 'UEFI CA 2023')
   {
      Write-Host -Object 'UEFI CA 2023 found'
      
      exit 0
   }
   else
   {
      Write-Host -Object 'UEFI CA 2023 NOT found'
      
      exit 1
   }
}
catch
{
   exit 1
}

# Default
exit 0
