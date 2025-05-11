function Get-MFAUserReport
{
   <#
      .SYNOPSIS
      Get a Azure AD MFA User report

      .DESCRIPTION
      Get a Azure AD MFA User report, the function can export the report as CSV.
      The export is disabled by default.

      .PARAMETER Export
      Export the MFA Report to CSV?

      .PARAMETER Path
      Path of the MFA Export CSV

      .EXAMPLE
      PS> Get-MFAUserReport

      Get a Azure AD MFA User report

      .EXAMPLE
      PS> Get-MFAUserReport -Export

      Get a Azure AD MFA User report and export it to the default report (C:\scripts\PowerShell\exports\MFAUsers.csv)

      .EXAMPLE
      PS> Get-MFAUserReport -Export -Path 'C:\scripts\PowerShell\exports\AllMFAUsers.csv'

      Get a Azure AD MFA User report and export it to given report (C:\scripts\PowerShell\exports\AllMFAUsers.csv)

      .NOTES
      ParameterSet added

      License: BSD 3-Clause
   #>
   [CmdletBinding(DefaultParameterSetName = 'Normal',
      SupportsShouldProcess)]
   param
   (
      [Parameter(ParameterSetName = 'Export',
         ValueFromPipeline,
         Position = 1)]
      [Alias('CSV')]
      [switch]
      $Export,
      [Parameter(ParameterSetName = 'Export',
         ValueFromPipeline,
         Position = 2)]
      [string]
      $Path = 'C:\scripts\PowerShell\exports\MFAUsers.csv'
   )

   begin
   {
      # Defaults
      $CNT = 'Continue'
      $STP = 'Stop'

      # Cleanup
      $Report = @()
      $i = 0

      if ($pscmdlet.ShouldProcess('MFA Users', 'Get'))
      {
         # get all Accounts
         try
         {
            $Accounts = (Get-MsolUser -All -ErrorAction $STP -WarningAction $CNT | Where-Object -FilterScript {
                  $Null -ne $PSItem.StrongAuthenticationMethods
               } | Sort-Object -Property DisplayName)
         }
         catch
         {
            $line = ($PSItem.InvocationInfo.ScriptLineNumber)

            # Dump the Info
            Write-Warning -Message ('Error was in Line {0}' -f $line)

            # Dump the Error catched
            Write-Error -Message $_ -ErrorAction $STP

            # Something that should never be reached
            break
         }
      }
   }

   process
   {
      if ($pscmdlet.ShouldProcess('MFA Users', 'Process'))
      {
         foreach ($Account in $Accounts)
         {
            $AccountDisplayName = $Account.DisplayName
            Write-Verbose -Message ('Processing {0}' -f $AccountDisplayName)

            # Counter
            $i++

            # Select Methods
            $Methods = ($Account | Select-Object -ExpandProperty StrongAuthenticationMethods)
            $MFA = ($Account | Select-Object -ExpandProperty StrongAuthenticationUserDetails)
            $State = ($Account | Select-Object -ExpandProperty StrongAuthenticationRequirements)

            $Methods | ForEach-Object -Process {
               if ($PSItem.IsDefault -eq $true)
               {
                  $Method = $PSItem.MethodType
               }
            }

            if ($State.State)
            {
               $MFAStatus = $State.State
            }
            else
            {
               $MFAStatus = 'Disabled'
            }

            $Object = [PSCustomObject][Ordered]@{
               User      = $Account.DisplayName
               UPN       = $Account.UserPrincipalName
               MFAMethod = $Method
               MFAPhone  = $MFA.PhoneNumber
               MFAEmail  = $MFA.Email
               MFAStatus = $MFAStatus
            }

            # Add Obejct to report
            $Report += $Object
         }
      }
   }

   end
   {
      if ($pscmdlet.ShouldProcess('MFA Users', 'Report'))
      {
         Write-Verbose -Message ('{0} accounts are MFA-enabled' -f $i)

         if ($pscmdlet.ParameterSetName -eq 'Export')
         {
            try
            {
               $Null = ($Report | Export-Csv -NoTypeInformation -Path $Path -Force -ErrorAction $STP -WarningAction $CNT)
            }
            catch
            {
               $line = ($PSItem.InvocationInfo.ScriptLineNumber)

               # Dump the Info
               Write-Warning -Message ('Error was in Line {0}' -f $line)

               # Dump the Error catched
               Write-Error -Message $_ -ErrorAction $STP

               # Something that should never be reached
               break
            }
         }
         else
         {
            # Dump to console
            $Report
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
