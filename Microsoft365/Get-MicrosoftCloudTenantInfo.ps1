function Get-MicrosoftCloudTenantInfo
{
   <#
      .SYNOPSIS
      Check if a given Name is available as Office365/Azure Tenant Name

      .DESCRIPTION
      Check if a given Name is available as Office365/Azure Tenant Name and optional return the Tenant ID if the Tenant exists.

      .PARAMETER name
      Check if a given Name is available as Office365/Azure Tenant Name

      .PARAMETER id
      Get the Tenant ID

      .EXAMPLE
      PS C:\> Get-MicrosoftCloudTenantInfo -name 'Contoso' -id
      The Tenant ID of contoso.onmicrosoft.com (contoso) is XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX

      .EXAMPLE
      PS C:\> Get-MicrosoftCloudTenantInfo -name 'Contoso'
      The Tenant contoso.onmicrosoft.com (contoso) is available

      .EXAMPLE
      PS C:\> Get-MicrosoftCloudTenantInfo -name 'Contoso'
      WARNING: The Tenant contoso.onmicrosoft.com (contoso) is taken!

      .NOTES
      Changelog: Initial Public Release
   #>
   param
   (
      [Parameter(Mandatory,
         ValueFromPipeline,
         Position = 1,
         HelpMessage = 'Check if a given Name is availible as Office365/Azure Tenant Name')]
      [ValidateNotNullOrEmpty()]
      [string]
      $name,
      [Alias('TenantID')]
      [switch]
      $id
   )

   begin
   {
      # Define some defaults
      $ST = 'Stop'
      $SC = 'SilentlyContinue'

      # Do not use SSLv3 for any kind of Web Requests
      if ([Net.ServicePointManager]::SecurityProtocol -notmatch 'TLS12')
      {
         [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::TLS11
         [Net.ServicePointManager]::SecurityProtocol += [Net.SecurityProtocolType]::TLS12
      }

      # Cleanup
      $available = $null
      $TenantID = $null
      $TenantLongName = $null

      # Make the tenant name lowercase all the way, just in case!
      $name = $name.ToLower()

      # Where to check
      $uri = 'https://portal.office.com/Signup/CheckDomainAvailability.ajax'

      # OK, the Body looks creapy
      $body = 'p0=' + $name + '&assembly=BOX.Admin.UI%2C+Version%3D16.0.0.0%2C+Culture%3Dneutral%2C+PublicKeyToken%3Dnull&class=Microsoft.Online.BOX.Signup.UI.SignupServerCalls'
   }

   process
   {
      # get the Info via Rest
      $paramInvokeRestMethod = $null
      $paramInvokeRestMethod = @{
         Method        = 'Post'
         Uri           = $uri
         Body          = $body
         ErrorAction   = $SC
         WarningAction = $SC
      }
      $response = (Invoke-RestMethod @paramInvokeRestMethod)

      # Error handler
      $valid = $response.Contains('SessionValid')

      if ($valid -eq $false)
      {
         # Whoops
         Write-Error -Message $response -ErrorAction $ST
         exit
      }

      # Looks good
      $available = $response.Contains('<![CDATA[1]]>')
   }

   end
   {
      # Internal log Name
      $TenantLongName = $name + '.onmicrosoft.com'

      if ($available)
      {
         Write-Output -InputObject ('The Tenant {0} ({1}) is available' -f $TenantLongName, $name)
      }
      else
      {
         if ($id)
         {
            # Cleanup
            $TenantID = $null

            try
            {
               # Build the UIR
               $TenantIDURI = 'https://login.windows.net/' + $name + '.onmicrosoft.com/.well-known/openid-configuration'

               # Get the Info via regular call and split it
               $paramInvokeWebRequest = $null
               $paramInvokeWebRequest = @{
                  Uri         = $TenantIDURI
                  ErrorAction = $ST
               }

               $TenantID = ((Invoke-WebRequest @paramInvokeWebRequest | ConvertFrom-Json -ErrorAction $ST).token_endpoint.Split('/')[3])

               Write-Output -InputObject ('The Tenant ID of {0} ({1}) is {2}' -f $TenantLongName, $name, $TenantID)
            }
            catch
            {
               # Whoops
               Write-Warning -Message 'The Tenant is taken, but we where unable to get the Tenant ID!!!'
            }
         }
         else
         {
            Write-Warning -Message ('The Tenant {0} ({1}) is taken!' -f $TenantLongName, $name)
         }
      }

      # Cleanup
      $available = $null
      $TenantID = $null
      $TenantLongName = $null
   }
}

#region LICENSE
<#
   BSD 3-Clause License

   Copyright (c) 2021, enabling Technology
   All rights reserved.

   Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

   1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
   2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
   3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>
#endregion LICENSE

#region DISCLAIMER
<#
   DISCLAIMER:
   - Use at your own risk, etc.
   - This is open-source software, if you find an issue try to fix it yourself. There is no support and/or warranty in any kind
   - This is a third-party Software
   - The developer of this Software is NOT sponsored by or affiliated with Microsoft Corp (MSFT) or any of its subsidiaries in any way
   - The Software is not supported by Microsoft Corp (MSFT)
   - By using the Software, you agree to the License, Terms, and any Conditions declared and described above
   - If you disagree with any of the terms, and any conditions declared: Just delete it and build your own solution
#>
#endregion DISCLAIMER
