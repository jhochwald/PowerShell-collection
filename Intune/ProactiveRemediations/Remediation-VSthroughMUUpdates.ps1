# Remediation: Opting in to preview Visual Studio updates via Microsoft Update
# https://developercommunity.visualstudio.com/t/automatic-updates/599126

$RegPath = 'HKLM:\SOFTWARE\Policies\Microsoft\VisualStudio\Setup'

if ((Test-Path -LiteralPath $RegPath -ErrorAction SilentlyContinue) -ne $true)
{
   $null = (New-Item -Path $RegPath -Force -Confirm:$false -ErrorAction Stop)
}

$paramNewItemProperty = @{
   LiteralPath  = $RegPath
   PropertyType = 'DWord'
   Force        = $true
   Confirm      = $false
   ErrorAction  = 'Stop'
}

# Join Preview = 1 / Leave Preview = 0
$null = (New-ItemProperty -Name 'PreviewAutomaticUpdates' -Value 1 @paramNewItemProperty)

# Opt-in = 0 / Opt-out = 1
$null = (New-ItemProperty -Name 'VSthroughMUUpdatesOptOut' -Value 0 @paramNewItemProperty)
