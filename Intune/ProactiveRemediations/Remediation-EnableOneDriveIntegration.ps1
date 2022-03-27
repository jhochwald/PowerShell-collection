#region Remediation
$RegistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive'

if ((Test-Path -LiteralPath $RegistryPath) -ne $true)
{
   $null = (New-Item -Path $RegistryPath -Force -Confirm:$false -ErrorAction SilentlyContinue)
}

$null = (Remove-ItemProperty -LiteralPath $RegistryPath -Name 'DisableFileSyncNGSC' -Confirm:$false -Force -ErrorAction SilentlyContinue)

return $true
#endregion Remediation