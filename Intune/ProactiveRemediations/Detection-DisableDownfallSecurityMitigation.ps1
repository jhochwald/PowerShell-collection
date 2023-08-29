#requires -Version 5.0

# Disable Downfall security mitigation for maximum CPU performance
# https://support.microsoft.com/en-us/topic/kb5029778-how-to-manage-the-vulnerability-associated-with-cve-2022-40982-d461157c-0411-4a91-9fc5-9b29e0fe2782

$RegPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management'

try 
{
   if (!(Test-Path -LiteralPath $RegPath -ErrorAction SilentlyContinue))
   {
      Exit 1
   }

	
   if (!((Get-ItemPropertyValue -LiteralPath $RegPath -Name 'FeatureSettingsOverride' -ErrorAction SilentlyContinue) -eq 33554432))
   {
      Exit 1
   }
}
catch
{
   Exit 1
}

Exit 0
