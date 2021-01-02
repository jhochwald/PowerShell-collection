function Set-UniFiApiLoginBody
      {
         <#
               .SYNOPSIS
               Create the request body for the UniFi Login

               .DESCRIPTION
               Creates the JSON based request body for the UniFi Login

               .EXAMPLE
               Set-UniFiApiLoginBody

               Creates the JSON based request body for the UniFi Login

               .NOTES
               This is an internal helper function only
         #>
         [CmdletBinding(ConfirmImpact = 'None')]
         param ()

         begin
         {
            Write-Verbose -Message 'Start Set-UniFiApiLoginBody'

            # Call meta function
            $null = (Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState -ErrorAction SilentlyContinue -WarningAction SilentlyContinue)

            # Cleanup
            $RestBody = $null
            $JsonBody = $null

            Write-Verbose -Message 'Check for API Credentials'
            if ((-not $ApiUsername) -or (-not $ApiPassword))
            {
               Write-Error -Message 'Please set the UniFi API Credentials' -ErrorAction Stop

               # Only here to catch a global ErrorAction overwrite
               break
            }
         }

         process
         {
            Write-Verbose -Message 'Create the Body Object'

            $RestBody = [PSCustomObject][ordered]@{
               username = $ApiUsername
               password = $ApiPassword
            }

            # Convert the Body Object to JSON
            try
            {
               $paramConvertToJson = @{
                  InputObject   = $RestBody
                  Depth         = 5
                  ErrorAction   = 'Stop'
                  WarningAction = 'SilentlyContinue'
               }
               $Script:JsonBody = (ConvertTo-Json @paramConvertToJson)
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

               Write-Error -Message ($info.Exception) -ErrorAction Stop

               # Only here to catch a global ErrorAction overwrite
               break
            }
         }

         end
         {
            Write-Verbose -Message 'Created the Body Object'

            # Cleanup
            $RestBody = $null

            Write-Verbose -Message 'Done Set-UniFiApiLoginBody'
         }
      }
