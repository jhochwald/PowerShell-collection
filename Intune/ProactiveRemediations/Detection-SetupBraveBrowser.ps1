# Detection: Setup Brave Browser

$RegPath = 'HKLM:\Software\Policies\BraveSoftware\Brave'

try {
   if (!(Test-Path -LiteralPath $RegPath -ErrorAction SilentlyContinue))
   {
      exit 1
   }

	
   if (!((Get-ItemPropertyValue -LiteralPath $RegPath -Name 'QuicAllowed' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $RegPath -Name 'EnableDoNotTrack' -ErrorAction SilentlyContinue) -eq 1))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $RegPath -Name 'ForceGoogleSafeSearch' -ErrorAction SilentlyContinue) -eq 1))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $RegPath -Name 'CryptoWalletEnabled' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $RegPath -Name 'DirectInvokeEnabled' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }
}
catch
{
   exit 1
}

exit 0
