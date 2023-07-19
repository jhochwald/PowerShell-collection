$RegPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel'

try
{
   if (!(Test-Path -LiteralPath $RegPath -ErrorAction Stop))
   {
      exit 1
   }

   if (!((Get-ItemPropertyValue -LiteralPath $RegPath -Name '{20D04FE0-3AEA-1069-A2D8-08002B30309D}' -ErrorAction Stop) -eq 0))
   {
      exit 1
   }
}
catch
{
   exit 1
}

exit 0