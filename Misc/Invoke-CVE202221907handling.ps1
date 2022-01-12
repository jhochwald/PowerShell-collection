<#
   .SYNOPSIS
      Mitigate potential vulnerability for CVE-2022-21907

   .DESCRIPTION
      Mitigate potential vulnerability for CVE-2022-21907
      By default we assume "Report only", but we present a warning if the system might be vulnerability for CVE-2022-21907.

   .PARAMETER Report
      Return FALSE is the system is not effected by CVE-2022-21907

   .PARAMETER Mitigate
      If the registry entry exists, that can cause a risk of vulnerability for CVE-2022-21907.
      To mitigate, the value will be set to 0

   .PARAMETER Default
      Revert to the default and remove the Registry entry and removes the registry entry that can cause a risk of vulnerability for CVE-2022-21907
      This is the preferred way!

   .EXAMPLE
      PS C:\> .\Invoke-CVE202221907handling.ps1

      Return FALSE is the system is not effected by CVE-2022-21907

   .EXAMPLE
      PS C:\> .\Invoke-CVE202221907handling.ps1 -Report

      Return FALSE is the system is not effected by CVE-2022-21907

   .EXAMPLE
      PS C:\> .\Invoke-CVE202221907handling.ps1 -Mitigate

      If the registry entry exists, that can cause a risk of vulnerability for CVE-2022-21907.

   .EXAMPLE
      PS C:\> .\Invoke-CVE202221907handling.ps1 -Default

      Revert to the default and remove the Registry entry and removes the registry entry that can cause a risk of vulnerability for CVE-2022-21907

   .LINK
      https://www.bleepingcomputer.com/news/microsoft/microsoft-new-critical-windows-http-vulnerability-is-wormable/

   .LINK
      https://msrc.microsoft.com/update-guide/vulnerability/CVE-2022-21907

   .LINK
      https://isc.sans.edu/diary/rss/28234

   .LINK
      https://dshield.org/forums/diary/A+Quick+CVE202221907+FAQ+work+in+progress/28234/


   .NOTES
      Quick and dirty CVE-2022-21907 mitigation and reporting
#>
[CmdletBinding(DefaultParameterSetName = 'Default',
   ConfirmImpact = 'Low')]
[OutputType([bool])]
param
(
   [Parameter(ParameterSetName = 'Report',
      ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
   [Alias('ReportOnly')]
   [switch]
   $Report,
   [Parameter(ParameterSetName = 'Mitigate',
      ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
   [Alias('MitigateCVE')]
   [switch]
   $Mitigate,
   [Parameter(ParameterSetName = 'Default',
      ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
   [Alias('Revert', 'RevertToDefault')]
   [switch]
   $Default
)

begin
{
   # Defaults
   $RegistryValue = 'EnableTrailerSupport'
   $RegistryPath = 'HKLM:\System\CurrentControlSet\Services\HTTP\Parameters\'

   # By default, we assume, the host is not vulnerable to CVE-2022-21907
   $IsEffected = $false
}

process
{
   # Let us check that
   $paramGetItemProperty = @{
      Path        = $RegistryPath
      Name        = $RegistryValue
      ErrorAction = 'SilentlyContinue'
   }
   if (((Get-ItemProperty @paramGetItemProperty ).EnableTrailerSupport) -eq 1)
   {
      # Whoops!
      $IsEffected = $true
   }
   $paramGetItemProperty = $null

   if ($IsEffected -eq $true)
   {
      Write-Warning -Message ('{0} might be vulnerable to CVE-2022-21907!!!' -f $env:COMPUTERNAME)

      try
      {
         if ($PSBoundParameters.ContainsKey('Mitigate'))
         {
            $paramSetItemProperty = @{
               Path        = $RegistryPath
               Name        = $RegistryValue
               Value       = '00000000'
               WhatIf      = $false
               Force       = $true
               Confirm     = $false
               ErrorAction = 'Stop'
            }
            $null = (Set-ItemProperty @paramSetItemProperty)
            $paramSetItemProperty = $null
         }
         elseif ($PSBoundParameters.ContainsKey('Default'))
         {
            $paramRemoveItemProperty = @{
               Path        = $RegistryPath
               Name        = $RegistryValue
               WhatIf      = $false
               Force       = $true
               Confirm     = $false
               ErrorAction = 'Stop'
            }
            $null = (Remove-ItemProperty @paramRemoveItemProperty)
            $paramRemoveItemProperty = $null
         }
         else
         {
            $IsEffected
         }
      }
      catch
      {
         #region ErrorHandler
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
         $info | Out-String | Write-Verbose

         Write-Warning -Message $info.Exception
         #endregion ErrorHandler
      }
   }
   else
   {
      $IsEffected
   }
}

end
{
   $IsEffected = $null
   $RegistryValue = $null
   $RegistryPath = $null
}