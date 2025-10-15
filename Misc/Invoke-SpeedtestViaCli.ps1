#requires -Version 3.0

# Execute speed test via the CLI
$Speedtest = (& 'C:\Tools\Speedtest\speedtest.exe' --progress=no --format=json --accept-license --accept-gdpr | ConvertFrom-Json)

# Create New Object SpeedObject
[PSCustomObject]$SpeedObject = [ordered] @{
   downloadspeed = [math]::Round($Speedtest.download.bandwidth / 1000000 * 8, 2)
   uploadspeed   = [math]::Round($Speedtest.upload.bandwidth / 1000000 * 8, 2)
   packetloss    = [math]::Round($Speedtest.packetLoss)
   Latency       = [math]::Round($Speedtest.ping.latency)
   isp           = $Speedtest.isp
   ExternalIP    = $Speedtest.interface.externalIp
   InternalIP    = $Speedtest.interface.internalIp
   UsedServer    = $Speedtest.server.host
   URL           = $Speedtest.result.url
   Jitter        = [math]::Round($Speedtest.ping.jitter)    
}

# Dump it
$SpeedObject

# Cleanup
$Speedtest = $null
$SpeedObject = $null
