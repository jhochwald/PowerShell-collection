#requires -Version 3.0 -Modules AzureAD, WhiteboardAdmin
function Get-MicrosoftWhiteboardReport
{
   <#
      .SYNOPSIS
      Get all Whiteboards for a given user

      .DESCRIPTION
      Get all Whiteboards for a given UserID or UserPrincipalName

      .PARAMETER UserId
      The UserID (AzureAD Object ID) for the User

      .PARAMETER UserName
      The UserPrincipalName for the User

      .EXAMPLE
      PS C:\> Get-MicrosoftWhiteboardReport -UserId '43c67825-9835-48c8-9a85-6ecf681bf5c9'

      Get all Whiteboards for the User with the Azure AD Object ID '43c67825-9835-48c8-9a85-6ecf681bf5c9'

      .EXAMPLE
      PS C:\> Get-MicrosoftWhiteboardReport -UserName 'john.doe@contoso.com'

      Get all Whiteboards for the User 'john.doe@contoso.com'

      .EXAMPLE
      PS C:\> Get-MicrosoftWhiteboardReport -UserName 'john.doe@contoso.com' | Where-Object {$PSItem.Id -eq '01b3d6ee-edbb-456a-8805-f768aaedcc6a'}

      Get the infomation about the Whiteboard with the ID '01b3d6ee-edbb-456a-8805-f768aaedcc6a' ot hte user 'john.doe@contoso.com'

      .OUTPUTS
      psobject

      .NOTES
      Hard to automate: The WhiteboardAdmin does not have a connect function and will always prompt for auth (and then cache the credentials used to connect).

      .LINK
      Get-Whiteboard

      .LINK
      https://www.powershellgallery.com/packages/WhiteboardAdmin/
   #>
   [CmdletBinding(DefaultParameterSetName = 'UseID',
      ConfirmImpact = 'None')]
   [OutputType([psobject], ParameterSetName = 'UseID')]
   [OutputType([psobject], ParameterSetName = 'UseName')]
   [OutputType([psobject])]
   param
   (
      [Parameter(ParameterSetName = 'UseID', HelpMessage = 'The UserID (AzureAD Obejct ID) for the User',
         Mandatory,
         ValueFromPipeline,
         ValueFromPipelineByPropertyName)]
      [ValidateNotNullOrEmpty()]
      [Alias('ObejctID')]
      [string]
      $UserId,
      [Parameter(ParameterSetName = 'UseName', HelpMessage = 'The UserPrincipalName for the User',
         Mandatory,
         ValueFromPipeline,
         ValueFromPipelineByPropertyName)]
      [ValidateNotNullOrEmpty()]
      [Alias('UserPrincipalName')]
      [string]
      $UserName
   )

   begin
   {
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

      if ($PsCmdlet.ParameterSetName -eq 'UseName')
      {
         $UserId = (Get-AzureADUser -Filter ("userPrincipalName eq '{0}'" -f $UserName) | Select-Object -ExpandProperty ObjectId)
      }

      $UserWhiteboards = $null
      $UserWhiteboards = (Get-Whiteboard -UserId $UserId -ErrorAction SilentlyContinue | Select-Object -Property *)
   }

   process
   {
      if ($UserWhiteboards)
      {
         # Create a new object for the report
         $Report = @()

         # Loop over the existing Whiteboards
         foreach ($UserWhiteboard in $UserWhiteboards)
         {
            try
            {
               $objUserId = (Get-AzureADUser -ObjectId $UserWhiteboard.userId -ErrorAction SilentlyContinue | Select-Object -ExpandProperty DisplayName)

               if (-not ($objUserId))
               {
                  $objUserId = $UserWhiteboard.userId
               }

               $objCreatedBy = (Get-AzureADUser -ObjectId $UserWhiteboard.createdBy -ErrorAction SilentlyContinue | Select-Object -ExpandProperty DisplayName)

               if (-not ($objCreatedBy))
               {
                  $objCreatedBy = $UserWhiteboard.createdBy
               }

               $objOwnerId = (Get-AzureADUser -ObjectId $UserWhiteboard.ownerId -ErrorAction SilentlyContinue | Select-Object -ExpandProperty DisplayName)

               if (-not ($objOwnerId))
               {
                  $objOwnerId = $UserWhiteboard.ownerId
               }

               $ObjOwnerTenantId = (Get-AzureADTenantDetail)

               if ($ObjOwnerTenantId.ObjectId -eq $UserWhiteboard.ownerTenantId)
               {
                  $ObjOwnerTenantId = $ObjOwnerTenantId.DisplayName
               }
               else
               {
                  $ObjOwnerTenantId = ('unknown (' + $UserWhiteboard.ownerTenantId + ')')
               }

               # Transform the DateTime String
               $objCreated = ($UserWhiteboard.createdTime | Get-Date -Format 'yyyy-MM-dd HH:mm' -ErrorAction SilentlyContinue)
               $objInvited = ($UserWhiteboard.invitedTime | Get-Date -Format 'yyyy-MM-dd HH:mm' -ErrorAction SilentlyContinue)
               $objPersonalLastModified = ($UserWhiteboard.personalLastModifiedTime | Get-Date -Format 'yyyy-MM-dd HH:mm' -ErrorAction SilentlyContinue)
               $objLastModified = ($UserWhiteboard.lastModifiedTime | Get-Date -Format 'yyyy-MM-dd HH:mm' -ErrorAction SilentlyContinue)
               $objGlobalLastViewed = ($UserWhiteboard.globalLastViewedTime | Get-Date -Format 'yyyy-MM-dd HH:mm' -ErrorAction SilentlyContinue)
               $objLastViewed = ($UserWhiteboard.lastViewedTime | Get-Date -Format 'yyyy-MM-dd HH:mm' -ErrorAction SilentlyContinue)

               $obj = New-Object -TypeName psobject
               $obj | Add-Member -MemberType NoteProperty -Name Title -Value $UserWhiteboard.title
               $obj | Add-Member -MemberType NoteProperty -Name Id -Value $UserWhiteboard.id

               $obj | Add-Member -MemberType NoteProperty -Name UserId -Value $objUserId
               $objUserId = $null

               $obj | Add-Member -MemberType NoteProperty -Name CreatedBy -Value $objCreatedBy
               $objCreatedBy = $null

               $obj | Add-Member -MemberType NoteProperty -Name OwnerId -Value $objOwnerId
               $objOwnerId = $null

               $obj | Add-Member -MemberType NoteProperty -Name OwnerTenant -Value $ObjOwnerTenantId
               $ObjOwnerTenantId = $null

               $obj | Add-Member -MemberType NoteProperty -Name IsShared -Value $UserWhiteboard.isShared

               if ($objCreated)
               {
                  $obj | Add-Member -MemberType NoteProperty -Name Created -Value $objCreated
                  $objCreated = $null
               }

               if ($objInvited)
               {
                  $obj | Add-Member -MemberType NoteProperty -Name Invited -Value $objInvited
                  $objInvited = $null
               }

               if ($objPersonalLastModified)
               {
                  $obj | Add-Member -MemberType NoteProperty -Name PersonalLastModified -Value $objPersonalLastModified
                  $objPersonalLastModified = $null
               }

               if ($objLastModified)
               {
                  $obj | Add-Member -MemberType NoteProperty -Name LastModified -Value $objLastModified
                  $objLastModified = $null
               }

               if ($objGlobalLastViewed)
               {
                  $obj | Add-Member -MemberType NoteProperty -Name GlobalLastViewed -Value $objGlobalLastViewed
                  $objGlobalLastViewed = $null
               }

               if ($objLastViewed)
               {
                  $obj | Add-Member -MemberType NoteProperty -Name LastViewed -Value $objLastViewed
                  $objLastViewed = $null
               }

               if ($UserWhiteboard.meetingId)
               {
                  $obj | Add-Member -MemberType NoteProperty -Name Meeting -Value $UserWhiteboard.meetingId
               }

               # Add to the report
               $Report += $obj

               # Cleanup
               $obj = $null
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

               Write-Warning -Message $e.Exception.Message -WarningAction Continue -ErrorAction Continue
               #endregion ErrorHandler
            }

            # Cleanup
            $UserWhiteboards = $null
         }
      }
   }

   end
   {
      # Dump the report to the Terminal
      if ($Report)
      {
         $Report
      }
      else
      {
         Write-Warning -Message 'There is not Whiteboard to report' -WarningAction Continue -ErrorAction Continue
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
