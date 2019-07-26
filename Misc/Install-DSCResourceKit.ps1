#requires -Version 3.0 -Modules PowerShellGet

function Install-DSCResourceKit
{
   <#
         .SYNOPSIS
         Install the complete PowerShell DSCResourceKit
	
         .DESCRIPTION
         Install the complete PowerShell DSCResourceKit from the PowerShell Gallery.
         It only installs the missing resources.
	
         .PARAMETER Scope
         Specifies the installation scope of the module. The acceptable values for this parameter are: AllUsers and CurrentUser.
		
         The AllUsers scope lets modules be installed in a location that is accessible to all users of the computer, that is, %systemdrive%:\ProgramFiles\WindowsPowerShell\Modules.
		
         The CurrentUser scope lets modules be installed only to $home\Documents\WindowsPowerShell\Modules, so that the module is available only to the current user.
	
         .EXAMPLE
         PS C:\> Install-DSCResourceKit
		
         Install the complete PowerShell DSCResourceKit
	
         .EXAMPLE
         PS C:\> Install-DSCResourceKit -verbose
		
         Install the complete PowerShell DSCResourceKit
	
         .NOTES
         Version: 1.0.0

         GUID: db68148a-c963-4195-894f-40377795e6df

         Author: Joerg Hochwald

         Companyname: Alright IT GmbH

         Copyright: Copyright (c) 2019, Alright IT GmbH - All rights reserved.

         License: https://opensource.org/licenses/BSD-3-Clause

         Releasenotes:
         1.0.0 2019-04-10: Internal Release

         THIS CODE IS MADE AVAILABLE AS IS, WITHOUT WARRANTY OF ANY KIND. THE ENTIRE RISK OF THE USE OR THE RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.

         Dependencies:
         PowerShellGet

         .LINK
         https://www.alright-it.com

         .LINK
         https://aka.ms/InstallModule

         .LINK
         https://www.powershellgallery.com
   #>
	
   [CmdletBinding(ConfirmImpact = 'None',
   SupportsShouldProcess)]
   param
   (
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 0)]
      [ValidateSet('AllUsers', 'CurrentUser', IgnoreCase = $true)]
      [Alias('ModuleScope')]
      [String]
      $Scope = 'AllUsers'
   )
	
   begin
   {
      try
      {
         if (-not ($Scope))
         {
            $Scope = 'AllUsers'
         }
			
         $AllReSources = ((Find-Module -Tag DSCResourceKit).name)
         $AllInstall = ((Get-Module -ListAvailable).Name)
      }
      catch
      {
         # Get error record
         [Management.Automation.ErrorRecord]$e = $_
			
         # Retrieve information about runtime error
         $info = [PSCustomObject]@{
            Exception = $e.Exception.Message
            Reason    = $e.CategoryInfo.Reason
            Target    = $e.CategoryInfo.TargetName
            Script    = $e.InvocationInfo.ScriptName
            Line      = $e.InvocationInfo.ScriptLineNumber
            Column    = $e.InvocationInfo.OffsetInLine
         }
			
         $info | Out-String | Write-Verbose
			
         # Whoops
         Write-Error -Message $info.Exception -ErrorAction Stop
      }
   }
	
   process
   {
      if ($pscmdlet.ShouldProcess('DSCResourceKit', 'Install'))
      {
         foreach ($DSCResource in $AllReSources)
         {
            if (-not ($AllInstall.Contains($DSCResource)))
            {
               try
               {
                  Write-Verbose -Message ('Try to install {0}' -f $DSCResource)
						
                  $paramInstallModule = @{
                     Name               = $DSCResource
                     Scope              = $Scope
                     AllowClobber       = $true
                     SkipPublisherCheck = $true
                     Repository         = 'PSGallery'
                     Force              = $true
                     ErrorAction        = 'Stop'
                  }
                  $null = (Install-Module @paramInstallModule)
						
                  Write-Verbose -Message ('Installed {0}' -f $DSCResource)
               }
               catch
               {
                  # Get error record
                  [Management.Automation.ErrorRecord]$e = $_
						
                  # Retrieve information about runtime error
                  $info = [PSCustomObject]@{
                     Exception = $e.Exception.Message
                     Reason    = $e.CategoryInfo.Reason
                     Target    = $e.CategoryInfo.TargetName
                     Script    = $e.InvocationInfo.ScriptName
                     Line      = $e.InvocationInfo.ScriptLineNumber
                     Column    = $e.InvocationInfo.OffsetInLine
                  }
						
                  $info | Out-String | Write-Verbose
						
                  Write-Warning -Message ('Unable to install {0}' -f $DSCResource) -ErrorAction Continue -WarningAction Continue
						
                  # Cleanup
                  $e = $null
                  $info = $null
               }
            }
            else
            {
               Write-Verbose -Message ('{0} is already installed' -f $DSCResource)
            }
         }
      }
   }
	
   end
   {
      # Cleanup
      $AllReSources = $null
      $AllInstall = $null
   }
}
