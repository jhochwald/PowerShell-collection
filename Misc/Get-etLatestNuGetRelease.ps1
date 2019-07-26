function Get-etLatestNuGetRelease
{
   <#
         .SYNOPSIS
         Get the latest published version of a given Module from a NuGet Repository
	
         .DESCRIPTION
         Get the latest published version of a given PowerShell Module from a NuGet Repository
	
         .PARAMETER Project
         Name of the Project, e.g. et.Office365
	
         .PARAMETER Repository
         NuGet Repository, default is the PowerShell Gallery
	
         .PARAMETER Version
         Return a PowerShell Version String instead of a String
	
         .EXAMPLE
         PS C:\> Get-etLatestNuGetRelease -Project 'et.Office365'
	
         Get the latest published version of a given Module from a NuGet Repository
	
         .EXAMPLE
         PS C:\> Get-etLatestNuGetRelease -Project 'et.Office365' -version
	
         Get the latest published version of a given Module from a NuGet Repository, but as Version instead of a String
	
         .EXAMPLE
         PS C:\> 'et.Office365' | Get-etLatestNuGetRelease
	
         Get the latest published version of a given Module from a NuGet Repository
	
         .NOTES
         enabling Technology internal Build helper function

         .LINK
         Get-etModuleVersion

         .LINK
         Compare-enModuleVersions

         .LINK
         Find-Module
   #>
	
   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([string])]
   param
   (
      [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 1,
      HelpMessage = 'Name of the Project, e.g. et.Office365')]
      [ValidateNotNullOrEmpty()]
      [Alias('etProject')]
      [string]
      $Project,
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 2)]
      [ValidateNotNullOrEmpty()]
      [Alias('etRepository', 'Gallery', 'NuGetGallery')]
      [string]
      $Repository = 'PSGallery',
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 3)]
      [Alias('enVersion')]
      [switch]
      $Version = $false
   )
	
   begin
   {
      $LatestNuGetRelease = $null
   }
	
   process
   {
      try 
      {
         $paramFindModule = @{
            Name          = $Project
            Repository    = $Repository
            ErrorAction   = 'Stop'
            WarningAction = 'SilentlyContinue'
         }
         $LatestNuGetRelease = (Find-Module @paramFindModule | Select-Object -ExpandProperty Version)
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
			
         # Output information. Post-process collected info, and log info (optional)
         $info | Out-String | Write-Verbose
			
         Write-Error -Message ($info.Exception) -TargetObject ($info.Target) -ErrorAction Stop
         break
      }   
   }
	
   end
   {
      if ($Version)
      {
         [version]$LatestNuGetRelease = $LatestNuGetRelease
      }
      else
      {
         [string]$LatestNuGetRelease = $LatestNuGetRelease
      }
		
      # Dump to the console
      $LatestNuGetRelease
   }
}
