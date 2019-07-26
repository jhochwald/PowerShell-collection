#requires -Version 1.0

<#
    .SYNOPSIS
    Skype for Business should use Proxy Server

    .DESCRIPTION
    Skype for Business should use Proxy Server to sign in instead of trying a direct connection.
    Works with Skype for Business 2015 and 2016 and should work with Lync 1013 as well.

    .EXAMPLE
    PS C:\> .\Set-Skype4BProxyUsage.ps1

    .NOTES
    Please note: This is a per user setting!

    SIP is not used between Clients (aka P2P or Cleint to Client).
    It wil be used between Client and Server and/or Server and Server.
    Media Bypass will be used for RTP media between Clients (when possible)

    .LINK
    https://support.microsoft.com/en-us/help/3207112/skype-for-business-should-use-proxy-server-to-sign-in-instead-of-tryin

    .LINK
    https://blogs.technet.microsoft.com/uclobby/2016/12/08/enabling-lyncsfb-client-to-use-proxy-server-for-sip-traffic-instead-of-trying-direct-connection/
#>
[CmdletBinding()]
param ()

$parameters = @{
  Path          = 'HKCU:\Software\Microsoft\UCCPlatform\Lync'
  Name          = 'EnableDetectProxyForAllConnections'
  PropertyType  = 'DWORD'
  Value         = '1'
  Force         = $true
  ErrorAction   = 'Stop'
  WarningAction = 'SilentlyContinue'
}

try
{
  $null = (New-ItemProperty @parameters)
  Write-Verbose -Message 'New value set.'
}
catch
{
  try
  {
    $null = (Set-ItemProperty @parameters)
    Write-Verbose -Message 'Existing value modified.'
  }
  catch
  {
    Write-Warning -Message 'Unable to create/set the value.'
  }
}
