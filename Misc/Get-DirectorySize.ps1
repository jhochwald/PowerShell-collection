function Get-DirectorySize
{
   <#
         .SYNOPSIS
         Get the size of a given folder in a human readable format

         .DESCRIPTION
         Get the size of a given folder in a human readable format

         .PARAMETER Path
         Folder to check

         .PARAMETER Type
         Type of the Return,
         Vaild values are: GB, MB, KB, B
         The default is MB (Megabyte)
	
         .EXAMPLE
         PS C:\> Get-DirectorySize -Path 'C:\scripts'

         .EXAMPLE
         PS C:\> Get-DirectorySize -Path 'C:\scripts' -Type GB
	
         .NOTES
         PowerShell function to emulate the wel known Linux DU command

         Version: 1.0.0
		
         GUID: e559f754-f1aa-4376-8c28-dea035fe2c5a
	
         Author: Joerg Hochwald
	
         Companyname: Alright IT GmbH
	
         Copyright: Copyright (c) 2019, Alright IT GmbH - All rights reserved.
	
         License: https://opensource.org/licenses/BSD-3-Clause
	
         Releasenotes:
         1.0.0 2019-05-09: Initial Release
	
         THIS CODE IS MADE AVAILABLE AS IS, WITHOUT WARRANTY OF ANY KIND. THE ENTIRE RISK OF THE USE OR THE RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.
   #>
	
   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([string])]
   param
   (
      [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
      [ValidateNotNullOrEmpty()]
      [Alias('Directory', 'Folder')]
      [string]
      $Path = '.',
      [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
      [ValidateNotNullOrEmpty()]
      [ValidateSet('GB', 'MB', 'KB', 'B', IgnoreCase = $true)]
      [Alias('InType')]
      [string]
      $Type = 'MB'
   )
	
   process
   {
      try
      {
         $AllFolderItems = (Get-ChildItem -Path $Path -Recurse -ErrorAction Stop | Measure-Object -Property length -Sum)
			
         switch ($Type)
         {
            'GB'
            {
               $FolderSize = '{0:N2}' -f ($AllFolderItems.sum / 1GB) + ' GB'
            }
            'MB'
            {
               $FolderSize = '{0:N2}' -f ($AllFolderItems.sum / 1MB) + ' MB'
            }
            'KB'
            {
               $FolderSize = '{0:N2}' -f ($AllFolderItems.sum / 1KB) + ' KB'
            }
            'B'
            {
               $FolderSize = '{0:N2}' -f ($AllFolderItems.sum) + ' B'
            }
            Default
            {
               $FolderSize = '{0:N2}' -f ($AllFolderItems.sum) + ' MB'
            }
         }

         return $FolderSize
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
			
         Write-Error -Message $e.Exception.Message -ErrorAction Continue -Exception $e.Exception -TargetObject $e.CategoryInfo.TargetName
      }
   }
}
