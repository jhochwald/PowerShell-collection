#requires -Version 2.0 -Modules Dism -RunAsAdministrator

$MSTeams = 'MicrosoftTeams'

try
{
   if (Get-AppxProvisionedPackage -Online -ErrorAction Stop | Where-Object -FilterScript {
         ($_.DisplayName -eq $MSTeams)
   })
   {
      Exit 1
   }
   else
   {
      Exit 0
   }
}
catch
{
   Exit 1
}

Exit 0
