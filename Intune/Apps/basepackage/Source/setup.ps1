<#
      C:\Program Files\enabling Technology\Packages\BasePackage.tag
#>

#region Global
$RegistryPath = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Communications'
$SCT = 'SilentlyContinue'
$SCT = $SCT

$paramRemoveItemProperty = @{
   Force       = $true
   Confirm     = $false
   ErrorAction = $SCT
}
#endregion Global

#region ARM64
# If we are running as a 32-bit process on an x64 system, re-launch as a 64-bit process
if ("$env:PROCESSOR_ARCHITEW6432" -ne 'ARM64')
{
    if (Test-Path -Path ('{0}\SysNative\WindowsPowerShell\v1.0\powershell.exe' -f $env:WINDIR) -ErrorAction $SCT -WarningAction $SCT)
    {
        & "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe" -ExecutionPolicy bypass -NoProfile -File $PSCommandPath
        Exit $lastexitcode
    }
}
#endregion ARM64

#region
$RegistryPath = 'HKLM:\SOFTWARE\enabling Technology\Packages\BasePackage'

$paramTestPath = @{
   LiteralPath   = $RegistryPath
   ErrorAction   = $SCT
   WarningAction = $SCT
}
if ((Test-Path @paramTestPath) -ne $true)
{
   $paramNewItem = @{
      Path          = $RegistryPath
      Force         = $true
      Confirm       = $false
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   $null = (New-Item @paramNewItem)
}

$paramNewItemProperty = @{
   LiteralPath   = $RegistryPath
   Name          = 'Installed'
   Value         = 1
   PropertyType  = 'DWord'
   Force         = $true
   Confirm       = $false
   ErrorAction   = $SCT
   WarningAction = $SCT
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion


#region HelperFunction
function Confirm-RegistryItemProperty
{
   <#
         .SYNOPSIS
         Enforce that an item property in the registry

         .DESCRIPTION
         Enforce that an item property in the registry

         .PARAMETER Path
         Registry Path

         .PARAMETER PropertyType
         The Property Type

         .PARAMETER Value
         The Registry Value to set

         .EXAMPLE
         PS C:\> Confirm-RegistryItemProperty -Path 'HKLM:\System\CurrentControlSet\Services\PimIndexMaintenanceSvc\Start' -PropertyType 'DWord' -Value '1'

         .NOTES
         Fixed version of the Helper:
         Recreate the Key if the Type is wrong (Possible cause the old version had a glitsch)
   #>
   [CmdletBinding(ConfirmImpact = 'None', SupportsShouldProcess)]
   param
   (
      [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      HelpMessage = 'Add help message for user')]
      [ValidateNotNullOrEmpty()]
      [Alias('RegistryPath')]
      [string]
      $Path,
      [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      HelpMessage = 'Add help message for user')]
      [ValidateNotNullOrEmpty()]
      [Alias('Property', 'Type')]
      [string]
      $PropertyType,
      [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
      [AllowEmptyCollection()]
      [AllowEmptyString()]
      [AllowNull()]
      [Alias('RegistryValue')]
      $Value
   )
   
   begin
   {
      #region
      $SCT = 'SilentlyContinue'
      #endregion
   }
   
   process
   {
      $paramTestPath = @{
         Path          = ($Path | Split-Path)
         WarningAction = $SCT
         ErrorAction   = $SCT
      }
      if (-Not (Test-Path @paramTestPath))
      {
         $paramNewItem = @{
            Path          = ($Path | Split-Path)
            Force         = $true
            WarningAction = $SCT
            ErrorAction   = $SCT
         }
         $null = (New-Item @paramNewItem)
      }
      
      $paramGetItemProperty = @{
         Path          = ($Path | Split-Path)
         Name          = ($Path | Split-Path -Leaf)
         WarningAction = $SCT
         ErrorAction   = $SCT
      }
      if (-Not (Get-ItemProperty @paramGetItemProperty))
      {
         $paramNewItemProperty = @{
            Path          = ($Path | Split-Path)
            Name          = ($Path | Split-Path -Leaf)
            PropertyType  = $PropertyType
            Value         = $Value
            Force         = $true
            Confirm       = $false
            WarningAction = $SCT
            ErrorAction   = $SCT
         }
         $null = (New-ItemProperty @paramNewItemProperty)
      }
      else
      {
         #region Workaround
         $paramGetItem = @{
            Path          = ($Path | Split-Path)
            ErrorAction   = $SCT
            WarningAction = $SCT
         }
         if (((Get-Item @paramGetItem).GetValueKind(($Path | Split-Path -Leaf))) -ne $PropertyType)
         {
            # The PropertyType is wrong! This might be an issue of our old version! Sorry for the glitsch
            $paramRemoveItemProperty = @{
               Path          = ($Path | Split-Path)
               Name          = ($Path | Split-Path -Leaf)
               Force         = $true
               Confirm       = $false
               WarningAction = $SCT
               ErrorAction   = $SCT
            }
            $null = (Remove-ItemProperty @paramRemoveItemProperty)
            
            $paramNewItemProperty = @{
               Path          = ($Path | Split-Path)
               Name          = ($Path | Split-Path -Leaf)
               PropertyType  = $PropertyType
               Value         = $Value
               Force         = $true
               Confirm       = $false
               WarningAction = $SCT
               ErrorAction   = $SCT
            }
            $null = (New-ItemProperty @paramNewItemProperty)
         }
         else
         {
            # Regular handling: PropertyType was correct
            $paramSetItemProperty = @{
               Path          = ($Path | Split-Path)
               Name          = ($Path | Split-Path -Leaf)
               Value         = $Value
               Force         = $true
               Confirm       = $false
               WarningAction = $SCT
               ErrorAction   = $SCT
            }
            $null = (Set-ItemProperty @paramSetItemProperty)
         }
         #endregion Workaround
      }
   }
}
#endregion HelperFunction

#region DirectoryStructure
$DirectoryStructure = @(
   ('{0}\Temp' -f $env:HOMEDRIVE)
   ('{0}\Scripts' -f $env:HOMEDRIVE)
   ('{0}\Scripts\Batch' -f $env:HOMEDRIVE)
   ('{0}\Scripts\PowerShell' -f $env:HOMEDRIVE)
   ('{0}\Scripts\PowerShell\export' -f $env:HOMEDRIVE)
   ('{0}\Scripts\PowerShell\import' -f $env:HOMEDRIVE)
   ('{0}\Scripts\PowerShell\logs' -f $env:HOMEDRIVE)
   ('{0}\Scripts\PowerShell\reports' -f $env:HOMEDRIVE)
   ('{0}\Tools' -f $env:HOMEDRIVE)
   ('{0}\windows\Provisioning\Autopilot' -f $env:HOMEDRIVE)
)

foreach ($Path in $DirectoryStructure)
{
   $paramTestPath = @{
      Path          = $Path
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if (-not (Test-Path @paramTestPath))
   {
      try
      {
         $paramNewItem = @{
            Path          = $Path
            ItemType      = 'Directory'
            Force         = $true
            Confirm       = $false
            ErrorAction   = $SCT
            WarningAction = $SCT
         }
         $null = (New-Item @paramNewItem)
      }
      catch
      {
         [Management.Automation.ErrorRecord]$e = $_
         $info = [PSCustomObject]@{
            Exception = $e.Exception.Message
            Reason    = $e.CategoryInfo.Reason
            Target    = $e.CategoryInfo.TargetName
            Script    = $e.InvocationInfo.ScriptName
            Line      = $e.InvocationInfo.ScriptLineNumber
            Column    = $e.InvocationInfo.OffsetInLine
         }
         Write-Verbose -Message $info
      }
   }
}
#endregion DirectoryStructure

#region Wallpapers
$TargetDirectory = "$env:windir\Web\Wallpaper\Windows\"

foreach ($Wallpaper in ((Get-Item -Path ('{0}\Wallpaper\*' -f $PSScriptRoot))))
{
   try
   {
      $paramCopyItem = @{
         Path          = $Wallpaper.FullName
         Destination   = ($TargetDirectory + $Wallpaper.Name)
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (Copy-Item @paramCopyItem)
   }
   catch
   {
      [Management.Automation.ErrorRecord]$e = $_
      $info = [PSCustomObject]@{
         Exception = $e.Exception.Message
         Reason    = $e.CategoryInfo.Reason
         Target    = $e.CategoryInfo.TargetName
         Script    = $e.InvocationInfo.ScriptName
         Line      = $e.InvocationInfo.ScriptLineNumber
         Column    = $e.InvocationInfo.OffsetInLine
      }
      Write-Verbose -Message $info
   }
}
#endregion Wallpapers

#region PowerShelScripts
$TargetDirectory = "$env:HOMEDRIVE\Scripts\PowerShell\"

$paramGetItem = @{
   Path          = ('{0}\PowerShell\*' -f $PSScriptRoot)
   ErrorAction   = $SCT
   WarningAction = $SCT
}
foreach ($PowerShelScript in (Get-Item @paramGetItem))
{
   try
   {
      $paramCopyItem = @{
         Path          = $PowerShelScript.FullName
         Destination   = ($TargetDirectory + $PowerShelScript.Name)
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (Copy-Item @paramCopyItem)
   }
   catch
   {
      [Management.Automation.ErrorRecord]$e = $_
      $info = [PSCustomObject]@{
         Exception = $e.Exception.Message
         Reason    = $e.CategoryInfo.Reason
         Target    = $e.CategoryInfo.TargetName
         Script    = $e.InvocationInfo.ScriptName
         Line      = $e.InvocationInfo.ScriptLineNumber
         Column    = $e.InvocationInfo.OffsetInLine
      }
      Write-Verbose -Message $info
   }
}
#endregion PowerShelScripts

#region Tools
$TargetDirectory = 'C:\Tools\'

foreach ($Tool in ((Get-Item -Path ('{0}\Tools\*' -f $PSScriptRoot))))
{
   try
   {
      $paramCopyItem = @{
         Path          = $Tool.FullName
         Destination   = ($TargetDirectory + $Tool.Name)
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (Copy-Item @paramCopyItem)
   }
   catch
   {
      [Management.Automation.ErrorRecord]$e = $_
      $info = [PSCustomObject]@{
         Exception = $e.Exception.Message
         Reason    = $e.CategoryInfo.Reason
         Target    = $e.CategoryInfo.TargetName
         Script    = $e.InvocationInfo.ScriptName
         Line      = $e.InvocationInfo.ScriptLineNumber
         Column    = $e.InvocationInfo.OffsetInLine
      }
      Write-Verbose -Message $info
   }
}
#endregion Tools

#region Autopilot
$TargetDirectory = "$env:windir\Provisioning\Autopilot\"
$ConfigurationFile = 'AutopilotConfigurationFile.json'

$paramTestPath = @{
   Path          = ($TargetDirectory + $ConfigurationFile)
   ErrorAction   = $SCT
   WarningAction = $SCT
}
if (Test-Path @paramTestPath)
{
   $paramRemoveItem = @{
      Path          = ($TargetDirectory + $ConfigurationFile)
      Force         = $true
      Confirm       = $false
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   $null = (Remove-Item @paramRemoveItem)
}

<#
      foreach ($Tool in ((Get-Item -Path ('{0}\Autopilot\*' -f $PSScriptRoot))))
      {
      try
      {
      $null = (Copy-Item -Path $Tool.FullName -Destination ($TargetDirectory + $Tool.Name) -Force -Confirm:$false -ErrorAction SilentlyContinue)
      }
      catch
      {
      [Management.Automation.ErrorRecord]$e = $_
      $info = [PSCustomObject]@{
      Exception = $e.Exception.Message
      Reason    = $e.CategoryInfo.Reason
      Target    = $e.CategoryInfo.TargetName
      Script    = $e.InvocationInfo.ScriptName
      Line      = $e.InvocationInfo.ScriptLineNumber
      Column    = $e.InvocationInfo.OffsetInLine
      }
      Write-Verbose -Message $info
      }
      }
#>
#endregion Autopilot

#region System32
$TargetDirectory = "$env:windir\System32\"

$paramGetItem = @{
   Path          = ('{0}\System32\*' -f $PSScriptRoot)
   ErrorAction   = $SCT
   WarningAction = $SCT
}
foreach ($Tool in (Get-Item @paramGetItem))
{
   try
   {
      $paramCopyItem = @{
         Path          = $Tool.FullName
         Destination   = ($TargetDirectory + $Tool.Name)
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (Copy-Item @paramCopyItem)
   }
   catch
   {
      [Management.Automation.ErrorRecord]$e = $_
      $info = [PSCustomObject]@{
         Exception = $e.Exception.Message
         Reason    = $e.CategoryInfo.Reason
         Target    = $e.CategoryInfo.TargetName
         Script    = $e.InvocationInfo.ScriptName
         Line      = $e.InvocationInfo.ScriptLineNumber
         Column    = $e.InvocationInfo.OffsetInLine
      }
      Write-Verbose -Message $info
   }
}
#endregion System32

#region etc
$TargetDirectory = "$env:windir\System32\drivers\etc\"

$paramGetItem = @{
   Path          = ('{0}\etc\*' -f $PSScriptRoot)
   ErrorAction   = $SCT
   WarningAction = $SCT
}
foreach ($Tool in (Get-Item @paramGetItem))
{
   try
   {
      $paramCopyItem = @{
         Path          = $Tool.FullName
         Destination   = ($TargetDirectory + $Tool.Name)
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (Copy-Item @paramCopyItem)
   }
   catch
   {
      [Management.Automation.ErrorRecord]$e = $_
      $info = [PSCustomObject]@{
         Exception = $e.Exception.Message
         Reason    = $e.CategoryInfo.Reason
         Target    = $e.CategoryInfo.TargetName
         Script    = $e.InvocationInfo.ScriptName
         Line      = $e.InvocationInfo.ScriptLineNumber
         Column    = $e.InvocationInfo.OffsetInLine
      }
      Write-Verbose -Message $info
   }
}
#endregion etc

#region remediation
try
{
   $paramTestPath = @{
      LiteralPath   = $RegistryPath
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   if ((Test-Path @paramTestPath ) -ne $true)
   {
      $paramNewItem = @{
         Path          = $RegistryPath
         Confirm       = $false
         Force         = $true
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (New-Item @paramNewItem)
   }
   
   $paramNewItemProperty = @{
      LiteralPath   = $RegistryPath
      Name          = 'ConfigureChatAutoInstall'
      Value         = 0
      PropertyType  = 'DWord'
      Confirm       = $false
      Force         = $true
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   $null = (New-ItemProperty @paramNewItemProperty)
}
catch
{
   Write-Verbose -Message 'This is ok for us'
}
#endregion remediation

#region
try
{
   $paramGetAppxPackage = @{
      AllUsers      = $true
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   $paramRemoveAppxPackage = @{
      AllUsers      = $true
      Confirm       = $false
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   $null = (Get-AppxPackage @paramGetAppxPackage | Where-Object {
         $PSItem.Name -eq 'Microsoftteams'
   } | Remove-AppxPackage @paramRemoveAppxPackage)
   
   $paramGetAppxProvisionedPackage = @{
      Online        = $true
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   $paramRemoveAppxProvisionedPackage = @{
      Online        = $true
      AllUsers      = $true
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   $null = (Get-AppxProvisionedPackage @paramGetAppxProvisionedPackage | Where-Object {
         $PSItem.DisplayName -eq 'MicrosoftTeams'
   } | Remove-AppxProvisionedPackage @paramRemoveAppxProvisionedPackage)
}
catch
{
   Write-Verbose -Message 'Did NOT see this one comming!'
}
#endregion

#region
$IntuneLink = ('{0}\Microsoft\Windows\Start Menu\Programs\Microsoft Intune Management Extension\Microsoft Intune Management Extension.lnk' -f $env:ProgramData)
$IntuneLinkDir = ('{0}\Microsoft\Windows\Start Menu\Programs\Microsoft Intune Management Extension\' -f $env:ProgramData)

$paramTestPath = @{
   Path          = $IntuneLink
   ErrorAction   = $SCT
   WarningAction = $SCT
}
if (Test-Path @paramTestPath)
{
   $paramRemoveItem = @{
      Path          = $IntuneLink
      Recurse       = $true
      Force         = $true
      Confirm       = $false
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   $null = (Remove-Item @paramRemoveItem)
}

$paramTestPath = @{
   Path          = $IntuneLinkDir
   ErrorAction   = $SCT
   WarningAction = $SCT
}
if (Test-Path @paramTestPath)
{
   $paramRemoveItem = @{
      Path          = $IntuneLinkDir
      Recurse       = $true
      Force         = $true
      Confirm       = $false
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   $null = (Remove-Item @paramRemoveItem)
}
#endregion
