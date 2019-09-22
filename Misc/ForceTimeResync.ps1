#requires -RunAsAdministrator

<#
      .SYNOPSIS
      Force Time Resync with PowerShell

      .DESCRIPTION
      Force Time Resync as a PowerShell script

      .EXAMPLE
      PS C:\> .\ForceTimeResync.ps1

      Force Time Resync as a PowerShell script (Wrapper for w32tm.exe). Most be executed in an elevated shell)

      .NOTES
      One of my VM's did a view time travels in the past. This little script runs every hour (Task).
      I still try to find the cause for the time travels (It jumps 2 hours forward, from time to time) and a better PowerShell way to do it.
      For now, this quick and dirty solution works just fine.
#>
[CmdletBinding(ConfirmImpact = 'None')]
param ()

process
{
   $null = (& "$env:windir\system32\w32tm.exe" /resync /force)
}
	