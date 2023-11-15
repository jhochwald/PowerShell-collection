# Remediate-NewTeamsFirewallPerUser.ps1

<#
      Create simple firewall rules for Microsoft Teams. if needed

      Adopted script to cover the new Microsoft Teams Client
      Due to the name change (the new name is 'ms-teams.exe' instad of 'teams.exe') of the client

      What does Simple mean:
      Allow TCP/UDP for Microsoft Teams on all Profiles to avoid Microsoft Defender Firewall messages on a client

      The rules will be checked and only created of they do NOT exist!

      License: BSD 3-Clause License
      Copyright © 2023 by enabling Technology. All rights reserved.
#>

#region 32BitRestarter
# If we are running as a 32-bit process on an x64 system, re-launch as a 64-bit process
# Idea is stolen from Michael Niehaus - https://oofhours.com
if ($env:PROCESSOR_ARCHITEW6432 -ne 'ARM64')
{
   if (Test-Path -Path ('{0}\SysNative\WindowsPowerShell\v1.0\powershell.exe' -f $env:WINDIR) -ErrorAction SilentlyContinue)
   {
      & "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy bypass -File $PSCommandPath
      Exit $lastexitcode
   }
}
#endregion 32BitRestarter

$AllUsers = (Get-ChildItem -Directory -Path (Join-Path -Path $env:SystemDrive -ChildPath 'Users') -Exclude 'Public', 'ADMINI~*')

if ($null -ne $AllUsers)
{
   foreach ($User in $AllUsers)
   {
      $TeamsPath = $null
      $TeamsPath = (Join-Path -Path $User.FullName -ChildPath 'AppData\Local\Microsoft\Teams\Current\Teams.exe' -ErrorAction SilentlyContinue)

      if (Test-Path -Path $TeamsPath -ErrorAction SilentlyContinue)
      {
         if (-not (Get-NetFirewallApplicationFilter -Program $TeamsPath -ErrorAction SilentlyContinue))
         {
            'UDP', 'TCP' | ForEach-Object -Process {
               $DefenderRuleName = $null
               $DefenderRuleName = ('Teams.exe ({0}) for ''{1}''' -f $_, $User.Name)

               try
               {
                  if (-not (Get-NetFirewallRule -DisplayName ('Inbound: ' + $DefenderRuleName) -ErrorAction SilentlyContinue))
                  {
                     $paramNewNetFirewallRule = @{
                        DisplayName = ('Inbound: ' + $DefenderRuleName)
                        Direction   = 'Inbound'
                        Profile     = 'Any'
                        Program     = $TeamsPath
                        Action      = 'Allow'
                        Protocol    = $_
                        Confirm     = $false
                        ErrorAction = 'Stop'
                     }
                     $null = (New-NetFirewallRule @paramNewNetFirewallRule)
                  }

                  if (-not (Get-NetFirewallRule -DisplayName ('Outbound: ' + $DefenderRuleName) -ErrorAction SilentlyContinue))
                  {
                     $paramNewNetFirewallRule = @{
                        DisplayName = ('Outbound: ' + $DefenderRuleName)
                        Direction   = 'Outbound'
                        Profile     = 'Any'
                        Program     = $TeamsPath
                        Action      = 'Allow'
                        Protocol    = $_
                        Confirm     = $false
                        ErrorAction = 'Stop'
                     }
                     $null = (New-NetFirewallRule @paramNewNetFirewallRule)
                  }
               }
               catch
               {
                  # Re-Throw the Error
                  $_ | Write-Error -ErrorAction Continue

                  $HadErrors = $true
               }
               $DefenderRuleName = $null
            }
         }
      }

      $TeamsPath = $null
   }
}

if ($HadErrors -eq $true)
{
   exit 1
}
else
{
   exit 0
}
