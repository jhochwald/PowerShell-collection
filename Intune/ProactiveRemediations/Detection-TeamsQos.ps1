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
   if (-not (Get-NetQosPolicy -Name 'Microsoft Teams Audio' -ErrorAction SilentlyContinue))
   {
      'NOT FOUND: Microsoft Teams Audio'
      Exit 1
   }

   if (-not (Get-NetQosPolicy -Name 'Microsoft Teams Video' -ErrorAction SilentlyContinue))
   {
      'NOT FOUND: Microsoft Teams Video'
      Exit 1
   }

   if (-not (Get-NetQosPolicy -Name 'Microsoft Teams AppSharing' -ErrorAction SilentlyContinue))
   {
      'NOT FOUND: Microsoft Teams AppSharing'
      Exit 1
   }
}
catch
{
   $_ | Write-Verbose
   Exit 1
}

Exit 0