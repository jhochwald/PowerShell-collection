#requires -Version 4.0 -RunAsAdministrator

<#
      .SYNOPSIS
      Update all installed global dotNET Tools

      .DESCRIPTION
      Update all installed global dotNET Tools

      .EXAMPLE
      PS C:\> .\Invoke-DotNetToolingUpgradeAll.ps1

      .NOTES
      Please execute within an elevated shell, be patient
      If you want to use this to update personal dotNET Tools, just remove the "--global" parameter in both command below
#>
[CmdletBinding(ConfirmImpact = 'None')]
[OutputType([string])]
param ()

process
{
   ((& "$env:ProgramW6432\dotnet\dotnet.exe" tool list --global | Select-Object -Skip 2).ForEach({
         $DotNetPackageName = ($_.Split(' ', 2)[0])
         Write-Verbose -Message ('Processing: {0}' -f $DotNetPackageName)
         $null = (& "$env:ProgramW6432\dotnet\dotnet.exe" tool update --global $DotNetPackageName)
   }))
}