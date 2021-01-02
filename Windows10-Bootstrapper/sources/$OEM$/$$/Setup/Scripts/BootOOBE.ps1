#requires -Version 3.0

<#
   .SYNOPSIS
   Interrupt the OOBE Process and starts our own

   .DESCRIPTION
   Interrupt the OOBE Process and starts our own

   .EXAMPLE
   PS C:\> .\BootOOBE.ps1

   .NOTES
   Adopted from Roger Zander (@rzander)

   .LINK
   https://github.com/rzander/mOSD
#>
[CmdletBinding(ConfirmImpact = 'None')]
param ()

begin
{
   $SCT = 'SilentlyContinue'

   $PantherUA = "$env:windir\Panther\unattend.xml"

   #region
   $paramGetProcess = @{
      Name        = 'sysprep'
      ErrorAction = $SCT
   }
   $paramStopProcess = @{
      Force       = $true
      ErrorAction = $SCT
   }
   #endregion
}

process
{
   $paramSetLocation = @{
      Path        = $PSScriptRoot
      ErrorAction = $SCT
   }
   $null = (Set-Location @paramSetLocation)

   $null = (Get-Process @paramGetProcess | Stop-Process @paramStopProcess)

   #Cleanup
   $paramTestPath = @{
      Path        = $PantherUA
      ErrorAction = $SCT
   }
   if (Test-Path @paramTestPath)
   {
      $paramRemoveItem = @{
         Path        = $PantherUA
         Force       = $true
         Confirm     = $false
         ErrorAction = $SCT
      }
      $null = (Remove-Item @paramRemoveItem)
   }

   $null = (Get-Process @paramGetProcess | Stop-Process @paramStopProcess)

   Start-Sleep -Seconds 2

   # Start the sysprep process
   try
   {
      $null = (Start-Process -FilePath "$env:windir\System32\Sysprep\sysprep.exe" -ArgumentList '/oobe /quiet /reboot /unattend:C:\Windows\system32\sysprep\unattend.xml' -Wait)
   }
   catch
   {
      exit (1)
   }
}

end
{
   exit (0)
}
