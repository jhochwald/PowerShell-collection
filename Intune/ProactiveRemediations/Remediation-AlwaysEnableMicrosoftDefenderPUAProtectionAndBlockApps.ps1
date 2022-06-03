#region Remediation
$RegistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender'

if ((Test-Path -LiteralPath $RegistryPath -ErrorAction SilentlyContinue) -ne $true)
{
   $null = (New-Item -Path $RegistryPath -Force -Confirm:$false -ErrorAction SilentlyContinue)
}

$null = (New-ItemProperty -LiteralPath $RegistryPath -Name 'PUAProtection' -Value 1 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)

exit 0
#endregion Remediation

