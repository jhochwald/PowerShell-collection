#requires -Version 3.0

function Invoke-KeepYouGreenInTheNewMicrosoftTeams
{
   <#
         .SYNOPSIS
         Keep you "green" in Teams, while the process is in the background

         .DESCRIPTION
         Keep you "green" in Teams, while the process is in the background

         .PARAMETER LoopTime
         Time, in seconds, to wait between the loops.

         The default is 120 (e.g., 2 minutes)

         Minimum is 30 seconds (Do not brute force Teams!)
         Maximum is 300 seconds (Should prevent status flickering)

         .EXAMPLE
         PS C:\> Invoke-KeepYouGreenInTheNewMicrosoftTeams

         Keep you "green" in Teams, while the process is in the background

         .NOTES
         "Did not call you, because you where away in Teams!"
         And I was active, but Microsoft Teams was minimized (Background) and I did my job: Write Code in my favorite editor.

         So, I came up with this Idea!

         What doe it so?
         It activates the minimized Microsoft Teams app, send some dummy key strokes and make a inactive again.
         You current window should not even realize that we did that!

         And as a benefit, it should keepalive your session, like "awake" (PowerToys) or "Caffeine"!

         Please do not abuse this in any kind...
   #>
   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([string])]
   param
   (
      [Parameter(ValueFromPipeline,
         ValueFromPipelineByPropertyName)]
      [ValidateRange(30, 300)]
      [ValidateNotNullOrEmpty()]
      [Alias('TimeToWait')]
      [int]
      $LoopTime = 120
   )

   begin
   {
      $null = (Add-Type -AssemblyName UIAutomationTypes -ErrorAction SilentlyContinue)
      $null = (Add-Type -AssemblyName UIAutomationClient -ErrorAction SilentlyContinue)

      # https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-showwindow?redirectedfrom=MSDN
      $Win32ShowWindowAsync = (Add-Type -MemberDefinition @'
[DllImport("user32.dll")]
public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
[DllImport("user32.dll", SetLastError = true)]
public static extern bool SetForegroundWindow(IntPtr hWnd);
'@ -Name 'Win32ShowWindowAsync' -Namespace Win32Functions -PassThru)

      # For the window states, from above
      $WindowStates = @{
         'FORCEMINIMIZE'   = 11
         'HIDE'            = 0
         'MAXIMIZE'        = 3
         'MINIMIZE'        = 6
         'RESTORE'         = 9
         'SHOW'            = 5
         'SHOWDEFAULT'     = 10
         'SHOWMAXIMIZED'   = 3
         'SHOWMINIMIZED'   = 2
         'SHOWMINNOACTIVE' = 7
         'SHOWNA'          = 8
         'SHOWNOACTIVATE'  = 4
         'SHOWNORMAL'      = 1
      }

      # This should never happen, right?
      if ($null -eq $LoopTime)
      {
         [int]$LoopTime = 120
      }
   }

   process
   {
      while ($true)
      {
         $TeamsApp = $null
         $TeamsApp = (Get-Process -Name 'ms-teams' -ErrorAction SilentlyContinue)


         if ($null -ne $TeamsApp)
         {
            # The title changes, it contains where you are and what you did, and therefore it can be very long
            $TeamsWindowTitle = $null
            $TeamsWindowTitle = ($TeamsApp).MainWindowTitle

            if ($null -ne $TeamsWindowTitle)
            {
               # if Minimized. Looks crappy, but it works very well here
               if ((([Windows.Automation.AutomationElement]::FromHandle($TeamsApp.MainWindowHandle)).GetCurrentPattern([Windows.Automation.WindowPatternIdentifiers]::Pattern)).Current.WindowVisualState -eq 'Minimized')
               {
                  Write-Verbose -Message 'Keeping you active (green) in Microsoft Teams!'

                  # Let us creates a new Component Object Model (COM) object, we need this this to send (inject) the keystrokes
                  # If Windows Script Host (WSH) is disabled, this might fail
                  $wshell = $null
                  $wshell = (New-Object -ComObject wscript.shell -ErrorAction SilentlyContinue)

                  # Make it active, but we keep it in the background (This is the secret sauce here)
                  $null = ($Win32ShowWindowAsync::ShowWindowAsync($TeamsApp.MainWindowHandle, $WindowStates['SHOWMINIMIZED']))

                  # Calm down and wait a very short moment here
                  $null = (Start-Sleep -Milliseconds 500)

                  # Send the dummy keystrokes, one that Teams don't know, therefore: So nothing
                  if ($null -ne $wshell)
                  {
                     $null = ($wshell.SendKeys('+{F15}'))
                  }
                  else
                  {
                     Write-Warning -Message 'We cannot send the dummy keystrokes!'
                  }

                  # Minimize and inactivate it again
                  $null = ($Win32ShowWindowAsync::ShowWindowAsync($TeamsApp.MainWindowHandle, $WindowStates['SHOWMINNOACTIVE']))
               }
               else
               {
                  # Your Teams Client in not in the background! No further action needed here.
                  Write-Verbose -Message 'Looks like Microsoft Teams is not in the background, so we do nothing here.'
               }
            }

            # Now we wait for the next loop
            $null = (Start-Sleep -Seconds $LoopTime)
         }
         else
         {
            Write-Verbose -Message 'Looks like Microsoft Teams is not even running.'

            # Therefore, we are done here!
            break
         }
      }
   }
}

Invoke-KeepYouGreenInTheNewMicrosoftTeams
