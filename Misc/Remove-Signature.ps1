function Remove-Signature
{
   <#
         .SYNOPSIS
         Finds all signed PowerShell files removes any digital signatures attached to them.

         .DESCRIPTION
         Finds all signed PowerShell files removes any digital signatures attached to them.
         Supported Filetypes are: psm1, ps1, psd1, and ps1xml - All other Files are ignored!

         .PARAMETER Path
         Single File or Path you want to parse for digital signatures. (Mandatory)

         .PARAMETER Recurse
         Recurse through all subdirectories of the path provided. The default is not work recursively (Optional)

         .EXAMPLE
         PS C:\> Remove-Signature -Path 'C:\Temp\Export-DistributionGroup2Cloud.ps1'

         Removes all digital signatures from 'C:\Temp\Export-DistributionGroup2Cloud.ps1'

         .EXAMPLE
         PS C:\> Remove-Signature -Path 'C:\Temp' -Recurse

         Removes all digital signatures from psm1, ps1, psd1, and ps1xml files found in 'C:\Temp' and below (recursively).

         .NOTES
         Based on the ideas and work of the original Authors: Adrian Rodriguez and Zachary Loeber

         .LINK
         http://www.the-little-things.net

         .LINK
         https://psrdrgz.github.io/RemoveAuthenticodeSignature/
   #>

   [CmdletBinding(ConfirmImpact = 'Low',
   SupportsShouldProcess)]
   param
   (
      [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 1,
      HelpMessage = 'Single File or Path you want to parse for digital signatures.')]
      [ValidateNotNullOrEmpty()]
      [Alias('FilePath')]
      [string]
      $Path,
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 2)]
      [switch]
      $Recurse = $false
   )

   begin
   {
      $paramGetChildItem = @{
         Path    = $Path
         File    = $true
         Include = '*.psm1', '*.ps1', '*.psd1', '*.ps1xml'
      }

      if ($Recurse)
      {
         Write-Verbose -Message 'Work recursively'
         $paramGetChildItem.Recurse = $true
      }
   }

   process
   {

      $FilesToProcess = (Get-ChildItem @paramGetChildItem)

      $FilesToProcess | ForEach-Object -Process {
         $SignatureStatus = (Get-AuthenticodeSignature -FilePath $_).Status
         $ScriptFileFullName = $_.FullName

         if ($SignatureStatus -ne 'NotSigned')
         {
            try
            {
               $paramGetContent = @{
                  Path          = $ScriptFileFullName
                  ErrorAction   = 'Stop'
                  WarningAction = 'Continue'
               }
               $Content = (Get-Content @paramGetContent)

               $paramNewObject = @{
                  TypeName      = 'System.Text.StringBuilder'
                  ErrorAction   = 'Stop'
                  WarningAction = 'Continue'
               }
               $StringBuilder = (New-Object @paramNewObject)

               foreach ($Line in $Content)
               {
                  if ($Line -match '^# SIG # Begin signature block|^<!-- SIG # Begin signature block -->')
                  {
                     break
                  }
                  else
                  {
                     $null = $StringBuilder.AppendLine($Line)
                  }
               }
               if ($pscmdlet.ShouldProcess("$ScriptFileFullName"))
               {
                  $paramSetContent = @{
                     Path          = $ScriptFileFullName
                     Value         = $StringBuilder.ToString()
                     Force         = $true
                     Confirm       = $false
                     Encoding      = 'UTF8'
                     ErrorAction   = 'Stop'
                     WarningAction = 'Continue'
                  }
                  $null = (Set-Content @paramSetContent)

                  Write-Verbose -Message ('Removed signature from {0}' -f $ScriptFileFullName)
               }
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
               Write-Verbose -Message $info

               Write-Error -Message ($info.Exception) -TargetObject ($info.Target) -ErrorAction Stop
               break
            }
         }
         else
         {
            Write-Verbose -Message ('No signature found in {0}' -f $ScriptFileFullName)
         }
      }
   }

   end
   {
      Write-Verbose -Message 'Remove-Signature Done'
   }
}
