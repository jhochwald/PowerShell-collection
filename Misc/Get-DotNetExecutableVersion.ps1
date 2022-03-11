<#
   .SYNOPSIS
   Get the version of the dotnet executable

   .DESCRIPTION
   Get the version of the dotnet executable
   It will update to a given version!

   .PARAMETER Version
   Required version, at least 2.1.401 is required

   .PARAMETER Unix
   Support for Unix/Linux, use the OS to get the latest executable

   .EXAMPLE
   PS C:\> .\Get-DotNetExecutableVersion.ps1

   .NOTES
   Inetrnal version (helper)
#>
[CmdletBinding(ConfirmImpact = 'None')]
[OutputType([psobject])]
param
(
   [Parameter(ValueFromPipeline,
              ValueFromPipelineByPropertyName)]
   [ValidateNotNullOrEmpty()]
   [string]
   $Version = '2.1.401',
   [Parameter(ValueFromPipeline,
              ValueFromPipelineByPropertyName)]
   [switch]
   $Unix
)

begin
{
   function TestDotNetVersion
   {
      <#
      .SYNOPSIS
      A brief description of the TestDotNetVersion function.

      .DESCRIPTION
      A detailed description of the TestDotNetVersion function.

      .PARAMETER command
      The executable to test

      .EXAMPLE
      PS C:\> TestDotNetVersion

      .NOTES
      Nothing fancy
      #>
      [CmdletBinding(ConfirmImpact = 'None')]
      [OutputType([psobject])]
      param
      (
         [Parameter(ValueFromPipeline,
                    ValueFromPipelineByPropertyName)]
         [Management.Automation.CommandInfo]
         $command
      )
      
      begin
      {
         $existingVersion = ((& $command --version) -split '-')[0]
      }
      
      process
      {
         if ($existingVersion -and (([version]$existingVersion) -ge ([version]$Version)))
         {
            return $true
         }
      }
      
      end
      {
         return $false
      }
      
   }
   
   $targetFolder = ('{0}/dotnet' -f $PSScriptRoot)
   $executableName = 'dotnet.exe'
   
   if ($Unix.IsPresent)
   {
      $executableName = 'dotnet'
   }
}

end
{
   if (($dotnet = (Get-Command -Name $executableName -ErrorAction SilentlyContinue)) -and (TestDotNetVersion -command $dotnet -ErrorAction SilentlyContinue))
   {
      return $dotnet
   }
   
   $localAppData = [Environment]::GetFolderPath(
      [Environment+SpecialFolder]::LocalApplicationData,
      [Environment+SpecialFolderOption]::Create
   )
   
   $localAppData = (Join-Path -Path $localAppData -ChildPath 'Microsoft/dotnet' -ErrorAction SilentlyContinue)
   
   if ($dotnet = Get-Command -Name $localAppData/$executableName -ErrorAction SilentlyContinue)
   {
      if (TestDotNetVersion -command $dotnet)
      {
         return $dotnet
      }
      
      <#
            If dotnet is already installed to local AppData but is not the version we are expecting, don't remove it.
            Instead try to install to the project directory (and check for an existing one).
      #>
      if ($dotnet = Get-Command -Name $targetFolder/$executableName -ErrorAction SilentlyContinue)
      {
         if (TestDotNetVersion -command $dotnet)
         {
            return $dotnet
         }
         
         Write-Warning -Message ('Found dotnet {0}.Version but require {1}' -f $dotnet, $Version)
         
         $null = (Remove-Item -Path $targetFolder -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue)
         
         $dotnet = $null
      }
   }
   else
   {
      # The Core SDK isn't already installed to local AppData, so install there.
      $targetFolder = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($localAppData)
      
      if (-not (Test-Path -Path $targetFolder))
      {
         $null = (New-Item -Path $targetFolder -ItemType Directory -Force -Confirm:$false -ErrorAction Stop)
      }
   }
   
   Write-Output -InputObject ('Green Downloading dotnet version {0}' -f $Version)
   
   try
   {
      $installerPath = $null
      
      if ($Unix.IsPresent)
      {
         $uri = 'https://raw.githubusercontent.com/dotnet/cli/v2.0.0/scripts/obtain/dotnet-install.sh'
         $installerPath = [IO.Path]::GetTempPath() + 'dotnet-install.sh'
         $scriptText = [Net.WebClient]::new().DownloadString($uri)
         $null = (Set-Content -Path $installerPath -Value $scriptText -Encoding UTF8 -Force -Confirm:$false)
         $installer = {
            [CmdletBinding()]
            param ($Version,
               $InstallDir)
            end
            {
               & (Get-Command -Name bash) $installerPath -Version $Version -InstallDir $InstallDir
            }
         }
      }
      else
      {
         $uri = 'https://raw.githubusercontent.com/dotnet/cli/v2.0.0/scripts/obtain/dotnet-install.ps1'
         $scriptText = [Net.WebClient]::new().DownloadString($uri)
         
         # Stop the official script from hard exiting at times...
         $safeScriptText = $scriptText -replace 'exit 0', 'return'
         $installer = [scriptblock]::Create($safeScriptText)
      }
      
      $null = & $installer -Version $Version -InstallDir $targetFolder
   }
   
   finally
   {
      if (-not [string]::IsNullOrEmpty($installerPath) -and (Test-Path -Path $installerPath))
      {
         $null = (Remove-Item -Path $installerPath -ErrorAction SilentlyContinue -Force -Confirm:$false)
      }
   }
   
   $found = (Get-Command -Name ('{0}/{1}' -f $targetFolder, $executableName) -ErrorAction SilentlyContinue)
   
   if (-not (TestDotNetVersion -command $found))
   {
      Write-Error -Exception 'Incorrect dotnet CLI version' -Message 'The dotnet CLI was downloaded without errors but appears to be the incorrect version.' -Category InvalidData -ErrorAction Stop
   }
   
   return $found
}