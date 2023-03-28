# Disable anonymous access to named pipes/shared, anonymous enumeration of SAM accounts, non-admin remote access to SAM
$RegPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'

try
{
   if (-not (Test-Path -LiteralPath $RegPath -ErrorAction SilentlyContinue))
   {
      Exit 1
   }

   if (-not ((Get-ItemPropertyValue -LiteralPath $RegPath -Name 'LimitBlankPasswordUse' -ErrorAction SilentlyContinue) -eq 1))
   {
      Exit 1
   }

   if (-not ((Get-ItemPropertyValue -LiteralPath $RegPath -Name 'restrictanonymous' -ErrorAction SilentlyContinue) -eq 1))
   {
      Exit 1
   }

   if (-not ((Get-ItemPropertyValue -LiteralPath $RegPath -Name 'restrictanonymoussam' -ErrorAction SilentlyContinue) -eq 1))
   {
      Exit 1
   }

   if (-not ((Get-ItemPropertyValue -LiteralPath $RegPath -Name 'RestrictRemoteSAM' -ErrorAction SilentlyContinue) -eq 'O:BAG:BAD:(A;;RC;;;BA)'))
   {
      Exit 1
   }

   if (-not ((Get-ItemPropertyValue -LiteralPath $RegPath -Name 'LmCompatibilityLevel' -ErrorAction SilentlyContinue) -eq 5))
   {
      Exit 1
   }

   if (-not ((Get-ItemPropertyValue -LiteralPath $RegPath -Name 'TokenLeakDetectDelaySecs' -ErrorAction SilentlyContinue) -eq 30))
   {
      Exit 1
   }
}
catch
{
   Exit 1
}

Exit 0