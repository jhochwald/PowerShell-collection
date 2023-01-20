function Convert-AzureADObjectIdToSid
{
   <#
         .SYNOPSIS
         Convert an Azure AD Object ID to The Security Identifier (SID)

         .DESCRIPTION
         Converts an Azure AD Object ID to a The Security Identifier (SID)

         .PARAMETER ObjectID
         The Azure AD Group or Azure AD User Object ID to convert

         .EXAMPLE
         PS C:\> Convert-AzureADObjectIdToSid -ObjectId '73d664e4-0886-4a73-b745-c694da45ddb4'

         Converts an Azure AD Object ID to a The Security Identifier (SID)

         .LINK
         https://erikengberg.com/azure-ad-object-id-to-sid/

         .LINK
         https://github.com/okieselbach/Intune/blob/master/Convert-AzureADObjectIdToSid.ps1

         .NOTES
         Original Author: Oliver Kieselbach (@okieselbach)
   #>
   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([string])]
   param
   (
      [Parameter(Mandatory, HelpMessage = 'Add help message for user',
         ValueFromPipeline,
         ValueFromPipelineByPropertyName)]
      [String]
      $ObjectId
   )

   process
   {
      $bytes = [Guid]::Parse($ObjectId).ToByteArray()
      $array = (New-Object -TypeName 'UInt32[]' -ArgumentList 4)
      [Buffer]::BlockCopy($bytes, 0, $array, 0, 16)
      $Sid = ('S-1-12-1-{0}' -f $array).Replace(' ', '-')
   }

   end
   {
      $Sid
   }
}