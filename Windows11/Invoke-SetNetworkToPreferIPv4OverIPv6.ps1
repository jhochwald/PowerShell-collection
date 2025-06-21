#requires -Version 5.0 -RunAsAdministrator
<#
      .SYNOPSIS
      Prioritising IPv4 over IPv6 on Windows

      .DESCRIPTION
      Prioritising IPv4 over IPv6 on Windows,
      this recommended instead of disabling IPv6

      .EXAMPLE
      PS C:\> .\Invoke-SetNetworkToPreferIPv4OverIPv6.ps1
      Prioritising IPv4 over IPv6 on Windows, recommended instead of disabling IPv6.

      .EXAMPLE
      PS C:\> .\Invoke-SetNetworkToPreferIPv4OverIPv6.ps1 -Verbose
      Prioritising IPv4 over IPv6 on Windows, recommended instead of disabling IPv6.

      .EXAMPLE
      PS C:\> .\Invoke-SetNetworkToPreferIPv4OverIPv6.ps1 -WhatIf
      Simmulate the Prioritising IPv4 over IPv6, but do NOT change anything

      .LINK
      https://learn.microsoft.com/en-us/troubleshoot/windows-server/networking/configure-ipv6-in-windows

      .NOTES
      I work from nearly anywhere! So I decided to use Microsoft Global Secure Access as a Zero Trust solution and "VPN replacement".
      I use it to access on premises systems with a least privilege approach, verify explicitly!
      I also always assume breach, because many locations and networks are unsecure (at least in my opinion).
      And I want some filters applied to my regular internet access, to prevent accidentally access to dangerous resources!

      I Use  Microsoft Global Secure Access for:
      - Microsoft Entra Internet Access - via Microsoft's Security Service Edge (SSE) [Internet access with some filetrs applied]
      - Microsoft Entra Internet Access for Microsoft Services - via Microsoft's Security Service Edge (SSE) [Microsoft 365 workload access]
      - Microsoft Entra Private Access - via on Premises Agents to access local recources verify explicitly and limited

      More about Microsoft Global Secure Access:
      https://learn.microsoft.com/en-us/entra/global-secure-access/overview-what-is-global-secure-access

      At this time, IPv4 is preferred over IPv6:
      https://learn.microsoft.com/en-us/entra/global-secure-access/resource-faq#does-global-secure-access-support-ipv6-

      But I don't want to disable it completly (whish is NOT recommended), so I came up with this approach!
#>
[CmdletBinding(ConfirmImpact = 'Low', SupportsShouldProcess)]
[OutputType([string])]
param ()

begin
{
   $RegistryPath = 'Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters'
}

process
{
   #region PathCheck
   # Check if the Registry Path exists
   $paramTestPath = @{
      LiteralPath = $RegistryPath
      ErrorAction = 'SilentlyContinue'
   }
   if (-not (Test-Path @paramTestPath))
   {
      # Create the Registry Path
      if ($pscmdlet.ShouldProcess($RegistryPath, 'Create'))
      {
         $paramNewItem = @{
            Path        = $RegistryPath
            Force       = $true
            Confirm     = $false
            ErrorAction = 'Stop'
         }
         $null = (New-Item @paramNewItem)
         $paramNewItem = $null
      }
   }
   else
   {
      Write-Verbose -Message ('The path ''{0}'' exists.' -f $RegistryPath)
   }
   $paramTestPath = $null
   #endregion PathCheck
   
   #region PreferIPv4overIPv6
   # Check if the value fits
   $paramGetItemPropertyValue = @{
      ErrorAction = 'SilentlyContinue'
      Path        = $RegistryPath
      Name        = 'DisabledComponents'
   }
   if ((Get-ItemPropertyValue @paramGetItemPropertyValue) -ne '32')
   {
      <#
            Set it to Prefer IPv4 over IPv6 (Decimal 32 / Hexadecimal 0x20 / Binary xx1x xxxx)
            Recommended instead of disabling IPv6.
      #>
      if ($pscmdlet.ShouldProcess('Prioritising IPv4 over IPv6 on Windows', 'True'))
      {
         $paramNewItemProperty = @{
            Path         = $RegistryPath
            Name         = 'DisabledComponents'
            Value        = '32'
            PropertyType = 'DWord'
            Force        = $true
            Confirm      = $false
            ErrorAction  = 'Stop'
         }
         $null = (New-ItemProperty @paramNewItemProperty)
         $paramNewItemProperty = $null
      }
   }
   else
   {
      Write-Verbose -Message ('The value of ''{0}'' do not need any changes.' -f $RegistryPath)
   }
   $paramGetItemPropertyValue = $null
   #endregion PreferIPv4overIPv6
}

end
{
   $RegistryPath = $null
}
