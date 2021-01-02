function Invoke-UniFiCidrWorkaround
{
   <#
         .SYNOPSIS
         IPv4 and IPv6 CIDR Workaround for UBNT USG Firewall Rules

         .DESCRIPTION
         IPv4 and IPv6 CIDR Workaround for UBNT USG Firewall Rules (Single IPv4 has to be without /32 OR single IPv6 has to be without /128)

         .PARAMETER CidrList
         Existing CIDR List Object

         .PARAMETER 6
         Process IPv6 CIDR (Single IPv6 has to be without /128)

         .EXAMPLE
         PS C:\> Invoke-UniFiCidrWorkaround -CidrList $value1

         IPv4 CIDR Workaround for UBNT USG Firewall Rules

         .EXAMPLE
         PS C:\> Invoke-UniFiCidrWorkaround -6 -CidrList $value1

         IPv6 CIDR Workaround for UBNT USG Firewall Rules

         .EXAMPLE
         PS C:\> $value1 | Invoke-UniFiCidrWorkaround

         IPv4 or IPv6 CIDR Workaround for UBNT USG Firewall Rules via Pipeline

         .EXAMPLE
         PS C:\> $value1 | Invoke-UniFiCidrWorkaround -6

         IPv6 CIDR Workaround for UBNT USG Firewall Rules via Pipeline

         .NOTES
         This is an internal helper function only (Will be moved to the private functions soon)

         .LINK
         https://github.com/jhochwald/UniFiTooling/issues/5
   #>

   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([psobject])]
   param
   (
      [Parameter(Mandatory = $true,
               ValueFromPipeline = $true,
               ValueFromPipelineByPropertyName = $true,
               Position = 0,
               HelpMessage = 'Existing CIDR List Object')]
      [ValidateNotNullOrEmpty()]
      [Alias('UniFiCidrList')]
      [psobject]
      $CidrList,
      [Parameter(ValueFromPipeline = $true,
               ValueFromPipelineByPropertyName = $true,
               Position = 1)]
      [Alias('IPv6', 'V6')]
      [switch]
      $6 = $false
   )

   begin
   {
      Write-Verbose -Message 'Start Invoke-UniFiCidrWorkaround'

      # Call meta function
      $null = (Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState -ErrorAction SilentlyContinue -WarningAction SilentlyContinue)

      # Cleanup
      $AddItem = @()
   }

   process
   {
      # Loop over the new list
      foreach ($NewInputItem in $CidrList)
      {
         if ($6)
         {
            # CIDR Workaround for UBNT USG Firewall Rules (Single IPv6 has to be without /128)
            if ($NewInputItem -match '/128')
            {
               $NewInputItem = $NewInputItem.Replace('/128', '')
            }
         }
         else
         {
            # CIDR Workaround for UBNT USG Firewall Rules (Single IP has to be without /32)
            if ($NewInputItem -match '/32')
            {
               $NewInputItem = $NewInputItem.Replace('/32', '')
            }
         }

         # Add to the List
         $AddItem = $AddItem + $NewInputItem
      }
   }

   end
   {
      # Dump
      $AddItem

      # Cleanup
      $AddItem = $null

      Write-Verbose -Message 'Done Invoke-UniFiCidrWorkaround'
   }
}
