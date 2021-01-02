function Invoke-DSCPerfReqConfigCheck
{
   <#
      .SYNOPSIS
      Perform Required Configuration Checks and suppress all outputs.

      .DESCRIPTION
      Run the DSCLocalConfigurationManager method PerformRequiredConfigurationChecks.

      .PARAMETER Silent
      The progress bar will be spressed. this is not the case by default.

      .EXAMPLE
      PS C:\> Invoke-DSCPerfReqConfigCheck
      True

      # Run without any error

      .EXAMPLE
      PS C:\> Invoke-DSCPerfReqConfigCheck -Silent
      True

      # Run without any error. Supress the progress bar.

      .EXAMPLE
      PS C:\> Invoke-DSCPerfReqConfigCheck
      False

      # The run had errors.

      .EXAMPLE
      PS C:\> Invoke-DSCPerfReqConfigCheck -Silent
      False

      # The run had errors. Supress the progress bar.

      .NOTES
      I do a lot of testing with several DSC configurations.
      I just want a TRUE or FALSE as return to see if its working, or not.
      You may guess why: I use this in a CI chain :-)

      You may want to have seperated EventLog entries for DSC (useful for the log-Resource):
      & "$env:windir\system32\wevtutil.exe" set-log 'Microsoft-Windows-Dsc/Analytic' /q:true /e:true
      & "$env:windir\system32\wevtutil.exe" set-log 'Microsoft-Windows-Dsc/Debug' /q:True /e:true

      I dedicate any and all copyright interest in this software to the public domain.
      I make this dedication for the benefit of the public at large and to the detriment of my heirs and successors.
      I intend this dedication to be an overt act of relinquishment in perpetuity of all present and future rights to this software under copyright law.

      .LINK
      Author http://jhochwald.com

      .LINK
      LICENSE http://unlicense.org

      .LINK
      Invoke-CimMethod
      Write-Verbose
      Get-WinEvent
   #>
   [OutputType([bool])]
   param
   (
      [Parameter(ValueFromPipeline,
         Position = 1)]
      [switch]
      $Silent = $null
   )

   begin
   {
      $SC = 'SilentlyContinue'

      if ($Silent)
      {
         $ProgressPreference = $SC
      }
   }

   process
   {
      $InvokeCimMethodParams = @{
         Namespace     = 'root/Microsoft/Windows/DesiredStateConfiguration'
         ClassName     = 'MSFT_DSCLocalConfigurationManager'
         MethodName    = 'PerformRequiredConfigurationChecks'
         Arguments     = @{
            Flags = [uint32] 1
         }
         ErrorAction   = $SC
         WarningAction = $SC
      }

      try
      {
         $null = (Invoke-CimMethod @InvokeCimMethodParams)

         if ($Silent)
         {
            $ProgressPreference = $null
         }
      }
      catch
      {
         $paramWriteVerbose = @{
            Message       = "$_.Exception.Message - Line Number: $_.InvocationInfo.ScriptLineNumber"
            ErrorAction   = $SC
            WarningAction = $SC
         }
         Write-Verbose @paramWriteVerbose
      }

      $GetWinEventParams = @{
         LogName       = 'Microsoft-Windows-Dsc/*'
         ErrorAction   = $SC
         WarningAction = $SC
         Oldest        = $true
      }

      # TODO: That is fast, but the code looks bad!
      $SuccessResult = (Get-WinEvent @GetWinEventParams | Group-Object -Property {
            $_.Properties[0].value
         }).Group.LevelDisplayName -notcontains 'Error'
   }

   end
   {
      return $SuccessResult
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
      - If you disagree with any of the Terms, and any Conditions declared: Just delete it and build your own solution
#>
#endregion DISCLAIMER
