function Grant-LogOnAsService
{
   <#
      .SYNOPSIS
      Grant user log on as a service right in PowerShell

      .DESCRIPTION
      Grant user log on as a service right in PowerShell

      .PARAMETER Users
      The User that should get the grant

      .INPUTS
      String, Multi Value is OK here

      .OUTPUTS
      None

      .EXAMPLE
      PS C:\> Grant-LogOnAsService -Users 'johndoe'

      Grant user log on as a service right in PowerShell

      .LINK
      https://gist.github.com/ned1313/9143039

      .NOTES
      Just a minor refactoring of the original
   #>
   [CmdletBinding(ConfirmImpact = 'Low',
      SupportsShouldProcess)]
   param
   (
      [Parameter(Mandatory,
         ValueFromPipeline,
         ValueFromPipelineByPropertyName,
         Position = 1,
         HelpMessage = 'The User that should get the grant')]
      [ValidateNotNullOrEmpty()]
      [string[]]
      $Users
   )

   process
   {
      if ($pscmdlet.ShouldProcess('Apply login as a service', "$Users"))
      {
         # Get list of currently used SIDs
         & "$env:windir\system32\secedit.exe" /export /cfg tempexport.inf
         $curSIDs = (Select-String -Path .\tempexport.inf -Pattern 'SeServiceLogonRight')
         $Sids = $curSIDs.line
         $sidstring = ''

         foreach ($user in $Users)
         {
            $objUser = (New-Object -TypeName System.Security.Principal.NTAccount -ArgumentList ($user))
            $strSID = $objUser.Translate([Security.Principal.SecurityIdentifier])

            if (!$Sids.Contains($strSID) -and !$Sids.Contains($user))
            {
               $sidstring += ",*$strSID"
            }
         }

         if ($sidstring)
         {
            $newSids = $Sids + $sidstring

            Write-Output -InputObject ('New Sids: {0}' -f $newSids)
            $tempinf = (Get-Content -Path tempexport.inf)
            $tempinf = $tempinf.Replace($Sids, $newSids)
            $null = (Add-Content -Path tempimport.inf -Value $tempinf -Force -Confirm:$false)

            & "$env:windir\system32\secedit.exe" /import /db secedit.sdb /cfg '.\tempimport.inf'
            & "$env:windir\system32\secedit.exe" /configure /db secedit.sdb
            & "$env:windir\system32\gpupdate.exe" /force
         }
         else
         {
            Write-Output -InputObject 'No new sids'
         }
      }
   }

   end
   {
      if ($pscmdlet.ShouldProcess('Cleanup', 'Tempfiles'))
      {
         # Splat the Defaults
         $paramRemoveItem = @{
            Force       = $true
            Confirm     = $false
            ErrorAction = 'SilentlyContinue'
         }

         $null = (Remove-Item -Path '.\tempimport.inf' @paramRemoveItem)
         $null = (Remove-Item -Path '.\secedit.sdb' @paramRemoveItem)
         $null = (Remove-Item -Path '.\tempexport.inf' @paramRemoveItem)
      }
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
