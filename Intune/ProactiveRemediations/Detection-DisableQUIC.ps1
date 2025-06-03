# Detection: Disable QUIC

try {
   #region Chrome
   $ChromeRegPath = 'HKLM:\SOFTWARE\Policies\Google\Chrome'

   if (!(Test-Path -LiteralPath $ChromeRegPath -ErrorAction SilentlyContinue))
   {
      exit 1
   }
   
   if (!((Get-ItemPropertyValue -LiteralPath $ChromeRegPath -Name 'QuicAllowed' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }

   $ChromeRegPath = $null
   #endregion Chrome

   #region ChromeOS
   $ChromeOSRegPath = 'HKLM:\SOFTWARE\Policies\Google\ChromeOS'

   if (!(Test-Path -LiteralPath $ChromeOSRegPath -ErrorAction SilentlyContinue))
   {
      exit 1
   }
   
   if (!((Get-ItemPropertyValue -LiteralPath $ChromeOSRegPath -Name 'QuicAllowed' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }

   $ChromeOSRegPath = $null
   #endregion ChromeOS

   #region MicrosoftEdge
   $EdgeRegPath = 'HKLM:\Software\Policies\Microsoft\Edge'

   if (!(Test-Path -LiteralPath $EdgeRegPath -ErrorAction SilentlyContinue))
   {
      exit 1
   }
   
   if (!((Get-ItemPropertyValue -LiteralPath $EdgeRegPath -Name 'QuicAllowed' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }

   $EdgeRegPath = $null
   #endregion MicrosoftEdge

   #region MicrosoftWebView2
   $WebView2RegPath = 'HKLM:\Software\Policies\Microsoft\Edge\WebView2'

   if (!(Test-Path -LiteralPath $WebView2RegPath -ErrorAction SilentlyContinue))
   {
      exit 1
   }
   
   if (!((Get-ItemPropertyValue -LiteralPath $WebView2RegPath -Name 'QuicAllowed' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }

   $WebView2RegPath = $null
   #endregion MicrosoftWebView2

   #region Brave
   $BraveRegPath = 'HKLM:\Software\Policies\BraveSoftware\Brave'

   if (!(Test-Path -LiteralPath $BraveRegPath -ErrorAction SilentlyContinue))
   {
      exit 1
   }

   if (!((Get-ItemPropertyValue -LiteralPath $BraveRegPath -Name 'QuicAllowed' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }

   $BraveRegPath = $null
   #endregion Brave
}
catch
{
   exit 1
}

exit 0
