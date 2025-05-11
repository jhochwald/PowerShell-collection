# Remediation - Hide/Remove WSL Linux icon from Desktop (Remediation-HideWSLLinuxIconFromDesktop.ps1)

$RegPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel'

try
{
   if ((Test-Path -LiteralPath $RegPath) -ne $true)
   {
      $null = (New-Item -Path $RegPath -Force -Confirm:$false -ErrorAction Stop)
   }

   # 1 = OFF (Hide) / Replace with 0 to turn it back on
   $paramNewItemProperty = @{
      LiteralPath  = $RegPath
      Name         = '{B2B4A4D1-2754-4140-A2EB-9A76D9D7CDC6}'
      Value        = 1
      PropertyType = 'DWord'
      Force        = $true
      Confirm      = $false
      ErrorAction  = 'Stop'
   }
   $null = (New-ItemProperty @paramNewItemProperty)
}
catch
{
   throw $_
   exit 1
}
