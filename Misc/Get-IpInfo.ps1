<#
      .SYNOPSIS
      Get all local IP addresses

      .DESCRIPTION
      Get all local IP addresses, just the addresses

      .EXAMPLE
      PS C:\> .\Get-IpInfo.ps1

      Get all local IP addresses, just the addresses

      .NOTES
      Quick an dirty function that uses Net.DNS to gather the information about the IP Addresses
#>
[CmdletBinding(ConfirmImpact = 'None')]
[OutputType([psobject])]
param ()

begin {
   #Cleanup
   $IpAddressInfo = $null
}

process {
   # Get the Info using Net.Dns
   $IpAddressInfo = @(
      (([Net.DNS]::GetHostAddresses([Net.Dns]::GetHostByName(($env:COMPUTERNAME)).HostName) | Where-Object -FilterScript {
               $_.IsIPv6LinkLocal -eq $false
         }).IPAddressToString | Where-Object -FilterScript {
            $_ -ne '::1'
      })
   )
}

end {
   # Dump the Info
   $IpAddressInfo

   #Cleanup
   $IpAddressInfo = $null
}