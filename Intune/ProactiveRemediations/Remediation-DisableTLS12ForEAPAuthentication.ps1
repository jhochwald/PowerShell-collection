# Remediation: Disable TLS 1.2 for EAP Authentication, workaround for some RADIUS servers

if((Test-Path -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Services\RasMan\PPP\EAP\13') -ne $true)
{
   $null = (New-Item -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\RasMan\PPP\EAP\13' -Force -Confirm:$false -ErrorAction SilentlyContinue)
}

$null = (New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Services\RasMan\PPP\EAP\13' -Name 'TlsVersion' -Value 192 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)

# Restart the EAP Host Service
$null = (Get-Service -Name EapHost -ErrorAction SilentlyContinue | Restart-Service -Force -Confirm:$false -ErrorAction SilentlyContinue)

Exit 0