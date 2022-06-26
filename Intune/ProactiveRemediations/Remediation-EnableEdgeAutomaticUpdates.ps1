<#
   .SYNOPSIS
   Enable Microsoft Edge Auto Update

   .DESCRIPTION
   Enable Microsoft Edge Auto Update

   .NOTES
   Designed to run in Microsoft Endpoint Manager (Intune)
#>
[CmdletBinding(ConfirmImpact = 'None')]
param ()

#region ARM64Handling
# Restart Process using PowerShell 64-bit
if ($ENV:PROCESSOR_ARCHITEW6432 -eq 'AMD64')
{
   try
   {
      &"$ENV:WINDIR\SysNative\WindowsPowershell\v1.0\PowerShell.exe" -File $PSCOMMANDPATH
   }
   catch
   {
      throw ('Failed to start {0}' -f $PSCOMMANDPATH)
   }

   exit
}
#endregion ARM64Handling

#region Defaults
$RegistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\EdgeUpdate'
$Channel = @(
   'Update{56EB18F8-B008-4CBD-B6D2-8C97FE7E9062}'
   'Update{2CD8A007-E189-409D-A2C8-9AF4EF3C72AA}'
   'Update{65C35B14-6C1D-4122-AC46-7148CC9D6497}'
   'Update{0D50BFEC-CD6A-4F9A-964C-C7416E3ACB10}'
)
$STP = 'Stop'
#endregion Defaults

$Channel | ForEach-Object {
   if (Get-ItemProperty -Path $RegistryPath -Name $PSItem -ErrorAction SilentlyContinue)
   {
      $RegistryName = $PSItem
   }
   else
   {
      $RegistryName = $null
   }

   try
   {
      if ($RegistryName)
      {
         $Registry = (Get-ItemProperty -Path $RegistryPath -Name $RegistryName -ErrorAction $STP | Select-Object -ExpandProperty $RegistryName)

         if (-not ($Registry -eq 1))
         {
            $null = (New-ItemProperty -Path $RegistryPath -Name $RegistryName -PropertyType 'DWORD' -Value 1 -Force -Confirm -ErrorAction $STP)
         }
      }
   }
   catch
   {
      Write-Error -Message $_ -ErrorAction $STP

      exit 1
   }
}
