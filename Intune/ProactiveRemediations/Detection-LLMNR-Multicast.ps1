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
try
{
   if (-not ((Get-ItemProperty -Path 'HKLM:\Software\policies\Microsoft\Windows NT\DNSClient' -Name 'EnableMulticast' -ErrorAction Stop | Select-Object -ExpandProperty 'EnableMulticast') -eq 0))
   {
      exit 1
   }
}
catch
{
   exit 1
}

exit 0
#endregion Check