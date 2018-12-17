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
