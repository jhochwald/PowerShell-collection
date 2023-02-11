# https://en.wikipedia.org/wiki/List_of_Microsoft_Windows_versions
switch (((Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop).BuildNumber))
{
   {
      $_ -lt '10240'
   } 
   {
      Write-Error -Exception 'Incompatible Windows Version' -Message 'This Windows Version is not supported' -RecommendedAction 'Upgrade to Windows 10 1809, or newer' -ErrorAction Stop -ErrorId 1
      $script:ExitCode = 1 #Set the exit code for the Packager
   }
   {
      $_ -lt '17763'
   } 
   {
      Write-Error -Exception 'Incompatible Windows Build' -Message 'This Windows build is not supported' -RecommendedAction 'Upgrade to Windows 10 1809, or newer' -ErrorAction Stop -ErrorId 1
      $script:ExitCode = 1 #Set the exit code for the Packager
   }
   {
      $_ -lt '22000'
   } 
   {
      'Need Migration to Windows 11'
   }
   {
      $_ -cge '22000'
   } 
   {
      'Already migrated to Windows 11' 
   }
}
