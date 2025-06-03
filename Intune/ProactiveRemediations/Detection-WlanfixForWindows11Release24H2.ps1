#requires -Version 1.0


# Detection-WlanfixForWindows11Release24H2

# Check Registry
$paramGetItemProperty = @{
   Path        = 'HKLM:\SYSTEM\CurrentControlSet\Services\Wcmsvc'
   ErrorAction = 'SilentlyContinue'
}
if ((Get-ItemProperty @paramGetItemProperty | Select-Object -ExpandProperty DependOnService) -contains 'WinHTTPAutoProxySvc') 
{
   Write-Output -InputObject 'WinHTTPAutoProxySvc key found in HKLM:\SYSTEM\CurrentControlSet\Services\Wcmsvc, needs Remediation'
   exit 1
}

# Check service
if ((Get-Service -Name WinHttpAutoProxySvc).StartType -ne 'Manual') 
{
   Write-Output -InputObject 'WinHTTP Web Proxy Auto-Discovery Service not configured as Manual, needs Remediation'
   exit 1
}

exit 0