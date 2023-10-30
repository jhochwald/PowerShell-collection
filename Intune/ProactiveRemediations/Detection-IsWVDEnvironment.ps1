# Detection-IsWVDEnvironment

$RegPath = 'HKLM:\SOFTWARE\Microsoft\Teams'

try
{
   $paramTestPath = @{
      LiteralPath = $RegPath
      ErrorAction = 'SilentlyContinue'
   }
   if (!(Test-Path @paramTestPath))
   {
      exit 1
   }

   $paramGetItemPropertyValue = @{
      LiteralPath = $RegPath
      Name        = 'IsWVDEnvironment'
      ErrorAction = 'SilentlyContinue'
   }
   if (!((Get-ItemPropertyValue @paramGetItemPropertyValue) -eq 1))
   {
      exit 1
   }
}
catch
{
   exit 1
}

exit 0
