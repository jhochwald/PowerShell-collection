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

if ((Test-Path -LiteralPath 'HKCU:\Software\Microsoft\Office\16.0\Outlook\Preferences') -ne $true)
{
   $null = (New-Item -Path 'HKCU:\Software\Microsoft\Office\16.0\Outlook\Preferences' -ItemType Directory -Force -Confirm:$false -ErrorAction SilentlyContinue)
}

if ((Test-Path -LiteralPath 'HKCU:\Software\Microsoft\Office\15.0\Outlook\Preferences') -ne $true)
{
   $null = (New-Item -Path 'HKCU:\Software\Microsoft\Office\15.0\Outlook\Preferences' -ItemType Directory -Force -Confirm:$false -ErrorAction SilentlyContinue)
}

$null = (New-ItemProperty -LiteralPath 'HKCU:\Software\Microsoft\Office\16.0\Outlook\Preferences' -Name 'DelegateSentItemsStyle' -Value 1 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -LiteralPath 'HKCU:\Software\Microsoft\Office\15.0\Outlook\Preferences' -Name 'DelegateSentItemsStyle' -Value 1 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
