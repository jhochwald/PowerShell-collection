#requires -Version 2.0 -Modules CimCmdlets

# Renames the default administrator account on the local machine
# Intune detection script for Cloud based LAPS

# Set the the new administrator account name
$NewAdmin = 'localadmin' # Change this to the name you want

# Get the data
$AdminAccount = (Get-CimInstance -ClassName Win32_UserAccount -Filter "LocalAccount = TRUE and SID like 'S-1-5-%-500'")

(($AdminAccount.Name) -ne $NewAdmin)
{
   exit 1
}
else
{
   exit 0
}
