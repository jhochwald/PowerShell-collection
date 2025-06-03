# Remediation: Disable Starface Auto-Update feature

$RegPath = 'HKLM:\SOFTWARE\STARFACE\APP'
$RegName = 'AutoUpdateCDN'
$RegValue = 0

if ((Test-Path -LiteralPath $RegPath -ErrorAction SilentlyContinue) -ne $true)
{
   $null = (New-Item -Path $RegPath -Force -Confirm:$false -ErrorAction SilentlyContinue)
}

$null = (New-ItemProperty -LiteralPath $RegPath -Name $RegName -Value $RegValue -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
