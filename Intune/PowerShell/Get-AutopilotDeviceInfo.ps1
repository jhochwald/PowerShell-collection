function Get-AutopilotDeviceInfo
{
   <#
         .SYNOPSIS
         Show in which tenant a device is registered with Windows Autopilot
   
         .DESCRIPTION
         Show in which tenant a device is registered with Windows Autopilot
         The details are stored in the device's registry (if the Autopilot profile has been downloaded).
   
         .PARAMETER Profile
         Show extended Information from cached profile
   
         .EXAMPLE
         PS C:\> Get-AutopilotDeviceInfo
      
         Show in which tenant a device is registered with Windows Autopilot
   
         .EXAMPLE
         PS C:\> Get-AutopilotDeviceInfo -Profile
      
         Show in which tenant a device is registered with Windows Autopilot and the extended Information from cached profile
   
         .NOTES
         Based on Get-AutopilotProfileInfo 1.1 by Florian Salzmann (MIT Licensed)
   #>
   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([pscustomobject])]
   param
   (
      [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
      [switch]
      $Profile
   )
   
   begin
   {
      # Create a new ordered object, I know... Wrong onject, right? guess not!
      $AutopilotDeviceInfo = [ordered]@{}

      # Autpilot Domain Info
      $CATDPath = 'HKLM:\SOFTWARE\Microsoft\Provisioning\Diagnostics\Autopilot'
      $CATDKey = 'CloudAssignedTenantDomain'

      # Autopilot Policy Cache, as JSON
      $APJCPath = 'HKLM:\SOFTWARE\Microsoft\Provisioning\AutopilotPolicyCache'
      $APJCKey = 'PolicyJsonCache'
   }
   
   process
   {
      try
      {
         if (Test-Path -Path $CATDPath -ErrorAction SilentlyContinue)
         {
            $paramGetItemProperty = @{
               Path        = $CATDPath
               Name        = $CATDKey
               ErrorAction = 'Stop'
            }
            #$CATDResult = (Get-ItemProperty @paramGetItemProperty | Select-Object -ExpandProperty $CATDKey)
            
            # Now we add the info to our existing object
            $AutopilotDeviceInfo += @{
               'RegisteredDomain' = [string](Get-ItemProperty @paramGetItemProperty | Select-Object -ExpandProperty $CATDKey)
            }
         }
         else
         {
            # OK, I guess we are done here
            $paramWriteError = @{
               Exception         = 'CloudAssignedTenantDomain not found'
               Message           = 'No Autopilot Infos found!'
               Category          = 'ObjectNotFound'
               TargetObject      = $CATDPath
               RecommendedAction = 'Check if device is registered for Autopilot'
               ErrorAction       = 'Stop'
            }
            Write-Error @paramWriteError
         }
         
         if ($Profile)
         {
            if (Test-Path -Path $APJCPath)
            {
               $paramGetItemProperty = @{
                  Path        = $APJCPath
                  Name        = $APJCKey
                  ErrorAction = 'Stop'
               }

               # Now we add the info to our existing object (each property)
               foreach ($Property  in (Get-ItemProperty @paramGetItemProperty | Select-Object -ExpandProperty $APJCKey | ConvertFrom-Json -WarningAction Stop).PSObject.Properties)
               {
                  # I know, this does not look fancy, but it works very well
                  $AutopilotDeviceInfo += @{
                     # Append each key/value pair to the existing object
                     $Property.Name = $Property.Value
                  }
               }
            }
            else
            {
               Write-Warning -Message 'No extended Autopilot Infos found!'
            }
         }
      }
      catch
      {
         # Get error record
         [Management.Automation.ErrorRecord]$e = $_
         
         # Retrieve information about runtime error
         $info = [PSCustomObject]@{
            Exception = $e.Exception.Message
            Reason    = $e.CategoryInfo.Reason
            Target    = $e.CategoryInfo.TargetName
            Script    = $e.InvocationInfo.ScriptName
            Line      = $e.InvocationInfo.ScriptLineNumber
            Column    = $e.InvocationInfo.OffsetInLine
         }
         
         # Rethrow everything and exit this circus
         $info | Write-Error -ErrorAction Stop
      }
   }
   
   end
   {
      # Just dump the info a object
      [pscustomobject]$AutopilotDeviceInfo
   }
}
