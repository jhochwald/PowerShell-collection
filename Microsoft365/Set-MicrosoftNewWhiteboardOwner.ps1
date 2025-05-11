#requires -Version 3.0 -Modules AzureAD, WhiteboardAdmin
function Set-MicrosoftNewWhiteboardOwner
{
   <#
      .SYNOPSIS
      Set the owner for a a given Microsoft Whiteboard

      .DESCRIPTION
      Set the owner for a a given Microsoft Whiteboard

      .PARAMETER WhiteboardId
      The Whiteboard for which the owner is being changed.

      .PARAMETER OwnerId
      The ID of the previous owner.

      .PARAMETER OwnerName
      The UserPrincipalName of the previous owner.

      .PARAMETER NewOwnerId
      The ID of the new owner.

      .PARAMETER NewOwnerName
      The UserPrincipalName of the new owner.

      .PARAMETER All
      Transfer ownership of all Whiteboards owned by a user to another user.

      .EXAMPLE
      PS C:\> Set-MicrosoftNewWhiteboardOwner -WhiteboardId 'ad8d4e1b-45c9-4ff8-9757-77086f1b3fec' -OwnerId 'c85245cf-d5d9-4286-968f-6f95d46a885f' -NewOwnerId '7ff1141a-d6fa-401b-a7e5-0f8c6dd64aba'

      Transfers the ownership of the Whiteboard with the ID 'ad8d4e1b-45c9-4ff8-9757-77086f1b3fec' from UserID 'c85245cf-d5d9-4286-968f-6f95d46a885f' the the new owner with the ID '7ff1141a-d6fa-401b-a7e5-0f8c6dd64aba'

      .EXAMPLE
      PS C:\> Set-MicrosoftNewWhiteboardOwner -WhiteboardId 'ad8d4e1b-45c9-4ff8-9757-77086f1b3fec' -OwnerName 'john.doe@contoso.com' -NewOwnerName 'jane.doe@contoso.com'

      Transfers the ownership of the Whiteboard with the ID 'ad8d4e1b-45c9-4ff8-9757-77086f1b3fec' from User 'john.doe@contoso.com' the the new owner 'jane.doe@contoso.com'

      .EXAMPLE
      PS C:\> Set-MicrosoftNewWhiteboardOwner -All -OwnerId 'c85245cf-d5d9-4286-968f-6f95d46a885f' -NewOwnerId '7ff1141a-d6fa-401b-a7e5-0f8c6dd64aba'

      Transfers the ownership of the Whiteboards from the Owner with the ID 'c85245cf-d5d9-4286-968f-6f95d46a885f' the the new owner with the ID '7ff1141a-d6fa-401b-a7e5-0f8c6dd64aba'
      This might be a use case for off boarding

      .EXAMPLE
      PS C:\> Set-MicrosoftNewWhiteboardOwner -All -OwnerName 'john.doe@contoso.com' -NewOwnerName 'jane.doe@contoso.com'

      Transfers the ownership of the Whiteboards from the Owner 'john.doe@contoso.com' the the new owner 'jane.doe@contoso.com'
      This might be a use case for off boarding

      .OUTPUTS
      bool

      .NOTES
      Hard to automate: The WhiteboardAdmin does not have a connect function and will always prompt for auth (and then cache the credentials used to connect).
      All transfered Whiteboards are then shared between both, the old and the new owner!

      .LINK
      Get-MicrosoftWhiteboardReport

      .LINK
      Invoke-TransferAllWhiteboards

      .LINK
      Set-WhiteboardOwner

      .LINK
      https://www.powershellgallery.com/packages/WhiteboardAdmin/
   #>

   [CmdletBinding(DefaultParameterSetName = 'UseID',
      ConfirmImpact = 'Low',
      SupportsShouldProcess)]
   [OutputType([bool], ParameterSetName = 'UseID')]
   [OutputType([bool], ParameterSetName = 'UseName')]
   [OutputType([bool])]
   param
   (
      [Parameter(ValueFromPipeline,
         ValueFromPipelineByPropertyName)]
      [ValidateNotNullOrEmpty()]
      [Alias('Whiteboard')]
      [string]
      $WhiteboardId = $null,
      [Parameter(ParameterSetName = 'UseID',
         Mandatory,
         ValueFromPipeline,
         ValueFromPipelineByPropertyName,
         HelpMessage = 'The ID of the previous owner.')]
      [ValidateNotNullOrEmpty()]
      [Alias('OldOwnerId')]
      [string]
      $OwnerId,
      [Parameter(ParameterSetName = 'UseName',
         Mandatory,
         ValueFromPipeline,
         ValueFromPipelineByPropertyName,
         HelpMessage = 'The UserPrincipalName of the previous owner.')]
      [Alias('OwnerUserPrincipalName', 'OwnerUserPrincipal')]
      [string]
      $OwnerName,
      [Parameter(ParameterSetName = 'UseID',
         Mandatory,
         ValueFromPipeline,
         ValueFromPipelineByPropertyName,
         HelpMessage = 'The ID of the new owner.')]
      [ValidateNotNullOrEmpty()]
      [string]
      $NewOwnerId,
      [Parameter(ParameterSetName = 'UseName', HelpMessage = 'The UserPrincipalName of the new owner.',
         Mandatory,
         ValueFromPipeline,
         ValueFromPipelineByPropertyName)]
      [ValidateNotNullOrEmpty()]
      [Alias('NewOwnerUserPrincipalName', 'NewOwnerUserPrincipal')]
      [string]
      $NewOwnerName,
      [Parameter(ValueFromPipeline,
         ValueFromPipelineByPropertyName)]
      [switch]
      $All
   )

   begin
   {
      # Check if one of the required parameters is present
      if ((-not (($PsCmdlet.MyInvocation.BoundParameters['All']))) -and (-not ($WhiteboardId)))
      {
         Write-Error -Message 'No WhiteboardId to transfer found and -All was not given!' -Category NotSpecified -TargetObject $WhiteboardId -RecommendedAction 'Specify -All or the WhiteboardId to transfer' -ErrorAction Stop

         # Only here to catch a global ErrorAction overwrite
         exit 1
      }

      try
      {
         try
         {
            $null = (Get-AzureADTenantDetail -ErrorAction Stop)
         }
         catch
         {
            Connect-AzureAD
         }
      }
      catch
      {
         #region ErrorHandler
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

         $paramWriteError = @{
            Message      = $e.Exception.Message
            ErrorAction  = 'Stop'
            Exception    = $e.Exception
            TargetObject = $e.CategoryInfo.TargetName
         }
         Write-Error @paramWriteError

         # Only here to catch a global ErrorAction overwrite
         exit 1
         #endregion ErrorHandler
      }
   }

   process
   {
      $TargetObject = if (($PsCmdlet.MyInvocation.BoundParameters['All']).IsPresent)
      {
         'all Whiteboards'
      }
      else
      {
         $WhiteboardId
      }

      if ($PsCmdlet.ShouldProcess($TargetObject, 'Transfer ownership'))
      {
         try
         {
            switch ($PsCmdlet.ParameterSetName)
            {
               'UseID'
               {
                  if (($PsCmdlet.MyInvocation.BoundParameters['All']).IsPresent)
                  {
                     Invoke-TransferAllWhiteboards -OldOwnerId $OwnerId -NewOwnerId $NewOwnerId -ErrorAction Stop -Confirm:$false
                  }
                  else
                  {
                     Set-WhiteboardOwner -WhiteboardId $WhiteboardId -OldOwnerId $OwnerId -NewOwnerId $NewOwnerId -ErrorAction Stop -Confirm:$false
                  }
                  break
               }
               'UseName'
               {
                  $OwnerId = (Get-AzureADUser -Filter ("userPrincipalName eq '{0}'" -f $OwnerName) | Select-Object -ExpandProperty ObjectId)
                  $NewOwnerId = (Get-AzureADUser -Filter ("userPrincipalName eq '{0}'" -f $NewOwnerName) | Select-Object -ExpandProperty ObjectId)

                  if (($PsCmdlet.MyInvocation.BoundParameters['All']).IsPresent)
                  {
                     Invoke-TransferAllWhiteboards -OldOwnerId $OwnerId -NewOwnerId $NewOwnerId -ErrorAction Stop -Confirm:$false
                  }
                  else
                  {
                     Set-WhiteboardOwner -WhiteboardId $WhiteboardId -OldOwnerId $OwnerId -NewOwnerId $NewOwnerId -ErrorAction Stop -Confirm:$false
                  }
                  break
               }
            }
         }
         catch
         {
            #region ErrorHandler
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

            $paramWriteError = @{
               Message      = $e.Exception.Message
               ErrorAction  = 'Stop'
               Exception    = $e.Exception
               TargetObject = $e.CategoryInfo.TargetName
            }
            Write-Error @paramWriteError

            # Only here to catch a global ErrorAction overwrite
            exit 1
            #endregion ErrorHandler
         }
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
