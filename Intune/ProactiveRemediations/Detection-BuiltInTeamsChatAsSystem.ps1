#requires -Version 2.0 -Modules Dism -RunAsAdministrator

$MSTeams = 'MicrosoftTeams'

try
{
   $paramGetAppxProvisionedPackage = @{
      Online        = $true
      ErrorAction   = 'Stop'
      WarningAction = 'SilentlyContinue'
   }
   if (Get-AppxProvisionedPackage @paramGetAppxProvisionedPackage | Where-Object -FilterScript {
         ($_.DisplayName -eq $MSTeams)
      })
   {
      exit 1
   }

   $paramGetItemProperty = @{
      Path          = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Chat'
      Name          = 'ChatIcon'
      ErrorAction   = 'Stop'
      WarningAction = 'SilentlyContinue'
   }
   if (((Get-ItemProperty @paramGetItemProperty).ChatIcon) -ne 3)
   {
      exit 1
   }
}
catch
{
   exit 1
}

exit 0
