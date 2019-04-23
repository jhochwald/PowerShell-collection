#requires -Version 2.0 -Modules DnsClient
function Test-LyncSRVRecords
{
   <#
         .SYNOPSIS
         Check for existing Lync/Skype for Business DNS Records
	
         .DESCRIPTION
         Check for existing Lync/Skype for Business DNS Records
	
         .PARAMETER DomainName
         Domain name to check, e.g. enatec.net
         Defaults to the DNS domain of the localhost
	
         .PARAMETER DNS
         Domain Name Server to use. Defaults to the CloudFlare Server 1.1.1.1
	
         .EXAMPLE
         PS C:\> Test-LyncSRVRecords
	
         Check for existing Lync/Skype for Business DNS Records for the DNS Domain of the local host
	
         .EXAMPLE
         PS C:\> Test-LyncSRVRecords -DomainName 'contoso.com'
	
         Check for existing Lync/Skype for Business DNS Records for contoso.com
	
         .EXAMPLE
         PS C:\> Test-LyncSRVRecords -DomainName 'contoso.com' -DNS '8.8.8.8'
	
         Check for existing Lync/Skype for Business DNS Records for contoso.com on the Google public DNS Server
	
         .NOTES
         Original by J. Hulsmans (@JHulsmans) https://about.me/jonihulsmans - MIT licensed
         Refactored and migrated to psobject output instead of Write-Host

         .LINK
         https://github.com/JHulsmans/PowerShell/blob/master/DNS/CheckSRVRecord.ps1
   #>
	
   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([psobject])]
   param
   (
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 0)]
      [ValidateNotNullOrEmpty()]
      [Alias('Domain')]
      [string]
      $DomainName = ((Get-WmiObject -Class win32_computersystem).Domain),
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 1)]
      [ValidateNotNullOrEmpty()]
      [string]
      $DNS = '1.1.1.1'
   )
	
   begin
   {
      # Definne some defaults
      $Type = 'SRV'
      $SCT = 'SilentlyContinue'
      
      # Set a default to prevent Null pointer exceptions, You can use $null here as well if you know what you're doing
      $NotFound = 'unknown'

      # Create the new Object
      $FinalResult = New-Object -TypeName psobject
   }
	
   process
   {
      $CnameResult = (Resolve-DnsName -Name sip.$DomainName -Server $DNS -ErrorAction $SCT)
      $LyncDiscoverResult = (Resolve-DnsName -Name lyncdiscover.$DomainName -Type A -Server $DNS -ErrorAction $SCT)
      $LyncDiscoverResultv6 = (Resolve-DnsName -Name lyncdiscover.$DomainName -Type AAAA -Server $DNS -ErrorAction $SCT)
      $FederationResult = (Resolve-DnsName -Name _sipfederationtls._tcp.$DomainName -Type $Type -Server $DNS -ErrorAction $SCT)
      $SipTlsResult = (Resolve-DnsName -Name _sip._tls.$DomainName -Type $Type -Server $DNS -ErrorAction $SCT)
		
      if ($CnameResult)
      {
         $FinalResult | Add-Member -MemberType NoteProperty -Name SipHost -Value sip.$DomainName
         $FinalResult | Add-Member -MemberType NoteProperty -Name Cname -Value $(@(foreach ($result in $CnameResult.namehost)
               {
                  $result
               }
         ))
      }
      else
      {
         $FinalResult | Add-Member -MemberType NoteProperty -Name SipHost -Value $NotFound
         $FinalResult | Add-Member -MemberType NoteProperty -Name Cname -Value $NotFound
      }
		
      if ($LyncDiscoverResult)
      {
         if ($LyncDiscoverResult.Name) 
         {
            $FinalResult | Add-Member -MemberType NoteProperty -Name LyncDiscover -Value ($LyncDiscoverResult.Name | Sort-Object | Get-Unique -OnType)
         } else 
         {
            $FinalResult | Add-Member -MemberType NoteProperty -Name LyncDiscover -Value $NotFound
         }
         
         if ($LyncDiscoverResult.NameHost) 
         {
            $FinalResult | Add-Member -MemberType NoteProperty -Name LyncDiscoverCname -Value ($LyncDiscoverResult.NameHost | Sort-Object | Get-Unique -OnType)
         } else 
         {
            $FinalResult | Add-Member -MemberType NoteProperty -Name LyncDiscoverCname -Value $NotFound
         }
      }
      else
      {
         $FinalResult | Add-Member -MemberType NoteProperty -Name LyncDiscover -Value $NotFound
         $FinalResult | Add-Member -MemberType NoteProperty -Name LyncDiscoverCname -Value $NotFound
      }
      
      # Get the IPv6 entry, if exists
      if ($LyncDiscoverResultv6)
      {
         if ($LyncDiscoverResultv6.Name)
         {
            $FinalResult | Add-Member -MemberType NoteProperty -Name LyncDiscoverV6 -Value ($LyncDiscoverResultv6.Name | Sort-Object | Get-Unique -OnType)
         } else 
         {
            $FinalResult | Add-Member -MemberType NoteProperty -Name LyncDiscoverV6 -Value $NotFound
         }
         
         if ($LyncDiscoverResultv6.NameHost) 
         {
            $FinalResult | Add-Member -MemberType NoteProperty -Name LyncDiscoverCnameV6 -Value ($LyncDiscoverResultv6.NameHost | Sort-Object | Get-Unique -OnType)
         } else 
         {
            $FinalResult | Add-Member -MemberType NoteProperty -Name LyncDiscoverCnameV6 -Value $NotFound
         }
      }
      else
      {
         $FinalResult | Add-Member -MemberType NoteProperty -Name LyncDiscoverV6 -Value $NotFound
         $FinalResult | Add-Member -MemberType NoteProperty -Name LyncDiscoverCnameV6 -Value $NotFound
      }
		
      if ($FederationResult)
      {
         $FinalResult | Add-Member -MemberType NoteProperty -Name Federation -Value $FederationResult.NameTarget

         if ($FederationResult.NameTarget -like '*.lync.com') 
         {
            $IsOnline = $true
         }
         else 
         {
            $IsOnline = $null
         }
      }
      else
      {
         $FinalResult | Add-Member -MemberType NoteProperty -Name Federation -Value $NotFound
         $IsOnline = $null
      }
		
      if ($SipTlsResult)
      {
         $FinalResult | Add-Member -MemberType NoteProperty -Name SipTls -Value $SipTlsResult.NameTarget

         if ($SipTlsResult.NameTarget -like '*.lync.com') 
         {
            $IsOnline = $true
         }
         else 
         {
            $IsOnline = $null
         }
      }
      else
      {
         $FinalResult | Add-Member -MemberType NoteProperty -Name SipTls -Value $NotFound
         $IsOnline = $null
      }
      
      if ($IsOnline) 
      {
         $FinalResult | Add-Member -MemberType NoteProperty -Name IsOnine -Value $true
      } else 
      {
         $FinalResult | Add-Member -MemberType NoteProperty -Name IsOnine -Value $false
      }
   }
	
   end
   {
      $FinalResult
   }
}
