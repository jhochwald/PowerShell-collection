function Set-bdcBusylightColor
{
   <#
         .SYNOPSIS
         Set the color of a connected Kuando Busylight device

         .DESCRIPTION
         Set the color of a connected Kuando Busylight device

         .PARAMETER Color
         Only the following colors are supported:
         - blue
         - cyan
         - green
         - magenta
         - orange
         - red
         - white
         - yellow
         - off

         Where off is not a color, as it should tell, it will turn the Busylight off!
         The default is off - If you invoke the function without any parameter, it will be turned off.

         .EXAMPLE
         PS C:\> Set-bdcBusylightColor

         Turn the Busylight off

         .EXAMPLE
         PS C:\> Set-bdcBusylightColor -Color green

         Set the Busylight color to green

         .LINK
         https://docs.microsoft.com/en-us/graph/api/resources/presence?view=graph-rest-beta

         .LINK
         https://docs.microsoft.com/en-us/graph/api/presence-get?view=graph-rest-beta

         .LINK
         https://www.plenom.com/support/develop/

         .NOTES
         You will need the BusylightSDK.DLL, as the PowerShell scripts communicates with the device by calling functions in the DLL.
         You can get it from the SDK, at https://www.plenom.com/support/develop/.
   #>

   [CmdletBinding(ConfirmImpact = 'None',
   SupportsShouldProcess)]
   param
   (
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 0)]
      [ValidateNotNullOrEmpty()]
      [ValidateSet('blue', 'cyan', 'green', 'magenta', 'orange', 'red', 'white', 'yellow', 'off', IgnoreCase = $true)]
      [Alias('BusylightColor')]
      [string]
      $Color = 'off '
   )

   begin
   {
      # Cleanup
      $MyBusyLight = $null

      # This is the path to the BusyLight SDK DLL.  Correct path as needed.
      $BusylightSDKDll = [IO.Path]::Combine((Split-Path -Path $script:MyInvocation.MyCommand.Path -Parent), 'BusylightSDK.dll')

      if (-not (Test-Path -Path $BusylightSDKDll)) {
         # Try a fallback
         Write-Warning "Whhops, $BusylightSDKDll was NOT found, we try a fallback method."
         $BusylightSDKDll = [IO.Path]::Combine('.\', 'BusylightSDK.dll')
      }

      $null = (Add-Type -Path $BusylightSDKDll -ErrorAction Stop)

      # Initialize the BusyLight objects
      $MyBusyLight = New-Object -TypeName Busylight.SDK
   }

   process
   {
      if ($pscmdlet.ShouldProcess('Busylight', 'Set Color'))
      {
         switch ($Color)
         {
            'blue'
            {
               $null = ($MyBusyLight.Light([Busylight.BusylightColor]::Blue))
            }
            'cyan'
            {
               $null = ($MyBusyLight.Light(128, 255, 255))
            }
            'green'
            {
               $null = ($MyBusyLight.Light([Busylight.BusylightColor]::Green))
            }
            'magenta'
            {
               $null = ($MyBusyLight.Light(128, 0, 255))
            }
            'orange'
            {
               $null = ($MyBusyLight.Light(255, 128, 0))
            }
            'red'
            {
               $null = ($MyBusyLight.Light([Busylight.BusylightColor]::Red))
            }
            'white'
            {
               $null = ($MyBusyLight.Light(255, 255, 255))
            }
            'yellow'
            {
               $null = ($MyBusyLight.Light([Busylight.BusylightColor]::Yellow))
            }
            'off'
            {
               $null = ($MyBusyLight.Light([Busylight.BusylightColor]::Off))
            }
            default
            {
               $null = ($MyBusyLight.Light([Busylight.BusylightColor]::Off))
            }
         }
      }
   }

   end
   {
      # Cleanup
      $MyBusyLight = $null
   }
}

function Set-bdcBusylightStatus
{
   <#
         .SYNOPSIS
         Wrapper function for Set-bdcBusylightColor

         .DESCRIPTION
         Wrapper function for Set-bdcBusylightColor to set the color on a connected Kuando Busylight device

         .PARAMETER Status
         The online Status you would like to set.

         Supported is:
         - Available = green on the Kuando Busylight device
         - AvailableIdle = green on the Kuando Busylight device
         - Away = yellow on the Kuando Busylight device
         - BeRightBack = yellow on the Kuando Busylight device
         - Busy = red on the Kuando Busylight device
         - BusyIdle = red on the Kuando Busylight device
         - DoNotDisturb = magenta on the Kuando Busylight device
         - Offline =  Turn off the Kuando Busylight device
         - PresenceUnknown = Turn off the Kuando Busylight device

         Based on this docs page: https://docs.microsoft.com/en-us/graph/api/resources/presence?view=graph-rest-beta

         .EXAMPLE
         PS C:\> Set-bdcBusylightStatus -Status Available

         .LINK
         https://docs.microsoft.com/en-us/graph/api/resources/presence?view=graph-rest-beta

         .LINK
         https://docs.microsoft.com/en-us/graph/api/presence-get?view=graph-rest-beta

         .LINK
         https://www.plenom.com/support/develop/

         .NOTES
         You will need the BusylightSDK.DLL, as the PowerShell scripts communicates with the device by calling functions in the DLL.
         You can get it from the SDK, at https://www.plenom.com/support/develop/.
   #>

   [CmdletBinding(ConfirmImpact = 'None')]
   param
   (
      [Parameter(Mandatory, HelpMessage = 'The online Status you would like to set.',
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 0)]
      [ValidateNotNullOrEmpty()]
      [ValidateSet('Available', 'AvailableIdle', 'Away', 'BeRightBack', 'Busy', 'BusyIdle', 'DoNotDisturb', 'Offline', 'PresenceUnknown', IgnoreCase = $true)]
      [Alias('BusylightStatus')]
      [string]
      $Status
   )

   process
   {
      switch ($Status)
      {
         'Available'
         {
            $null = (Set-bdcBusylightColor -Color green)
         }
         'AvailableIdle'
         {
            $null = (Set-bdcBusylightColor -Color green)
         }
         'Away'
         {
            $null = (Set-bdcBusylightColor -Color yellow)
         }
         'BeRightBack'
         {
            $null = (Set-bdcBusylightColor -Color yellow)
         }
         'Busy'
         {
            $null = (Set-bdcBusylightColor -Color red)
         }
         'BusyIdle'
         {
            $null = (Set-bdcBusylightColor -Color red)
         }
         'DoNotDisturb'
         {
            $null = (Set-bdcBusylightColor -Color magenta)
         }
         'Offline'
         {
            $null = (Set-bdcBusylightColor -Color off)
         }
         'PresenceUnknown'
         {
            $null = (Set-bdcBusylightColor -Color off)
         }
         'default'
         {
            $null = (Set-bdcBusylightColor -Color off)
         }
      }
   }
}
