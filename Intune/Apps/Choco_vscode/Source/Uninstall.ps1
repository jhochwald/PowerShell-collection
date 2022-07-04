$ChocoPackage = 'visualstudiocode-disableautoupdate'
$null = (& "$env:ChocolateyInstall\bin\choco.exe" uninstall $ChocoPackage --acceptlicense --limitoutput --no-progress --yes --force)

$ChocoPackage = 'vscode'
$null = (& "$env:ChocolateyInstall\bin\choco.exe" uninstall $ChocoPackage --acceptlicense --limitoutput --no-progress --yes --force)

