#requires -Version 2.0

<#
   .SYNOPSIS
   Get information from the local computer such as Azure AD join status, tenant Id, device id

   .DESCRIPTION
   Get information from the local computer such as Azure AD join status, tenant Id, device id and such. Similar information as dsregcmd /status

   .EXAMPLE
   .\Get-AadJoinInformation.ps1

   .NOTES
   Version 1.0.1

   Based on Get-AadJoinInformation.ps1 1.0 from Mattias Fors (DeployWindows.com)
#>
[CmdletBinding(ConfirmImpact = 'None')]
[OutputType([int])]
param ()

begin
{
   $SCT = 'SilentlyContinue'

   if (Get-Command -Name 'Set-MpPreference' -ErrorAction $SCT)
   {
      $null = (Set-MpPreference -EnableControlledFolderAccess Disabled -Force -ErrorAction $SCT)
   }

   $null = (Add-Type -TypeDefinition @'
using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.InteropServices;

public class NetAPI32{
public enum DSREG_JOIN_TYPE {
DSREG_UNKNOWN_JOIN,
DSREG_DEVICE_JOIN,
DSREG_WORKPLACE_JOIN
}

[StructLayout(LayoutKind.Sequential, CharSet=CharSet.Unicode)]
public struct DSREG_USER_INFO {
[MarshalAs(UnmanagedType.LPWStr)] public string UserEmail;
[MarshalAs(UnmanagedType.LPWStr)] public string UserKeyId;
[MarshalAs(UnmanagedType.LPWStr)] public string UserKeyName;
}

[StructLayout(LayoutKind.Sequential, CharSet=CharSet.Unicode)]
public struct CERT_CONTEX {
public uint   dwCertEncodingType;
public byte   pbCertEncoded;
public uint   cbCertEncoded;
public IntPtr pCertInfo;
public IntPtr hCertStore;
}

[StructLayout(LayoutKind.Sequential, CharSet=CharSet.Unicode)]
public struct DSREG_JOIN_INFO
{
public int joinType;
public IntPtr pJoinCertificate;
[MarshalAs(UnmanagedType.LPWStr)] public string DeviceId;
[MarshalAs(UnmanagedType.LPWStr)] public string IdpDomain;
[MarshalAs(UnmanagedType.LPWStr)] public string TenantId;
[MarshalAs(UnmanagedType.LPWStr)] public string JoinUserEmail;
[MarshalAs(UnmanagedType.LPWStr)] public string TenantDisplayName;
[MarshalAs(UnmanagedType.LPWStr)] public string MdmEnrollmentUrl;
[MarshalAs(UnmanagedType.LPWStr)] public string MdmTermsOfUseUrl;
[MarshalAs(UnmanagedType.LPWStr)] public string MdmComplianceUrl;
[MarshalAs(UnmanagedType.LPWStr)] public string UserSettingSyncUrl;
public IntPtr pUserInfo;
}

[DllImport("netapi32.dll", CharSet=CharSet.Unicode, SetLastError=true)]
public static extern void NetFreeAadJoinInformation(
IntPtr pJoinInfo);

[DllImport("netapi32.dll", CharSet=CharSet.Unicode, SetLastError=true)]
public static extern int NetGetAadJoinInformation(
string pcszTenantId,
out IntPtr ppJoinInfo);
}
'@ -ErrorAction $SCT)

   $pcszTenantId = $null
   $ptrJoinInfo = [IntPtr]::Zero
}

process
{
   # https://docs.microsoft.com/en-us/windows/win32/api/lmjoin/nf-lmjoin-netgetaadjoininformation
   [NetAPI32]::NetFreeAadJoinInformation([IntPtr]::Zero)
   $retValue = [NetAPI32]::NetGetAadJoinInformation($pcszTenantId, [ref]$ptrJoinInfo)

   # https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-erref/18d8fbe8-a967-4f1c-ae50-99ca8e491d2d
   if ($retValue -eq 0)
   {
      # https://support.microsoft.com/en-us/help/2909958/exceptions-in-windows-powershell-other-dynamic-languages-and-dynamical

      $paramNewObject = @{
         TypeName = 'NetAPI32+DSREG_JOIN_INFO'
      }
      $ptrJoinInfoObject = (New-Object @paramNewObject)
      $joinInfo = ([Runtime.InteropServices.Marshal]::PtrToStructure($ptrJoinInfo, [type]$ptrJoinInfoObject.GetType()) | Select-Object -ExpandProperty joinType)

      switch ($joinInfo)
      {
         ([NetAPI32+DSREG_JOIN_TYPE]::DSREG_DEVICE_JOIN.value__)
         {
            Write-Verbose -Message 'Device is joined'

            [int]$JoinType = 1
         }
         ([NetAPI32+DSREG_JOIN_TYPE]::DSREG_UNKNOWN_JOIN.value__)
         {
            Write-Verbose -Message 'Device is not joined, or unknown type'
            [int]$JoinType = 0
         }
         ([NetAPI32+DSREG_JOIN_TYPE]::DSREG_WORKPLACE_JOIN.value__)
         {
            Write-Verbose -Message 'Device workplace joined'

            [int]$JoinType = 2
         }
      }
   }
   else
   {
      Write-Verbose -Message 'Not Azure Joined'

      [int]$JoinType = 0
   }
}

end
{
   $JoinType

   if (Get-Command -Name 'Set-MpPreference' -ErrorAction $SCT)
   {
      $null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction $SCT)
   }
}

