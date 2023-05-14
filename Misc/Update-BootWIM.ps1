#requires -Version 3.0 -Modules Dism -RunAsAdministrator
<#
   .SYNOPSIS
   Update WinPE/boot image/boot.wim

   .DESCRIPTION
   Update Windows installation media with Dynamic Update
   Update WinPE/boot image/boot.wim
   You need to download the appropriate CU for the boot image version you are using.

   .PARAMETER LCUPath
   Declare Dynamic Update packages

   .PARAMETER BootWin
   Declare Dynamic Update packages

   .PARAMETER WorkingPath
   Declare folders for mounted images and temp files

   .PARAMETER WinPEMount
   Declare folders for mounted images and temp files

   .EXAMPLE
   PS C:\> .\Update-BootWIM.ps1
   Update WinPE/boot image/boot.wim

   .LINK
   https://learn.microsoft.com/en-us/windows/deployment/update/media-dynamic-update

   .LINK
   https://github.com/Ccmexec/MEMCM-OSD-Scripts/blob/master/Update-BootWIM.ps1

   .NOTES
   Adopted from Update-BootWIM.ps1 version 0.1 of Sassan Fanai
#>
[CmdletBinding(ConfirmImpact = 'Low')]
[OutputType([string])]
param
(
   [Parameter(ValueFromPipeline,
   ValueFromPipelineByPropertyName)]
   [ValidateNotNullOrEmpty()]
   [Alias('LCU_PATH')]
   [string]
   $LCUPath = 'C:\mediaRefresh\packages\LCU.msu',
   [Parameter(ValueFromPipeline,
   ValueFromPipelineByPropertyName)]
   [ValidateNotNullOrEmpty()]
   [Alias('BOOT_WIM')]
   [string]
   $BootWin = 'C:\Boot Image Backup\boot.wim',
   [Parameter(ValueFromPipeline,
   ValueFromPipelineByPropertyName)]
   [ValidateNotNullOrEmpty()]
   [Alias('WORKING_PATH')]
   [string]
   $WorkingPath = 'C:\mediaRefresh\temp',
   [Parameter(ValueFromPipeline,
   ValueFromPipelineByPropertyName)]
   [ValidateNotNullOrEmpty()]
   [Alias('WINPE_MOUNT')]
   [string]
   $WinPEMount = 'C:\mediaRefresh\temp\WinPEMount'
)

begin
{
   function Get-TS
   {
      <#
         .SYNOPSIS
         Timestamp Helper

         .DESCRIPTION
         Timestamp Helper

         .EXAMPLE
         Get-TS
         Timestamp Helper

         .NOTES
         Internal Helper, adopted from Update-BootWIM.ps1 version 0.1 of Sassan Fanai

         .LINK
         https://github.com/Ccmexec/MEMCM-OSD-Scripts/blob/master/Update-BootWIM.ps1
      #>
      [CmdletBinding(ConfirmImpact = 'None')]
      [OutputType([string])]
      param ()

      process
      {
         <#
            1. [DateTime]::Now gets the current date and time
            2. -f is a format operator
            3. '{0:HH:mm:ss}' is a format string that tells the format operator to output the hours, minutes, and seconds of the datetime value
         #>
         '{0:HH:mm:ss}' -f [DateTime]::Now
      }
   }

   Write-Output -InputObject "$(Get-TS): Starting media refresh"
}

process
{
   # Check for LCU MSU
   if (-not (Test-Path -Path $LCUPath))
   {
      Write-Error -Exception 'No LCU.msu found.' -Message ('{0}: No LCU.msu found. You nned to download and copy the CU for your boot image version to {1} and rename the file to LCU.msu' -f (Get-TS), $LCUPath) -Category ObjectNotFound -TargetObject $LCUPath -RecommendedAction 'Please check the Path' -ErrorAction Stop
      break
   }

   # Create folders for mounting images and storing temporary files
   if (-not (Test-Path -Path $WorkingPath))
   {
      <#
         1. Create a new directory at the specified path
         2. -ItemType: specifies the type of item that this cmdlet creates
         3. -Path: specifies the path to the new directory
         4. -Force: suppress the confirmation prompt
         5. -Confirm: prompts you for confirmation before running the cmdlet
         6. -ErrorAction: specifies what to do when an error occurs
         7. Stop: tells the cmdlet to stop processing and to generate an error
      #>
      $null = (New-Item -ItemType directory -Path $WorkingPath -Force -Confirm:$false -ErrorAction Stop)
   }

   if (-not (Test-Path -Path $WinPEMount))
   {
      $null = (New-Item -ItemType directory -Path $WinPEMount -Force -Confirm:$false -ErrorAction stop)
   }

   # Update Windows Preinstallation Environment (WinPE)

   # Get the list of images contained within WinPE
   $WINPE_IMAGES = Get-WindowsImage -ImagePath $BootWin

   foreach ($IMAGE in $WINPE_IMAGES)
   {
      # Update WinPE
      Write-Output -InputObject ('{0}: Mounting WinPE, image index {1}' -f (Get-TS), $IMAGE.ImageIndex)

      <#
         1. Mount-WindowsImage cmdlet is used to mount the Windows image in the boot.wim file.
         2. The ImagePath parameter specifies the location of the boot.wim file.
         3. The Index parameter specifies the image in the boot.wim file that you want to mount.
         4. The Path parameter specifies the location of the folder to which you want to mount the image.
      #>
      $null = (Mount-WindowsImage -ImagePath $BootWin -Index $IMAGE.ImageIndex -Path $WinPEMount -ErrorAction Stop)

      try
      {
         Write-Output -InputObject ('{0}: Adding package {1}' -f (Get-TS), $LCUPath)

         $null = (Add-WindowsPackage -Path $WinPEMount -PackagePath $LCUPath -ErrorAction Stop)
      }
      catch
      {
         $theError = $_
         Write-Output -InputObject ('{0}: {1}' -f (Get-TS), $theError)

         if ($theError.Exception -like '*0x8007007e*')
         {
            Write-Output -InputObject "$(Get-TS): This failure is a known issue with combined cumulative update, we can ignore."
         }
         else
         {
            throw
         }
      }

      # Perform image cleanup
      Write-Output -InputObject "$(Get-TS): Performing image cleanup on WinPE"

      $null = & "$env:windir\system32\dism.exe" /image:$WinPEMount /cleanup-image /StartComponentCleanup

      # Dismount
      $null = (Dismount-WindowsImage -Path $WinPEMount -Save -ErrorAction Stop)

      # Export WinPE
      Write-Output -InputObject ('{0}: Exporting image to {1}\boot2.wim' -f (Get-TS), $WorkingPath)

      $null = (Export-WindowsImage -SourceImagePath $BootWin -SourceIndex $IMAGE.ImageIndex -DestinationImagePath $WorkingPath"\boot2.wim" -ErrorAction Stop)
   }

   $null = (Move-Item -Path ('{0}\boot2.wim' -f $WorkingPath) -Destination $BootWin -Force -ErrorAction Stop)
}
