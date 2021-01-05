function Get-AllCookiesFromWebRequestSession
{
   <#
         .SYNOPSIS
         Get all cookies stored in the WebRequestSession variable from any Invoke-RestMethod and/or Invoke-WebRequest request

         .DESCRIPTION
         Get all cookies stored in the WebRequestSession variable from any Invoke-RestMethod and/or Invoke-WebRequest request
         The WebRequestSession stores useful info and it has something that some my know as CookieJar or http.cookiejar.

         .PARAMETER WebRequestSession
         Specifies a variable where Invoke-RestMethod and/or Invoke-WebRequest saves values.
         Must be a valid [Microsoft.PowerShell.Commands.WebRequestSession] object!

         .EXAMPLE
         PS C:\> $null = Invoke-WebRequest -UseBasicParsing -Uri 'http://jhochwald.com' -Method Get -SessionVariable WebSession -ErrorAction SilentlyContinue
         PS C:\> $WebSession | Get-AllCookiesFromWebRequestSession

         Get all cookies stored in the $WebSession variable from the request above.
         This page doesn't use or set any cookies, but the (awesome) CloudFlare service does.

		   .EXAMPLE
         $null = Invoke-RestMethod -UseBasicParsing -Uri 'https://jsonplaceholder.typicode.com/todos/1' -Method Get -SessionVariable RestSession -ErrorAction SilentlyContinue
         $RestSession | Get-AllCookiesFromWebRequestSession

         Get all cookies stored in the $RestSession variable from the request above.
         Please do not abuse the free API service above!

         .NOTES
         I used something I had stolen from Chrissy LeMaire's TechNet Gallery entry a (very) long time ago.
         But I needed something more generic, independent from the URL! This can become handy, to find any cookie from a 3rd party site or another host.

         .LINK
         https://docs.python.org/3/library/http.cookiejar.html

         .LINK
         https://en.wikipedia.org/wiki/HTTP_cookie

         .LINK
         https://gallery.technet.microsoft.com/scriptcenter/Getting-Cookies-using-3c373c7e

         .LINK
         Invoke-RestMethod

         .LINK
         Invoke-WebRequest
   #>

   [CmdletBinding(ConfirmImpact = 'None')]
   param
   (
      [Parameter(Mandatory,
         ValueFromPipeline,
         ValueFromPipelineByPropertyName,
         Position = 0,
         HelpMessage = 'Specifies a variable where Invoke-RestMethod and/or Invoke-WebRequest saves values.')]
      [ValidateNotNull()]
      [Alias('Session', 'InputObject')]
      [Microsoft.PowerShell.Commands.WebRequestSession]
      $WebRequestSession
   )

   begin
   {
      # Do the housekeeping
      $CookieInfoObject = $null
   }

   process
   {
      try
      {
         # I know, this look very crappy, but it just work fine!
         [pscustomobject]$CookieInfoObject = ((($WebRequestSession).Cookies).GetType().InvokeMember('m_domainTable', [Reflection.BindingFlags]::NonPublic -bor [Reflection.BindingFlags]::GetField -bor [Reflection.BindingFlags]::Instance, $null, (($WebRequestSession).Cookies), @()))
      }
      catch
      {
         #region ErrorHandler
         # get error record
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
            ErrorAction  = 'Stop'
            Exception    = $e.Exception
            TargetObject = $e.CategoryInfo.TargetName
         }
         Write-Error @paramWriteError

         # Only here to catch a global ErrorAction overwrite
         exit 1
         #endregion ErrorHandler
      }
   }

   end
   {
      # Dump the Cookies to the Console
      ((($CookieInfoObject).Values).Values)
   }
}
