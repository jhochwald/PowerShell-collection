# DETECT: Disable TLS 1.2 for EAP Authentication, workaround for some RADIUS servers

try
{
   if(-not (Test-Path -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Services\RasMan\PPP\EAP\13'))
   {
      Exit 1
   }

   if(-not ((Get-ItemPropertyValue -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Services\RasMan\PPP\EAP\13' -Name 'TlsVersion' -ErrorAction SilentlyContinue) -eq 192))
   {
      Exit 1
   }
}
catch
{
   Exit 1
}

Exit 0