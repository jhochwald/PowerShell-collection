#requires -Version 1.0

# Disable Downfall security mitigation for maximum CPU performance
# https://support.microsoft.com/en-us/topic/kb5029778-how-to-manage-the-vulnerability-associated-with-cve-2022-40982-d461157c-0411-4a91-9fc5-9b29e0fe2782

$RegPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management'

if ((Test-Path -LiteralPath $RegPath -ErrorAction SilentlyContinue) -ne $true)
{
   $null = (New-Item -Path $RegPath -Force -Confirm:$false -ErrorAction SilentlyContinue)
}

$null = (New-ItemProperty -LiteralPath $RegPath -Name 'FeatureSettingsOverride' -Value 33554432 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
