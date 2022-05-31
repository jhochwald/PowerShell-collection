#requires -Version 3.0 -RunAsAdministrator

<#
      .SYNOPSIS
      Apply the CVE-2022-30190 workaround as recommended by the MSRC

      .DESCRIPTION
      Apply the CVE-2022-30190 workaround by disable the MSDT URL Protocol as recommended by the Microsoft Security Response Center

      .EXAMPLE
      PS C:\> .\Invoke-MitigateCVE202230190.ps1

      .LINK
      https://msrc.microsoft.com/update-guide/en-US/vulnerability/CVE-2022-30190

      .LINK
      https://msrc-blog.microsoft.com/2022/05/30/guidance-for-cve-2022-30190-microsoft-support-diagnostic-tool-vulnerability/

      .NOTES
      This is a full PowerShell version of this simple CMD command:
      reg delete HKEY_CLASSES_ROOT\ms-msdt /f

      A bit more complex, because the "HKEY_CLASSES_ROOT" is not a default path in most cases,
      bus this cases are also supported.
#>
[CmdletBinding(ConfirmImpact = 'Low')]
param ()

begin
{
   # Clean-up
   $RegistryRoot = $null

   # Figure out if we have an existing PowerShell Registry Provider mapping
   $paramGetPSDrive = @{
      ErrorAction   = 'SilentlyContinue'
      WarningAction = 'SilentlyContinue'
   }
   $RegistryRoot = ((Get-PSDrive @paramGetPSDrive | Where-Object {
            $PSItem.Root -eq 'HKEY_CLASSES_ROOT'
         }).Name)
   $paramGetPSDrive = $null

   if (-not ($RegistryRoot))
   {
      # PowerShell Registry Provider
      $paramNewPSDrive = @{
         PSProvider  = 'registry'
         Root        = 'HKEY_CLASSES_ROOT'
         Name        = 'HKCR'
         ErrorAction = 'Stop'
      }
      $RegistryRoot = ((New-PSDrive @paramNewPSDrive).Name)
      $paramNewPSDrive = $null
   }
}

process
{
   try
   {
      # Guidance for CVE-2022-30190 Microsoft Support Diagnostic Tool Vulnerability
      $paramRemoveItem = @{
         Path        = ('{0}:\ms-msdt' -f $RegistryRoot)
         Force       = $true
         Recurse     = $true
         ErrorAction = 'Stop'
      }
      $null = (Remove-Item @paramRemoveItem)
      $paramRemoveItem = $null
   }
   catch
   {
      [Management.Automation.ErrorRecord]$e = $_

      $info = [PSCustomObject]@{
         Exception = $e.Exception.Message
         Reason    = $e.CategoryInfo.Reason
         Target    = $e.CategoryInfo.TargetName
         Script    = $e.InvocationInfo.ScriptName
         Line      = $e.InvocationInfo.ScriptLineNumber
         Column    = $e.InvocationInfo.OffsetInLine
      }

      Write-Warning -Message $info -WarningAction Stop

      exit 1
   }
}

end
{
   Write-Output -InputObject 'CVE-2022-30190 workaround was applied!'

   exit 0
}
