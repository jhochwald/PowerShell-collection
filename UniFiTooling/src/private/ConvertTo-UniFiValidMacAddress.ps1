function ConvertTo-UniFiValidMacAddress
{
   <#
         .SYNOPSIS
         Check and transform the given Mac addess for UniFi API usage

         .DESCRIPTION
         Check and transform, if needed, the given Mac addess for UniFi API usage

         .PARAMETER Mac
         Client MAC address

         .EXAMPLE
         PS C:\> ConvertTo-UniFiValidMacAddress -Mac '84-3a-4b-cd-88-2D'

         .NOTES
         Helper to check and make sure we have the right format
   #>

   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([string])]
   param
   (
      [Parameter(Mandatory,HelpMessage = 'Client MAC address',
               ValueFromPipeline,
               ValueFromPipelineByPropertyName,
               Position = 0)]
      [ValidateNotNullOrEmpty()]
      [Alias('UniFiMac', 'MacAddress')]
      [string]
      $Mac
   )

   begin
   {
      Write-Verbose -Message 'Start ConvertTo-UniFiValidMacAddress'

      # Call meta function
      $paramGetCallerPreference = @{
         Cmdlet        = $PSCmdlet
         SessionState  = $ExecutionContext.SessionState
         ErrorAction   = 'SilentlyContinue'
         WarningAction = 'SilentlyContinue'
      }
      $null = (Get-CallerPreference @paramGetCallerPreference)
   }

   process
   {
      # Define the REGEX Filter
      $regex = '((\d|([a-f]|[A-F])){2}){6}'

      # Transform, if needed
      [string]$Mac = $Mac.Trim().Replace(':', '').Replace('.', '').Replace('-', '')

      # Mac everything lower case
      $Mac = $Mac.ToLower()

      # Do a check
      if (($Mac.Length -eq 12) -and ($Mac -match $regex))
      {
         [string]$Mac = ($Mac -replace '..(?!$)', '$&:')
      }
      else
      {
         # Verbose stuff
         $Script:line = $_.InvocationInfo.ScriptLineNumber

         Write-Verbose -Message ('Error was in Line {0}' -f $line)

         # Error Message
         Write-Error -Message ('Sorry, but {0} is a format that the UniFi Controller will nor understand' -f $Mac) -ErrorAction Stop

         # Only here to catch a global ErrorAction overwrite
         break
      }
   }

   end
   {
      # Dump to the Console $Mac
      $Mac

      Write-Verbose -Message 'Start ConvertTo-UniFiValidMacAddress'
   }
}
