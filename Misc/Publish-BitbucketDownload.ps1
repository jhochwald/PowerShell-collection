#requires -Version 3.0

function Publish-BitbucketDownload
{
  <#
      .SYNOPSIS
      Upload given file to BitBucket cloud service downloads section.

      .DESCRIPTION
      Upload given file to BitBucket cloud service downloads section.
      I use this to upload build artifacts to the BitBucket Download section.

      The code might not be perfect, and we still use the AUTH Header instead of OAuth yet,
      but I needed a quick and dirty solution to get things going.

      I might change a few things soon, but for now; this function is doing what it should.

      .PARAMETER username
      BitBucket cloud username, as plain text

      .PARAMETER password
      BitBucket cloud password, as plain text

      .PARAMETER FilePath
      File to upload, full path needed

      .PARAMETER team
      BitBucket cloud team aka username (Might not be the login username!!!)

      .PARAMETER Project
      BitBucket cloud project name

      .EXAMPLE
      PS ~> Publish-BitbucketDownload -username 'MyUsername' -password 'MySectretPassword' -FilePath 'Y:\dev\release\myproject-current.zip' -team 'dummyTeam' -Project 'myproject'

      # Upload the artifact 'Y:\dev\release\myproject-current.zip' to the Download sections of the 'myproject' project of the 'dummyTeam', It uses User name and password (Both in plain ASC) to authenticate. However, both are converted to base64 to prevent any clear text header transfers.

      .EXAMPLE
      PS ~> Publish-BitbucketDownload -username 'MyUsername' -password 'MySectretPassword' -FilePath 'Y:\dev\release\myproject.nuget' -team 'dummyTeam' -Project 'myproject'

      # Upload the artifact 'Y:\dev\release\myproject.nuget' to the Download sections of the 'myproject' project of the 'dummyTeam', It uses Username and password (Both in plain ASC) to authenticate. However, both are converted to base64 to prevent any clear text header transfers.

      .NOTES
      I created this because I did not have CURL installed on my build system.

      With Curl this is an absolute no brainer:
      curl -X POST "https://MyUsername:MySectretPassword@api.bitbucket.org/2.0/repositories/dummyTeam/myproject/downloads" --form files=@"/home/dev/release\myproject-current.zip"

      INFO: Max. CPU: 16 %  Max. Memory: 28.48 MB

      TODO: Convert the request to use OAuth ASAP
  #>
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory,
        ValueFromPipeline,
    HelpMessage = 'BitBucket cloud username, as plain text')]
    [ValidateNotNullOrEmpty()]
    [Alias('user')]
    [string]
    $username,
    [Parameter(Mandatory,
        ValueFromPipeline,
    HelpMessage = 'BitBucket cloud password, as plain text')]
    [ValidateNotNullOrEmpty()]
    [Alias('pass')]
    [string]
    $password,
    [Parameter(Mandatory,
        ValueFromPipeline,
    HelpMessage = 'File to upload, full path needed')]
    [ValidateNotNullOrEmpty()]
    [string]
    $FilePath,
    [Parameter(Mandatory,
        ValueFromPipeline,
    HelpMessage = 'BitBucket cloud team name')]
    [ValidateNotNullOrEmpty()]
    [string]
    $team,
    [Parameter(Mandatory,
        ValueFromPipeline,
    HelpMessage = 'BitBucket cloud project name')]
    [ValidateNotNullOrEmpty()]
    [Alias('ProjectName')]
    [string]
    $Project
  )

  process
  {
    # Build the URI for our request
    $URI = 'https://api.bitbucket.org/2.0/repositories/' + $team + '/' + $Project + '/downloads'

    # Create our authentication header
    # TODO: Migrate to OAUTH
    $pair = ($username + ':' + $password)
    $encodedCreds = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($pair))
    $basicAuthValue = ('Basic {0}' -f $encodedCreds)
    $Headers = @{
      Authorization = $basicAuthValue
    }

    # Cleanup the plain text stuff
    $pair = $null
    $encodedCreds = $null

    # The boundary is essential - Trust me, very essential
    $boundary = [Guid]::NewGuid().ToString()

    <#
        This is the crappy part: Build a body for a multipart request with PowerShell

        This is something that should be changed in PowerShell ASAP (I mean it is really crappy and really bad).

        It is an absolute no brainer with Curl.
    #>
    $bodyStart = @"
