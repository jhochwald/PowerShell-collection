# Save Sent Items in Shared Mailbox Sent Items folder only

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

try
{
   if (-not (Test-Path -LiteralPath 'HKCU:\Software\Microsoft\Office\16.0\Outlook\Preferences'))
   {
      Exit 1
   }

   if (-not (Test-Path -LiteralPath 'HKCU:\Software\Microsoft\Office\15.0\Outlook\Preferences'))
   {
      Exit 1
   }

   if (-not ((Get-ItemPropertyValue -LiteralPath 'HKCU:\Software\Microsoft\Office\16.0\Outlook\Preferences' -Name 'DelegateSentItemsStyle' -ErrorAction SilentlyContinue) -eq 1))
   {
      Exit 1
   }

   if (-not ((Get-ItemPropertyValue -LiteralPath 'HKCU:\Software\Microsoft\Office\15.0\Outlook\Preferences' -Name 'DelegateSentItemsStyle' -ErrorAction SilentlyContinue) -eq 1))
   {
      Exit 1
   }
}
catch
{
   Exit 1
}

Exit 0