#region Remediation
$RegistryPath = 'Registry::\HKEY_USERS\.DEFAULT\Control Panel\Desktop'

if ((Test-Path -LiteralPath $RegistryPath -ErrorAction SilentlyContinue) -ne $true)
{
   $null = (New-Item -Path $RegistryPath -Force -Confirm:$false -ErrorAction SilentlyContinue )
}

$null = (New-ItemProperty -LiteralPath $RegistryPath -Name 'AutoEndTasks' -Value '1' -PropertyType String -Force -Confirm:$false -ErrorAction SilentlyContinue)

return $true
#endregion Remediation