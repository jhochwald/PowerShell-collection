# Disable Show Lock Screen Background on Sign-in Screen

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

#region Check
$RegistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'

try
{
   if (-not (Test-Path -LiteralPath $RegistryPath -ErrorAction Stop))
   {
      Exit 1
   }

   if (-not ((Get-ItemPropertyValue -LiteralPath $RegistryPath -Name 'DisableLogonBackgroundImage' -ErrorAction Stop) -eq 1))
   {
      Exit 1
   }
}
catch
{
   Exit 1
}

Exit 0
#region Check
