# Enable Secure Sign-in (Ctrl+Alt+Del) for all users

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
$RegistryName = 'DisableCAD'
$RegistryPathTwo = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
$RegistryPathOne = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'

try
{
   if (-not (Test-Path -LiteralPath $RegistryPathOne -ErrorAction Stop))
   {
      Exit 1
   }

   if (-not (Test-Path -LiteralPath $RegistryPathTwo -ErrorAction Stop))
   {
      Exit 1
   }

   if (-not ((Get-ItemPropertyValue -LiteralPath $RegistryPathOne -Name $RegistryName -ErrorAction Stop) -eq 0))
   {
      Exit 1
   }

   if (-not ((Get-ItemPropertyValue -LiteralPath $RegistryPathTwo -Name $RegistryName -ErrorAction Stop) -eq 0))
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
