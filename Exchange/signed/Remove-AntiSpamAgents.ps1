#requires -Version 1.0

<#
    .SYNOPSIS
    Uninstalls the old and retired Antispam Agents from an Exchange Server
	
    .DESCRIPTION
    Microsoft announced that they deprecated the support for the SmartScreen Antispam content filters for Exchange Servers. This script uninstalls the old an retired SmartScreen Antispam Agents from the local Exchange Server.
    This is an easy to use and light weight replacement for Uninstall-AntiSpamAgents.ps1 from the \Scripts of your Exchange Installation, it will remove just the dead parts and leave the rest as it is. Some find that it might be better to leave the rest intact.

    .EXAMPLE
    PS C:\> Remove-AntiSpamAgents

    .NOTES
    Find a suitable an solid replacement solution for your email hygiene. This could be any 3rd party solution on premise or cloud. Never use email without any good email hygiene!

    If you want, you might run the Uninstall-AntiSpamAgents.ps1 from the \Scripts folder created by Setup during Exchange installation. It removes erything related to the AntiSpamAgents.

    Taken from the links below.

    .LINK
    https://blogs.technet.microsoft.com/exchange/2016/09/01/deprecating-support-for-smartscreen-in-outlook-and-exchange/

    .LINK
    https://blogs.technet.microsoft.com/exchange/2017/03/23/exchange-server-edge-support-on-windows-server-2016-update/
#>
[CmdletBinding(ConfirmImpact = 'Medium',
SupportsShouldProcess = $true)]
param ()

begin
{
  # Constants
  $STP = 'SilentlyContinue'
	
  # Agents to remove
  $TransportAgentsToRemove = 'Content Filter Agent', 'Sender Id Agent', 'Protocol Analysis Agent'
}

process
{
  # Loop over the List
  foreach ($TransportAgentToRemove in $TransportAgentsToRemove)
  {
    # Do we have the agent we would like to remove?
    if (Get-TransportAgent -Identity $TransportAgentToRemove -ErrorAction $STP -WarningAction $STP)
    {
      Write-Verbose -Message "Try to remove $TransportAgentToRemove"
			
      try
      {
        # Do it, or dry run it?
        if ($pscmdlet.ShouldProcess("$TransportAgentToRemove", 'Remove TransportAgent'))
        {
          # Remove it...
          $paramUninstallTransportAgent = @{
            Identity      = $TransportAgentToRemove
            ErrorAction   = $STP
            WarningAction = $STP
            Confirm       = $false
          }
          $null = (Uninstall-TransportAgent @paramUninstallTransportAgent)
        }
      }
      catch
      {
        # Whoopsss
        Write-Warning -Message "Unable to remove $TransportAgentToRemove"
      }
			
      Write-Verbose -Message "$TransportAgentToRemove was removed"
    }
    else
    {
      Write-Verbose -Message "Sorry, $TransportAgentToRemove was not found..."
    }
  }
	
}

#region CHANGELOG
<#
  Soon
#>
#endregion CHANGELOG

#region LICENSE
<#
  LICENSE:

  Copyright 2018 by enabling Technology - http://enatec.io

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

  By using the Software, you agree to the License, Terms and Conditions above!
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
  - If you disagree with any of the Terms, and any Conditions declared: Just delete it and build your own solution
#>
#endregion DISCLAIMER

