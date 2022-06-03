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

#region Remediation
$MMAgentSetup = (Get-MMAgent -ErrorAction SilentlyContinue)

If ($MMAgentSetup.ApplicationPreLaunch -ne $true)
{
   exit 1
}

If ($MMAgentSetup.MaxOperationAPIFiles -lt 8192)
{
   exit 1
}

If ($MMAgentSetup.MemoryCompression -ne $true)
{
   exit 1
}

If ($MMAgentSetup.PageCombining -ne $true)
{
   exit 1
}

exit 0
#endregion Remediation
