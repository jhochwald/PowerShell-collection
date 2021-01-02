# Current script path
[string]$ModulePath = (Split-Path -Path (Get-Variable -Name myinvocation -Scope script).value.Mycommand.Definition -Parent)

# Current module name based on the directory
$ModuleName = ($ModulePath | Split-Path -Leaf)

#region ForceUnload
if ($ModuleName)
{
   $null = (Remove-Module -Name $ModuleName -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue)
}
#endregion ForceUnload

#region ModulePreLoadCode
# Module Pre-Load code
$null = (. (Join-Path -Path $ModulePath -ChildPath 'src\default\PreLoad.ps1' -ErrorAction Continue -WarningAction SilentlyContinue) @ProfilePathArg)
#endregion ModulePreLoadCode

#region ModulePrivateFunctions
$null = (Get-ChildItem -Path (Join-Path -Path $ModulePath -ChildPath 'src\private') -Recurse -Filter '*.ps1' -File | Sort-Object -Property Name | ForEach-Object -Process {
      Write-Verbose -Message "Dot sourcing private script file: $($_.Name)"
      . $_.FullName
})
#endregion ModulePrivateFunctions

#region ModulePublicFunctions
$null = (Get-ChildItem -Path (Join-Path -Path $ModulePath -ChildPath 'src\public') -Recurse -Filter '*.ps1' -File | Sort-Object -Property Name | ForEach-Object -Process {
      Write-Verbose -Message "Dot sourcing public script file: $($_.Name)"
      . $_.FullName

      # Find all the functions defined no deeper than the first level deep and export it.
      # This looks ugly but allows us to not keep any uneeded variables in memory that are not related to the module.
      ([Management.Automation.Language.Parser]::ParseInput((Get-Content -Path $_.FullName -Raw), [ref]$null, [ref]$null)).FindAll({
            $args[0] -is [Management.Automation.Language.FunctionDefinitionAst]
      }, $false) | ForEach-Object -Process {
         $null = (Export-ModuleMember -Function $_.Name)
      }
})
#endregion ModulePublicFunctions

#region ModulePostLoadCode
$null = (. (Join-Path -Path $ModulePath -ChildPath 'src\default\PostLoad.ps1' -ErrorAction Continue -WarningAction SilentlyContinue))
#endregion ModulePostLoadCode