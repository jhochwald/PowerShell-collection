#requires -Version 3.0 -Modules CimCmdlets

<#
      .SYNOPSIS
      Change brightness with powershell script without third-part software

      .DESCRIPTION
      Change brightness with powershell script without third-part software

      .PARAMETER Brightness
      Brightness level

      .EXAMPLE
      PS C:\> .\Set-DisplayBrightness.ps1 -Brightness 50

      Set Display Brightness to 50

      .LINK
      https://github.com/AutoDarkMode/Windows-Auto-Night-Mode/discussions/835

      .NOTES
      Rewritten function
#>
[CmdletBinding(ConfirmImpact = 'None')]
param
(
   [Parameter(ValueFromPipeline,
         ValueFromPipelineByPropertyName,
   ValueFromRemainingArguments = $true)]
   [ValidateNotNullOrEmpty()]
   [ValidateRange(0, 100)]
   [Alias('br', 'b')]
   [int]
   $Brightness = 50
)

begin
{
   # Windows-Auto-Night-Mode Script config (YAML)
   <#
         Enabled: true
         Component:
         TimeoutMillis: 3000
         Scripts:
         - Name: ChangeBrightnessScript
           Command: C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
           ArgsLight: [${pathToYourScriptsDir\Set-DisplayBrightness.ps1}, -b, 95]
           ArgsDark: [${pathToYourScriptsDir\Set-DisplayBrightness.ps1}, -b, 80]
           AllowedSources: [Any]
   #>
   
   # change screen's brightness with CIM   
   function Set-DisplayBrightness
   {
      <#
            .SYNOPSIS
            Set Display Brightness

            .DESCRIPTION
            Set Display Brightness via CIM

            .PARAMETER Brightness
            Brightness level

            .EXAMPLE
            PS C:\> Set-DisplayBrightness -Brightness 50

            Set Display Brightness to 50
      
            .LINK
            https://www.reddit.com/r/PowerShell/comments/1alrbbf/comment/kpht0e4/?rdt=54261

            .NOTES
            Rewritten function
      #>
      [CmdletBinding(ConfirmImpact = 'None',
      SupportsShouldProcess)]
      param
      (
         [Parameter(Mandatory,
               ValueFromPipeline,
               ValueFromPipelineByPropertyName,
         HelpMessage = 'Brightness level')]
         [ValidateNotNullOrEmpty()]
         [ValidateRange(0, 100)]
         [Alias('br', 'b')]
         [int]
         $Brightness
      )
      
      process
      {
         if ($pscmdlet.ShouldProcess('Brightness', 'Set'))
         {
            $paramGetCimInstance = @{
               Namespace   = 'root/WMI'
               ClassName   = 'WmiMonitorBrightnessMethods'
               ErrorAction = 'SilentlyContinue'
            }
            $paramInvokeCimMethod = @{
               MethodName  = 'WmiSetBrightness'
               Arguments   = @{
                  Timeout    = 0
                  Brightness = $Brightness
               }
               ErrorAction = 'SilentlyContinue'
            }
            $null = (Get-CimInstance @paramGetCimInstance | Invoke-CimMethod @paramInvokeCimMethod)
         }
      }
   }
}

process
{
   Set-DisplayBrightness -Brightness $Brightness
}
