<#
   .SYNOPSIS
   Helper script to investigate a Hafnium attack

   .DESCRIPTION
   Helper script to investigate a Hafnium attack

   .PARAMETER ReportPath
   Where to save the reports

   .EXAMPLE
   PS C:\> .\Get-HafniumReports.ps1

   .LINK
   https://discuss.elastic.co/t/detection-and-response-for-hafnium-activity/266289

   . LINK
   https://www.msxfaq.de/exchange/update/hafnium-nachbereitung.htm

   .NOTES
   This does NOT replace a Anti Virus scanner and also does NOT replace the Microsoft investigation scripts!
   You can use this to bring your ongoing security investigation(s) a step forward, not more but not less.
#>
[CmdletBinding(ConfirmImpact = 'None')]
param
(
   [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
   [ValidateNotNullOrEmpty()]
   [ValidateNotNull()]
   [Alias('Path')]
   [string]
   $ReportPath = 'C:\scripts\PowerShell\reports\Hafnium\'
)

begin
{
   # Create the report directory, if needed
   if (-not (Test-Path -Path $ReportPath -ErrorAction SilentlyContinue))
   {
      $null = (New-Item -Path $ReportPath -ItemType Directory -Force -ErrorAction Stop)
   }

   # Create a Timestamp
   $TimeStamp = (Get-Date -Format 'yyyyMMdd_HHmmss')
}

process
{
   <#
      Look for commands like "Set-OABVirtualDirectory" - This is one of the known commands that the attackers used.
   #>

   # Get Exchange Event Logs
   $null = (Get-WinEvent -LogName 'MSExchange Management' -ErrorAction SilentlyContinue | Export-Csv -Path ($ReportPath + 'MSExchangeManagement_' + $TimeStamp + '.csv') -NoTypeInformation -Force -Encoding UTF8 -ErrorAction SilentlyContinue)

   <#
      Look for tasks that you don't know.
      "WwanSvcdcs" is one of the names that are known as related to Hafnium

      Please keep in mind: Windows itself use Scheduled Tasks a lot!
	#>

   # Get Scheduled Task info
   $null = (Get-ScheduledTask -ErrorAction SilentlyContinue | Select-Object -Property actions -ExpandProperty actions -ErrorAction SilentlyContinue | Export-Csv -Path ($ReportPath + 'ScheduledTaskInfo_' + $TimeStamp + '.csv') -NoTypeInformation -Force -Encoding UTF8 -ErrorAction SilentlyContinue)

   <#
      See above, and watch for tasks that are created since January 2021 that you can not identify.

      Please keep in mind: Windows itself use Scheduled Tasks a lot!
	#>

   # TaskScheduler info
   $null = (Get-WinEvent -LogName 'Microsoft-Windows-TaskScheduler/Operational' -ErrorAction SilentlyContinue | Export-Csv -Path ($ReportPath + 'TaskScheduler_' + $TimeStamp + '.csv') -NoTypeInformation -Force -Encoding UTF8 -ErrorAction SilentlyContinue)

   <#
      PowerShell keeps a history that will be saved into a plain ASC File. At least if the ReadLine Module is installed!
      A bit work, but you can at least try to identify something strange here!
	#>

   # Get all History Files from PowerShell
   $null = (Get-ChildItem -Path 'C:\Users' -Filter 'ConsoleHost_history.txt' -Recurse -ErrorAction SilentlyContinue -Force | ForEach-Object -Process {
         $null = (Get-Content -Path $_.FullName -ErrorAction SilentlyContinue | Out-File -FilePath ($ReportPath + 'PowerShell_History_' + $TimeStamp + '.txt') -Encoding utf8 -Append -ErrorAction SilentlyContinue)
      })
}

end
{
   # Open the directory in the File Explorer
   Invoke-Item -Path $ReportPath
}
