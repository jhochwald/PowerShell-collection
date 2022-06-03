#region ARM64Handling
# Restart Process using PowerShell 64-bit
if ($ENV:PROCESSOR_ARCHITEW6432 -eq 'AMD64')
{
   try
   {
      &"$ENV:WINDIR\SysNative\WindowsPowershell\v1.0\PowerShell.exe" -File $PSCOMMANDPATH
   }
   catch
   {
      Throw ('Failed to start {0}' -f $PSCOMMANDPATH)
   }

   exit
}
#endregion ARM64Handling

$ProgData = $env:PROGRAMDATA
$Log_File = ('{0}\Drivers_Error_log.log' -f $ProgData)

function Write_Log
{
   [CmdletBinding()]
   param(
      $Message_Type,
      $Message
   )

   $MyDate = '[{0:MM/dd/yy} {0:HH:mm:ss}]' -f (Get-Date)
   $null = (Add-Content -Path $Log_File -Value ('{0} - {1} : {2}' -f $MyDate, $Message_Type, $Message) -Force -Confirm:$false -ErrorAction SilentlyContinue)
}

if (-not (Test-Path -Path $Log_File -ErrorAction SilentlyContinue))
{
   $null = (New-Item -Path $Log_File -ItemType file -Force -Confirm:$false -ErrorAction Stop)
}
else
{
   $null = (Add-Content -Path $Log_File -Value '' -Force -Confirm:$false -ErrorAction SilentlyContinue)
}

$Drivers_Test = (Get-WmiObject -Class Win32_PNPEntity -ErrorAction SilentlyContinue | Where-Object -FilterScript {
      $PSItem.ConfigManagerErrorCode -gt 0
   })
$Search_Disabled_Missing_Drivers = ($Drivers_Test | Where-Object -FilterScript {
      (($PSItem.ConfigManagerErrorCode -eq 22) -or ($PSItem.ConfigManagerErrorCode -eq 28))
   })

If (($Search_Disabled_Missing_Drivers).count -gt 0)
{
   $Search_Missing_Drivers = ($Search_Disabled_Missing_Drivers | Where-Object -FilterScript {
         $PSItem.ConfigManagerErrorCode -eq 28
      }).count
   $Search_Disabled_Drivers = ($Search_Disabled_Missing_Drivers | Where-Object -FilterScript {
         $PSItem.ConfigManagerErrorCode -eq 22
      }).count

   Write_Log -Message_Type 'ERROR' -Message ('There is an issue with drivers. Missing drivers: {0} - Disabled drivers: {1}' -f $Search_Missing_Drivers, $Search_Disabled_Drivers) -ErrorAction SilentlyContinue

   ForEach ($Driver in $Search_Disabled_Missing_Drivers)
   {
      $Driver_Name = $Driver.Caption
      $Driver_DeviceID = $Driver.DeviceID

      Write_Log -Message_Type 'INFO' -Message ('Driver name is: {0}' -f $Driver_Name) -ErrorAction SilentlyContinue
      Write_Log -Message_Type 'INFO' -Message ('Driver device ID is: {0}' -f $Driver_DeviceID) -ErrorAction SilentlyContinue

      $null = (Add-Content -Path $Log_File -Value '' -Force -Confirm:$false -ErrorAction SilentlyContinue)
   }

   Exit 1
   Break
}
Else
{
   Write_Log -Message_Type 'SUCCESS' -Message 'There is no issue with drivers.' -ErrorAction SilentlyContinue

   Exit 0
}
