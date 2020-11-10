function ConvertFrom-SafeLinksURL
{
   <#
         .SYNOPSIS
         Decode a ATP SafeLinks URL

         .DESCRIPTION
         Decode a Office 365 Advanced Threat Protection SafeLinks URL

         .PARAMETER SafeLinksURL
         The ATP SafeLinks URL that you want to decode into original URL

         .EXAMPLE
         PS C:\> ConvertFrom-SafeLinksURL -SafeLinksURL 'https://eur03.safelinks.protection.outlook.com/?url=https%3A%2F%2Fhochwald.net%2F&data=04%7C01%7Cjoerg%40hochwald.net%7C6944b67827e54648125508d884babf16%7Cb768b3c4dc4b445c94c0388882f966fb%7C0%7C0%7C637405284900251734%7CUnknown%7CTWFpbGZsb3d8eyJWIjoiMC4wLjAwMDAiLCJQIjoiV2luMzIiLCJBTiI6Ik1haWwiLCJXVCI6Mn0%3D%7C1000&sdata=qPb0a6MdRNuAzMIyLPlQ9iHPAufxNRywP2kKi%2FIHs%2FA%3D&reserved=0'

         This will decode the given URL and return the original URL (https://hochwald.net/)

         .EXAMPLE
         PS C:\> ConvertFrom-SafeLinksURL -SafeLinksURL 'https://jhochwald.com'

         This will fail, the provided string is not a valid ATP SafeLink URL

         .EXAMPLE
         PS C:\> ConvertFrom-SafeLinksURL -SafeLinksURL 'https://eur03.safelinks.protection.outlook.com/?url=https%3A%2F%2Fhochwald.net%2F&reserved=0'

         This will fail, the provided string is not a valid ATP SafeLink URL

         .NOTES
         Basic PowerShell function to replace an outdated Ruby script
         There is also a great web based solution for this approach: http://www.o365atp.com

         .LINK
         https://gist.github.com/jhochwald/8c9a3ef448058502ed184512e586815f

         .LINK
         http://www.o365atp.com

         .LINK
         https://products.office.com/en-us/exchange/online-email-threat-protection
   #>

   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([string])]
   param
   (
      [Parameter(Mandatory,
         ValueFromPipeline,
         ValueFromPipelineByPropertyName,
         Position = 0,
         HelpMessage = 'The ATP SafeLinks URL that you want to decode into original URL')]
      [ValidateNotNullOrEmpty()]
      [Alias('SafeLink')]
      [uri]
      $SafeLinksURL
   )

   begin
   {
      #region Defaults
      $STP = 'Stop'
      #endregion Defaults

      try
      {
         # Load the Web Assembly to decode the URL
         $null = (Add-Type -AssemblyName System.Web)
      }
      catch
      {
         # Get error record
         [Management.Automation.ErrorRecord]$e = $_

         # retrieve information about runtime error
         $info = [PSCustomObject]@{
            Exception = $e.Exception.Message
            Reason    = $e.CategoryInfo.Reason
            Target    = $e.CategoryInfo.TargetName
            Script    = $e.InvocationInfo.ScriptName
            Line      = $e.InvocationInfo.ScriptLineNumber
            Column    = $e.InvocationInfo.OffsetInLine
         }

         # output information. Post-process collected info, and log info (optional)
         $info | Out-String | Write-Verbose

         $paramWriteError = @{
            Message      = $e.Exception.Message
            ErrorAction  = $STP
            Exception    = $e.Exception
            TargetObject = $e.CategoryInfo.TargetName
         }
         Write-Error @paramWriteError
      }
   }


   process
   {
      try
      {
         # Create a new Object with the decoded URL, we use the default Web Assembly here
         $OriginalURL = [Web.HttpUtility]::UrlDecode($SafeLinksURL)

         # Check the URL object
         if ($OriginalURL -match '.safelinks.protection.outlook.com\/\?url=.+&data=')
         {
            $OriginalURL = $Matches[$Matches.Count - 1]

            # The default value (&) is used to provide the data string
            $OriginalURL = (($OriginalURL -Split '\?url=')[1] -Split '&data=')[0]
         }
         elseif ($OriginalURL -match '.safelinks.protection.outlook.com\/\?url=.+&amp;data=')
         {
            $OriginalURL = $Matches[$Matches.Count - 1]

            # Does the object use &amp; instead of & to provide the data string
            $OriginalURL = (($OriginalURL -Split '\?url=')[1] -Split '&amp;data=')[0]
         }
         else
         {
            $paramWriteError = @{
               Exception         = 'Invalid SafeLinks URL provided'
               Message           = 'The URL provided die NOT look like a valid Office 365 Advanced Threat Protection SafeLink URL'
               Category          = 'InvalidData'
               TargetObject      = $SafeLinksURL
               RecommendedAction = 'Check the provided URL'
               ErrorAction       = $STP
            }
            Write-Error @paramWriteError
         }
      }
      catch
      {
         # Get error record
         [Management.Automation.ErrorRecord]$e = $_

         # retrieve information about runtime error
         $info = [PSCustomObject]@{
            Exception = $e.Exception.Message
            Reason    = $e.CategoryInfo.Reason
            Target    = $e.CategoryInfo.TargetName
            Script    = $e.InvocationInfo.ScriptName
            Line      = $e.InvocationInfo.ScriptLineNumber
            Column    = $e.InvocationInfo.OffsetInLine
         }

         # output information. Post-process collected info, and log info (optional)
         $info | Out-String | Write-Verbose

         $paramWriteError = @{
            Message      = $e.Exception.Message
            ErrorAction  = $STP
            Exception    = $e.Exception
            TargetObject = $e.CategoryInfo.TargetName
         }
         Write-Error @paramWriteError
      }
   }

   end
   {
      [string]$OriginalURL
   }
}
