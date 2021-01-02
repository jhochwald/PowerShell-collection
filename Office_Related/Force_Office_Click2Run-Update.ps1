#requires -Version 2.0

<#
		.SYNOPSIS
		Triggers the Click 2 Run Update Process

		.DESCRIPTION
		This Script triggers the Click 2 Run Update Process.

		.PARAMETER Silent
		Suppress the User Info

		.EXAMPLE
		# Regular Operation
		PS C:\> .\Force_Office_Click2Run-Update.ps1

		.EXAMPLE
		# Silent Operation
		PS C:\> .\Force_Office_Click2Run-Update.ps1 -Silent

		.EXAMPLE
		# Silent Operation
		PS C:\> .\Force_Office_Click2Run-Update.ps1 -s

		.NOTES
		Author: Joerg Hochwald - http://hochwald.net
		License: Freeware, Public Domain
#>
param
(
   [Parameter(ValueFromPipeline = $true,
      Position = 1)]
   [Alias('s')]
   [switch]
   $Silent
)

begin
{
   # Constants
   $SC = 'SilentlyContinue'

   # The Click 2 Run Executable
   $UpdateEXE = "$env:CommonProgramW6432\Microsoft Shared\ClickToRun\OfficeC2RClient.exe"

   if ($Silent)
   {
      # Commandline (Silent)
      $UpdateArguements = '/update user displaylevel=false'
   }
   else
   {
      # Commandline (Inform the User in this case)
      $UpdateArguements = '/update user displaylevel=true'
   }
}
process
{
   $paramTestPath = @{
      Path        = $UpdateEXE
      ErrorAction = $SC
   }
   if (Test-Path @paramTestPath)
   {
      try
      {
         $paramStartProcess = @{
            FilePath     = $UpdateEXE
            ArgumentList = $UpdateArguements
            ErrorAction  = $SC
         }
         $null = (Start-Process @paramStartProcess)
      }
      catch
      {
         Write-Warning -Message 'Unable to start the Update Process...'
      }
   }
   else
   {
      Write-Error -Message 'The Office Click 2 Run Update executable was not found!' -ErrorAction Stop
   }
}