# SIG # Begin signature block
# MIIO6AYJKoZIhvcNAQcCoIIO2TCCDtUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUY5dkiD/1oohUU3uiwb6vNIwK
# llagggxZMIIFLzCCBBegAwIBAgIVAJ0OATHCEQYLKXlMtSRrPmYvJ3aiMA0GCSqG
# SIb3DQEBCwUAMD8xCzAJBgNVBAYTAkdCMREwDwYDVQQKEwhBc2NlcnRpYTEdMBsG
# A1UEAxMUQXNjZXJ0aWEgUHVibGljIENBIDEwHhcNMTkwMTA0MTUzMjA3WhcNMTkw
# MjA0MTUzMjA3WjCBpzELMAkGA1UEBhMCREUxITAfBgkqhkiG9w0BCQEWEmpvZXJn
# QGhvY2h3YWxkLm5ldDEPMA0GA1UECBMGSGVzc2VuMRAwDgYDVQQHEwdNYWludGFs
# MRcwFQYDVQQKEw5Kb2VyZyBIb2Nod2FsZDEgMB4GA1UECxMXT3BlbiBTb3VyY2Ug
# RGV2ZWxvcG1lbnQxFzAVBgNVBAMTDkpvZXJnIEhvY2h3YWxkMIIBIjANBgkqhkiG
# 9w0BAQEFAAOCAQ8AMIIBCgKCAQEAy+erEpBAhw0epCs5yobwm9/nDvCufmCXVxu5
# Gc5CnJ7DoqPNN/mtz5Dv8xTR/QrqvjnP9cEZHqHj2mi75PVa10ODQY8cevWTv0WP
# hB0jmes93ghW/JoMyzX9WeKsIFlfdRhdSD2uFZ4pQ0sLFvfGsUPpZDl6i7tfKoU9
# Ujz/MWaf+ZhtnLQ9xwO6eposgl5BQQSJYOh3Zz5/wHMavU+7/RqWFePo857dgK3v
# mCVfSekpd6inIY5TSHpLRDTiVep5JnmSfTyY+rDowBbQD5RSYKBtRcNfvhqKDcgt
# +57qljipQir6fG69BdosVo7NktTrp/8PtOiZ1+P9GWYU3e3UnwIDAQABo4IBtzCC
# AbMwDgYDVR0PAQH/BAQDAgbAMAwGA1UdEwEB/wQCMAAwPQYIKwYBBQUHAQEEMTAv
# MC0GCCsGAQUFBzABhiFodHRwOi8vb2NzcC5nbG9iYWx0cnVzdGZpbmRlci5jb20w
# gfAGA1UdIASB6DCB5TCB4gYKKwYBBAH8SQEBATCB0zCB0AYIKwYBBQUHAgIwgcMM
# gcBXYXJuaW5nOiBDZXJ0aWZpY2F0ZXMgYXJlIGlzc3VlZCB1bmRlciB0aGlzIHBv
# bGljeSB0byBpbmRpdmlkdWFscyB0aGF0IGhhdmUgbm90IGhhZCB0aGVpciBpZGVu
# dGl0eSBjb25maXJtZWQuIERvIG5vdCB1c2UgdGhlc2UgY2VydGlmaWNhdGVzIGZv
# ciB2YWx1YWJsZSB0cmFuc2FjdGlvbnMuIE5PIExJQUJJTElUWSBJUyBBQ0NFUFRF
# RC4wTAYDVR0fBEUwQzBBoD+gPYY7aHR0cDovL3d3dy5nbG9iYWx0cnVzdGZpbmRl
# ci5jb20vY3Jscy9Bc2NlcnRpYVB1YmxpY0NBMS5jcmwwEwYDVR0lBAwwCgYIKwYB
# BQUHAwMwDQYJKoZIhvcNAQELBQADggEBAIxGRztqVffdY91xmUr4P41HdSRX9lAJ
# wnlu7MSLyJOwFT7OspypFCHSecguJKoDV5LN6vOKcGgpo8T1W5oOsGVfxLVSG21+
# M6DVu1FQVJdyMngqisWj05wk6FZ2W6HdEvfasFeTmCjxRpj7rp6kkOhuLpUxbx6G
# Oax3eYyO+VZnpjdZVuhZYnSY6IR+m4jPjjN6dS8HGLb4rT1kj+HL7Bb7RSoad67y
# lIojwchPqpsfbTbktcqYMUX7Z3QsJmqp14823mUaDaQ9Ru0a3IeFnqVehYSte96g
# X8APvLfCqwdFuIe9ehI5O0ZMkJO4WsDthgSw6mtqm1y5Ihz7Gu1u8dQwggciMIIG
# CqADAgECAgIA5jANBgkqhkiG9w0BAQUFADA9MQswCQYDVQQGEwJHQjERMA8GA1UE
# ChMIQXNjZXJ0aWExGzAZBgNVBAMTEkFzY2VydGlhIFJvb3QgQ0EgMjAeFw0wOTA0
# MjExMjE1MTdaFw0yODA0MTQyMzU5NTlaMD8xCzAJBgNVBAYTAkdCMREwDwYDVQQK
# EwhBc2NlcnRpYTEdMBsGA1UEAxMUQXNjZXJ0aWEgUHVibGljIENBIDEwggEiMA0G
# CSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDPWPIzxLPZHflPEdu447bWvKchN1cu
# e6kMlLPLEvBHWs4hcF4Tg5w+zKP+nr1T1tgwZD+Kbl3EG1KwEfXZCNBO9gRP/v8k
# cl8NrLSqfDT42wpYJms0u6xpNCjM8YVrkheQld6fi/Hfo4rVEEhWeHE5XjSdaLua
# swnz/WQOJ12InjrOxOdu8fvyHVHt64fW07nBMI+Np8nNXQ/rfn8Em19GxgezP826
# lbFX9Jtv5rSKGGUq4A9AAA5EcMB++AZ6tWozF/SbMRk1RL0bBjn6lmnnolWUad8h
# jcHRCfae65imcyCh1Zl3CCK5/Okds+hZ8NIQcJopDi3O7EQ4cxdyQTdlAgMBAAGj
# ggQoMIIEJDAOBgNVHQ8BAf8EBAMCAQYwEgYDVR0TAQH/BAgwBgEB/wIBAjCB8AYD
# VR0gBIHoMIHlMIHiBgorBgEEAfxJAQEBMIHTMIHQBggrBgEFBQcCAjCBwxqBwFdh
# cm5pbmc6IENlcnRpZmljYXRlcyBhcmUgaXNzdWVkIHVuZGVyIHRoaXMgcG9saWN5
# IHRvIGluZGl2aWR1YWxzIHRoYXQgaGF2ZSBub3QgaGFkIHRoZWlyIGlkZW50aXR5
# IGNvbmZpcm1lZC4gRG8gbm90IHVzZSB0aGVzZSBjZXJ0aWZpY2F0ZXMgZm9yIHZh
# bHVhYmxlIHRyYW5zYWN0aW9ucy4gTk8gTElBQklMSVRZIElTIEFDQ0VQVEVELjCC
# ATMGA1UdDgSCASoEggEmMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA
# z1jyM8Sz2R35TxHbuOO21rynITdXLnupDJSzyxLwR1rOIXBeE4OcPsyj/p69U9bY
# MGQ/im5dxBtSsBH12QjQTvYET/7/JHJfDay0qnw0+NsKWCZrNLusaTQozPGFa5IX
# kJXen4vx36OK1RBIVnhxOV40nWi7mrMJ8/1kDiddiJ46zsTnbvH78h1R7euH1tO5
# wTCPjafJzV0P635/BJtfRsYHsz/NupWxV/Sbb+a0ihhlKuAPQAAORHDAfvgGerVq
# Mxf0mzEZNUS9GwY5+pZp56JVlGnfIY3B0Qn2nuuYpnMgodWZdwgiufzpHbPoWfDS
# EHCaKQ4tzuxEOHMXckE3ZQIDAQABMFoGA1UdHwRTMFEwT6BNoEuGSWh0dHA6Ly93
# d3cuYXNjZXJ0aWEuY29tL09ubGluZUNBL2NybHMvQXNjZXJ0aWFSb290Q0EyL0Fz
# Y2VydGlhUm9vdENBMi5jcmwwPQYIKwYBBQUHAQEEMTAvMC0GCCsGAQUFBzABhiFo
# dHRwOi8vb2NzcC5nbG9iYWx0cnVzdGZpbmRlci5jb20wggE3BgNVHSMEggEuMIIB
# KoCCASYwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCWN76e4Nk+poYT
# F/ZK86kH8xZo1X9EFkfzIZ99/OT/pPQLvs30wgYD4uyhRBTFkKGf0dH3HjKz1N9S
# FJud0eqbxtH3YPr8rUjHkxjrX34LxCFWBNoj4T3Fw3LGnTpGeO6xEaEDAdvdInm3
# BJvpG4VWES3Z7SJteaIbkNmqDn0DhRpMFXiNKgZKNWIcJM1ZGW9+OZO7vxUZrOPB
# fceplWg70Torc8TBYL7Pv1/g6kuZCO7Dx1nF6agi9GCIHRkMrcjguIqkg8qSL+KW
# xwWuKi8YHBG4i7vIgvHOKL2lnmdoe63WRAG9wUHb68duwBc1tIAPqam90MQrMyhT
# GzhwI7aDAgMBAAEwDQYJKoZIhvcNAQEFBQADggEBAJSUl6GjE5m6hkpci2WLPoJM
# rG90TALbigGZS1zTYLsIwUxfx0VndhR/YU7dUQf5vFPhzQf9mwm9vidT9Wwd6Wg0
# hmDiT8Lh5y7T4XyqjuMKN3cp7eDFkrSCUhvT8Lg2n/qxeeJMD3ghtFhoyXtI5A/6
# CmPHBkcNMtQZAhORKjpJ41wSa+vH6v1TzC8otw+xuxgyAkO/hRmmmBIgGDuwxKfL
# rdBQRZWeBRmWqH7grQlE0gYYpBFS4FlorwBqjiIDp6FH52OrLS9gLV2f1emxMQAl
# wh3LMBmwvUtTQs++8M8oX2EpXZCIHeoOEFEMbzmEv4I88yooHJxcTL026vcl/1Ix
# ggH5MIIB9QIBATBYMD8xCzAJBgNVBAYTAkdCMREwDwYDVQQKEwhBc2NlcnRpYTEd
# MBsGA1UEAxMUQXNjZXJ0aWEgUHVibGljIENBIDECFQCdDgExwhEGCyl5TLUkaz5m
# Lyd2ojAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkq
# hkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGC
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU8wRWYnMo9yGoT414nFs31c/CfYgwDQYJKoZI
# hvcNAQEBBQAEggEACwzwg/mJXOLGc92HCQFWd5D2D82IU39igSytO257dSYK8BNO
# UC9coi1fmxOu4YEIAEBcybh7b0tYV6FN7sN/Gzc2sq4l0s113WuQOxGLVboEaN9G
# QBrjFot50MW3r/eKnonTZ7wHvHYiaKIo455fimbMUGq2GLRCXzYUnDMu7kRktdvI
# LWkF07VD+RE0HlmdPR3Ic3KH0Tph5xOKFkZ1KZTef+ozXpxcg1CuUkuDDmWg6U06
# VGfTneNTZYThEh/6ZJ64KWcbkDugLO9H2/ovMbXVNI6UXWsF34nxyClCDscAQGy9
# 56AAWmTVM5UlENTXvUxezy1Ia9b4SsGlj+5bmA==
# SIG # End signature block
