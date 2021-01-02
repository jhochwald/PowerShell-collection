
#TODO: Replace PATH
$here = 'C:\scripts\PowerShell\dev\UniFiTooling'

$module = 'UniFiTooling'

Describe -Name ('{0} Module Tests' -f $module)  -Fixture {

   Context -Name 'Module Setup' -Fixture {
      It -name ('Has the root module {0}.psm1' -f $module) -test {
         "$here\$module.psm1" | Should Exist
      }

      It -name "Has the a manifest file of $module.psm1" -test {
         "$here\$module.psd1" | Should Exist
         "$here\$module.psd1" | Should Contain "$module.psm1"
      }

      It -name "$module folder has functions" -test {
         "$here\src\public\*.ps1" | Should Exist
      }

      It -name "$module is valid PowerShell code" -test {
         $psFile = Get-Content -Path "$here\$module.psm1" `
         -ErrorAction Stop
         $errors = $null
         $null = [Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)
         $errors.Count | Should Be 0
      }
   }

   $functions = @()
   
   #TODO: Replace PATH
   $FunctionFiles = (Get-ChildItem -Path (Join-Path -Path 'C:\scripts\PowerShell\dev\UniFiTooling' -ChildPath 'src\public') -Recurse -Filter '*.ps1' -File | Sort-Object -Property Name | ForEach-Object -Process {
         Write-Verbose -Message "Dot sourcing public script file: $($_.Name)"
         . $_.FullName

         # Find all the functions defined no deeper than the first level deep and export it.
         # This looks ugly but allows us to not keep any uneeded variables in memory that are not related to the module.
         ([Management.Automation.Language.Parser]::ParseInput((Get-Content -Path $_.FullName -Raw), [ref]$null, [ref]$null)).FindAll({
               $args[0] -is [Management.Automation.Language.FunctionDefinitionAst]
         }, $false) | ForEach-Object -Process {
            $FunctionName = $_.Name
            $functions = $functions + $FunctionName
         }
   })

   foreach ($function in $functions)
   {
  
      Context -Name "Test Function $function" -Fixture {
      
         It -name "$function.ps1 should exist" -test {
            "$here\src\public\$function.ps1" | Should Exist
         }
    
         It -name "$function.ps1 should have help block" -test {
            "$here\src\public\$function.ps1" | Should Contain '<#'
            "$here\src\public\$function.ps1" | Should Contain '#>'
         }

         It -name "$function.ps1 should have a SYNOPSIS section in the help block" -test {
            "$here\src\public\$function.ps1" | Should Contain '.SYNOPSIS'
         }
    
         It -name "$function.ps1 should have a DESCRIPTION section in the help block" -test {
            "$here\src\public\$function.ps1" | Should Contain '.DESCRIPTION'
         }

         It -name "$function.ps1 should have a EXAMPLE section in the help block" -test {
            "$here\src\public\$function.ps1" | Should Contain '.EXAMPLE'
         }
    
         It -name "$function.ps1 should be an advanced function" -test {
            "$here\src\public\$function.ps1" | Should Contain 'function'
            "$here\src\public\$function.ps1" | Should Contain 'cmdletbinding'
            "$here\src\public\$function.ps1" | Should Contain 'param'
         }
      
         It -name "$function.ps1 should contain Write-Verbose blocks" -test {
            "$here\src\public\$function.ps1" | Should Contain 'Write-Verbose'
         }
    
         It -name "$function.ps1 is valid PowerShell code" -test {
            $psFile = Get-Content -Path "$here\src\public\$function.ps1" `
                              -ErrorAction Stop
            $errors = $null
            $null = [Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)
            $errors.Count | Should Be 0
         }

    
      } # Context "Test Function $function"

      Context -Name "$function has tests" -Fixture {
         It -name "$($function).Tests.ps1 should exist" -test {
            #TODO: Replace with "$($function).Tests.ps1" | Should Exist
            "$here\src\tests\$($function).Tests.ps1" | Should Exist
         }
      }
  
   } # foreach ($function in $functions)

}

