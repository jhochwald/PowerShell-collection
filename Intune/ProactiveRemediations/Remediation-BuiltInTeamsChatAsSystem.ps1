#requires -Version 2.0 -Modules Dism -RunAsAdministrator

$MSTeams = 'MicrosoftTeams'

try
{
   $TeamsAppxProvisionedPackage = (Get-AppxProvisionedPackage -Online -ErrorAction Stop | Where-Object -FilterScript {
         ($_.DisplayName -eq $MSTeams)
      })

   if ($TeamsAppxProvisionedPackage)
   {
      $null = (Remove-AppxProvisionedPackage -Online -PackageName $TeamsAppxProvisionedPackage.Packagename -AllUsers -ErrorAction Stop)
   }

   Exit 0
}
catch
{
   Exit 1
}

Exit 0
