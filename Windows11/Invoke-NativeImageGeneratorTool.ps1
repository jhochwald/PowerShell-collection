#requires -Version 1.0 -RunAsAdministrator

$env:PATH = [Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory()
[AppDomain]::CurrentDomain.GetAssemblies() | ForEach-Object -Process {
   $CompilePath = $null
   $CompilePath = $_.Location

   if ($CompilePath) 
   {
      $null = (ngen.exe install $CompilePath /NoDependencies /nologo /silent)
   }

   $CompilePath = $null
}

$null = (ngen.exe update /NoDependencies /nologo /silent)

# Create the path if missing 
If (!(Test-Path -Path 'HKLM:\SOFTWARE\Policies\Microsoft\SystemCertificates\ChainEngine'))
{
   $null = (New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\SystemCertificates\ChainEngine' -Force -Confirm:$false -ErrorAction SilentlyContinue)
}

If (!(Test-Path -Path 'HKLM:\SOFTWARE\Policies\Microsoft\SystemCertificates\ChainEngine\Config'))
{
   $null = (New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\SystemCertificates\ChainEngine\Config' -Force -Confirm:$false -ErrorAction SilentlyContinue)
}

# Set Timeout values to 1 second (1000 ms)
$null = (New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\SystemCertificates\ChainEngine\Config' -Name ChainUrlRetrievalTimeoutMilliseconds -Value 1000 -PropertyType DWORD -Force -Confirm:$false -ErrorAction SilentlyContinue)
$null = (New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\SystemCertificates\ChainEngine\Config' -Name ChainRevAccumulativeUrlRetrievalTimeoutMilliseconds -Value 1000 -PropertyType DWORD -Force -Confirm:$false -ErrorAction SilentlyContinue)
