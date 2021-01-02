#requires -Version 3.0

<#
      .SYNOPSIS
      Basic Installer for the UniFiTooling PowerShell Module

      .DESCRIPTION
      Basic Installer for the enabling Technology UniFiTooling PowerShell Module

      .EXAMPLE
      PS C:\> Install-Module -Name 'UniFiTooling' -Scope CurrentUser

      Install the module for the Current User with PowerShellGet directly from the Powershell Gallery, Preferred method

      .EXAMPLE
      PS C:\> Install-Module -Name 'UniFiTooling' -Scope AllUsers

      Install the module for the All Users with PowerShellGet directly from the Powershell Gallery, Preferred method.
      Run this in an administrative PowerShell prompt (Elevated).

      .EXAMPLE
      PS C:\> .\Install.ps1

      Basic Installer for the UniFiTooling PowerShell Module

      .EXAMPLE
      PS C:\> iex (New-Object Net.WebClient).DownloadString("https://github.com/Enatec/UniFiTooling/raw/master/Install.ps1")

      Basic Installer for the UniFiTooling PowerShell Module

      .NOTES
      This is a unsupported method to install the UniFiTooling PowerShell Module!

      .LINK

#>
[CmdletBinding(ConfirmImpact = 'Low')]
param ()

begin
{
   # Variables
   $ModuleName = 'UniFiTooling'
   $DownloadURL = 'https://github.com/Enatec/UniFiTooling/raw/master/release/UniFiTooling-current.zip'
}

process
{
   try
   {
      # Download and install the module
      $webclient = (New-Object -TypeName System.Net.WebClient)
      $file = "$($env:TEMP)\$($ModuleName).zip"

      Write-Output -InputObject ('Downloading latest version of {0} from {1}' -f $ModuleName, $DownloadURL)

      $webclient.DownloadFile($DownloadURL, $file)

      Write-Output -InputObject ('File saved to {0}' -f $file)

      $targetondisk = "$($env:USERPROFILE)\Documents\WindowsPowerShell\Modules\$($ModuleName)"
      $null = (New-Item -ItemType Directory -Force -Path $targetondisk)
      $shell_app = (New-Object -ComObject shell.application)
      $zip_file = $shell_app.namespace($file)

      Write-Output -InputObject ('Uncompressing the Zip file to {0}' -f $targetondisk)

      $destination = $shell_app.namespace($targetondisk)
      $destination.Copyhere($zip_file.items(), 0x10)
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
      Write-Verbose -Message $info

      Write-Error -Message ($info.Exception) -TargetObject ($info.Target) -ErrorAction Stop
      break
   }
}

end
{
   Write-Output -InputObject 'Module has been installed!'
   Write-Output -InputObject ('You can now import the module with: Import-Module -Name {0}' -f $ModuleName)
}
