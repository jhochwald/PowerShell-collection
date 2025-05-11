#requires -Version 1.0

<#
      .SYNOPSIS
      Detection for Entra Global Secure Access (GSA) - Private Access automatic network detection
   
      .DESCRIPTION
      Detection for Entra Global Secure Access (GSA) - Private Access automatic network detection
   
      .EXAMPLE
      PS C:\> .\Detection-GlobalSecureAccessConnectedLocal.ps1

      .LINK
      https://github.com/KnudsenMorten/EntraGSA_InternalNetworkDetection_Performance/blob/main/EntraGSA_internal_network_Intune_detectionscript.ps1

      .LINK
      https://mortenknudsen.net/?p=3090#EntraGSAv2

      .NOTES
      This is based on the idea of Morten Knudsen
      It is tested with the Global Secure Access client for Windows version 2.18.62
#>
[CmdletBinding(ConfirmImpact = 'None')]
[OutputType([string])]
param ()

begin
{
   # Global Variables
   $RegPath = 'HKCU:\SOFTWARE\EntraGSA_NetworkDetection'
   $RegKey_LastDetection = 'EntraGSA_DetectionScript_Last_Run'
}

process
{
   # Create initial reg-path stucture in registry
   if (!(Test-Path -Path $RegPath -ErrorAction SilentlyContinue))
   {
      $paramNewItem = @{
         Path        = $RegPath
         Force       = $true
         Confirm     = $false
         ErrorAction = 'SilentlyContinue'
      }
      $null = (New-Item @paramNewItem)
      $paramNewItem = $null
   }
   
   #  Set last run value in registry
   $paramNewItemProperty = @{
      Path         = $RegPath
      Name         = $RegKey_LastDetection
      Value        = (Get-Date)
      PropertyType = 'STRING'
      Force        = $true
      Confirm      = $false
      ErrorAction  = 'SilentlyContinue'
   }
   $null = (New-ItemProperty @paramNewItemProperty)
   $paramNewItemProperty = $null
}

end
{
   # We force Intune detection script to disable to force remediation script to run, where we have the checks
   exit 1
}
