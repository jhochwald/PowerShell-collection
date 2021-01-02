#requires -Version 3.0 -Modules ActiveDirectory

<#
   .SYNOPSIS
   Tool that bulk imports or removes User pictures, based on AD Group Membership

   .DESCRIPTION
   Tool that bulk imports or removes User pictures, based on AD Group Membership
   If a user is in both groups, the picture will be removed!
   Idea based on my old tool to import Active Directory pictures.
   They are a bit to tiny, so I use Exchange now to make them look better in Exchange and Skype.

   .PARAMETER AddGroup
   Active Directory Group with users that would like to have a picture.
   For all Members of this group, the Tool will try to set an image.

   .PARAMETER RemGroup
   Active Directory Group with users that would like have have the picture removed.
   For all Members of this group, the Tool will try to remove the existing image (If set).

   .PARAMETER PictureDir
   Directory that contains the pictures

   .PARAMETER Extension
   Extension of the pictures

   .PARAMETER workaround
   Workaround for Exchange 2016 on Windows Server 2016

   .PARAMETER UPNDomain
   The default Domain, to add to the UPN

   .EXAMPLE
   # Use the Groups 'ADDPIXX' and 'NOPIXX' to Set/Remove the User Pictures
   # There was an Issue with the User joerg.hochwald (Possible Picture Problem!
   PS C:\> .\Set-ADAllUserPicture.ps1 -AddGroup 'ADDPIXX' -RemGroup 'NOPIXX' -PictureDir 'c:\upixx\' -workaround -UPNDomain 'jhochwald.com'

   WARNING: Unable to set Image c:\upixx\joerg.hochwald.jpg for User joerg.hochwald

   .EXAMPLE
   # Use the Groups 'ADDPIXX' and 'NOPIXX' to Set/Remove the User Pictures
   # There was an Issue with the User jane.doe - Check that this user has a provissioned Mailbox (on Prem or Cloud)
   PS C:\> .\Set-ADAllUserPicture.ps1 -AddGroup 'ADDPIXX' -RemGroup 'NOPIXX' -PictureDir 'c:\upixx\' -workaround -UPNDomain 'jhochwald.com'

   WARNING: Unable to handle jane.doe - Check that this user has a valid Mailbox!

   .EXAMPLE
   # Use the Groups 'ADDPIXX' and 'NOPIXX' to Set/Remove the User Pictures - Everything went well
   PS C:\> .\Set-ADAllUserPicture.ps1 -AddGroup 'ADDPIXX' -RemGroup 'NOPIXX' -PictureDir 'c:\upixx\' -workaround -UPNDomain 'jhochwald.com'

   WARNING: Unable to handle jane.doe - Check that this user has a valid Mailbox!

   .NOTES
   TODO: There is no logging! Only the Exchange RBAC logging is in use
   TODO: A few error handlers are still missing

   If a user is in both groups, the picture will be removed!
   Verbose could be very verbose. This is due to the fact, that the complete Exchange logging will be shown!

   There are a few possibilities for Warnings and Errors. (Mostly for missing things)

   Disclaimer: The code is provided 'as is,' with all possible faults, defects or errors, and without warranty of any kind.
#>
param
(
   [Parameter(Mandatory,
      ValueFromPipeline,
      ValueFromPipelineByPropertyName,
      Position = 1,
      HelpMessage = 'Active Directory Group with users that would like to have a picture')]
   [ValidateNotNullOrEmpty()]
   [Alias('positive')]
   [string]
   $AddGroup,
   [Parameter(Mandatory,
      ValueFromPipeline,
      ValueFromPipelineByPropertyName,
      Position = 2,
      HelpMessage = 'Active Directory Group with users that would like have have the picture removed.')]
   [ValidateNotNullOrEmpty()]
   [string]
   $RemGroup,
   [Parameter(Mandatory,
      ValueFromPipeline,
      ValueFromPipelineByPropertyName,
      Position = 3,
      HelpMessage = 'Directory that contains the picures')]
   [ValidateNotNullOrEmpty()]
   [Alias('PixxDir')]
   [string]
   $PictureDir,
   [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName,
      Position = 5)]
   [Alias('defaultDomain')]
   [string]
   $UPNDomain,
   [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName,
      Position = 4)]
   [ValidateSet('png', 'jpg', 'gif', 'bmp')]
   [ValidateNotNullOrEmpty()]
   [string]
   $Extension = 'jpg',
   [switch]
   $workaround = $false
)

