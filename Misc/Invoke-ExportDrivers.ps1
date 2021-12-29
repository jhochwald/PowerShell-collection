#requires -Version 3.0 -Modules Dism -RunAsAdministrator
function Invoke-ExportDrivers
{
   <#
      .SYNOPSIS
      Export all Windows Drivers

      .DESCRIPTION
      Export all Windows Drivers, if they come via Windows Update (Microsoft)
      This could be useful, e.g., you can snapshot all your drivers before you update

      .PARAMETER Path
      Destination Directory

      .EXAMPLE
      PS C:\> Invoke-ExportDrivers -Path 'c:\drivers\'

      Export all Windows Drivers to c:\drivers\

      .EXAMPLE
      PS C:\> Invoke-ExportDrivers -Path 'c:\drivers'

      Export all Windows Drivers to c:\drivers\ <- See the difference?
      Demo of the PathCheck below

      .LINK
      https://github.com/jimbrig/PowerShell/blob/main/Custom/Export-Drivers.ps1

      .NOTES
      Reworked function found at @jimbrig repository

      This version was created during a workshop,
      therefore we have extensive and fancy verbose outputs in here
   #>
   [CmdletBinding(ConfirmImpact = 'None')]
   param
   (
      [Parameter(Mandatory,
         ValueFromPipeline,
         ValueFromPipelineByPropertyName,
         HelpMessage = 'Destination Directory')]
      [ValidateNotNullOrEmpty()]
      [Alias('destdir')]
      [string]
      $Path
   )

   begin
   {
      #region Cleanup
      $DriverTable = $null
      $DriverPath = $null
      #endregion Cleanup

      #region GarbageCollection
      [GC]::Collect()
      [GC]::WaitForPendingFinalizers()
      [GC]::Collect()
      [GC]::WaitForPendingFinalizers()
      #endregion GarbageCollection

      #region PathCheck
      if ($Path -notmatch '\\$')
      {
         # Append \
         $Path += '\'
      }
      #endregion PathCheck

      # Handle snapshots
      $DriverPath = ($Path + (Get-Date -Format 'yyyy-MM-dd'))

      #region DirectoryCheckAndHandler
      if (-not (Test-Path -Path $DriverPath -ErrorAction SilentlyContinue))
      {
         try
         {
            Write-Verbose -Message ('Try to create {0}' -f $DriverPath)

            $paramNewItem = @{
               ItemType    = 'Directory'
               Path        = $DriverPath
               Force       = $true
               Confirm     = $false
               ErrorAction = 'Stop'
            }
            $null = (New-Item @paramNewItem)
            $paramNewItem = $null

            Write-Verbose -Message ('[{0}] Done' -f ([Char]8730))
         }
         catch
         {
            Write-Verbose -Message ('[X] Failed')

            #region ErrorHandler
            [Management.Automation.ErrorRecord]$e = $_
            $info = @{
               Exception = $e.Exception.Message
               Reason    = $e.CategoryInfo.Reason
               Target    = $e.CategoryInfo.TargetName
               Script    = $e.InvocationInfo.ScriptName
               Line      = $e.InvocationInfo.ScriptLineNumber
               Column    = $e.InvocationInfo.OffsetInLine
            }
            $info | Out-String | Write-Verbose

            Write-Error -Message ($info.Exception) -ErrorAction Stop

            # Only here to catch a global ErrorAction overwrite
            break
            #endregion ErrorHandler
         }
      }
      #endregion DirectoryCheckAndHandler
   }


   process
   {
      #region DISM
      try
      {
         Write-Verbose -Message ('Export drivers via Deployment Image Servicing and Management to {0}' -f $DriverPath)

         $null = (& "$env:windir\system32\dism.exe" /online /export-driver /destination:$DriverPath)

         Write-Verbose -Message ('[{0}] Done' -f ([Char]8730))
      }
      catch
      {
         Write-Output -InputObject ('[X] Failed')

         #region ErrorHandler
         [Management.Automation.ErrorRecord]$e = $_
         $info = @{
            Exception = $e.Exception.Message
            Reason    = $e.CategoryInfo.Reason
            Target    = $e.CategoryInfo.TargetName
            Script    = $e.InvocationInfo.ScriptName
            Line      = $e.InvocationInfo.ScriptLineNumber
            Column    = $e.InvocationInfo.OffsetInLine
         }
         $info | Out-String | Write-Verbose

         Write-Error -Message ($info.Exception) -ErrorAction Stop

         # Only here to catch a global ErrorAction overwrite
         break
         #endregion ErrorHandler
      }
      #endregion DISM

      #region GetWindowsDriver
      try
      {
         #region GatherInfo
         Write-Verbose -Message 'Gathering Driver infos'

         $DriverTable = (Get-WindowsDriver -Online -ErrorAction Stop | Select-Object -Property Driver, CatalogFile, ClassName, ClassDescription, ProviderName, Online, Version, Date)

         Write-Verbose -Message ('[{0}] Done' -f ([Char]8730))
         #endregion GatherInfo

         #region ExportInfo
         Write-Verbose -Message ('Export Driver infos to {0}\Driver-Details.csv' -f $DriverPath)

         <#
               We use CSV, but we could also use JSON, or any other format
               We could use switches to implement this, or a parameter with a ValidateSet

               Example:
               param
               (
                  [ValidateNotNullOrEmpty()]
                  [ValidateSet('CSV', 'JSON', 'YAML', 'XML', IgnoreCase = $true)]
                  [String]
                  $Output = 'CSV'
               )

               Even Parameters Sets might be an option, but it seems to be a bit of an overkill in this case, right?
         #>
         $null = ($DriverTable | Sort-Object -Property Date -Descending | ConvertTo-Csv -Delimiter ';' -NoTypeInformation -ErrorAction Stop | Out-File -FilePath ('{0}\Driver-Details.csv' -f $DriverPath) -Force -Confirm:$false -Encoding utf8 -ErrorAction Stop)

         <#
               # Sample: Info as JSON File (Build into PowerShell)
               $null = ($DriverTable | Sort-Object -Property Date -Descending | ConvertTo-Json -Compress -Depth 5 -ErrorAction Stop | Out-File -FilePath ('{0}\Driver-Details.json' -f $DriverPath) -Force -Confirm:$false -Encoding utf8 -ErrorAction Stop)
         #>

         <#
               # Sample: Info as YAML File (Required the powershell-yaml from the PowerShellGallery)
               # Install it via: Install-Module -Name powershell-yaml -Repository PSGallery
               $null = ($DriverTable | Sort-Object -Property Date -Descending | ConvertTo-Yaml -Force -ErrorAction Stop | Out-File -FilePath ('{0}\Driver-Details.yml' -f $DriverPath) -Force -Confirm:$false -Encoding utf8 -ErrorAction Stop)
         #>

         <#
               # Sample: Info as XML (Build into PowerShell)
               $null = ($DriverTable | Sort-Object -Property Date -Descending | ConvertTo-Xml -As String -Depth 10 -ErrorAction Stop | Out-File -FilePath ('{0}\Driver-Details.xml' -f $DriverPath) -Force -Confirm:$false -Encoding utf8 -ErrorAction Stop)
         #>

         Write-Verbose -Message ('[{0}] Done' -f ([Char]8730))
         #endregion ExportInfo
      }
      catch
      {
         Write-Output -InputObject ('[X] Failed')

         #region ErrorHandler
         [Management.Automation.ErrorRecord]$e = $_
         $info = @{
            Exception = $e.Exception.Message
            Reason    = $e.CategoryInfo.Reason
            Target    = $e.CategoryInfo.TargetName
            Script    = $e.InvocationInfo.ScriptName
            Line      = $e.InvocationInfo.ScriptLineNumber
            Column    = $e.InvocationInfo.OffsetInLine
         }
         $info | Out-String | Write-Verbose

         Write-Error -Message ($info.Exception) -ErrorAction Stop

         # Only here to catch a global ErrorAction overwrite
         break
         #endregion ErrorHandler
      }
      #endregion GetWindowsDriver
   }

   end
   {
      Write-Verbose -Message ('Exported drivers and info can be found in {0}' -f $DriverPath)

      #region Cleanup
      $DriverTable = $null
      $DriverPath = $null
      #endregion Cleanup

      #region GarbageCollection
      [GC]::Collect()
      [GC]::WaitForPendingFinalizers()
      [GC]::Collect()
      [GC]::WaitForPendingFinalizers()
      #endregion GarbageCollection
   }
}

Invoke-ExportDrivers -Path 'c:\drivers\' -Verbose