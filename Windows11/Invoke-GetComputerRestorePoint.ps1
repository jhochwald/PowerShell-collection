#requires -Version 2.0 -RunAsAdministrator

<#
      .SYNOPSIS
      Get the existing restore points

      .DESCRIPTION
      Get the existing restore points and show only the required info.

      .EXAMPLE
      PS C:\> .\Invoke-GetComputerRestorePoint.ps1

      Get the existing restore points and show only the required info.

      .NOTES
      The Date is transformed into a human radable form using the ManagementDateTimeConverter.ToDateTime(String) method
#>
[CmdletBinding(ConfirmImpact = 'None')]
[OutputType([array])]
param ()

process
{
   Get-ComputerRestorePoint -ErrorAction Stop | Select-Object -Property @{
      n = 'Date'
      e = {
         [Management.ManagementDateTimeConverter]::ToDateTime($_.creationtime)
      }
   }, Description, SequenceNumber | Sort-Object -Property Date
}
