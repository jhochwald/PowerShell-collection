#requires -Version 2.0 -Modules Dism -RunAsAdministrator

$MSTeams = 'MicrosoftTeams'

try
{
   $TeamsAppxProvisionedPackage = (Get-AppxProvisionedPackage -Online -ErrorAction Stop | Where-Object -FilterScript {
         ($_.DisplayName -eq $MSTeams)
      })

   if ($TeamsAppxProvisionedPackage)
   {
      $paramRemoveAppxProvisionedPackage = @{
         Online        = $true
         PackageName   = $TeamsAppxProvisionedPackage.Packagename
         AllUsers      = $true
         ErrorAction   = 'Stop'
         WarningAction = 'SilentlyContinue'
      }
      $null = (Remove-AppxProvisionedPackage @paramRemoveAppxProvisionedPackage)
   }

   $paramNewItemProperty = @{
      Path          = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Chat'
      Name          = 'ChatIcon'
      PropertyType  = 'DWord'
      Value         = 3
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
