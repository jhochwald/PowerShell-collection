function Get-RunAsAdmin
{
   <#
      .SYNOPSIS
      Check if the the process runs as Admin (Elevated)

      .DESCRIPTION
      Check if the the process runs as Admin (Elevated)

      .EXAMPLE
      Get-RunAsAdmin
      Check if the the process runs as Admin (Elevated)

      .NOTES
      Easy check
   #>
   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([bool])]
   param ()

   process {
      [Security.Principal.WindowsIdentity]::GetCurrent().Groups -contains 'S-1-5-32-544'
   }
}
