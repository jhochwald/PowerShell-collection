#requires -Version 3.0 -Modules CimCmdlets, Microsoft.PowerShell.LocalAccounts

# Renames the default administrator account on the local machine
# Intune remediation script for Cloud based LAPS

# Set the the new administrator account name
$NewAdmin = 'localadmin' # Change this to the name you want

# Get the data
$AdminAccount = (Get-CimInstance -ClassName Win32_UserAccount -Filter "LocalAccount = TRUE and SID like 'S-1-5-%-500'")

# Check if the default administrator account exists
if (($AdminAccount.Name) -ne $NewAdmin)
{
   try
   {
      # Rename the default administrator account to the new administrator account
      $null = (Rename-LocalUser -SID ($AdminAccount.SID) -NewName $NewAdmin -ErrorAction Stop -Confirm:$false)
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

      # output information. Post-process collected info, and log info (optional)
      $info | Out-String

      # re-throw exception
      $_ | Write-Error -ErrorAction Stop
   }
}
