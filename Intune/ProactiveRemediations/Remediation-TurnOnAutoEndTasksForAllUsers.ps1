#region Remediation
$RegistryPath = 'Registry::\HKEY_USERS\.DEFAULT\Control Panel\Desktop'

if (-not (Test-Path -LiteralPath $RegistryPath -ErrorAction SilentlyContinue))
{
   $null = (New-Item -Path $RegistryPath -Force -Confirm:$false -ErrorAction Stop )
}

$null = (New-ItemProperty -LiteralPath $RegistryPath -Name 'AutoEndTasks' -Value '1' -PropertyType String -Force -Confirm:$false -ErrorAction Stop)

exit 0
#endregion Remediation

