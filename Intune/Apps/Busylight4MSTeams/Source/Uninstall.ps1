# 7.0.2.0090

#region
$SCT = 'SilentlyContinue'
#endregion

# Restart Process using PowerShell 64-bit
If ($ENV:PROCESSOR_ARCHITEW6432 -eq 'AMD64')
{
   Try
   {
      &"$ENV:WINDIR\SysNative\WindowsPowershell\v1.0\PowerShell.exe" -File $PSCOMMANDPATH
   }
   Catch
   {
      Throw ('Failed to start {0}' -f $PSCOMMANDPATH)
   }

   Exit
}

# Stop FortiClient Process
$null = (Stop-Process -Name FortiClient -Force -Confirm:$false -ErrorAction $SCT)

# Uninstall FortiClient
$null = (Start-Process -FilePath ('{0}\system32\msiexec.exe' -f $env:windir) -Wait -ArgumentList /'x {C0063176-0C6B-4087-B19D-437BD6CD7341} /qn')

