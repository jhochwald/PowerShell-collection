<#
      .SYNOPSIS
      Update the DistinguishedName Atrribute for all Active Directory Users
	
      .DESCRIPTION
      Update the DistinguishedName Atrribute for all Active Directory Users.
      It will update the 'CN=' to match the SamAccountName
	
      .EXAMPLE
      PS C:\> .\Convert-ADDistinguishedNameForAllUsers.ps1
	
      .NOTES
      MIND THE GAP:
      This will change the DistinguishedName and this might break things

      It will only update/change the DistinguishedName if the 'CN=' does NOT match the SamAccountName

      I created this to bulk migrate older users, they had german umlauts and other crappy character in the DistinguishedName

      .LINK
      https://github.com/jhochwald/PowerShell-collection/

      .LINK
      Get-ADUser

      .LINK
      Rename-ADObject
#>
[CmdletBinding(ConfirmImpact = 'Medium',
SupportsShouldProcess)]
param ()

if ($pscmdlet.ShouldProcess('All Users', 'Set'))
{
   try
   {
      $AllUsers = (Get-ADUser -Filter * -Properties SamAccountName, UserPrincipalName, DistinguishedName -ErrorAction Stop | Select-Object -Property SamAccountName, UserPrincipalName, DistinguishedName | Where-Object -FilterScript {
            ($_.UserPrincipalName) -and ($_.SamAccountName)
      })
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
		
      Write-Verbose -Message $info
		
      Write-Error -Message $e.Exception.Message -ErrorAction Stop
		
      break
   }
	
   try
   {
      foreach ($User in $AllUsers)
      {
         $OldRDN = (($User | Select-Object -Property @{
                  l = 'OldRDN'
                  e = {
                     $_.DistinguishedName.split(',')[0].split('=')[1]
                  }
         }) | Select-Object -ExpandProperty OldRDN)
			
         if ($OldRDN -ne ($User.SamAccountName))
         {
            # Mind the Gap: This will change the DistinguishedName and this might break things
            $null = (Rename-ADObject -Identity $User.DistinguishedName -NewName $User.SamAccountName -Confirm:$false -ErrorAction Stop)
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
		
      Write-Verbose -Message $info
		
      Write-Warning -Message $e.Exception.Message -ErrorAction Continue -WarningAction Continue
   }
}

#region License
<#
      BSD 3-Clause License
      Copyright (c) 2019, enabling Technology <http://enatec.io>
      All rights reserved.
      Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
      1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
      2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
      3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
      THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
      By using the Software, you agree to the License, Terms and Conditions above!
#>
#endregion License

#region Hints
<#
      This is a third-party Software!
      The developer(s) of this Software is NOT sponsored by or affiliated with Microsoft Corp (MSFT) or any of its subsidiaries in any way
      The Software is not supported by Microsoft Corp (MSFT)!
#>
#endregion Hints