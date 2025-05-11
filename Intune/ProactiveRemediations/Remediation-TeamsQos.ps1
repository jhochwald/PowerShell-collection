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
      $paramNewNetQosPolicy = @{
         AppPathNameMatchCondition    = 'Teams.exe'
         NetworkProfile               = 'All'
         IPSrcPortStartMatchCondition = 50000
         IPSrcPortEndMatchCondition   = 50019
         DSCPAction                   = 46
         IPProtocolMatchCondition     = 'Both'
         Name                         = 'Microsoft Teams Audio'
         Confirm                      = $false
         WarningAction                = 'Continue'
         ErrorAction                  = 'Stop'
      }
      $null = (New-NetQosPolicy @paramNewNetQosPolicy)
   }

   if (-not (Get-NetQosPolicy -Name 'Microsoft Teams Video' -ErrorAction SilentlyContinue))
   {
      $paramNewNetQosPolicy = @{
         AppPathNameMatchCondition    = 'Teams.exe'
         NetworkProfile               = 'All'
         IPSrcPortStartMatchCondition = 50020
         IPSrcPortEndMatchCondition   = 50039
         DSCPAction                   = 34
         IPProtocolMatchCondition     = 'Both'
         Name                         = 'Microsoft Teams Video'
         Confirm                      = $false
         WarningAction                = 'Continue'
         ErrorAction                  = 'Stop'
      }
      $null = (New-NetQosPolicy @paramNewNetQosPolicy)
   }

   if (-not (Get-NetQosPolicy -Name 'Microsoft Teams AppSharing' -ErrorAction SilentlyContinue))
   {
      $paramNewNetQosPolicy = @{
         AppPathNameMatchCondition    = 'Teams.exe'
         NetworkProfile               = 'All'
         IPSrcPortStartMatchCondition = 50040
         IPSrcPortEndMatchCondition   = 50059
         DSCPAction                   = 28
         IPProtocolMatchCondition     = 'Both'
         Name                         = 'Microsoft Teams AppSharing'
         Confirm                      = $false
         WarningAction                = 'Continue'
         ErrorAction                  = 'Stop'
      }
      $null = (New-NetQosPolicy @paramNewNetQosPolicy)
   }
}
catch
{
   # get error record
   [Management.Automation.ErrorRecord]$e = $_

   # retrieve information about runtime error
   $info = [PSCustomObject]@{
      Exception = $e.Exception.Message
      Reason    = $e.CategoryInfo.Reason
      Target    = $e.CategoryInfo.TargetName
      Script    = $e.InvocationInfo.ScriptName
      Line      = $e.InvocationInfo.ScriptLineNumber
      Column    = $e.InvocationInfo.OffsetInLine
   }

   Write-Verbose -Message $info
   
   $_ | Write-Error -ErrorAction Stop
   
   Exit 1
}

Exit 0