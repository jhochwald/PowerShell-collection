#requires -Version 2.0 -Modules Appx

$MSTeams = 'MicrosoftTeams'

try
{
   $paramGetAppxPackage = @{
      ErrorAction   = 'Stop'
      WarningAction = 'SilentlyContinue'
   }
   if (Get-AppxPackage @paramGetAppxPackage | Where-Object -FilterScript {
         ($_.Name -eq $MSTeams)
      })
   {
      exit 1
   }

   $paramGetItemProperty = @{
      Path          = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
      Name          = 'TaskbarMn'
      ErrorAction   = 'Stop'
      WarningAction = 'SilentlyContinue'
   }
   if (((Get-ItemProperty @paramGetItemProperty).TaskbarMn) -ne 0)
   {
      exit 1
   }
}
catch
{
   exit 1
}

exit 0
