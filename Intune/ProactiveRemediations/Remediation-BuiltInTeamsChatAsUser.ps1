#requires -Version 2.0 -Modules Appx

$MSTeams = 'MicrosoftTeams'

try
{
   $TeamsAppxPackage = (Get-AppxPackage -ErrorAction Stop | Where-Object -FilterScript {
         ($_.Name -eq $MSTeams)
      })

   if ($TeamsAppxPackage)
   {
      $null = (Remove-AppxPackage -Package $TeamsAppxPackage.PackageFullName -Confirm:$false -ErrorAction Stop)
   }

   Exit 0
}
catch
{
   Exit 1
}

Exit 0
