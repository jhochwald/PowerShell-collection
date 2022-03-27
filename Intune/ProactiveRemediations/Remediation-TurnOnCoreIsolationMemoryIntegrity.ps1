#region Remediation
$RegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity'

if ((Test-Path -LiteralPath $RegistryPath -ErrorAction) -ne $true)
{
   $null = (New-Item -Path $RegistryPath -Force -Confirm:$false -ErrorAction SilentlyContinue)
}

$null = (New-ItemProperty -LiteralPath $RegistryPath -Name 'Enabled' -Value 1 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)

return $true
#endregion Remediation