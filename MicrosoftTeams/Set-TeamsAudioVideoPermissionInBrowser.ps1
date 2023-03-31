<#
      .SYNOPSIS
      Allow the Teams Web App to access cam and microphone automatically

      .DESCRIPTION
      Allow the Teams Web App to access cam and microphone automatically,
      we support Microsoft Edge, Google Chrome and the Brave browser

      .EXAMPLE
      PS C:\> .\Set-TeamsAudioVideoPermissionInBrowser.ps1

      Set the Teams web app permissions to allow access automatically to the cam and the microphone in the browser

      .LINK
      https://learn.microsoft.com/en-us/deployedge/microsoft-edge-policies#videocaptureallowedurls

      .LINK
      https://admx.help/?Category=Chrome&Policy=Google.Policies.Chrome::VideoCaptureAllowedUrls

      .NOTES
      The Brave entry needs some further checks, we hope that Brave handles it the Chromium way (what it should)
      How about Mozilla Firefox?
#>
[CmdletBinding(ConfirmImpact = 'Low',
               SupportsShouldProcess)]
[OutputType([string])]
param ()

begin
{
   $RegistryValue = 'https://teams.microsoft.com'

   $AllPolicies = @(
      # Microsoft Chromium Edge
      'HKLM:\SOFTWARE\Policies\Microsoft\Edge\VideoCaptureAllowedUrls'
      'HKLM:\SOFTWARE\Policies\Microsoft\Edge\AudioCaptureAllowedUrls'
      # Google Chrome
      'HKLM:\SOFTWARE\Policies\Google\Chrome\VideoCaptureAllowedUrls'
      'HKLM:\SOFTWARE\Policies\Google\Chrome\AudioCaptureAllowedUrls'
      # Brave bowser (Chromium based)
      'HKLM:\SOFTWARE\Policies\BraveSoftware\Brave\VideoCaptureAllowedUrls'
      'HKLM:\SOFTWARE\Policies\BraveSoftware\Brave\AudioCaptureAllowedUrls'
   )
}

process
{
   foreach ($RegistryPath in $AllPolicies)
   {
      # Clean-up
      $RegistryName = $null

      # Check if the Path for the policy exists
      if (-not (Test-Path -Path $RegistryPath -ErrorAction SilentlyContinue))
      {
         # Create the Policy Path
         if ($pscmdlet.ShouldProcess($RegistryPath, 'create'))
         {
            $paramNewItem = @{
               Path        = $RegistryPath
               Force       = $true
               Confirm     = $false
               ErrorAction = 'SilentlyContinue'
            }
            $null = (New-Item @paramNewItem)
         }

         # Take the first numer, because there is none
         $RegistryName = 1
      }
      else
      {
         # We do have entries, we check them
         (Get-Item -Path $RegistryPath).Property | ForEach-Object {
            if ((Get-ItemPropertyValue -Path $RegistryPath -Name $_) -contains $RegistryValue)
            {
               # Entry exists, skip to the next one
               $SkipEntry = $true

               return
            }
            else
            {
               # Looks like we need the entry
               $SkipEntry = $null
            }
         }
      }

      # Skip it?
      if (-not $SkipEntry)
      {
         # Find the next free entry
         if (-not ($RegistryName))
         {
            # Find a free number
            1 .. 20 | ForEach-Object -Process {
               if ((-not $RegistryName) -and (-not (Get-ItemProperty -Path $RegistryPath -Name $_ -ErrorAction SilentlyContinue)))
               {
                  $RegistryName = $_
               }
            }
         }

         if ($pscmdlet.ShouldProcess(('{0} in {1} with value {2}' -f $RegistryName, $RegistryPath, $RegistryValue), 'create'))
         {
            $paramNewItemProperty = @{
               Path         = $RegistryPath
               Name         = $RegistryName
               Value        = $RegistryValue
               PropertyType = 'String'
               Force        = $true
               Confirm      = $false
               ErrorAction  = 'SilentlyContinue'
            }
            $null = (New-ItemProperty @paramNewItemProperty)
         }

         # Remove the SKIP to process the next one
         $SkipEntry = $null
      }
      else
      {
         # Remove the SKIP to process the next one
         $SkipEntry = $null
      }
   }
}