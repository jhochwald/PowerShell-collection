function Get-ADUserLockouts
{
   <#
         .SYNOPSIS
         Tracking down account lockout sources with PowerShell

         .DESCRIPTION
         Tracking down account lockout sources with PowerShell

         .PARAMETER Identity
         Just scan for a single User?

         .PARAMETER StartTime
         Start-point

         .PARAMETER EndTime
         Endpoint

         .EXAMPLE
         PS C:\> Get-ADUserLockout

         Tracking down account lockout sources for all users for the last 7 days

         .EXAMPLE
         Get-ADUser -Filter {Department -eq 'Development'} | Get-ADUserLockout

         Tracking down account lockout sources for all users in the Development Department for the last 7 days

         .EXAMPLE
         Get-ADUserLockout -StartTime (Get-Date).AddDays(-2) -EndTime (Get-Date).AddDays(-1)

         Tracking down account lockout sources for all users for the last day

         .NOTES
         Original by Anthony Howell (@ThePoShWolf) - MIT Licenses
         Copyright (c) 2018 Anthony Howell

         .LINK
         https://theposhwolf.com/howtos/Get-ADUserLockouts/

         .LINK
         https://github.com/ThePoShWolf/Utilities/blob/master/ActiveDirectory/Get-ADUserLockouts.ps1
   #>
   [CmdletBinding(DefaultParameterSetName = 'All',
      ConfirmImpact = 'None')]
   [OutputType([pscustomobject])]
   param
   (
      [Parameter(ParameterSetName = 'ByUser',
         ValueFromPipeline)]
      [string]
      $Identity,
      [Parameter(ValueFromPipeline,
         ValueFromPipelineByPropertyName)]
      [Alias('Start')]
      [datetime]
      $StartTime = (Get-Date).AddDays(-8),
      [Parameter(ValueFromPipeline,
         ValueFromPipelineByPropertyName)]
      [Alias('End')]
      [datetime]
      $EndTime = (Get-Date).AddDays(-1)
   )

   begin
   {
      $filterHt = @{
         LogName = 'Security'
         ID      = 4740
      }

      if ($PSBoundParameters.ContainsKey('StartTime'))
      {
         $filterHt['StartTime'] = $StartTime
      }

      if ($PSBoundParameters.ContainsKey('EndTime'))
      {
         $filterHt['EndTime'] = $EndTime
      }

      try
      {
         $PDCEmulator = ((Get-ADDomain -ErrorAction Stop).PDCEmulator)

         Write-Verbose -Message ('Use {0} to find the lockout events' -f $PDCEmulator)

         # Query the event log just once instead of for each user if using the pipeline
         $events = (Get-WinEvent -ComputerName $PDCEmulator -FilterHashtable $filterHt -ErrorAction Stop)
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

         # output information. Post-process collected info, and log info (optional)
         $info | Out-String | Write-Verbose

         Write-Error -Message $e.Exception.Message -ErrorAction Stop -Exception $e.Exception -TargetObject $e.CategoryInfo.TargetName

         break
      }

      Write-Verbose -Message 'Found the following events:'
      Write-Verbose -Message $events
   }

   process
   {
      if ($PSCmdlet.ParameterSetName -eq 'ByUser')
      {
         try
         {
            Write-Verbose -Message ('Querry AD Info for {0}' -f $Identity)

            $user = (Get-ADUser -Identity $Identity -ErrorAction Stop)

            Write-Verbose -Message ('Found the following AD Info for {0}:' -f $Identity)
            Write-Verbose -Message $user

            # Filter the events
            $output = $events | Where-Object -FilterScript {
               $PSItem.Properties[0].Value -eq $user.SamAccountName
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

            # output information. Post-process collected info, and log info (optional)
            $info | Out-String | Write-Verbose

            Write-Error -Message $e.Exception.Message -ErrorAction Stop -Exception $e.Exception -TargetObject $e.CategoryInfo.TargetName

            break
         }
      }
      else
      {
         $output = $events
      }

      foreach ($event in $output)
      {
         [pscustomobject]@{
            UserName       = $event.Properties[0].Value
            CallerComputer = $event.Properties[1].Value
            TimeStamp      = $event.TimeCreated
         }
      }
   }
}

#region LICENSE
<#
   BSD 3-Clause License

   Copyright (c) 2022, enabling Technology
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
