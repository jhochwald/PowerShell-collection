function Resolve-DNSHost
{
  <#
      .SYNOPSIS
      Resolve DNS hostname to IP and reverse

      .DESCRIPTION
      This function resolves DNS hostname to IP and  the other way around (reverse)

      .PARAMETER HostEntry
      Hostname (Single, or multiple) to test.

      .EXAMPLE
      PS C:\> Resolve-DNSHost -HostEntry www.hochwald.net

      HostName         IPAddress
      --------         ---------
      www.hochwald.net {104.28.0.64, 104.28.1.64, 2606:4700:30::681c:140, 2606:4700:30::681c:40}

      This function resolves DNS hostname to IP and  the other way around (reverse)

      .EXAMPLE
      PS C:\> Resolve-DNSHost -HostEntry 'www.hochwald.net','autodiscover.hochwald.net'

      HostName                  IPAddress
      --------                  ---------
      www.hochwald.net          {104.28.0.64, 104.28.1.64, 2606:4700:30::681c:140, 2606:4700:30::681c:40}
      autodiscover.hochwald.net {40.101.88.8, 40.101.88.184, 52.97.151.104, 40.101.60.24...}

      This function resolves DNS hostname to IP and  the other way around (reverse)

      .OUTPUTS
      psobject

      .NOTES
      Refactored of Resolve-Host.Ps1 by @PrateekKumarSingh

      .LINK
      Original:
      https://gist.github.com/PrateekKumarSingh/586f2d3d43f7e8cb07ce

      .LINK
      Dns Class (system.net.dns):
      https://docs.microsoft.com/de-de/dotnet/api/system.net.dns

      .INPUTS
      String
  #>
  [CmdletBinding(ConfirmImpact = 'None')]
  [OutputType([psobject])]
  param
  (
    [Parameter(Mandatory,
        ValueFromPipeline,
        ValueFromPipelineByPropertyName,
        Position = 0,
    HelpMessage = 'Hostname (Single, or multiple) to test.')]
    [ValidateNotNullOrEmpty()]
    [String[]]
    $HostEntry
  )

  begin
  {
    # Cleanup
    $Obj = @()
    $Object = @()
  }

  process
  {
    $HostEntry | ForEach-Object -Process {
      $Obj += New-Object -TypeName psobject -Property @{
        HostName  = $_
        IPAddress = $([Net.Dns]::gethostentry($_).AddressList.IPAddressToString)
      }
    }

    # Append
    $Object = ($Obj | Select-Object -Property Hostname, IPAddress)
  }

  end
  {
    # Dump to the console
    $Object
  }
}
