# 7.0.2.0090

# VPN profile
$VPNProfilePath = 'HKLM:\SOFTWARE\Fortinet\FortiClient\Sslvpn\Tunnels\<NAME>'

#region
$SCT = 'SilentlyContinue'
#endregion

# Restart Process using PowerShell 64-bit
If ($ENV:PROCESSOR_ARCHITEW6432 -eq 'AMD64')
{
   Try
   {
      &"$ENV:WINDIR\SysNative\WindowsPowershell\v1.0\PowerShell.exe" -File $PSCOMMANDPATH
   }
   Catch
   {
      Throw ('Failed to start {0}' -f $PSCOMMANDPATH)
   }

   Exit
}

# Install FortiClient VPN
Start-Process -FilePath ('{0}\system32\msiexec.exe' -f $env:windir) -Wait -ArgumentList '/i FortiClientVPN.msi TRANSFORMS=FortiClientVPN.mst REBOOT=ReallySuppress /qn'

# Install VPN Profiles
if ((Test-Path -LiteralPath $VPNProfilePath) -ne $true)
{
   $null = (New-Item -Path $VPNProfilePath -Force -Confirm:$false -ErrorAction $SCT )
}

$null = (New-ItemProperty -LiteralPath $VPNProfilePath -Name 'Description' -Value '<NAME>' -PropertyType String -Force -Confirm:$false -ErrorAction $SCT)
$null = (New-ItemProperty -LiteralPath $VPNProfilePath -Name 'Server' -Value '<SERVER>:<PORT>' -PropertyType String -Force -Confirm:$false -ErrorAction $SCT)
$null = (New-ItemProperty -LiteralPath $VPNProfilePath -Name 'sso_enabled' -Value 1 -PropertyType DWord -Force -Confirm:$false -ErrorAction $SCT)
$null = (New-ItemProperty -LiteralPath $VPNProfilePath -Name 'single_user_mode' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction $SCT)
$null = (New-ItemProperty -LiteralPath $VPNProfilePath -Name 'machine' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction $SCT)
$null = (New-ItemProperty -LiteralPath $VPNProfilePath -Name 'ServerCert' -Value '1' -PropertyType String -Force -Confirm:$false -ErrorAction $SCT)
$null = (New-ItemProperty -LiteralPath $VPNProfilePath -Name 'promptcertificate' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction $SCT)
$null = (New-ItemProperty -LiteralPath $VPNProfilePath -Name 'promptusername' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction $SCT)

