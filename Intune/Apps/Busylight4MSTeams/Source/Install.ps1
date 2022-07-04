# 2.1.7
# "C:\Program Files\Busylight for MS Teams\Busylight4MSTeams64.exe"

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

# Install Busylight 4 Microsoft Teams
Start-Process -FilePath ('{0}\system32\msiexec.exe' -f $env:windir) -Wait -ArgumentList '/i Busylight4MS_Teams_Setup.msi TRANSFORMS=Busylight4MS_Teams_Setup.mst /qn  /norestart'

