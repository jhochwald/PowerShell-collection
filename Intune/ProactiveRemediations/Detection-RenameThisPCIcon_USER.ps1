$RegPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}'
$ThisPCName = $env:COMPUTERNAME

try
{
   if (!(Test-Path -LiteralPath $RegPath -ErrorAction Stop))
   {
      exit 1
   }

   if (!((Get-ItemPropertyValue -LiteralPath $RegPath -Name '(default)' -ErrorAction Stop) -eq $ThisPCName))
   {
      exit 1
   }
}
catch
{
   exit 1
}

exit 0