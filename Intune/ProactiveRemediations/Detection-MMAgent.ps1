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
$MMAgentSetup = (Get-MMAgent -ErrorAction SilentlyContinue)

If ($MMAgentSetup.ApplicationPreLaunch -ne $true)
{
   $null = (Enable-MMAgent -ApplicationPreLaunch -ErrorAction SilentlyContinue)
}

If ($MMAgentSetup.MaxOperationAPIFiles -lt 8192)
{
   $null = (Set-MMAgent -MaxOperationAPIFiles 8192 -ErrorAction SilentlyContinue)
}

If ($MMAgentSetup.MemoryCompression -ne $true)
{
   $null = (Enable-MMAgent -MemoryCompression -ErrorAction SilentlyContinue)
}

If ($MMAgentSetup.PageCombining -ne $true)
{
   $null = (Enable-MMAgent -PageCombining -ErrorAction SilentlyContinue)
}

exit 0
#endregion Check
