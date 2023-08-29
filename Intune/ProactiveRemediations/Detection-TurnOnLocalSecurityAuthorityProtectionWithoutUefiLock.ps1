#requires -Version 5.0

# Turn On Local Security Authority (LSA) Protection without UEFI Lock
# Detection-TurnOnLocalSecurityAuthorityProtectionWithoutUefiLock

$RegPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'

try
{
   if (!(Test-Path -LiteralPath $RegPath -ErrorAction SilentlyContinue))
   {
      exit 1
   }
   
   
   if (!((Get-ItemPropertyValue -LiteralPath $RegPath -Name 'RunAsPPL' -ErrorAction SilentlyContinue) -eq 2))
   {
      exit 1
   }
   
   if (!((Get-ItemPropertyValue -LiteralPath $RegPath -Name 'RunAsPPLBoot' -ErrorAction SilentlyContinue) -eq 2))
   {
      exit 1
   }
}
catch
{
   exit 1
}

exit 0
