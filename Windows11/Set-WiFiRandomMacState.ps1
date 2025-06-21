function Set-WiFiRandomMacState
{
   <#
         .SYNOPSIS
         Enable or disable MAC address randomization for the WiFI NIC
   
         .DESCRIPTION
         Enable or disable MAC address randomization for the WiFI NIC
   
         .PARAMETER Enable
         Enable MAC address randomization
   
         .PARAMETER Disable
         Disable MAC address randomization
   
         .EXAMPLE
         PS C:\> Set-WiFiRandomMacState -Enable

         Enable MAC address randomization for the WiFI NIC

         .EXAMPLE
         PS C:\> Set-WiFiRandomMacState -Enable -WhatIf

         Simmulate (WhatIf) to enable MAC address randomization for the WiFI NIC

         .EXAMPLE
         PS C:\> Set-WiFiRandomMacState -Enable -Confirm

         Enable MAC address randomization for the WiFI NIC, but you have to confirm any change before it is done

         .EXAMPLE
         PS C:\> Set-WiFiRandomMacState -Disable

         Disable MAC address randomization for the WiFI NIC
   
         .EXAMPLE
         PS C:\> Set-WiFiRandomMacState -Disable -Verbose

         Disable MAC address randomization for the WiFI NIC in verbose mode of PowerShell

         .NOTES
         Prototype
   #>   
   [CmdletBinding(DefaultParameterSetName = 'Enable',
         ConfirmImpact = 'Low',
   SupportsShouldProcess)]
   [OutputType([string])]
   param
   (
      [Parameter(ParameterSetName = 'Enable',
            ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
      [Alias('On')]
      [switch]
      $Enable,
      [Parameter(ParameterSetName = 'Disable',
            ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
      [Alias('Off')]
      [switch]
      $Disable
   )
   
   begin
   {
      $WiFi = ((Get-NetAdapter -Name 'Wi-Fi' -ErrorAction SilentlyContinue).InterfaceGuid)
      
      if (!($WiFi))
      {
         # Fallback: get the GUID of the wireless Interface
         $WiFi = ((Get-NetAdapter -Name 'WiFi' -ErrorAction SilentlyContinue).InterfaceGuid)
      }
   }
   
   process
   {
      if ($WiFi)
      {
         if ($pscmdlet.ShouldProcess('WiFi Network Interface', ('Change MAC address to ''{0}'' randomization' -f $pscmdlet.ParameterSetName.ToLower())))
         {
            $paramNewItemProperty = $null
            $paramNewItemProperty = @{
               Path         = ('HKLM:SOFTWARE\Microsoft\WlanSvc\Interfaces\{0}' -f $WiFi)
               Name         = 'RandomMacState'
               PropertyType = 'Binary'
               Force        = $true
               Confirm      = $false
               ErrorAction  = 'Stop'
            }

            switch ($pscmdlet.ParameterSetName)
            {
               'Enable' 
               {
                  $paramNewItemProperty.Add('Value', ([byte[]](0x01, 0x00, 0x00, 0x00)))
               }
               'Disable' 
               {
                  $paramNewItemProperty.Add('Value', ([byte[]](0x00, 0x00, 0x00, 0x00)))
               }
            }

            $null = (New-ItemProperty @paramNewItemProperty)
            $paramNewItemProperty = $null
         }
      }
      else
      {
         $paramWriteError = @{
            Exception         = 'No WiFi inetrface was found'
            Message           = 'Sorry, no valid Wi-Fi Networkcard was found!'
            Category          = 'ObjectNotFound'
            RecommendedAction = 'Check that the WiFi NIC Inetrface is valis and enabled'
            ErrorAction       = 'Stop'
         }
         Write-Error @paramWriteError
         
         # Just in case
         exit 1
      }
   }
   
   end
   {
      # Final Cleanup
      $WiFi = $null
   }
}