begin
{
   if ($workaround)
   {
      # Unsupported Workaround according to https://hochwald.net/workaround-for-get-help-issue-with-exchange-2016-on-windows-server-2016/
      $null = (Add-PSSnapin -Name Microsoft.Exchange.Management.PowerShell.SnapIn)
   }

   # Cleanup
   $AddUserPixx = $null
   $NoUserPixx = $null

   # Check the source directory string and fix it if needed
   if (-not ($PictureDir).EndsWith('\'))
   {
      # Fix it
      $PictureDir = $PictureDir + '\'

      $paramWriteVerbose = @{
         Message = 'Fixed the Source Directory String!'
      }
      Write-Verbose @paramWriteVerbose
   }

   try
   {
      $paramGetADGroupMember = @{
         Identity      = $AddGroup
         ErrorAction   = 'Stop'
         WarningAction = 'SilentlyContinue'
      }
      $AddUserPixx = (Get-ADGroupMember @paramGetADGroupMember | Select-Object -ExpandProperty samaccountname)
   }
   catch
   {
      $paramWriteError = @{
         Message     = ('Unable to find {0}' -f $AddGroup)
         ErrorAction = 'Stop'
      }
      Write-Error @paramWriteError

      return
   }

   try
   {
      $paramGetADGroupMember = @{
         Identity      = $RemGroup
         ErrorAction   = 'Stop'
         WarningAction = 'SilentlyContinue'
      }
      $NoUserPixx = (Get-ADGroupMember @paramGetADGroupMember | Select-Object -ExpandProperty samaccountname)
   }
   catch
   {
      $paramWriteError = @{
         Message     = ('Unable to find {0}' -f $AddGroup)
         ErrorAction = 'Stop'
      }
      Write-Error @paramWriteError

      return
   }

   function Test-ValidEmail
   {
      <#
         .SYNOPSIS
         Simple Function to check if a String is a valid Mail

         .DESCRIPTION
         Simple Function to check if a String is a valid Mail and return a Bool

         .PARAMETER address
         Address String to Check

         .EXAMPLE
         # Not a valid String
         PS C:\> Test-ValidEmail -address 'Joerg.Hochwald'
         False

         .EXAMPLE
         # Valid String
         PS C:\> Test-ValidEmail -address 'Joerg.Hochwald@outlook.com'
         True

         .NOTES
         Disclaimer: The code is provided 'as is,' with all possible faults, defects or errors, and without warranty of any kind.

         Author: Joerg Hochwald
      #>

      [OutputType([bool])]
      param
      (
         [Parameter(Mandatory,
            HelpMessage = 'Address String to Check')]
         [ValidateNotNullOrEmpty()]
         [string]
         $address
      )

      process
      {
         ($address -as [mailaddress]).Address -eq $address -and $address -ne $null
      }
   }
}

process
{
   if (-not ($AddUserPixx.samaccountname))
   {
      $paramWriteVerbose = @{
         Message = ('The AD Group {0} has no members.' -f $AddGroup)
      }
      Write-Verbose @paramWriteVerbose
   }
   else
   {
      # Add a counter
      $AddUserPixxCount = (($AddUserPixx.samaccountname).count)

      $paramWriteVerbose = @{
         Message = ('The AD Group {0} has {1} members.' -f $AddGroup, $AddUserPixxCount)
      }
      Write-Verbose @paramWriteVerbose

      foreach ($AddUser in $AddUserPixx.samaccountname)
      {
         if (($NoUserPixx.samaccountname) -notcontains $AddUser)
         {
            # Check the UPN and Fix it, if possible
            if (-not (Test-ValidEmail -address ($AddUser)))
            {
               if (-not ($UPNDomain))
               {
                  # Whoopsie
                  $paramWriteError = @{
                     Message     = 'UPN Default Domain not set but needed!'
                     ErrorAction = 'Stop'
                  }
                  Write-Error @paramWriteError
               }
               else
               {
                  # Let us fix this
                  $AddUserUPN = ($AddUser + '@' + $UPNDomain)
               }
            }

            # Build the Full Image Path
            $SingleUserPicture = ($PictureDir + $AddUser + '.' + $Extension)

            # Check if Picture exists
            $paramTestPath = @{
               Path          = $SingleUserPicture
               ErrorAction   = 'Stop'
               WarningAction = 'SilentlyContinue'
            }

            if (Test-Path @paramTestPath)
            {
               try
               {
                  $paramSetUserPhoto = @{
                     Identity      = $AddUserUPN
                     PictureData   = ([IO.File]::ReadAllBytes($SingleUserPicture))
                     Confirm       = $false
                     ErrorAction   = 'Stop'
                     WarningAction = 'SilentlyContinue'
                  }

                  $null = (Set-UserPhoto @paramSetUserPhoto)
               }
               catch
               {
                  $paramWriteWarning = @{
                     Message     = ('Unable to set Image {0} for User {1}' -f $SingleUserPicture, $AddUser)
                     ErrorAction = 'SilentlyContinue'
                  }
                  Write-Warning @paramWriteWarning
               }
            }
            else
            {
               $paramWriteWarning = @{
                  Message     = ('The Image {0} for User {1} was not found' -f $SingleUserPicture, $AddUser)
                  ErrorAction = 'SilentlyContinue'
               }
               Write-Warning @paramWriteWarning
            }
         }
         else
         {
            $paramWriteVerbose = @{
               Message = ('Sorry, User {0} is member of {1} and {2}' -f $AddUser, $AddGroup, $RemGroup)
            }
            Write-Verbose @paramWriteVerbose
         }
      }
   }

   if (-not ($NoUserPixx.samaccountname))
   {
      $paramWriteVerbose = @{
         Message = ('The AD Group {0} has no members.' -f $RemGroup)
      }
      Write-Verbose @paramWriteVerbose
   }
   else
   {
      # Add a counter
      $NoUserPixxCount = (($NoUserPixx.samaccountname).count)

      $paramWriteVerbose = @{
         Message = ('The AD Group {0} has {1} members.' -f $RemGroup, $NoUserPixxCount)
      }
      Write-Verbose @paramWriteVerbose

      foreach ($NoUser in $NoUserPixx.samaccountname)
      {
         # Check the UPN and Fix it, if possible
         if (-not (Test-ValidEmail -address ($NoUser)))
         {
            if (-not ($UPNDomain))
            {
               # Whoopsie
               $paramWriteError = @{
                  Message     = 'UPN Default Domain not set but needed!'
                  ErrorAction = 'Stop'
               }
               Write-Error @paramWriteError
            }
            else
            {
               # Let us fix this
               $NoUserUPN = ($NoUser + '@' + $UPNDomain)
            }
         }

         $paramSetUserPhoto = @{
            Identity      = $NoUserUPN
            Confirm       = $false
            ErrorAction   = 'Stop'
            WarningAction = 'SilentlyContinue'
         }

         try
         {
            $null = (Remove-UserPhoto @paramSetUserPhoto)
         }
         catch
         {
            $paramWriteWarning = @{
               Message     = ('Unable to handle {0} - Check that this user has a valid Mailbox!' -f $NoUser)
               ErrorAction = 'SilentlyContinue'
            }
            Write-Warning @paramWriteWarning
         }
      }
   }
}

end
{
   # Cleaniup
   $AddUserPixx = $null
   $NoUserPixx = $null
   $AddUserPixxCount = $null
   $NoUserPixxCount = $null

   # Do a garbage collection: Call the .NET function to cleanup some stuff
   $null = ([GC]::Collect())
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
