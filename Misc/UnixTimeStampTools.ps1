function ConvertFrom-UnixTimeStamp
{
   <#
         .SYNOPSIS
         Converts a Timestamp (Epochdate) into Datetime

         .DESCRIPTION
         Converts a Timestamp (Epochdate) into Datetime

         .PARAMETER TimeStamp
         Timestamp (Epochdate)

         .PARAMETER Milliseconds
         Is the given Timestamp (Epochdate) in Miliseconds instead of Seconds?

         .EXAMPLE
         PS C:\> ConvertFrom-UnixTimeStamp -TimeStamp 1547839380

         Converts a Timestamp (Epochdate) into Datetime

         .EXAMPLE
         PS C:\> ConvertFrom-UnixTimeStamp -TimeStamp 1547839380712 -Milliseconds

         Converts a Timestamp (Epochdate) into Datetime, given value is in Milliseconds

         .NOTES
         Added the 'UniFi' (Alias for the switch 'Milliseconds') because the API returns miliseconds instead of seconds
   #>
   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([datetime])]
   param
   (
      [Parameter(Mandatory,
         ValueFromPipeline,
         Position = 0,
         HelpMessage = 'Timestamp (Epochdate)')]
      [ValidateNotNullOrEmpty()]
      [Alias('Epochdate')]
      [long]
      $TimeStamp,
      [Parameter(ValueFromPipeline,
         ValueFromPipelineByPropertyName,
         Position = 1)]
      [Alias('UniFi')]
      [switch]
      $Milliseconds = $false
   )

   begin
   {
      # Set some defaults
      $UnixStartTime = '1/1/1970'

      # Cleanup
      $Result = $null
   }

   process
   {
      try
      {
         if ($Milliseconds)
         {
            $Result = ((Get-Date -Date $UnixStartTime -ErrorAction Stop -WarningAction SilentlyContinue).AddMilliseconds($TimeStamp))
         }
         else
         {
            try
            {
               $Result = ((Get-Date -Date $UnixStartTime -ErrorAction Stop -WarningAction SilentlyContinue).AddSeconds($TimeStamp))
            }
            catch
            {
               # Try a Fallback!
               $Result = ((Get-Date -Date $UnixStartTime -ErrorAction Stop -WarningAction SilentlyContinue).AddMilliseconds($TimeStamp))
            }
         }
      }
      catch
      {
         # get error record
         [Management.Automation.ErrorRecord]$e = $_

         # retrieve information about runtime error
         $info = [PSCustomObject]@{
            Exception = $e.Exception.Message
            Reason    = $e.CategoryInfo.Reason
            Target    = $e.CategoryInfo.TargetName
            Script    = $e.InvocationInfo.ScriptName
            Line      = $e.InvocationInfo.ScriptLineNumber
            Column    = $e.InvocationInfo.OffsetInLine
         }

         $info | Out-String | Write-Verbose

         Write-Error -Message ($info.Exception) -ErrorAction Stop

         # Only here to catch a global ErrorAction overwrite
         break
      }
   }

   end
   {
      $Result
   }
}

function ConvertTo-UnixTimeStamp
{
   <#
         .SYNOPSIS
         Converts a Datetime into a Unix Timestamp (Epochdate)

         .DESCRIPTION
         Converts a Datetime into a Unix Timestamp (Epochdate)

         .PARAMETER Date
         The Date String that should be converted, default is now (if none is given)

         .PARAMETER Milliseconds
         Should the Timestamp (Epochdate) in Miliseconds instead of Seconds?

         .EXAMPLE
         PS C:\> ConvertTo-UnixTimeStamp

         Converts the actual time into a Unix Timestamp (Epochdate)

         .EXAMPLE
         PS C:\> ConvertTo-UnixTimeStamp -Milliseconds

         Converts the actual time into a Unix Timestamp (Epochdate), in milliseconds

         .EXAMPLE
         PS C:\> ConvertTo-UnixTimeStamp -Date ((Get-Date).AddDays(-1))

         Covert the same time yesterday into a Unix Timestamp (Epochdate)

         .EXAMPLE
         PS C:\> ConvertTo-UnixTimeStamp -Date ((Get-Date).AddDays(-1)) -Milliseconds

         Covert the same time yesterday into a Unix Timestamp (Epochdate), in milliseconds

         .NOTES
         Added the 'UniFi' (Alias for the switch 'Milliseconds') because the API returns milliseconds instead of seconds
   #>

   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([long])]
   param
   (
      [Parameter(ValueFromPipeline,
         ValueFromPipelineByPropertyName,
         Position = 0)]
      [ValidateNotNullOrEmpty()]
      [Alias('TimeStamp', 'DateTimeStamp')]
      [datetime]
      $Date = (Get-Date),
      [Parameter(ValueFromPipeline,
         ValueFromPipelineByPropertyName,
         Position = 1)]
      [Alias('UniFi')]
      [switch]
      $Milliseconds = $false
   )

   begin
   {
      # Set some defaults
      $UnixStartTime = '1/1/1970'

      # Cleanup
      $Result = $null
   }

   process
   {
      try
      {
         if ($Milliseconds)
         {
            $Result = ([long]((New-TimeSpan -Start (Get-Date -Date $UnixStartTime -ErrorAction Stop -WarningAction SilentlyContinue) -End (Get-Date -Date $Date -ErrorAction Stop -WarningAction SilentlyContinue) -ErrorAction Stop -WarningAction SilentlyContinue).TotalMilliseconds))
         }
         else
         {
            $Result = ([long]((New-TimeSpan -Start (Get-Date -Date $UnixStartTime -ErrorAction Stop -WarningAction SilentlyContinue) -End (Get-Date -Date $Date -ErrorAction Stop -WarningAction SilentlyContinue) -ErrorAction Stop -WarningAction SilentlyContinue).TotalSeconds))
         }
      }
      catch
      {
         # get error record
         [Management.Automation.ErrorRecord]$e = $_

         # retrieve information about runtime error
         $info = [PSCustomObject]@{
            Exception = $e.Exception.Message
            Reason    = $e.CategoryInfo.Reason
            Target    = $e.CategoryInfo.TargetName
            Script    = $e.InvocationInfo.ScriptName
            Line      = $e.InvocationInfo.ScriptLineNumber
            Column    = $e.InvocationInfo.OffsetInLine
         }

         $info | Out-String | Write-Verbose

         Write-Error -Message ($info.Exception) -ErrorAction Stop

         # Only here to catch a global ErrorAction overwrite
         break
      }
   }

   end
   {
      $Result
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
   - If you disagree with any of the terms, and any conditions declared: Just delete it and build your own solution
#>
#endregion DISCLAIMER
