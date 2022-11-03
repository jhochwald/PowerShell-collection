#region ARM64Handling
# Restart Process using PowerShell 64-bit
if ($ENV:PROCESSOR_ARCHITEW6432 -eq 'AMD64')
{
   try
   {
      &"$ENV:WINDIR\SysNative\WindowsPowershell\v1.0\PowerShell.exe" -File $PSCOMMANDPATH
   }
   catch
   {
      Throw ('Failed to start {0}' -f $PSCOMMANDPATH)
   }

   exit
}
#endregion ARM64Handling

#region CheckScript
$RegistryPath = 'HKLM:\SOFTWARE\Microsoft\MSRDC\Policies'

try 
{
   if (-not (Test-Path -LiteralPath $RegistryPath -ErrorAction Stop))
   {
      Exit 1
   }

   if (-not ((Get-ItemPropertyValue -LiteralPath $RegistryPath -Name 'ReleaseRing' -ErrorAction Stop) -eq 'insider')) 
   {
      Exit 1
   }
}
catch 
{
   Throw $_
   Exit 1
}

Exit 0
#endregion CheckScript