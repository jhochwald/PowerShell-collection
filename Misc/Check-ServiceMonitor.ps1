#requires -Version 3.0 -RunAsAdministrator

<#
    .SYNOPSIS
    Quick an dirty Windows Service Monitor

    .DESCRIPTION
    I came accross the the problem, that one of the services I depend one was not started after the system reboots.
    That happend aftzer a .NET update. So I decided to create this real simple monitor to make sure, that this service is running.
    If not, the script tries to restart it.

    .PARAMETER MonService
    The Service we would like to check. Default is RoyalServer

    .EXAMPLE
    PS C:\> .\Check-ServiceMonitor.ps1

    .EXAMPLE
    PS C:\> .\Check-ServiceMonitor.ps1 -MonService 'myservice'

    .NOTES
    The script itself have some basic error handling,
    nothing to complex or fancy.
#>
[CmdletBinding(ConfirmImpact = 'None')]
param
(
  [Parameter(ValueFromPipeline,
  Position = 1)]
  [Alias('ServiceToMonitor')]
  [string]
  $MonService = 'RoyalServer'
)

begin
{
  [string]$SC = 'SilentlyContinue'
  [string]$STP = 'Stop'
}

process
{
  # Get the Status
  try
  {
    Write-Verbose -Message ('Get the Status of {0}' -f $MonService)

    $paramGetService = @{
      Name          = $MonService
      ErrorAction   = $STP
      WarningAction = $SC
    }

    [string]$MonServiceStatus = ((Get-Service @paramGetService).Status)

    Write-Verbose -Message ('We have the Status of {0}' -f $MonService)
  }
  catch
  {
    Write-Error -Message ('Looks like the Service {0} is not installed!' -f $MonService) -ErrorAction $STP

    # Point of no return (Should never be reached)
    break
  }


  # Do the check
  if ($MonServiceStatus -ne 'Running')
  {
    Write-Warning -Message ('Sorry, but {0} is not running ' -f $MonService)

    try
    {
      Write-Verbose -Message ('Try to restart {0}' -f $MonService)

      $MonParam = @{
        Name          = $MonService
        Confirm       = $false
        ErrorAction   = $STP
        WarningAction = $SC
      }

      $null = (Restart-Service @MonParam)
    }
    catch
    {
      # Whooooops! Try it again... Let us try to stop the services

      Write-Verbose -Message ('Try to stop {0}' -f $MonService)
      $null = (Stop-Service @MonParam)

      # Wait a second
      $null = (Start-Sleep -Seconds 1)

      # Try to stop it again...
      $null = (Stop-Service @MonParam)

      # Wait a second
      $null = (Start-Sleep -Seconds 1)

      # Try to kill it, again!
      $null = (Stop-Service @MonParam)

      # Wait two seconds to cool down
      Write-Verbose -Message ('Try to start {0}' -f $MonService)

      $null = (Start-Sleep -Seconds 2)

      try
      {
        # Now let us try to start the service
        Write-Verbose -Message ('Try to start {0} again!' -f $MonService)

        $null = (Start-Service @MonParam)
      }
      catch
      {
        # Dude, this is bad! And I mean real bad!!!
        Write-Error -Message ('We where not able to start {0} - Might be a good idea to reboot this system' -f $MonService)
      }
    }
  }
  else
  {
    # Looks good so far
    Write-Verbose -Message ('Looks like {0} is doing great...' -f $MonService)
  }
}
