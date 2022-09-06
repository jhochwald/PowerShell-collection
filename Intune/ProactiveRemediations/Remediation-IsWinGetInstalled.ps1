# Install missing WinGet

#region ARM64Handling
# Restart Process using PowerShell 64-bit
if ($ENV:PROCESSOR_ARCHITEW6432 -eq 'AMD64')
{
   try
   {
      &"$ENV:WINDIR\SysNative\WindowsPowershell\v1.0\PowerShell.exe" -File $PSCOMMANDPATH
   }
   catch
   {
      Throw ('Failed to start {0}' -f $PSCOMMANDPATH)
   }

   exit
}
#endregion ARM64Handling

#region Remediation
try
{
   $DownloadDirectory = [string] '{0}\AppInstaller' -f $env:TEMP

   $DownloadFiles = [PSCustomObject[]](
      $(
         [string[]](
            'https://aka.ms/Microsoft.VCLibs.x86.14.00.Desktop.appx', 
            'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx', 
            'https://github.com/microsoft/winget-cli/releases/download/v1.4.2161-preview/9959140a134740e68264cd1f82d35936_License1.xml', 
            'https://github.com/microsoft/winget-cli/releases/download/v1.4.2161-preview/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle'
         )
      ).ForEach{
         [PSCustomObject]@{
            'Uri'      = [string] $_
            'FileName' = [string] $_.Split('/')[-1]
            'TargetPath' = [string] '{0}\{1}' -f $DownloadDirectory, $_.Split('/')[-1]
         }
      }
   )

   # Download
   if (-not [IO.Directory]::Exists($DownloadDirectory)) 
   {
      $null = [IO.Directory]::CreateDirectory($DownloadDirectory)
   }

   foreach ($DownloadFile in $DownloadFiles) 
   {
      if ([IO.File]::Exists($DownloadFile.'TargetPath')) 
      {
         $null = [IO.File]::Delete($DownloadFile.'TargetPath')
      }
      $null = [Net.WebClient]::new().DownloadFile(
         $DownloadFile.'Uri',
         $DownloadFile.'TargetPath'
      )
   }

   # Install
   $null = Add-AppxProvisionedPackage -Online -PackagePath ($DownloadFiles.'TargetPath'.Where{
         $_.Split('.')[-1] -eq 'msixbundle'
   } -as [string]) -LicensePath ($DownloadFiles.'TargetPath'.Where{
         $_.Split('.')[-1] -eq 'xml'
   } -as [string]) -DependencyPackagePath ($DownloadFiles.'TargetPath'.Where{
         $_.Split('.')[-1] -eq 'appx'
   } -as [string[]])
}
catch
{
   Throw $_
   Exit 1
}

Exit 0
#endregion Remediation