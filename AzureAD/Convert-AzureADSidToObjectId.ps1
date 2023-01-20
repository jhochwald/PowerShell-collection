function Convert-AzureADSidToObjectId
{
   <#
         .SYNOPSIS
         Convert a Azure AD Security Identifier (SID) to Object ID

         .DESCRIPTION
         Converts an Azure AD Security Identifier (SID) to Object ID.

         .PARAMETER Sid
         The Security Identifier (SID) to convert

         .PARAMETER Simple
         Return only the ID string
         Instead of returning as guid it will then be a simple string (a/k/a it changes the output type)

         .EXAMPLE
         PS C:\> Convert-AzureADSidToObjectId -Sid 'S-1-12-1-1943430372-1249052806-2496021943-3034400218'

         Convert a Azure AD Security Identifier (SID) to Object ID

         .EXAMPLE
         PS C:\> (Convert-AzureADSidToObjectId -Sid 'S-1-12-1-1943430372-1249052806-2496021943-3034400218').Guid

         Convert a Azure AD Security Identifier (SID) to Object ID, return only the ID string

         .EXAMPLE
         PS C:\> Convert-AzureADSidToObjectId -Sid 'S-1-12-1-1943430372-1249052806-2496021943-3034400218' -Simple

         Convert a Azure AD Security Identifier (SID) to Object ID, return only the ID string

         .LINK
         https://erikengberg.com/azure-ad-sid-to-object-id/

         .LINK
         https://github.com/okieselbach/Intune/blob/master/Convert-AzureADSidToObjectId.ps1

         .OUTPUTS
         guid, string

         .NOTES
         Original Author: Oliver Kieselbach (@okieselbach)
   #>
   [CmdletBinding(DefaultParameterSetName = 'Default',
      ConfirmImpact = 'None')]
   [OutputType([guid], ParameterSetName = 'Default')]
   [OutputType([string], ParameterSetName = 'Simple')]
   param
   (
      [Parameter(Mandatory,
         ValueFromPipeline,
         ValueFromPipelineByPropertyName,
         HelpMessage = 'The Security Identifier (SID) to convert')]
      [ValidateNotNullOrEmpty()]
      [String]
      $Sid,
      [Parameter(ParameterSetName = 'Simple',
         ValueFromPipeline,
         ValueFromPipelineByPropertyName)]
      [Alias('Plain')]
      [switch]
      $Simple
   )

   process
   {
      $text = $Sid.Replace('S-1-12-1-', '')
      $array = [UInt32[]]$text.Split('-')
      $bytes = (New-Object -TypeName 'Byte[]' -ArgumentList 16)
      [Buffer]::BlockCopy($array, 0, $bytes, 0, 16)
      [Guid]$guid = $bytes
   }

   end
   {
      if ($Simple.IsPresent)
      {
         $guid.Guid
      }
      else
      {
         $guid
      }
   }
}