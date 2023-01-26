function Invoke-SubscribeToSessionSwitchEvents
{
   <#
         .SYNOPSIS
         Subscribe To SessionSwitch Events

         .DESCRIPTION
         Subscribe To SessionSwitch Events

         .EXAMPLE
         PS C:\> Invoke-SubscribeToSessionSwitchEvents

         Subscribe To SessionSwitch Events

         .LINK
         Invoke-UnsubscribeFromSessionSwitchEvents

         .NOTES
         Prototype, please change the loghic below
   #>
   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([string])]
   param ()

   process
   {
      $null = (Register-ObjectEvent -InputObject ([microsoft.win32.systemevents]) -EventName 'SessionSwitch' -Action {
            switch (($args[1]).Reason)
            {
               'SessionLock'
               {
                  #TODO: Add real Code to execute when session locks
                  [console]::Beep()
                  ('Bye bye {0}!' -f $env:username) | Add-Content -Path c:\temp\log.txt -Force
               }
               'SessionUnlock'
               {
                  #TODO: Add real Code to execute when session unlocks
                  [console]::Beep()
                  [console]::Beep()
                  ('Nice to see you again {0}!' -f $env:username) | Add-Content -Path c:\temp\log.txt -Force
               }
            }
      })
   }
}

function Invoke-UnsubscribeFromSessionSwitchEvents
{
   <#
         .SYNOPSIS
         Unsubscribe From SessionSwitch Events

         .DESCRIPTION
         Unsubscribe From SessionSwitch Events

         .EXAMPLE
         PS C:\> Invoke-UnsubscribeFromSessionSwitchEvents

         Unsubscribe From SessionSwitch Events

         .LINK
         Invoke-SubscribeToSessionSwitchEvents

         .NOTES
         Prototype
   #>
   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([string])]
   param ()

   begin
   {
      $events = (Get-EventSubscriber -ErrorAction SilentlyContinue | Where-Object -FilterScript {
            (($_.SourceObject -eq [Microsoft.Win32.SystemEvents]) -and ($_.EventName -eq 'SessionSwitch'))
      })
   }

   process
   {
      if ($events)
      {
         $jobs = ($events | Select-Object -ExpandProperty Action)
         $null = ($events | Unregister-Event -Force -Confirm:$false -ErrorAction SilentlyContinue)
         $null = ($jobs | Remove-Job -Force -Confirm:$false -ErrorAction SilentlyContinue)
      }
   }
}

<#
      Get-WinEvent -FilterHashtable @{
      LogName = 'Security'
      Id      = 4800, 4801
      } -MaxEvents 10
#>