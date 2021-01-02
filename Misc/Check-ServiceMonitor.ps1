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

#region LICENSE
<#
      BSD 3-Clause License

      Copyright (c) 2021, enabling Technology
      All rights reserved.

      Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
      1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
      2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
      3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

      THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>
#endregion LICENSE

#region DISCLAIMER
<#
      DISCLAIMER:
      - Use at your own risk, etc.
      - This is open-source software, if you find an issue try to fix it yourself. There is no support and/or warranty in any kind
      - This is a third-party Software
      - The developer of this Software is NOT sponsored by or affiliated with Microsoft Corp (MSFT) or any of its subsidiaries in any way
      - The Software is not supported by Microsoft Corp (MSFT)
      - By using the Software, you agree to the License, Terms, and any Conditions declared and described above
      - If you disagree with any of the Terms, and any Conditions declared: Just delete it and build your own solution
#>
#endregion DISCLAIMER
