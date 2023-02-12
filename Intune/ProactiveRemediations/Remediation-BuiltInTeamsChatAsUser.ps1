#requires -Version 2.0 -Modules Appx

$MSTeams = 'MicrosoftTeams'

try
{
   $TeamsAppxPackage = (Get-AppxPackage -ErrorAction Stop | Where-Object -FilterScript {
         ($_.Name -eq $MSTeams)
      })

   if ($TeamsAppxPackage)
   {
      $paramRemoveAppxPackage = @{
         Package       = $TeamsAppxPackage.PackageFullName
         Confirm       = $false
         ErrorAction   = 'Stop'
         WarningAction = 'SilentlyContinue'
      }
      $null = (Remove-AppxPackage @paramRemoveAppxPackage)
   }

   $paramNewItemProperty = @{
      Path          = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
      Name          = 'TaskbarMn'
      PropertyType  = 'DWord'
      Value         = 0
      Force         = $true
      Confirm       = $false
      ErrorAction   = 'SilentlyContinue'
      WarningAction = 'SilentlyContinue'
   }
   $null = (New-ItemProperty @paramNewItemProperty)
}
catch
{
   exit 1
}

exit 0
