$ChocoPackage = 'nextcloud-client'

$null = (& "$env:ChocolateyInstall\bin\choco.exe" uninstall $ChocoPackage --acceptlicense --limitoutput --no-progress --yes --force)
