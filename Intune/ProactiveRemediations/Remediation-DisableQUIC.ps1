# Remediation: Disable QUIC

#region Chrome
$ChromeRegPath = 'HKLM:\SOFTWARE\Policies\Google\Chrome'

if ((Test-Path -LiteralPath $ChromeRegPath -ErrorAction SilentlyContinue) -ne $true)
{
   $null = (New-Item -Path $ChromeRegPath -Force -Confirm:$false -ErrorAction SilentlyContinue)
}

$null = (New-ItemProperty -LiteralPath $ChromeRegPath -Name 'QuicAllowed' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)

$ChromeRegPath = $null
#endregion Chrome

#region ChromeOS
$ChromeOSRegPath = 'HKLM:\SOFTWARE\Policies\Google\ChromeOS'

if ((Test-Path -LiteralPath $ChromeOSRegPath -ErrorAction SilentlyContinue) -ne $true)
{
   $null = (New-Item -Path $ChromeOSRegPath -Force -Confirm:$false -ErrorAction SilentlyContinue)
}

$null = (New-ItemProperty -LiteralPath $ChromeOSRegPath -Name 'QuicAllowed' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)

$ChromeOSRegPath = $null
#endregion ChromeOS

#region MicrosoftEdge
$EdgeRegPath = 'HKLM:\Software\Policies\Microsoft\Edge'

if ((Test-Path -LiteralPath $EdgeRegPath -ErrorAction SilentlyContinue) -ne $true)
{
   $null = (New-Item -Path $EdgeRegPath -Force -Confirm:$false -ErrorAction SilentlyContinue)
}

$null = (New-ItemProperty -LiteralPath $EdgeRegPath -Name 'QuicAllowed' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)

$EdgeRegPath = $null
#endregion MicrosoftEdge

#region MicrosoftWebView2
$WebView2RegPath = 'HKLM:\Software\Policies\Microsoft\Edge\WebView2'

if ((Test-Path -LiteralPath $WebView2RegPath -ErrorAction SilentlyContinue) -ne $true)
{
   $null = (New-Item -Path $WebView2RegPath -Force -Confirm:$false -ErrorAction SilentlyContinue)
}

$null = (New-ItemProperty -LiteralPath $WebView2RegPath -Name 'QuicAllowed' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)

$WebView2RegPath = $null
#endregion MicrosoftWebView2

#region Brave
$BraveRegPath = 'HKLM:\Software\Policies\BraveSoftware\Brave'

if ((Test-Path -LiteralPath $BraveRegPath -ErrorAction SilentlyContinue) -ne $true)
{
   $null = (New-Item -Path $BraveRegPath -Force -Confirm:$false -ErrorAction SilentlyContinue)
}

$null = (New-ItemProperty -LiteralPath $BraveRegPath -Name 'QuicAllowed' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)

$BraveRegPath = $null
#endregion Brave
