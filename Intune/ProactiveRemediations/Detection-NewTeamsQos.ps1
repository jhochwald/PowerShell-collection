<#
      Adopted script to cover the new Microsoft Teams Client
      Due to the name change (the new name is 'ms-teams.exe' instad of 'teams.exe') of the client

      License: BSD 3-Clause License
      Copyright © 2023 by enabling Technology. All rights reserved. 
#>

#region 32BitRestarter
# If we are running as a 32-bit process on an x64 system, re-launch as a 64-bit process
# Idea is stolen from Michael Niehaus - https://oofhours.com
if ($env:PROCESSOR_ARCHITEW6432 -ne 'ARM64')
{
   if (Test-Path -Path ('{0}\SysNative\WindowsPowerShell\v1.0\powershell.exe' -f $env:WINDIR) -ErrorAction SilentlyContinue)
   {
      & "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy bypass -File $PSCommandPath
      Exit $lastexitcode
   }
}
#endregion 32BitRestarter

try
{
   $paramGetNetQosPolicy = @{
      ErrorAction   = 'SilentlyContinue'
      WarningAction = 'SilentlyContinue'
   }
   
   if (-not (Get-NetQosPolicy -Name 'New Microsoft Teams Audio' @paramGetNetQosPolicy))
   {
      Exit 1
   }

   if (-not (Get-NetQosPolicy -Name 'New Microsoft Teams Video' @paramGetNetQosPolicy))
   {
      Exit 1
   }

   if (-not (Get-NetQosPolicy -Name 'New Microsoft Teams AppSharing' @paramGetNetQosPolicy))
   {
      Exit 1
   }
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

   Write-Verbose -Message $info
   
   $_ | Write-Error -ErrorAction Stop
   
   Exit 1
}

Exit 0