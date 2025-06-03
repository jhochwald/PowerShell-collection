# Remediation Auto Time-Zone Update
# Remediation-AutoTimeZoneUpdate

#region tzautoupdate
[string]$RegPath = 'HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate'

if ((Test-Path -LiteralPath $RegPath -ErrorAction SilentlyContinue) -ne $true)
{
   $null = (New-Item -Path $RegPath -Force -Confirm:$false -ErrorAction SilentlyContinue)
}

$null = (New-ItemProperty -LiteralPath $RegPath -Name 'Start' -Value 3 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)

$RegPath = $null
#endregion tzautoupdate

#region location
$RegPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location'

if ((Test-Path -LiteralPath $RegPath -ErrorAction SilentlyContinue) -ne $true)
{
   $null = (New-Item -Path $RegPath -Force -Confirm:$false -ErrorAction SilentlyContinue)
}

$null = (New-ItemProperty -LiteralPath $RegPath -Name 'Value' -Value 'Allow' -PropertyType String -Force -Confirm:$false -ErrorAction SilentlyContinue)

$RegPath = $null
#endregion location

# Ensure a clean exit!
exit 0
