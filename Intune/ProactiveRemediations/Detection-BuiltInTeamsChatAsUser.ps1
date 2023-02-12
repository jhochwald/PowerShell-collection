#requires -Version 2.0 -Modules Appx

$MSTeams = 'MicrosoftTeams'

try
{
   if (Get-AppxPackage -ErrorAction Stop | Where-Object -FilterScript {
         ($_.Name -eq $MSTeams)
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
