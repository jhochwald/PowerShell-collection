#requires -Version 3.0

function Invoke-AdvancedInstallerUpdate
{
   <#
         .SYNOPSIS
         Sample function to rebuild a given Advanced Installer Project

         .DESCRIPTION
         Rebuild a given Advanced Installer Project.
         Sample script to update the build Number from our build server and create a new MSI installer.

         .PARAMETER Project
         Advanced installer project name (the name of the Project file, without the AIP extension).
         Example: DummyProduct for DummyProduct.aip

         .PARAMETER Path
         Specifies the path to Advanced Installer Project File.

         .PARAMETER Version
         Version of the new build.

         .EXAMPLE
         PS C:\> Invoke-AdvancedInstallerUpdate -Project 'DummyProduct' -Path 'x:\dev\projects\DummyProduct\' -Version '1.0.3'

         .NOTES
         Sample Project

         .LINK
         https://www.advancedinstaller.com/user-guide/powershell-automation.html
   #>

   [CmdletBinding(ConfirmImpact = 'None')]
   param
   (
      [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 0,
      HelpMessage = 'Advanced installer project name (the name of the Project file, without the AIP extension).')]
      [ValidateNotNullOrEmpty()]
      [Alias('ProjectName', 'aipName')]
      [string]
      $Project,
      [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 1,
      HelpMessage = 'Specifies the path to Advanced Installer Project File.')]
      [ValidateNotNullOrEmpty()]
      [Alias('aipPath')]
      [string]
      $Path,
      [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 2,
      HelpMessage = 'Version of the new build.')]
      [ValidateNotNullOrEmpty()]
      [Alias('aipVersion')]
      [string]
      $Version
   )

   begin
   {
      # Create the full path of the Avanced Installer Project file
      $AdvancedInstallerProjectName = $Path + $Project + '.aip'

      # Check if the File exists
      if (-not (Test-Path -Path $AdvancedInstallerProjectName -ErrorAction SilentlyContinue))
      {
         #region ErrorHandler
         $paramWriteError = @{
            Message           = ('The given File {0} was not found' -f $AdvancedInstallerProjectName)
            TargetObject      = $AdvancedInstallerProjectName
            Category          = 'ObjectNotFound'
            RecommendedAction = 'Check filename'
            ErrorAction       = 'Stop'
         }
         Write-Error @paramWriteError

         # Only here to catch a global ErrorAction overwrite
         break
         #endregion ErrorHandler
      }

      # New Version number
      $AdvancedInstallerProjectVersion = $Version
   }

   process
   {
      # Cleanup
      $AdvancedInstallerProject = $null

      # Creates a new PS object for Advanced Installer interaction
      $AdvancedInstaller = (New-Object -ComObject AdvancedInstaller)

      # Load the Advanced Installer object
      try
      {
         $AdvancedInstallerProject = $AdvancedInstaller.LoadProject($AdvancedInstallerProjectName)
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

         Write-Verbose -Message $info

         Write-Error -Message ($info.Exception) -ErrorAction Stop

         # Only here to catch a global ErrorAction overwrite
         break
         #endregion ErrorHandler
      }

      if ($AdvancedInstallerProject)
      {
         # Modidy the version number
         $AdvancedInstallerProject.ProductDetails.Version = $AdvancedInstallerProjectVersion

         try
         {
            # Build the project
            $AdvancedInstallerProjectBuild = ($AdvancedInstallerProject.Build())

            Write-Verbose -Message $AdvancedInstallerProjectBuild

            # Save the modified file
            try
            {
               # Note: Remove the $null if you would like to see the output
               $null = ($AdvancedInstallerProject.SaveAs($AdvancedInstallerProjectName))
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

               Write-Verbose -Message $info

               Write-Error -Message ($info.Exception) -ErrorAction Stop

               # Only here to catch a global ErrorAction overwrite
               break
               #endregion ErrorHandler
            }
         }
         catch
         {
            Write-Error -Message 'Build failed'
         }
         finally
         {
            # Cleanup
            $AdvancedInstallerProject = $null
            $AdvancedInstaller = $null
         }
      }
      else
      {
         #region ErrorHandler
         $paramWriteError = @{
            Message           = ('Unable to load {0}' -f $AdvancedInstallerProjectName)
            TargetObject      = $AdvancedInstallerProjectName
            Category          = 'InvalidData'
            RecommendedAction = 'Check file'
            ErrorAction       = 'Stop'
         }
         Write-Error @paramWriteError

         # Only here to catch a global ErrorAction overwrite
         break
         #endregion ErrorHandler
      }
   }

   end
   {
      # Create a filter for the MSI
      $AdvancedInstallerProjectMSI = $Project + '.msi'

      # Cleanup
      $AdvancedInstallerProjectMSIPath = $null

      # Loop over the returned object and try to find the MSI
      $AdvancedInstallerProjectMSIPath = ($AdvancedInstallerProjectBuild.Split("`n") | ForEach-Object {
            if($_ -match $AdvancedInstallerProjectMSI)
            {
               $_
            }
      })
      # TODO: The method is a bit crappy

      if ($AdvancedInstallerProjectMSIPath)
      {
         Write-Host -Object $AdvancedInstallerProjectMSIPath
      } else
      {
         Write-Warning -Message 'New MSI was not found' -WarningAction Continue
      }
   }
}
