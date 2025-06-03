# Please check everything, before deploy it to Intune.
# Please apply source formatting!

if ((Test-Path -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -ErrorAction SilentlyContinue) -ne $true)
{
   $null = (New-Item -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Force -Confirm:$false -ErrorAction SilentlyContinue)
}

if ((Test-Path -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0' -ErrorAction SilentlyContinue) -ne $true)
{
   $null = (New-Item -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0' -Force -Confirm:$false -ErrorAction SilentlyContinue)
}

$null = (New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name 'fullprivilegeauditing' -Value ([byte[]](0x00)) -PropertyType Binary -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name 'LimitBlankPasswordUse' -Value 1 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name 'NoLmHash' -Value 1 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name 'disabledomaincreds' -Value 1 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name 'restrictanonymous' -Value 1 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name 'restrictanonymoussam' -Value 1 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name 'LmCompatibilityLevel' -Value 5 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name 'RunAsPPL' -Value 1 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name 'RunAsPPLBoot' -Value 2 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0' -Name 'NtlmMinClientSec' -Value 537395200 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0' -Name 'NtlmMinServerSec' -Value 537395200 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
