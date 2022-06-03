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
#region Defaults
$STP = 'Stop'
$SCT = 'SilentlyContinue'
#endregion Defaults

# Clean-up
$RegistryRoot = $null

# Figure out if we have an existing PowerShell Registry Provider mapping
$paramGetPSDrive = @{
   ErrorAction   = $SCT
   WarningAction = $SCT
}
$RegistryRoot = ((Get-PSDrive @paramGetPSDrive | Where-Object {
         $PSItem.Root -eq 'HKEY_CLASSES_ROOT'
      }).Name)
$paramGetPSDrive = $null

if (-not ($RegistryRoot))
{
   # PowerShell Registry Provider
   $paramNewPSDrive = @{
      PSProvider  = 'registry'
      Root        = 'HKEY_CLASSES_ROOT'
      Name        = 'HKCR'
      ErrorAction = $STP
   }
   $RegistryRoot = ((New-PSDrive @paramNewPSDrive).Name)
   $paramNewPSDrive = $null
}

try
{
   If (Get-Item -Path ('{0}:\ms-msdt' -f $RegistryRoot) -ErrorAction $SCT)
   {
      # Guidance for CVE-2022-30190 Microsoft Support Diagnostic Tool Vulnerability
      $paramRemoveItem = @{
         Path          = ('{0}:\ms-msdt' -f $RegistryRoot)
         Force         = $true
         Recurse       = $true
         ErrorAction   = $STP
         WarningAction = $SCT
      }
      $null = (Remove-Item @paramRemoveItem)
      $paramRemoveItem = $null
   }
}
catch
{
   [Management.Automation.ErrorRecord]$e = $_

   $info = [PSCustomObject]@{
      Exception = $e.Exception.Message
      Reason    = $e.CategoryInfo.Reason
      Target    = $e.CategoryInfo.TargetName
      Script    = $e.InvocationInfo.ScriptName
      Line      = $e.InvocationInfo.ScriptLineNumber
      Column    = $e.InvocationInfo.OffsetInLine
   }

   Write-Warning -Message $info -WarningAction Continue

   exit 1
}

exit 0
#endregion Remediation
