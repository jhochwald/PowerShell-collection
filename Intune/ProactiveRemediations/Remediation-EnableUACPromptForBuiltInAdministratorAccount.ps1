#region Remediation
$RegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'

if (-not (Test-Path -LiteralPath $RegistryPath -ErrorAction SilentlyContinue))
{
   $null = (New-Item -Path $RegistryPath -Force -Confirm:$false -ErrorAction Stop)
}

$null = (New-ItemProperty -LiteralPath $RegistryPath -Name 'FilterAdministratorToken' -Value 1 -PropertyType DWord -Force -Confirm:$false -ErrorAction Stop)

exit 0
#endregion Remediation

