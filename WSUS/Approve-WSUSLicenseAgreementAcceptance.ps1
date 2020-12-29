#requires -Version 3.0 -Modules UpdateServices

<#
   .SYNOPSIS
   Accept License Agreements

   .DESCRIPTION
   Accept License Agreements for all Windows Server Update Services (WSUS) Updates

   .PARAMETER Name
   Specifies the name of a WSUS server.

   .EXAMPLE
   PS C:\> Approve-WSUSLicenseAgreementAcceptance -Name 'mycdc01'

   Accept License Agreements on the WSUS Server 'mycdc01'

   .EXAMPLE
   PS C:\> Approve-WSUSLicenseAgreementAcceptance

   Accept License Agreements

   .NOTES
   Initial beta Version
#>
[CmdletBinding(ConfirmImpact = 'None',
   SupportsShouldProcess)]
param
(
   [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName,
      Position = 1)]
   [Alias('WSUSServer')]
   [string]
   $Name = $null
)

begin
{
   try
   {
      # Set the Defaults
      $paramGetWsusServer = @{
         ErrorAction   = 'Stop'
         WarningAction = 'Continue'
      }

      if ($Name)
      {
         Write-Verbose -Message ('Use {0} as WSUS Server' -f $Name)

         # Add the Name field with the given value to the Hashtable (Command Splat)
         $paramGetWsusServer['Name'] = $Name
      }

      $WSUS = (Get-WsusServer @paramGetWsusServer)
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

   $unapprovedUpdates = $null
   $unapprovedUpdates = $WSUS.getupdates() | Where-Object -FilterScript {
      $_.isdeclined -ne $true
   }

   $license = $null
   if ($unapprovedUpdates)
   {
      $license = $unapprovedUpdates | Where-Object -FilterScript {
         $_.RequiresLicenseAgreementAcceptance
      }
   }
   else
   {
      Write-Verbose -Message 'Nothing left todo.'
   }
}

process
{
   if ($license)
   {
      if ($pscmdlet.ShouldProcess("$license", 'Accept License Agreement'))
      {
         $license | ForEach-Object -Process {
            $_.AcceptLicenseAgreement()
         }
      }
   }
   else
   {
      Write-Verbose -Message 'Nothing left todo...'
   }
}

end
{
   Write-Verbose -Message 'Done'
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
