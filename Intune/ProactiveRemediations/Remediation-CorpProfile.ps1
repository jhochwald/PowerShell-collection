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

$CorpNet = 'CORP-FQDN'

try
{
   $null = (Set-NetConnectionProfile -Name $CorpNet -NetworkCategory Private -Confirm:$false -ErrorAction Stop)
   $CorpNetStatus = ((Get-NetConnectionProfile -Name $CorpNet).networkcategory)

   if ($CorpNetStatus -eq 'Private')
   {
      exit 0
   }
   else
   {
      exit 1
   }
}
catch
{
   $errMsg = $_.Exception.Message
   Write-Error -Message $errMsg

   exit 1
}