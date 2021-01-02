#requires -Version 3.0 -Modules UniFiTooling
<#
      .SYNOPSIS
      Update the UniFi with the latest Exchange Online Endpoints

      .DESCRIPTION
      Update existing UniFi Firewall Groups with the latest Exchange Online Endpoints. This script supports IPv4 and IPv6.

      .EXAMPLE
      PS C:\> .\UpdateUniFiWithLatestExchangeOnlineEndpoints.ps1
      Update the UniFi with the latest Exchange Online Endpoints

      .NOTES
      Just a use case demo

      This script updates the following USG Firewall Groups:
      - ExchangeOnline-Sumission-IPv6
      - ExchangeOnline-Sumission-IPv4
      - ExchangeOnline-SMTP-IPv6
      - ExchangeOnline-SMTP-IPv4

      The Groups are hardcoded in this sample script!

      The script use my Get-Office365Endpoints to get the latest Exchange Online Endpoints from Microsoft.

      .LINK
      Get-Office365Endpoints
#>
[CmdletBinding(ConfirmImpact = 'None')]
param ()

begin
{
   # Create new objects
   $NewExo587EndpointsIPv4 = @()
   $NewExo587EndpointsIPv6 = @()
   $NewExo25EndpointsIPv4 = @()
   $NewExo25EndpointsIPv6 = @()

   # Login
   $null = (Invoke-UniFiApiLogin)
   
   # Safe ProgressPreference and Setup SilentlyContinue for the function
   $ExistingProgressPreference = ($ProgressPreference)
   $ProgressPreference = 'SilentlyContinue'
}

process
{
   try
   {
      # If you like to enforce the update, set SkipVersionCheck to $true
      $paramGetOffice365Endpoints = @{
         Instance         = 'Worldwide'
         Services         = 'Exchange'
         SkipVersionCheck = $false
      }
      $NewOffice365Endpoints = ((Get-Office365Endpoints @paramGetOffice365Endpoints) | Where-Object -FilterScript {
            ($PSItem.required -eq $true) -and (($PSItem.tcpPorts -eq '587') -or ($PSItem.tcpPorts -eq '25')) -and ($PSItem.ip -ne $null)
      } | Select-Object -Property ip, tcpPorts)

      $NewExo587Endpoints = ($NewOffice365Endpoints | Where-Object -FilterScript {
            ($PSItem.tcpPorts -eq '587')
      } | Select-Object -Property ip)

      foreach ($item in $NewExo587Endpoints.ip)
      {
         # Split IPv6 and IPv4
         if ($item -match ':')
         {
            $NewExo587EndpointsIPv6 = $NewExo587EndpointsIPv6 + $item
         }
         elseif ($item -match '.')
         {
            $NewExo587EndpointsIPv4 = $NewExo587EndpointsIPv4 + $item
         }
      }

      # Create a Ubiquiti UniFi compatible IPv6 List
      $NewExo587EndpointsIPv6 = ($NewExo587EndpointsIPv6 | Sort-Object -Unique | Invoke-UniFiCidrWorkaround -6)

      # Modify the existing group
      $null = (Set-UnifiFirewallGroup -UnfiFirewallGroup 'ExchangeOnline-Sumission-IPv6' -UnifiCidrInput $NewExo587EndpointsIPv6)

      # Create a Ubiquiti UniFi compatible IPv4 List
      $NewExo587EndpointsIPv4 = ($NewExo587EndpointsIPv4 | Sort-Object -Unique | Invoke-UniFiCidrWorkaround)

      # Modify the existing group
      $null = (Set-UnifiFirewallGroup -UnfiFirewallGroup 'ExchangeOnline-Sumission-IPv4' -UnifiCidrInput $NewExo587EndpointsIPv4)

      $NewExo25Endpoints = ($NewOffice365Endpoints | Where-Object -FilterScript {
            ($PSItem.tcpPorts -eq '25')
      } |  Select-Object -Property ip)

      # Create new objects

      foreach ($item in $NewExo25Endpoints.ip)
      {
         # Split IPv6 and IPv4
         if ($item -match ':')
         {
            $NewExo25EndpointsIPv6 = $NewExo25EndpointsIPv6 + $item
         }
         elseif ($item -match '.')
         {
            $NewExo25EndpointsIPv4 = $NewExo25EndpointsIPv4 + $item
         }
      }

      # Create a Ubiquiti UniFi compatible IPv6 List
      $NewExo25EndpointsIPv6 = ($NewExo25EndpointsIPv6 | Sort-Object -Unique | Invoke-UniFiCidrWorkaround -6)

      # Modify the existing group
      $null = (Set-UnifiFirewallGroup -UnfiFirewallGroup 'ExchangeOnline-SMTP-IPv6' -UnifiCidrInput $NewExo25EndpointsIPv6)

      # Create a Ubiquiti UniFi compatible IPv4 List
      $NewExo25EndpointsIPv4 = ($NewExo25EndpointsIPv4 | Sort-Object -Unique | Invoke-UniFiCidrWorkaround)

      # Modify the existing group
      $null = (Set-UnifiFirewallGroup -UnfiFirewallGroup 'ExchangeOnline-SMTP-IPv4' -UnifiCidrInput $NewExo25EndpointsIPv4)
   }
   catch
   {
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
      Write-Warning -Message $info
   }
}

end
{
   # Logoff
   $null = (Invoke-UniFiApiLogout)
   
   # Restore ProgressPreference
   $ProgressPreference = $ExistingProgressPreference
}
