function Get-RunAsSystem
{
   <#
      .SYNOPSIS
      Check if the the process runs as System

      .DESCRIPTION
      Check if the the process runs as System

      .EXAMPLE
      Get-RunAsSystem
      Check if the the process runs as System

      .NOTES
      Easy check
   #>
   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([bool])]
   param ()

   process {
      if ((& "$env:windir\system32\whoami.exe") -eq 'nt authority\system')
      {
         $true
      }
      else
      {
         $false
      }
   }
}
