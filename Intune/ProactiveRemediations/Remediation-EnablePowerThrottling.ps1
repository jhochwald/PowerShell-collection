#region Remediation
$RegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling'

if ((Test-Path -LiteralPath $RegistryPath -ErrorAction SilentlyContinue) -ne $true)
{
   $null = (New-Item -Path $RegistryPath -Force -Confirm:$false -ErrorAction SilentlyContinue)
}

$null = (New-ItemProperty -LiteralPath $RegistryPath -Name 'PowerThrottlingOff' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)

return $true
#endregion Remediation