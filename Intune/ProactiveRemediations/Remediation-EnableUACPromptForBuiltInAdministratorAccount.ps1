#region Remediation
$RegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'

if ((Test-Path -LiteralPath $RegistryPath) -ne $true)
{
   $null = (New-Item -Path $RegistryPath -Force -Confirm:$false -ErrorAction SilentlyContinue)
}

$null = (New-ItemProperty -LiteralPath $RegistryPath -Name 'FilterAdministratorToken' -Value 1 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)

return $true
#endregion Remediation