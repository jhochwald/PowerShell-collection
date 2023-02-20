# Detection-TeamsFirewallPerUser.ps1

<#
      Create simple firewall rules for Microsoft Teams. if needed

      What does Simple mean:
      Allow TCP/UDP for Microsoft Teams on all Profiles to avoid Microsoft Defender Firewall messages on a client

      The rules will be checked and only created of they do NOT exist!
#>

$AllUsers = (Get-ChildItem -Directory -Path (Join-Path -Path $env:SystemDrive -ChildPath 'Users') -Exclude 'Public', 'ADMINI~*')

if ($null -ne $AllUsers)
{
   foreach ($User in $AllUsers)
   {
      try
      {
         $TeamsPath = $null
         $TeamsPath = (Join-Path -Path $User.FullName -ChildPath 'AppData\Local\Microsoft\Teams\Current\Teams.exe' -ErrorAction SilentlyContinue)

         if (Test-Path -Path $TeamsPath -ErrorAction SilentlyContinue)
         {
            if (-not (Get-NetFirewallApplicationFilter -Program $TeamsPath -ErrorAction Stop))
            {
               'UDP', 'TCP' | ForEach-Object -Process {
                  $DefenderRuleName = $null
                  $DefenderRuleName = ('Teams.exe ({0}) for ''{1}''' -f $_, $User.Name)

                  if (-not (Get-NetFirewallRule -DisplayName ('Inbound: ' + $DefenderRuleName) -ErrorAction Stop))
                  {
                     exit 1
                  }

                  if (-not (Get-NetFirewallRule -DisplayName ('Outbound: ' + $DefenderRuleName) -ErrorAction Stop))
                  {
                     exit 1
                  }

                  $DefenderRuleName = $null
               }
            }
         }
      }
      catch
      {
         # Re-Throw the Error
         $_ | Write-Error -ErrorAction Continue

         $HadErrors = $true
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