function Get-MyIpAddress
{
   <#
         .SYNOPSIS
         Get the external IP Address
   
         .DESCRIPTION
         Get the external IP Address, both IPv6 and IPv4 is supported
         If an IPv6 is found, this is used by default!
   
         .PARAMETER IPv6
         Get the IPv6 Address
   
         .PARAMETER IPv4
         Get the external IPv4 Address (NAT?)
   
         .EXAMPLE
         PS C:\> Get-MyIpAddress

         Get the external IP Address, both IPv6 and IPv4 is supported

         .EXAMPLE
         PS C:\> Get-MyIpAddress -IPv6

         Get the IPv6 Address

         .EXAMPLE
         PS C:\> Get-MyIpAddress -IPv4

         Get the external IPv4 Address
   
         .OUTPUTS
         string

         .LINK
         https://www.my-ip.io/api
   
         .NOTES
         Uses https://www.my-ip.io to get the IP info
   #>
   [CmdletBinding(DefaultParameterSetName = 'Default',
   ConfirmImpact = 'None')]
   [OutputType([string], ParameterSetName = 'IPv6')]
   [OutputType([string], ParameterSetName = 'IPv4')]
   [OutputType([string], ParameterSetName = 'Default')]
   [OutputType([string])]
   param
   (
      [Parameter(ParameterSetName = 'IPv6',
            ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
      [Alias('6')]
      [switch]
      $IPv6,
      [Parameter(ParameterSetName = 'IPv4',
            ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
      [Alias('4')]
      [switch]
      $IPv4
   )
   
   begin
   {
      #region
      $Result = $null
      $HostName = $null
      $URI = $null
      #endregion
      
      switch ($PsCmdlet.ParameterSetName)
      {
         'IPv6' 
         {
            $HostName = 'api6'
         }
         'IPv4' 
         {
            $HostName = 'api4'
         }
         'Default' 
         {
            $HostName = 'api'
         }
      }
      
      $URI = ('https://{0}.my-ip.io/ip.json' -f $HostName)
   }
   
   process
   {
      $Result = (Invoke-RestMethod -Method Get -Uri $URI -DisableKeepAlive -ErrorAction Stop | Select-Object -ExpandProperty ip)
   }
   
   end
   {
      $Result
      
      #region
      $Result = $null
      $HostName = $null
      $URI = $null
      #endregion
   }
}
