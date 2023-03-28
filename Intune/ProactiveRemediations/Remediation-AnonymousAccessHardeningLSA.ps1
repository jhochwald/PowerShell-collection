# Disable anonymous access to named pipes/shared, anonymous enumeration of SAM accounts, non-admin remote access to SAM
$RegPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'

try
{
   if ((Test-Path -LiteralPath $RegPath -ErrorAction SilentlyContinue) -ne $true)
   {
      $null = (New-Item -Path $RegPath -Force -Confirm:$false -ErrorAction SilentlyContinue )
   }

   $null = (New-ItemProperty -LiteralPath $RegPath -Name 'LimitBlankPasswordUse' -Value 1 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
   $null = (New-ItemProperty -LiteralPath $RegPath -Name 'restrictanonymous' -Value 1 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
   $null = (New-ItemProperty -LiteralPath $RegPath -Name 'restrictanonymoussam' -Value 1 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
   $null = (New-ItemProperty -LiteralPath $RegPath -Name 'RestrictRemoteSAM' -Value 'O:BAG:BAD:(A;;RC;;;BA)' -PropertyType String -Force -Confirm:$false -ErrorAction SilentlyContinue)
   $null = (New-ItemProperty -LiteralPath $RegPath -Name 'LmCompatibilityLevel' -Value 5 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
   $null = (New-ItemProperty -LiteralPath $RegPath -Name 'TokenLeakDetectDelaySecs' -Value 30 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
}
catch
{
   Exit 1
}

Exit 0