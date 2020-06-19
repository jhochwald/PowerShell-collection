#requires -Version 3.0

<#
   .SYNOPSIS
   List all active Lync/Skype for Business conferences

   .DESCRIPTION
   List all active Lync/Skype for Business conferences

   .PARAMETER FrontendPool
   Please enter the Lync/Skype for Business Frontend Pool FQDN

   .EXAMPLE
   PS C:\> .\Get-CsActiveConferences.ps1 -FrontendPool 'atl-cs-001.litwareinc.com'

   .NOTES
   Originally written by Richard Brynteson

   .LINK
   https://masteringlync.com/2013/11/19/list-all-active-conferences-via-powershell/
#>
[CmdletBinding(ConfirmImpact = 'None',
   SupportsShouldProcess)]
param
(
   [Parameter(Mandatory,
      ValueFromPipeline,
      ValueFromPipelineByPropertyName,
      Position = 1,
      HelpMessage = 'Please enter the Frontend Pool FQDN')]
   [ValidateNotNullOrEmpty()]
   [Alias('PoolFQDN')]
   [string]
   $FrontendPool
)

begin
{
   # Convert UTC to Local timezone
   function Convert-UTCtoLocal
   {
      <#
         .SYNOPSIS
         Convert UTC to Local timezone

         .DESCRIPTION
         Convert UTC to Local timezone

         .PARAMETER UTCTime
         UTC Time Format datetime

         .EXAMPLE
         PS C:\> Convert-UTCtoLocal -UTCTime Value
         Convert UTC to Local timezone

         .OUTPUTS
         datetime

         .INPUTS
         datetime

         .NOTES
         Just a small internal Helper Script
      #>

      [CmdletBinding(ConfirmImpact = 'None')]
      [OutputType([datetime])]
      param
      (
         [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 1,
            HelpMessage = 'UTC Time Format datetime')]
         [ValidateNotNullOrEmpty()]
         [datetime]
         $UTCTime
      )

      begin
      {
         # Cleanup
         $LocalTime = $null
      }

      process
      {
         # Transform the Format
         $paramGetWmiObject = @{
            Class         = 'win32_timezone'
            ErrorAction   = 'Stop'
            WarningAction = 'SilentlyContinue'
         }
         $strCurrentTimeZone = ((Get-WmiObject @paramGetWmiObject).StandardName)
         $TZ = [TimeZoneInfo]::FindSystemTimeZoneById($strCurrentTimeZone)
         $LocalTime = [TimeZoneInfo]::ConvertTimeFromUtc($UTCTime, $TZ)
      }

      end
      {
         # Dump it
         return $LocalTime
      }
   }

   # Create a Dummy Object
   $Results = @()
}

process
{
   if ($pscmdlet.ShouldProcess('FrontendPool', 'Get A List of Computers that are members'))
   {
      try
      {
         # Cleanup
         $FrontendPoolComputers = $null

         # Get all member servers of the Lync pool
         $paramGetCsPool = @{
            Identity      = $FrontendPool
            ErrorAction   = 'Stop'
            WarningAction = 'SilentlyContinue'
         }
         $FrontendPoolComputers = ((Get-CsPool @paramGetCsPool).Computers)
      }
      catch
      {
         # Get error record
         [Management.Automation.ErrorRecord]$e = $_

         # Retrieve information about the error
         $info = [PSCustomObject]@{
            Exception = $e.Exception.Message
            Reason    = $e.CategoryInfo.Reason
            Target    = $e.CategoryInfo.TargetName
            Script    = $e.InvocationInfo.ScriptName
            Line      = $e.InvocationInfo.ScriptLineNumber
            Column    = $e.InvocationInfo.OffsetInLine
         }

         # Do some verbose stuff for troubleshooting
         $info | Out-String | Write-Verbose

         # Thow the error and go...
         Write-Error -Message "$info.Exception" -ErrorAction Stop

         # This is a point the code should never reach (You told PowerShell to Ignore the ErrorAction above!)
         break

         # OK, now we have reached a point the we would never, never ever, see
         exit 1
      }

      if (-not $FrontendPoolComputers)
      {
         # Get error record
         [Management.Automation.ErrorRecord]$e = $_

         # Retrieve information about the error
         $info = [PSCustomObject]@{
            Exception = $e.Exception.Message
            Reason    = $e.CategoryInfo.Reason
            Target    = $e.CategoryInfo.TargetName
            Script    = $e.InvocationInfo.ScriptName
            Line      = $e.InvocationInfo.ScriptLineNumber
            Column    = $e.InvocationInfo.OffsetInLine
         }

         # Do some verbose stuff for troubleshooting
         $info | Out-String | Write-Verbose

         # Thow the error and go...
         Write-Error -Message 'No members of the Lync Pool found...' -ErrorAction Stop

         # This is a point the code should never reach (You told PowerShell to Ignore the ErrorAction above!)
         break

         # OK, now we have reached a point the we would never, never ever, see
         exit 1
      }
   }

   if ($pscmdlet.ShouldProcess('FrontendPool', 'Get A List of Computers that are members'))
   {
      #Loop Through Front-End Pool
      foreach ($Computer in $FrontendPoolComputers)
      {
         try
         {
            # Create the Object with a SQL command
            $paramInvokeSQLCmd = @{
               ServerInstance = "$Computer\rtclocal"
               Database       = 'rtcdyn'
               Query          = "SELECT ActiveConference.ConfId AS 'Conference ID', ActiveConference.Locked, Participant.UserAtHost AS  'Participant', Participant.JoinTime AS 'Join Time', Participant.EnterpriseId, ActiveConference.IsLargeMeeting AS 'Large Meeting' FROM   ActiveConference INNER JOIN Participant ON ActiveConference.ConfId = Participant.ConfId;"
               ErrorAction    = 'Stop'
               WarningAction  = 'SilentlyContinue'
            }
            $Result = (Invoke-SQLCmd @paramInvokeSQLCmd)
            $Result | Add-Member -NotePropertyName 'Frontend' -NotePropertyValue $Computer
            $Result.'Join Time' = Convert-UTCtoLocal -UTCTime $Result.'Join Time'

            # Append
            $Results += $Result
         }
         catch
         {
            # Get error record
            [Management.Automation.ErrorRecord]$e = $_

            # Retrieve information about the error
            $info = [PSCustomObject]@{
               Exception = $e.Exception.Message
               Reason    = $e.CategoryInfo.Reason
               Target    = $e.CategoryInfo.TargetName
               Script    = $e.InvocationInfo.ScriptName
               Line      = $e.InvocationInfo.ScriptLineNumber
               Column    = $e.InvocationInfo.OffsetInLine
            }

            # Do some verbose stuff for troubleshooting
            $info | Out-String | Write-Verbose

            # A simple warning is OK here
            Write-Warning -Message "$info.Exception" -WarningAction Continue -ErrorAction Continue
         }
      }
   }
}

end
{
   if ($Results)
   {
      # Dump it
      $Results
   }
   else
   {
      # Thow the error and go...
      Write-Error -Message 'No Results found!' -ErrorAction Stop

      # This is a point the code should never reach (You told PowerShell to Ignore the ErrorAction above!)
      break

      # OK, now we have reached a point the we would never, never ever, see
      exit 1
   }
}

#region LICENSE
<#
      BSD 3-Clause License

      Copyright (c) 2020, enabling Technology
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
