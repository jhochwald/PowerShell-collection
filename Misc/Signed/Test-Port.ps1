#requires -Version 3.0

function Test-Port
{
  <#
      .SYNOPSIS
      Tests port on a given computer.

      .DESCRIPTION
      Tests port on computer. This functions supports both: TCP and UPD

      .PARAMETER computer
      Name of server to test the port connection on.

      .PARAMETER port
      Port to test

      .PARAMETER tcp
      Use tcp port

      .PARAMETER udp
      Use udp port

      .PARAMETER UDPTimeOut
      Sets a timeout for UDP port query. (In milliseconds, Default is 1000)

      .PARAMETER TCPTimeOut
      Sets a timeout for TCP port query. (In milliseconds, Default is 1000)

      .EXAMPLE
      Test-Port -computer 'server' -port 80
      Checks port 80 on server 'server' to see if it is listening

      .EXAMPLE
      'server' | Test-Port -port 80
      Checks port 80 on server 'server' to see if it is listening

      .EXAMPLE
      Test-Port -computer @("server1","server2") -port 80
      Checks port 80 on server1 and server2 to see if it is listening

      .EXAMPLE
      Test-Port -computer dc1 -port 17 -udp -UDPtimeout 10000

      Server   : dc1
      Port     : 17
      TypePort : UDP
      Open     : True
      Notes    : "My spelling is Wobbly.  It's good spelling but it Wobbles, and the letters
      get in the wrong places." A. A. Milne (1882-1958)

      Description
      -----------
      Queries port 17 (qotd) on the UDP port and returns whether port is open or not
       
      .EXAMPLE
      @("server1","server2") | Test-Port -port 80
      Checks port 80 on server1 and server2 to see if it is listening

      .EXAMPLE
      (Get-Content hosts.txt) | Test-Port -port 80
      Checks port 80 on servers in host file to see if it is listening

      .EXAMPLE
      Test-Port -computer (Get-Content hosts.txt) -port 80
      Checks port 80 on servers in host file to see if it is listening

      .EXAMPLE
      Test-Port -computer (Get-Content hosts.txt) -port @(1..59)
      Checks a range of ports from 1-59 on all servers in the hosts.txt file

      .NOTES
      For TCP tests, you might want to use Test-NetConnection
      But Test-NetConnection is unable to test UDP Ports

      Author: Boe Prox
      DateCreated: 18Aug2010
      Contributor: Joerg Hochwald

      .LINK
      https://boeprox.wordpress.org

      .LINK
      http://jhochwald.com

      .LINK
      http://www.iana.org/assignments/port-numbers
  #>
  [cmdletbinding(
      DefaultParameterSetName = '',
      ConfirmImpact = 'None'
  )]
  param (
    [Parameter(
        Mandatory, HelpMessage = 'Name of server to test the port connection on.',
        Position = 0,
        ParameterSetName = '',
    ValueFromPipeline)]
    [array]
    $computer,
    [Parameter(
        Position = 1, HelpMessage = 'Port to test',
        Mandatory,
    ParameterSetName = '')]
    [array]
    $port,
    [Parameter(
    ParameterSetName = '')]
    [int]
    $TCPtimeout = 1000,
    [Parameter(
    ParameterSetName = '')]
    [int]
    $UDPtimeout = 1000,
    [Parameter(
    ParameterSetName = '')]
    [switch]
    $TCP,
    [Parameter(
    ParameterSetName = '')]
    [switch]
    $UDP
  )

  begin
  {
    # Check if we test TCP or UDP
    if ((-not $TCP) -AND (-not $UDP))
    {
      <#
          Nothing? OK, we use the Defualt (TCP)
      #>
      $TCP = $True
    }
		
    <#
        Typically you never do this, but in this case I felt it was for the benefit of the function as any errors will be noted in the output of the report
        It also reduce the handling within the code. Smart, right?
    #>
    $ErrorActionPreference = 'SilentlyContinue'

    # Cleanup
    $report = @()
  }

  process
  {
    foreach ($c in $computer)
    {
      foreach ($p in $port)
      {
        if ($TCP)
        {
          # Create temporary holder
          # TODO: Replace this
          $temp = '' | Select-Object -Property Server, Port, TypePort, Open, Notes
					
          # Create object for connecting to port on computer
          $tcpobject = (New-Object -TypeName system.Net.Sockets.TcpClient)
					
          # Connect to remote machine's port
          $connect = $tcpobject.BeginConnect($c, $p, $null, $null)
					
          # Configure a timeout before quitting
          $wait = $connect.AsyncWaitHandle.WaitOne($TCPtimeout, $False)
					
          # If timeout
          if (-not $wait)
          {
            # Close connection
            $tcpobject.Close()

            Write-Verbose -Message 'Connection Timeout'

            # Build report
            $temp.Server = $c
            $temp.Port = $p
            $temp.TypePort = 'TCP'
            $temp.Open = $False
            $temp.Notes = 'Connection to Port Timed Out'
          }
          else
          {
            $error.Clear()
            $null = $tcpobject.EndConnect($connect)

            # If error
            if ($error[0])
            {
              # Begin making error more readable in report
              [string]$string = ($error[0].exception).message
              $message = (($string.split(':')[1]).replace('"', '')).TrimStart()
              $failed = $True
            }

            # Close connection
            $tcpobject.Close()

            # If unable to query port to due failure
            if ($failed)
            {
              # Build report
              $temp.Server = $c
              $temp.Port = $p
              $temp.TypePort = 'TCP'
              $temp.Open = $False
              $temp.Notes = "$message"
            }
            else
            {
              # Build report
              $temp.Server = $c
              $temp.Port = $p
              $temp.TypePort = 'TCP'
              $temp.Open = $True
              $temp.Notes = ''
            }
          }

          # Reset failed value
          $failed = $null

          # Merge temp array with report
          $report += $temp
        }

        if ($UDP)
        {
          # Create temporary holder
          $temp = '' | Select-Object -Property Server, Port, TypePort, Open, Notes

          # Create object for connecting to port on computer
          $udpobject = (New-Object -TypeName system.Net.Sockets.Udpclient)

          # Set a timeout on receiving message
          $udpobject.client.ReceiveTimeout = $UDPtimeout

          # Connect to remote machine's port
          Write-Verbose -Message 'Making UDP connection to remote server'

          $udpobject.Connect("$c", $p)

          # Sends a message to the host to which you have connected.
          Write-Verbose -Message 'Sending message to remote host'

          $a = (New-Object -TypeName system.text.asciiencoding)
          $byte = $a.GetBytes("$(Get-Date)")
          $null = $udpobject.Send($byte, $byte.length)

          # IPEndPoint object will allow us to read datagrams sent from any source.
          Write-Verbose -Message 'Creating remote endpoint'

          $remoteendpoint = (New-Object -TypeName system.net.ipendpoint -ArgumentList ([ipaddress]::Any, 0))

          try
          {
            # Blocks until a message returns on this socket from a remote host.
            Write-Verbose -Message 'Waiting for message return'

            $receivebytes = $udpobject.Receive([ref]$remoteendpoint)
            [string]$returndata = $a.GetString($receivebytes)

            if ($returndata)
            {
              Write-Verbose -Message 'Connection Successful'

              # Build report
              $temp.Server = $c
              $temp.Port = $p
              $temp.TypePort = 'UDP'
              $temp.Open = $True
              $temp.Notes = $returndata
              $udpobject.close()
            }
          }
          catch
          {
            if ($error[0].ToString() -match '\bRespond after a period of time\b')
            {
              # Close connection
              $udpobject.Close()

              # Make sure that the host is online and not a false positive that it is open
              if (Test-Connection -ComputerName $c -Count 1 -Quiet)
              {
                Write-Verbose -Message 'Connection Open'

                # Build report
                $temp.Server = $c
                $temp.Port = $p
                $temp.TypePort = 'UDP'
                $temp.Open = $True
                $temp.Notes = ''
              }
              else
              {
                <#
                    It is possible that the host is not online or that the host is online,
                    but ICMP is blocked by a firewall and this port is actually open.
                #>

                Write-Verbose -Message 'Host maybe unavailable'

                # Build report
                $temp.Server = $c
                $temp.Port = $p
                $temp.TypePort = 'UDP'
                $temp.Open = $False
                $temp.Notes = 'Unable to verify if port is open or if host is unavailable.'
              }
            }
            elseif ($error[0].ToString() -match 'forcibly closed by the remote host')
            {
              # Close connection
              $udpobject.Close()

              Write-Verbose -Message 'Connection Timeout'

              # Build report
              $temp.Server = $c
              $temp.Port = $p
              $temp.TypePort = 'UDP'
              $temp.Open = $False
              $temp.Notes = 'Connection to Port Timed Out'
            }
            else
            {
              $udpobject.close()
            }
          }
          # Merge temp array with report
          $report += $temp
        }
      }
    }
  }

  end
  {
    # Generate Report
    $report
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
# MIIZkAYJKoZIhvcNAQcCoIIZgTCCGX0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUkm6y62QiPunakW/5gKJQQYrz
# sVmgghTyMIID7jCCA1egAwIBAgIQfpPr+3zGTlnqS5p31Ab8OzANBgkqhkiG9w0B
# AQUFADCBizELMAkGA1UEBhMCWkExFTATBgNVBAgTDFdlc3Rlcm4gQ2FwZTEUMBIG
# A1UEBxMLRHVyYmFudmlsbGUxDzANBgNVBAoTBlRoYXd0ZTEdMBsGA1UECxMUVGhh
# d3RlIENlcnRpZmljYXRpb24xHzAdBgNVBAMTFlRoYXd0ZSBUaW1lc3RhbXBpbmcg
# Q0EwHhcNMTIxMjIxMDAwMDAwWhcNMjAxMjMwMjM1OTU5WjBeMQswCQYDVQQGEwJV
# UzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xMDAuBgNVBAMTJ1N5bWFu
# dGVjIFRpbWUgU3RhbXBpbmcgU2VydmljZXMgQ0EgLSBHMjCCASIwDQYJKoZIhvcN
# AQEBBQADggEPADCCAQoCggEBALGss0lUS5ccEgrYJXmRIlcqb9y4JsRDc2vCvy5Q
# WvsUwnaOQwElQ7Sh4kX06Ld7w3TMIte0lAAC903tv7S3RCRrzV9FO9FEzkMScxeC
# i2m0K8uZHqxyGyZNcR+xMd37UWECU6aq9UksBXhFpS+JzueZ5/6M4lc/PcaS3Er4
# ezPkeQr78HWIQZz/xQNRmarXbJ+TaYdlKYOFwmAUxMjJOxTawIHwHw103pIiq8r3
# +3R8J+b3Sht/p8OeLa6K6qbmqicWfWH3mHERvOJQoUvlXfrlDqcsn6plINPYlujI
# fKVOSET/GeJEB5IL12iEgF1qeGRFzWBGflTBE3zFefHJwXECAwEAAaOB+jCB9zAd
# BgNVHQ4EFgQUX5r1blzMzHSa1N197z/b7EyALt0wMgYIKwYBBQUHAQEEJjAkMCIG
# CCsGAQUFBzABhhZodHRwOi8vb2NzcC50aGF3dGUuY29tMBIGA1UdEwEB/wQIMAYB
# Af8CAQAwPwYDVR0fBDgwNjA0oDKgMIYuaHR0cDovL2NybC50aGF3dGUuY29tL1Ro
# YXd0ZVRpbWVzdGFtcGluZ0NBLmNybDATBgNVHSUEDDAKBggrBgEFBQcDCDAOBgNV
# HQ8BAf8EBAMCAQYwKAYDVR0RBCEwH6QdMBsxGTAXBgNVBAMTEFRpbWVTdGFtcC0y
# MDQ4LTEwDQYJKoZIhvcNAQEFBQADgYEAAwmbj3nvf1kwqu9otfrjCR27T4IGXTdf
# plKfFo3qHJIJRG71betYfDDo+WmNI3MLEm9Hqa45EfgqsZuwGsOO61mWAK3ODE2y
# 0DGmCFwqevzieh1XTKhlGOl5QGIllm7HxzdqgyEIjkHq3dlXPx13SYcqFgZepjhq
# IhKjURmDfrYwggSjMIIDi6ADAgECAhAOz/Q4yP6/NW4E2GqYGxpQMA0GCSqGSIb3
# DQEBBQUAMF4xCzAJBgNVBAYTAlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jwb3Jh
# dGlvbjEwMC4GA1UEAxMnU3ltYW50ZWMgVGltZSBTdGFtcGluZyBTZXJ2aWNlcyBD
# QSAtIEcyMB4XDTEyMTAxODAwMDAwMFoXDTIwMTIyOTIzNTk1OVowYjELMAkGA1UE
# BhMCVVMxHTAbBgNVBAoTFFN5bWFudGVjIENvcnBvcmF0aW9uMTQwMgYDVQQDEytT
# eW1hbnRlYyBUaW1lIFN0YW1waW5nIFNlcnZpY2VzIFNpZ25lciAtIEc0MIIBIjAN
# BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAomMLOUS4uyOnREm7Dv+h8GEKU5Ow
# mNutLA9KxW7/hjxTVQ8VzgQ/K/2plpbZvmF5C1vJTIZ25eBDSyKV7sIrQ8Gf2Gi0
# jkBP7oU4uRHFI/JkWPAVMm9OV6GuiKQC1yoezUvh3WPVF4kyW7BemVqonShQDhfu
# ltthO0VRHc8SVguSR/yrrvZmPUescHLnkudfzRC5xINklBm9JYDh6NIipdC6Anqh
# d5NbZcPuF3S8QYYq3AhMjJKMkS2ed0QfaNaodHfbDlsyi1aLM73ZY8hJnTrFxeoz
# C9Lxoxv0i77Zs1eLO94Ep3oisiSuLsdwxb5OgyYI+wu9qU+ZCOEQKHKqzQIDAQAB
# o4IBVzCCAVMwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAO
# BgNVHQ8BAf8EBAMCB4AwcwYIKwYBBQUHAQEEZzBlMCoGCCsGAQUFBzABhh5odHRw
# Oi8vdHMtb2NzcC53cy5zeW1hbnRlYy5jb20wNwYIKwYBBQUHMAKGK2h0dHA6Ly90
# cy1haWEud3Muc3ltYW50ZWMuY29tL3Rzcy1jYS1nMi5jZXIwPAYDVR0fBDUwMzAx
# oC+gLYYraHR0cDovL3RzLWNybC53cy5zeW1hbnRlYy5jb20vdHNzLWNhLWcyLmNy
# bDAoBgNVHREEITAfpB0wGzEZMBcGA1UEAxMQVGltZVN0YW1wLTIwNDgtMjAdBgNV
# HQ4EFgQURsZpow5KFB7VTNpSYxc/Xja8DeYwHwYDVR0jBBgwFoAUX5r1blzMzHSa
# 1N197z/b7EyALt0wDQYJKoZIhvcNAQEFBQADggEBAHg7tJEqAEzwj2IwN3ijhCcH
# bxiy3iXcoNSUA6qGTiWfmkADHN3O43nLIWgG2rYytG2/9CwmYzPkSWRtDebDZw73
# BaQ1bHyJFsbpst+y6d0gxnEPzZV03LZc3r03H0N45ni1zSgEIKOq8UvEiCmRDoDR
# EfzdXHZuT14ORUZBbg2w6jiasTraCXEQ/Bx5tIB7rGn0/Zy2DBYr8X9bCT2bW+IW
# yhOBbQAuOA2oKY8s4bL0WqkBrxWcLC9JG9siu8P+eJRRw4axgohd8D20UaF5Mysu
# e7ncIAkTcetqGVvP6KUwVyyJST+5z3/Jvz4iaGNTmr1pdKzFHTx/kuDDvBzYBHUw
# ggUvMIIEF6ADAgECAhUAnQ4BMcIRBgspeUy1JGs+Zi8ndqIwDQYJKoZIhvcNAQEL
# BQAwPzELMAkGA1UEBhMCR0IxETAPBgNVBAoTCEFzY2VydGlhMR0wGwYDVQQDExRB
# c2NlcnRpYSBQdWJsaWMgQ0EgMTAeFw0xOTAxMDQxNTMyMDdaFw0xOTAyMDQxNTMy
# MDdaMIGnMQswCQYDVQQGEwJERTEhMB8GCSqGSIb3DQEJARYSam9lcmdAaG9jaHdh
# bGQubmV0MQ8wDQYDVQQIEwZIZXNzZW4xEDAOBgNVBAcTB01haW50YWwxFzAVBgNV
# BAoTDkpvZXJnIEhvY2h3YWxkMSAwHgYDVQQLExdPcGVuIFNvdXJjZSBEZXZlbG9w
# bWVudDEXMBUGA1UEAxMOSm9lcmcgSG9jaHdhbGQwggEiMA0GCSqGSIb3DQEBAQUA
# A4IBDwAwggEKAoIBAQDL56sSkECHDR6kKznKhvCb3+cO8K5+YJdXG7kZzkKcnsOi
# o803+a3PkO/zFNH9Cuq+Oc/1wRkeoePaaLvk9VrXQ4NBjxx69ZO/RY+EHSOZ6z3e
# CFb8mgzLNf1Z4qwgWV91GF1IPa4VnilDSwsW98axQ+lkOXqLu18qhT1SPP8xZp/5
# mG2ctD3HA7p6miyCXkFBBIlg6HdnPn/Acxq9T7v9GpYV4+jznt2Are+YJV9J6Sl3
# qKchjlNIektENOJV6nkmeZJ9PJj6sOjAFtAPlFJgoG1Fw1++GooNyC37nuqWOKlC
# Kvp8br0F2ixWjs2S1Oun/w+06JnX4/0ZZhTd7dSfAgMBAAGjggG3MIIBszAOBgNV
# HQ8BAf8EBAMCBsAwDAYDVR0TAQH/BAIwADA9BggrBgEFBQcBAQQxMC8wLQYIKwYB
# BQUHMAGGIWh0dHA6Ly9vY3NwLmdsb2JhbHRydXN0ZmluZGVyLmNvbTCB8AYDVR0g
# BIHoMIHlMIHiBgorBgEEAfxJAQEBMIHTMIHQBggrBgEFBQcCAjCBwwyBwFdhcm5p
# bmc6IENlcnRpZmljYXRlcyBhcmUgaXNzdWVkIHVuZGVyIHRoaXMgcG9saWN5IHRv
# IGluZGl2aWR1YWxzIHRoYXQgaGF2ZSBub3QgaGFkIHRoZWlyIGlkZW50aXR5IGNv
# bmZpcm1lZC4gRG8gbm90IHVzZSB0aGVzZSBjZXJ0aWZpY2F0ZXMgZm9yIHZhbHVh
# YmxlIHRyYW5zYWN0aW9ucy4gTk8gTElBQklMSVRZIElTIEFDQ0VQVEVELjBMBgNV
# HR8ERTBDMEGgP6A9hjtodHRwOi8vd3d3Lmdsb2JhbHRydXN0ZmluZGVyLmNvbS9j
# cmxzL0FzY2VydGlhUHVibGljQ0ExLmNybDATBgNVHSUEDDAKBggrBgEFBQcDAzAN
# BgkqhkiG9w0BAQsFAAOCAQEAjEZHO2pV991j3XGZSvg/jUd1JFf2UAnCeW7sxIvI
# k7AVPs6ynKkUIdJ5yC4kqgNXks3q84pwaCmjxPVbmg6wZV/EtVIbbX4zoNW7UVBU
# l3IyeCqKxaPTnCToVnZbod0S99qwV5OYKPFGmPuunqSQ6G4ulTFvHoY5rHd5jI75
# VmemN1lW6FlidJjohH6biM+OM3p1LwcYtvitPWSP4cvsFvtFKhp3rvKUiiPByE+q
# mx9tNuS1ypgxRftndCwmaqnXjzbeZRoNpD1G7Rrch4WepV6FhK173qBfwA+8t8Kr
# B0W4h716Ejk7RkyQk7hawO2GBLDqa2qbXLkiHPsa7W7x1DCCByIwggYKoAMCAQIC
# AgDmMA0GCSqGSIb3DQEBBQUAMD0xCzAJBgNVBAYTAkdCMREwDwYDVQQKEwhBc2Nl
# cnRpYTEbMBkGA1UEAxMSQXNjZXJ0aWEgUm9vdCBDQSAyMB4XDTA5MDQyMTEyMTUx
# N1oXDTI4MDQxNDIzNTk1OVowPzELMAkGA1UEBhMCR0IxETAPBgNVBAoTCEFzY2Vy
# dGlhMR0wGwYDVQQDExRBc2NlcnRpYSBQdWJsaWMgQ0EgMTCCASIwDQYJKoZIhvcN
# AQEBBQADggEPADCCAQoCggEBAM9Y8jPEs9kd+U8R27jjtta8pyE3Vy57qQyUs8sS
# 8EdaziFwXhODnD7Mo/6evVPW2DBkP4puXcQbUrAR9dkI0E72BE/+/yRyXw2stKp8
# NPjbClgmazS7rGk0KMzxhWuSF5CV3p+L8d+jitUQSFZ4cTleNJ1ou5qzCfP9ZA4n
# XYieOs7E527x+/IdUe3rh9bTucEwj42nyc1dD+t+fwSbX0bGB7M/zbqVsVf0m2/m
# tIoYZSrgD0AADkRwwH74Bnq1ajMX9JsxGTVEvRsGOfqWaeeiVZRp3yGNwdEJ9p7r
# mKZzIKHVmXcIIrn86R2z6Fnw0hBwmikOLc7sRDhzF3JBN2UCAwEAAaOCBCgwggQk
# MA4GA1UdDwEB/wQEAwIBBjASBgNVHRMBAf8ECDAGAQH/AgECMIHwBgNVHSAEgegw
# geUwgeIGCisGAQQB/EkBAQEwgdMwgdAGCCsGAQUFBwICMIHDGoHAV2FybmluZzog
# Q2VydGlmaWNhdGVzIGFyZSBpc3N1ZWQgdW5kZXIgdGhpcyBwb2xpY3kgdG8gaW5k
# aXZpZHVhbHMgdGhhdCBoYXZlIG5vdCBoYWQgdGhlaXIgaWRlbnRpdHkgY29uZmly
# bWVkLiBEbyBub3QgdXNlIHRoZXNlIGNlcnRpZmljYXRlcyBmb3IgdmFsdWFibGUg
# dHJhbnNhY3Rpb25zLiBOTyBMSUFCSUxJVFkgSVMgQUNDRVBURUQuMIIBMwYDVR0O
# BIIBKgSCASYwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDPWPIzxLPZ
# HflPEdu447bWvKchN1cue6kMlLPLEvBHWs4hcF4Tg5w+zKP+nr1T1tgwZD+Kbl3E
# G1KwEfXZCNBO9gRP/v8kcl8NrLSqfDT42wpYJms0u6xpNCjM8YVrkheQld6fi/Hf
# o4rVEEhWeHE5XjSdaLuaswnz/WQOJ12InjrOxOdu8fvyHVHt64fW07nBMI+Np8nN
# XQ/rfn8Em19GxgezP826lbFX9Jtv5rSKGGUq4A9AAA5EcMB++AZ6tWozF/SbMRk1
# RL0bBjn6lmnnolWUad8hjcHRCfae65imcyCh1Zl3CCK5/Okds+hZ8NIQcJopDi3O
# 7EQ4cxdyQTdlAgMBAAEwWgYDVR0fBFMwUTBPoE2gS4ZJaHR0cDovL3d3dy5hc2Nl
# cnRpYS5jb20vT25saW5lQ0EvY3Jscy9Bc2NlcnRpYVJvb3RDQTIvQXNjZXJ0aWFS
# b290Q0EyLmNybDA9BggrBgEFBQcBAQQxMC8wLQYIKwYBBQUHMAGGIWh0dHA6Ly9v
# Y3NwLmdsb2JhbHRydXN0ZmluZGVyLmNvbTCCATcGA1UdIwSCAS4wggEqgIIBJjCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAJY3vp7g2T6mhhMX9krzqQfz
# FmjVf0QWR/Mhn3385P+k9Au+zfTCBgPi7KFEFMWQoZ/R0fceMrPU31IUm53R6pvG
# 0fdg+vytSMeTGOtffgvEIVYE2iPhPcXDcsadOkZ47rERoQMB290iebcEm+kbhVYR
# LdntIm15ohuQ2aoOfQOFGkwVeI0qBko1YhwkzVkZb345k7u/FRms48F9x6mVaDvR
# OitzxMFgvs+/X+DqS5kI7sPHWcXpqCL0YIgdGQytyOC4iqSDypIv4pbHBa4qLxgc
# EbiLu8iC8c4ovaWeZ2h7rdZEAb3BQdvrx27AFzW0gA+pqb3QxCszKFMbOHAjtoMC
# AwEAATANBgkqhkiG9w0BAQUFAAOCAQEAlJSXoaMTmbqGSlyLZYs+gkysb3RMAtuK
# AZlLXNNguwjBTF/HRWd2FH9hTt1RB/m8U+HNB/2bCb2+J1P1bB3paDSGYOJPwuHn
# LtPhfKqO4wo3dynt4MWStIJSG9PwuDaf+rF54kwPeCG0WGjJe0jkD/oKY8cGRw0y
# 1BkCE5EqOknjXBJr68fq/VPMLyi3D7G7GDICQ7+FGaaYEiAYO7DEp8ut0FBFlZ4F
# GZaofuCtCUTSBhikEVLgWWivAGqOIgOnoUfnY6stL2AtXZ/V6bExACXCHcswGbC9
# S1NCz77wzyhfYSldkIgd6g4QUQxvOYS/gjzzKigcnFxMvTbq9yX/UjGCBAgwggQE
# AgEBMFgwPzELMAkGA1UEBhMCR0IxETAPBgNVBAoTCEFzY2VydGlhMR0wGwYDVQQD
# ExRBc2NlcnRpYSBQdWJsaWMgQ0EgMQIVAJ0OATHCEQYLKXlMtSRrPmYvJ3aiMAkG
# BSsOAwIaBQCgeDAYBgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJ
# AzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMG
# CSqGSIb3DQEJBDEWBBT9b5OGaYuaNc4WBG+4EUQqAfwlHzANBgkqhkiG9w0BAQEF
# AASCAQCp3MkbubM0qtd4aKhUkzHZllH8cb9K8wl/MiL8laakjBIVu+b8oGB1iMWe
# kzWFwHN4jbqsVZbdTRHmV3qBvFGB7BsTxh8G0vdhFMfj25EZTzCed3KYyLJjazLu
# K2MGISkjya/RY4wA2WKBi4hBYXaZsGk2t5UMu/FEjYewP1/ek3F//ZERF2iGbJd+
# 4/VSONFv2meWsEqeCZ3Ul9tEIcZMGcebGL0k3n48jlRiutp4saHguikTPJMtP0ut
# RoIUQvO9DHUPHyV/LwJqlgdhUqjZY2hZXT2jgg89Ss2AFWIGBSxM4CPeDquLyUVd
# cmsIUY0PZ3g/kYcOIL6zW+P60PhzoYICCzCCAgcGCSqGSIb3DQEJBjGCAfgwggH0
# AgEBMHIwXjELMAkGA1UEBhMCVVMxHTAbBgNVBAoTFFN5bWFudGVjIENvcnBvcmF0
# aW9uMTAwLgYDVQQDEydTeW1hbnRlYyBUaW1lIFN0YW1waW5nIFNlcnZpY2VzIENB
# IC0gRzICEA7P9DjI/r81bgTYapgbGlAwCQYFKw4DAhoFAKBdMBgGCSqGSIb3DQEJ
# AzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE5MDEwNDE2MDQyMFowIwYJ
# KoZIhvcNAQkEMRYEFOUG0D7o1jDxL6ddNoMO/L/CuVQwMA0GCSqGSIb3DQEBAQUA
# BIIBACpmfhV2UnLASduCTDRnZqOSZQ+b+iYwrfc3mL1SPLcndnCh3YCZzJgHGJM8
# iypK4+46seA25BcH3XWb9xmXiNIZxQ7vduVCPc+CMYzrhHm11sOE7ENUdgS0lIaU
# JvFy4gQrLonIU6Tq3S3Z4OmgW94pUjlyxO2y8e/zCVBidA9scZ4SSIs1nD4Saf95
# nYXhAcq+xRBltsDrKy52bodYzZkntysj8zesUWT1/V9PvSdht7TOwzgAhg91WuKm
# +uVKBuquHtaEQicbnOX2ttJjpc7XGOxBhcQHcrBDsZMc/C3r4JV68zcmIR1Mzna4
# reN+F63rddWbG3dAIXOyJVUL9DE=
# SIG # End signature block
