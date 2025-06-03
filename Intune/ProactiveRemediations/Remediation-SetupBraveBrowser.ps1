# Remediation: Setup Brave Browser

$Regpath = 'HKLM:\Software\Policies\BraveSoftware\Brave'

if ((Test-Path -LiteralPath $Regpath -ErrorAction SilentlyContinue) -ne $true)
{
	$null = (New-Item -Path $Regpath -Force -Confirm:$false -ErrorAction SilentlyContinue)
}

$null = (New-ItemProperty -LiteralPath $Regpath -Name 'QuicAllowed' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $Regpath -Name 'EnableDoNotTrack' -Value 1 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $Regpath -Name 'ForceGoogleSafeSearch' -Value 1 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $Regpath -Name 'CryptoWalletEnabled' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath $Regpath -Name 'DirectInvokeEnabled' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)

$Regpath = $null
