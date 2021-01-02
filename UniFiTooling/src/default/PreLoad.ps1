<#
      This is an early beta version! I can't recommend using it in production.
#>

function Get-CallerPreference
{
   <#
         .Synopsis
         Fetches "Preference" variable values from the caller's scope.

         .DESCRIPTION
         Script module functions do not automatically inherit their caller's variables, but they can be obtained through the $PSCmdlet variable in Advanced Functions.
         This function is a helper function for any script module Advanced Function; by passing in the values of $ExecutionContext.SessionState and $PSCmdlet, Get-CallerPreference will set the caller's preference variables locally.

         .PARAMETER Cmdlet
         The $PSCmdlet object from a script module Advanced Function.

         .PARAMETER SessionState
         The $ExecutionContext.SessionState object from a script module Advanced Function.
         This is how the Get-CallerPreference function sets variables in its callers' scope, even if that caller is in a different script module.

         .PARAMETER Name
         Optional array of parameter names to retrieve from the caller's scope.
         Default is to retrieve all Preference variables as defined in the about_Preference_Variables help file (as of PowerShell 4.0)
         This parameter may also specify names of variables that are not in the about_Preference_Variables help file, and the function will retrieve and set those as well.

         .EXAMPLE
         Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

         Imports the default PowerShell preference variables from the caller into the local scope.

         .EXAMPLE
         Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState -Name 'ErrorActionPreference','SomeOtherVariable'

         Imports only the ErrorActionPreference and SomeOtherVariable variables into the local scope.

         .EXAMPLE
         'ErrorActionPreference','SomeOtherVariable' | Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

         Same as Example 2, but sends variable names to the Name parameter via pipeline input.

         .INPUTS
         String

         .OUTPUTS
         None.  This function does not produce pipeline output.

         .LINK
         about_Preference_Variables

         .LINK
         about_CommonParameters

         .LINK
         https://gallery.technet.microsoft.com/scriptcenter/Inherit-Preference-82343b9d

         .LINK
         http://powershell.org/wp/2014/01/13/getting-your-script-module-functions-to-inherit-preference-variables-from-the-caller/

         .NOTE
         Original Script by David Wyatt
   #>

   [CmdletBinding(DefaultParameterSetName = 'AllVariables')]
   param (
      [Parameter(Mandatory,HelpMessage = 'The PSCmdlet object from a script module Advanced Function.')]
      [ValidateScript({
               $_.GetType().FullName -eq 'System.Management.Automation.PSScriptCmdlet'
      })]
      $Cmdlet,
      [Parameter(Mandatory,HelpMessage = ' The ExecutionContext.SessionState object from a script module Advanced Function.')]
      [Management.Automation.SessionState]
      $SessionState,
      [Parameter(ParameterSetName = 'Filtered', ValueFromPipeline)]
      [string[]]
      $Name
   )

   begin
   {
      $filterHash = @{}
   }

   process
   {
      if ($null -ne $Name)
      {
         foreach ($string in $Name)
         {
            $filterHash[$string] = $true
         }
      }
   }

   end
   {
      # List of preference variables taken from the about_Preference_Variables help file in PowerShell version 4.0
      $vars = @{
         'ErrorView'                   = $null
         'FormatEnumerationLimit'      = $null
         'LogCommandHealthEvent'       = $null
         'LogCommandLifecycleEvent'    = $null
         'LogEngineHealthEvent'        = $null
         'LogEngineLifecycleEvent'     = $null
         'LogProviderHealthEvent'      = $null
         'LogProviderLifecycleEvent'   = $null
         'MaximumAliasCount'           = $null
         'MaximumDriveCount'           = $null
         'MaximumErrorCount'           = $null
         'MaximumFunctionCount'        = $null
         'MaximumHistoryCount'         = $null
         'MaximumVariableCount'        = $null
         'OFS'                         = $null
         'OutputEncoding'              = $null
         'ProgressPreference'          = $null
         'PSDefaultParameterValues'    = $null
         'PSEmailServer'               = $null
         'PSModuleAutoLoadingPreference' = $null
         'PSSessionApplicationName'    = $null
         'PSSessionConfigurationName'  = $null
         'PSSessionOption'             = $null
         'ErrorActionPreference'       = 'ErrorAction'
         'DebugPreference'             = 'Debug'
         'ConfirmPreference'           = 'Confirm'
         'WhatIfPreference'            = 'WhatIf'
         'VerbosePreference'           = 'Verbose'
         'WarningPreference'           = 'WarningAction'
      }


      foreach ($entry in $vars.GetEnumerator())
      {
         if (([string]::IsNullOrEmpty($entry.Value) -or -not $Cmdlet.MyInvocation.BoundParameters.ContainsKey($entry.Value)) -and ($PSCmdlet.ParameterSetName -eq 'AllVariables' -or $filterHash.ContainsKey($entry.Name)))
         {
            $variable = $Cmdlet.SessionState.PSVariable.Get($entry.Key)

            if ($null -ne $variable)
            {
               if ($SessionState -eq $ExecutionContext.SessionState)
               {
                  $paramSetVariable = @{
                     Scope   = 1
                     Name    = $variable.Name
                     Value   = $variable.Value
                     Force   = $true
                     Confirm = $false
                     WhatIf  = $false
                  }
                  $null = (Set-Variable @paramSetVariable)
               }
               else
               {
                  $SessionState.PSVariable.Set($variable.Name, $variable.Value)
               }
            }
         }
      }

      if ($PSCmdlet.ParameterSetName -eq 'Filtered')
      {
         foreach ($varName in $filterHash.Keys)
         {
            if (-not $vars.ContainsKey($varName))
            {
               $variable = $Cmdlet.SessionState.PSVariable.Get($varName)

               if ($null -ne $variable)
               {
                  if ($SessionState -eq $ExecutionContext.SessionState)
                  {
                     $paramSetVariable = @{
                        Scope   = 1
                        Name    = $variable.Name
                        Value   = $variable.Value
                        Force   = $true
                        Confirm = $false
                        WhatIf  = $false
                     }
                     $null = (Set-Variable @paramSetVariable)
                  }
                  else
                  {
                     $SessionState.PSVariable.Set($variable.Name, $variable.Value)
                  }
               }
            }
         }
      }
   }
}
