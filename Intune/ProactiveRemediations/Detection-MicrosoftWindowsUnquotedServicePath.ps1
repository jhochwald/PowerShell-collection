# Detection - Microsoft Windows Unquoted Service Path (CVE-2013-1609, CVE-2014-0759, CVE-2014-5455)

try
{
   if (Get-CimInstance -Class Win32_Service -ErrorAction SilentlyContinue | Where-Object -FilterScript {
         (($_.StartMode -eq 'Auto') -and ($_.PathName -notmatch 'Windows') -and ($_.PathName -notmatch '"'))
   })
   {
      exit 1
   }
   else
   {
      exit 0
   }
}
catch
{
   exit 1
}