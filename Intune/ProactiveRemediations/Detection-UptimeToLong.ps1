# Detection-UptimeToLong

# Don't display the progress bar
$ProgressPreference = 'SilentlyContinue'

$Uptime = (Get-ComputerInfo | Select-Object -ExpandProperty OSUptime -ErrorAction SilentlyContinue)

if ($Uptime.Days -ge 7)
{
   Write-Output -InputObject ('Device has not rebooted in {0} days, notify user to reboot' -f $Uptime.Days)

   exit 1
}
else
{
   Write-Output -InputObject ('Device has rebooted {0} days ago, all good' -f $Uptime.Days)

   exit 0
}