--$boundary
Content-Disposition: form-data; name="token"

--$boundary
Content-Disposition: form-data; name="files"; filename="$(Split-Path -Leaf -Path $FilePath)"
Content-Type: application/octet-stream


"@

    # Generate the end of the request body to finish it.
    $bodyEnd = @"

--$boundary--
"@

    # Now we create a temp file (Another crappy/bad thing)
    $requestInFile = (Join-Path -Path $env:TEMP -ChildPath ([IO.Path]::GetRandomFileName()))

    try
    {
      # Create a new object for the brand new temporary file
      $fileStream = (New-Object -TypeName 'System.IO.FileStream' -ArgumentList ($requestInFile, [IO.FileMode]'Create', [IO.FileAccess]'Write'))

      try
      {
        # The Body start
        $bytes = [Text.Encoding]::UTF8.GetBytes($bodyStart)
        $fileStream.Write($bytes, 0, $bytes.Length)

        # The original File
        $bytes = [IO.File]::ReadAllBytes($FilePath)
        $fileStream.Write($bytes, 0, $bytes.Length)

        # Append the end of the body part
        $bytes = [Text.Encoding]::UTF8.GetBytes($bodyEnd)
        $fileStream.Write($bytes, 0, $bytes.Length)
      }
      finally
      {
        # End the Stream to close the file
        $fileStream.Close()

        # Cleanup
        $fileStream = $null

        # PowerShell garbage collector
        [GC]::Collect()
      }

      # Make it multipart, this is the magic part...
      $contentType = 'multipart/form-data; boundary={0}' -f $boundary

      <#
          The request itself is simple and easy, also works fine with Invoke-WebRequest instead of Invoke-RestMethod

          I use Microsoft.PowerShell.Utility\Invoke-RestMethod to make sure the build in (Windows PowerShell native) function is used.
          If PowerShell Core is installed or any Module provides a tweaked version... Just in case!
      #>
      try
      {
        $null = (Microsoft.PowerShell.Utility\Invoke-RestMethod -Uri $URI -Method Post -InFile $requestInFile -ContentType $contentType -Headers $Headers -ErrorAction Stop -WarningAction SilentlyContinue)
      }
      catch
      {
        # Remove the temp file
        $null = (Remove-Item -Path $requestInFile -Force -Confirm:$false)

        # Cleanup
        $contentType = $null

        # PowerShell garbage collector
        [GC]::Collect()

        # For the Build logs (will not break the build)
        Write-Warning -Message 'StatusCode:' $_.Exception.Response.StatusCode.value__
        Write-Warning -Message 'StatusDescription:' $_.Exception.Response.StatusDescription

        # Saved in the verbose logs for this build
        Write-Verbose -Message $_

        # Inform the build and terminate (Will break the build)
        Write-Error -Message 'We were unable to upload your file to the BitBucket downloads section, please check the build logs for further information.' -ErrorAction Stop
      }
    }
    finally
    {
      # Remove the temp file
      $null = (Remove-Item -Path $requestInFile -Force -Confirm:$false)

      # Cleanup
      $contentType = $null

      # PowerShell garbage collector
      [GC]::Collect()
    }
  }
}

#region License
<#
    BSD 3-Clause License

    Copyright (c) 2018, enabling Technology <http://enatec.io>
    All rights reserved.

    Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

    2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

    3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

    By using the Software, you agree to the License, Terms and Conditions above!
#>
#endregion License

#region Hints
<#
    This is a third-party Software!

    The developer(s) of this Software is NOT sponsored by or affiliated with Microsoft Corp (MSFT) or any of its subsidiaries in any way

    The Software is not supported by Microsoft Corp (MSFT)!
#>
#endregion Hints