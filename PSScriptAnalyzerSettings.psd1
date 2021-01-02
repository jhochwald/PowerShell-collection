#requires -Version 1.0

<#
      Use Severity when you want to limit the generated diagnostic records to a subset of: Error, Warning and Information.
      Uncomment the following line if you only want Errors and Warnings but not Information diagnostic records.

      SAMPLE:
      Severity     = @(
         'Error',
         'Warning'
      )

      Use IncludeRules when you want to run only a subset of the default rule set.

      SAMPLE:
      IncludeRules = @(
         'PSAvoidDefaultValueSwitchParameter',
         'PSMissingModuleManifestField',
         'PSReservedCmdletChar',
         'PSReservedParams',
         'PSShouldProcess',
         'PSUseApprovedVerbs',
         'PSUseDeclaredVarsMoreThanAssigments',
         'PSUseCompatibleCmdlets'
      )

      Use ExcludeRules when you want to run most of the default set of rules except for a few rules you wish to "exclude".
      Note: if a rule is in both IncludeRules and ExcludeRules, the rule will be excluded.

      SAMPLE:
      ExcludeRules = @(
         'PSAvoidTrailingWhitespace',
         'PSUseDeclaredVarsMoreThanAssignments'
      )

      You can use the following entry to supply parameters to rules that take parameters.
      For instance, the PSAvoidUsingCmdletAliases rule takes a whitelist for aliases you want to allow.

      SAMPLE:
      Rules = @{
      # https://github.com/PowerShell/PSScriptAnalyzer/blob/260a573e5e3f1ce8580c6ceb6f9089c7f1aadbc6/RuleDocumentation/UseCompatibleCmdlets.md
      PSUseCompatibleCmdlets = @{Compatibility = @(
         "core-6.0.0-alpha-linux",
         "core-6.0.0-alpha-windows",
         "core-6.0.0-alpha-osx"
      )}
      }
#>

@{
   Severity     = @(
      'Error',
      'Warning'
   )
   ExcludeRules = @(
      'PSAvoidUsingUserNameAndPassWordParams',
      'PSAvoidUsingPlainTextForPassword',
      'PSAvoidTrailingWhitespace',
      'PSUseDeclaredVarsMoreThanAssignments',
      'PSUseSingularNouns',
      'PSAvoidGlobalVars'
   )
   Rules        = @{
      PSUseCompatibleCmdlets = @{
         Compatibility = @(
            'core-6.0.2-alpha-linux',
            'core-6.0.2-alpha-windows',
            'core-6.0.2-alpha-osx',
            'desktop-5.1.17763.134-windows'
         )
      }
   }
}
