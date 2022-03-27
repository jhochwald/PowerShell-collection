#region Remediation
$RegistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore'

if ((Test-Path -LiteralPath $RegistryPath -ErrorAction SilentlyContinue) -ne $true)
{
   $null = (New-Item -Path $RegistryPath -Force -Confirm:$false -ErrorAction SilentlyContinue)
}

$null = (New-ItemProperty -LiteralPath $RegistryPath -Name 'AutoDownload' -Value 4 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)

return $true
#endregion Remediation