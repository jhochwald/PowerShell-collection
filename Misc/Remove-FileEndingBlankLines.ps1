function Remove-FileEndingBlankLines
{
   <#
         .SYNOPSIS
         Strip white space/blank lines from end of file or path

         .DESCRIPTION
         Strip white space/blank lines from end of file or path

         .PARAMETER Path
         Single File or Path you want to unclutter. (Mandatory)

         .PARAMETER Recurse
         Recurse through all subdirectories of the path provided. The default is not work recursively (Optional)

         .PARAMETER noNewLine
         No new (blank) line at the end of a file.

         .PARAMETER SafeFilesOnly
         Only safe files were processed. This is the default! This will prevent any issues with Binary Files or any other non safe to process files. If you like to process all files (can be dangerous) just negate this by using -SafeFilesOnly:$false

         .EXAMPLE
         PS C:\> Remove-FileEndingBlankLines -Path 'C:\Temp\Export-DistributionGroup2Cloud.ps1'

         Strip white space/blank lines from end of 'C:\Temp\Export-DistributionGroup2Cloud.ps1'

         .EXAMPLE
         PS C:\> Remove-FileEndingBlankLines -Path 'C:\Temp\Export-DistributionGroup2Cloud.ps1'

         Strip white space/blank lines from end of 'C:\Temp\Export-DistributionGroup2Cloud.ps1' without ending a final blank line at the end.
         NOTE: Set-Content adds a final blank line by default. this switch prevents this!

         .EXAMPLE
         PS C:\> Remove-FileEndingBlankLines -Path 'C:\Temp' -Recurse

         Strip white space/blank lines from end of files found in 'C:\Temp' and below (recursively).

         .EXAMPLE
         PS C:\> Remove-FileEndingBlankLines -Path 'C:\Temp' -Recurse -SafeFilesOnly:$false

         Strip white space/blank lines from end of all files found in 'C:\Temp' and below (recursively).
         This might be risky and/or even dangerous! If you process any binary files, they might be corrupt afterwards.

         .NOTES
         I created this helper function to unclutter the file ends and white space/blank lines from files during my build process.

         I prefer the way that Set-Content handles it: Add a single blank line at the end of each file. This is use to the fact, that I concatenate several files during a build process.

         I also added a switch (noNewLine) to prevent this.

         By default only PowerShell and Markdown Files are processed by this function

         .LINK
         Set-Content

         .LINK
         Get-Content
   #>
   [CmdletBinding(ConfirmImpact = 'Low',
   SupportsShouldProcess)]
   param
   (
      [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 1,
      HelpMessage = 'Single File or Path you want to unclutter.')]
      [ValidateNotNullOrEmpty()]
      [Alias('FilePath')]
      [string]
      $Path,
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 2)]
      [switch]
      $Recurse = $false,
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 3)]
      [switch]
      $noNewLine = $false,
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 4)]
      [switch]
      $SafeFilesOnly = $true
   )

   begin
   {
      $paramGetChildItem = @{
         Path = $Path
         File = $true
      }

      if ($SafeFilesOnly)
      {
         Write-Verbose -Message 'Only safe files are processed'
         $paramGetChildItem.Include = '*.psm1', '*.ps1', '*.psd1', '*.ps1xml', '*.md'
      }
      else
      {
         Write-Verbose -Message 'All are processed - Might be a bad idea!!!'
      }

      if ($Recurse)
      {
         Write-Verbose -Message 'Read the info recursively'
         $paramGetChildItem.Recurse = $true
      }
      else
      {
         Write-Verbose -Message 'Read the info'
      }
   }

   process
   {
      # Make sure only files are processed and get the minimal info
      (Get-ChildItem @paramGetChildItem| Where-Object -FilterScript {
-not $_.PSIsContainer
} | Select-Object -ExpandProperty FullName) | ForEach-Object -Process {
         Write-Verbose -Message ('Try to unclutter {0}' -f $_)

         $UnclutteredText = (((Get-Content -Path $_ -Raw).TrimEnd()).ToString())

         try
         {
            if ($noNewLine)
            {
               Write-Verbose -Message ('Try to unclutter {0} (no final new line)' -f $_)

               $null = ([io.file]::WriteAllText($_.FullName, $UnclutteredText))
            }
            else
            {
               Write-Verbose -Message ('Try to unclutter {0}' -f $_)

               $paramSetContent = @{
                  Path          = $_
                  Value         = $UnclutteredText
                  Force         = $true
                  Confirm       = $false
                  Encoding      = 'UTF8'
                  ErrorAction   = 'Stop'
                  WarningAction = 'Continue'
               }
               $null = (Set-Content @paramSetContent)
            }

            Write-Verbose -Message ('Uncluttered {0}' -f $_)
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
   }

   end
   {
      Write-Verbose -Message 'Clear-FileEnding Done'
   }
}
