#requires -Version 3.0

<#
      .SYNOPSIS
      Get OneDrive size and size on disk

      .DESCRIPTION
      Get OneDrive size and size on disk

      .PARAMETER Path
      Path to the OneDrive Folder

      .PARAMETER GridView
      Should a detailed information list be dispayed using Out-GridView?

      .EXAMPLE
      PS C:\> .\Get-OneDriveSizeOnDisk.ps1 -Path 'C:\Users\JohnDoe\OneDrive - Contoso\'
      Get OneDrive size and size on disk, e.g., something like:
      OneDrive usage size '3.23 GB' - OneDrive usage on disk size  '125.52 MB'

      .EXAMPLE
      PS C:\> .\Get-OneDriveSizeOnDisk.ps1 -Path 'C:\Users\JohnDoe\OneDrive - Contoso\' -GridView
      Get OneDrive size and size on disk in a detailed GridView,
      

      .NOTES
      Just a reqorked version of this:
      https://github.com/damienvanrobaeys/OneDrive_SizeOnDisk/blob/main/Get_SizeOnDisk.ps1

      by: Damien Van Robaeys

      .LINK
      https://www.systanddeploy.com/2021/04/onedrive-and-powershell-get-size-and.html
#>
[CmdletBinding(ConfirmImpact = 'None')]
[OutputType([string])]
param
(
   [Parameter(Mandatory,
         ValueFromPipeline,
         ValueFromPipelineByPropertyName,
   HelpMessage = 'Path to the OneDrive Folder')]
   [ValidateNotNullOrEmpty()]
   [Alias('OD_Path', 'ODPath', 'OneDrivePath')]
   [string]
   $Path,
   [Parameter(ValueFromPipeline,
   ValueFromPipelineByPropertyName)]
   [Alias('Files_Size', 'FilesSize')]
   [switch]
   $GridView
)

begin
{
   #region Get-FormatSize
   function Get-FormatSize
   {
      <#
            .SYNOPSIS
            Internal Helper to transform the File Size

            .DESCRIPTION
            Internal Helper to transform the File Size

            .PARAMETER Size
            Size that should be transformed

            .EXAMPLE
            PS C:\> Get-FormatSize Get-FormatSize -Size 106824
            104,32 KB

            .EXAMPLE
            Get-FormatSize -Size 69220000
            66,01 MB

            .EXAMPLE
            Get-FormatSize -Size 109
            109,00 B

            .NOTES
            Switch statements don't even make the code easier to read, so we keep the  If/ElseIf
      #>
      [CmdletBinding(ConfirmImpact = 'None')]
      [OutputType([string])]
      param
      (
         [Parameter(Mandatory,
               ValueFromPipeline,
               ValueFromPipelineByPropertyName,
         HelpMessage = 'Size that should be transformed')]
         [ValidateNotNullOrEmpty()]
         [long]
         $Size
      )
      
      process
      {
         # We use "administrative constants" to figure out what size it is
         if ($null -eq $Size)
         {
            '0'
         }
         elseif ($Size -lt 1KB)
         {
            $FormatedSize = "$('{0:N2}' -f $Size) B"
         }
         elseif ($Size -lt 1MB)
         {
            $FormatedSize = "$('{0:N2}' -f ($Size / 1KB)) KB"
         }
         elseif ($Size -lt 1GB)
         {
            $FormatedSize = "$('{0:N2}' -f ($Size / 1MB)) MB"
         }
         elseif ($Size -lt 1TB)
         {
            $FormatedSize = "$('{0:N2}' -f ($Size / 1GB)) GB"
         }
         elseif ($Size -lt 1PB)
         {
            $FormatedSize = "$('{0:N2}' -f ($Size / 1TB)) TB"
         }
      }
      
      end
      {
         $FormatedSize
      }
   }
   #endregion Get-FormatSize

   #region GetSize
   # C# code to define "Disk.Size"
   $null = (Add-Type  -TypeDefinition @'
	using System;
	using System.Runtime.InteropServices;
	using System.ComponentModel;
	using System.IO;

	namespace Disk
   {
       public class Size
       {
           [DllImport("kernel32.dll")]
           private static extern uint GetCompressedFileSizeW([In] [MarshalAs(UnmanagedType.LPWStr)] string lpFileName,
               out uint lpFileSizeHigh);

           public static ulong SizeOnDisk(string filename)
           {
               uint High_Order;
               uint Low_Order;
               ulong GetSize;

               FileInfo CurrentFile = new FileInfo(filename);
               Low_Order = GetCompressedFileSizeW(CurrentFile.FullName, out High_Order);
               int GetError = Marshal.GetLastWin32Error();

               if (High_Order == 0 && Low_Order == 0xFFFFFFFF && GetError != 0)
               {
                   throw new Win32Exception(GetError);
               }

               GetSize = ((ulong)High_Order << 32) + Low_Order;
               return GetSize;
           }
       }
   }
'@ -Language CSharp -IgnoreWarnings -ErrorAction SilentlyContinue -WarningAction SilentlyContinue)
   #endregion GetSize

   # Create an empty object
   $OneDriveFiles = @()
}

process
{
   # Get all files
   $AllFiles = (Get-ChildItem -Path $Path -Recurse -ErrorAction SilentlyContinue | Where-Object -FilterScript {
         (! $_.PSIsContainer)
   })
   
   #region FileLoop
   foreach ($File in $AllFiles)
   {
      if ((Test-Path -Path $File.FullName -ErrorAction SilentlyContinue))
      {
         $SizeOnDisk = [Disk.Size]::SizeOnDisk($File.FullName)
         
         if ($GridView.IsPresent)
         {
            $OneDriveObject = $null
            $OneDriveObject = [PSCustomObject][ordered]@{
               'File name'    = $File.Name
               'Path'         = $File.DirectoryName
               'Size'         = $File.Length
               'Size on Disk' = $SizeOnDisk
            }
            $OneDriveFiles += $OneDriveObject
            $OneDriveObject = $null
         }
         
         $TotalDiskSize += $SizeOnDisk
         $TotalSize += $File.Length
      }
   }
   #endregion FileLoop
   
   # Get the formated size
   $FormatedFullSize = (Get-FormatSize -Size $TotalSize)
   $FormatedSizeOnDisk = (Get-FormatSize -Size $TotalDiskSize)
   
   #region
   $SecondOneDriveObject = $null
   $SecondOneDriveObject = [PSCustomObject][ordered]@{
      'File name'    = ' OneDrive resume'
      'Path'         = $Path
      'Size'         = $FormatedFullSize
      'Size on disk' = $FormatedSizeOnDisk
   }
   $OneDriveFiles += $SecondOneDriveObject
   $SecondOneDriveObject = $null
   #endregion
}

end
{
   if ($GridView.IsPresent)
   {
      if ($PSVersionTable.PSEdition -eq 'Core')
      {
         Write-Warning -Message 'We had issues with ''Out-GridView'' on PowerShell Core, if it crashed... Don´t blame me :-(' -WarningAction Continue
      }

      # Leverage Out-GridView to display the details
      $OneDriveFiles | Out-GridView
   }
   else
   {
      # Just quickly dump the info to the console
      ('OneDrive usage size ''{0}'' - OneDrive usage on disk size  ''{1}''' -f $FormatedFullSize, $FormatedSizeOnDisk)
   }
   
   #region FinalCleanup
   $OneDriveFiles = $null
   $FormatedFullSize = $null
   $FormatedSizeOnDisk = $null
   $SizeOnDisk = $null
   $OneDriveObject = $null
   $SecondOneDriveObject = $null
   #endregion FinalCleanup
   
   # Release as much memory as possible
   [GC]::Collect()
   [GC]::WaitForPendingFinalizers()
}