#region AllowAllNETUpdates
function Get-AllowAllNETUpdates
{
   <#
         .SYNOPSIS
         Check Allow All .NET Updates

         .DESCRIPTION
         Check Allow All .NET Updates

         .EXAMPLE
         PS C:\> Get-AllowAllNETUpdates

         .LINK
         https://devblogs.microsoft.com/dotnet/server-operating-systems-auto-updates/
   #>
   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([bool])]
   param ()

   $RegistryPath = 'HKLM:\SOFTWARE\Microsoft.NET'

   try
   {
      if (-not (Test-Path -LiteralPath $RegistryPath -ErrorAction SilentlyContinue))
      {
         exit 1
      }

      if (-not ((Get-ItemPropertyValue -LiteralPath $RegistryPath -Name 'AllowAUOnServerOS' -ErrorAction SilentlyContinue) -eq 1))
      {
         exit 1
      }
   }
   catch
   {
      exit 1
   }

   exit 0
}

function Set-AllowAllNETUpdates
{
   <#
         .SYNOPSIS
         Remediation Allow All .NET Updates

         .DESCRIPTION
         Remediation Allow All .NET Updates

         .EXAMPLE
         PS C:\> Set-AllowAllNETUpdates

         .LINK
         https://devblogs.microsoft.com/dotnet/server-operating-systems-auto-updates/
   #>
   [CmdletBinding(ConfirmImpact = 'None')]
   param ()

   $RegistryPath = 'HKLM:\SOFTWARE\Microsoft.NET'

   if ((Test-Path -LiteralPath $RegistryPath -ErrorAction SilentlyContinue) -ne $true)
   {
      $paramNewItem = @{
         Path        = $RegistryPath
         Force       = $true
         Confirm     = $false
         ErrorAction = 'SilentlyContinue'
      }
      $null = (New-Item @paramNewItem)
   }

   $paramNewItemProperty = @{
      LiteralPath  = $RegistryPath
      Name         = 'AllowAUOnServerOS'
      Value        = 1
      PropertyType = 'DWord'
      Force        = $true
      Confirm      = $false
      ErrorAction  = 'SilentlyContinue'
   }
   $null = (New-ItemProperty @paramNewItemProperty)
}
#endregion AllowAllNETUpdates

#region AllowAllNET6Updates
function Get-AllowAllNET6Updates
{
   <#
         .SYNOPSIS
         Check Allow .NET 6.0 Updates

         .DESCRIPTION
         Check Allow .NET 6.0 Updates

         .EXAMPLE
         PS C:\> Get-AllowAllNET6Updates

         .LINK
         https://devblogs.microsoft.com/dotnet/server-operating-systems-auto-updates/
   #>
   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([bool])]
   param ()

   $RegistryPath = 'HKLM:\SOFTWARE\Microsoft.NET\6.0'

   try
   {
      if (-not (Test-Path -LiteralPath $RegistryPath -ErrorAction SilentlyContinue))
      {
         exit 1
      }

      if (-not ((Get-ItemPropertyValue -LiteralPath $RegistryPath -Name 'AllowAUOnServerOS' -ErrorAction SilentlyContinue) -eq 1))
      {
         exit 1
      }
   }
   catch
   {
      exit 1
   }

   exit 0
}

function Set-AllowAllNET6Updates
{
   <#
         .SYNOPSIS
         Remediation Allow .NET 6.0 Updates

         .DESCRIPTION
         Remediation Allow .NET 6.0 Updates

         .EXAMPLE
         PS C:\> Set-AllowAllNET6Updates

         .LINK
         https://devblogs.microsoft.com/dotnet/server-operating-systems-auto-updates/
   #>
   [CmdletBinding(ConfirmImpact = 'None')]
   param ()

   $RegistryPath = 'HKLM:\SOFTWARE\Microsoft.NET\6.0'

   if ((Test-Path -LiteralPath $RegistryPath -ErrorAction SilentlyContinue) -ne $true)
   {
      $paramNewItem = @{
         Path        = $RegistryPath
         Force       = $true
         Confirm     = $false
         ErrorAction = 'SilentlyContinue'
      }
      $null = (New-Item @paramNewItem)
   }

   $paramNewItemProperty = @{
      LiteralPath  = $RegistryPath
      Name         = 'AllowAUOnServerOS'
      Value        = 1
      PropertyType = 'DWord'
      Force        = $true
      Confirm      = $false
      ErrorAction  = 'SilentlyContinue'
   }
   $null = (New-ItemProperty @paramNewItemProperty)
}
#endregion AllowAllNET6Updates

#region AllowAllNET5Updates
function Get-AllowAllNET5Updates
{
   <#
         .SYNOPSIS
         Check Allow .NET 5.0 Updates

         .DESCRIPTION
         Check Allow .NET 5.0 Updates

         .EXAMPLE
         PS C:\> Get-AllowAllNET5Updates

         .LINK
         https://devblogs.microsoft.com/dotnet/server-operating-systems-auto-updates/
   #>
   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([bool])]
   param ()

   $RegistryPath = 'HKLM:\SOFTWARE\Microsoft.NET\5.0'

   try
   {
      if (-not (Test-Path -LiteralPath $RegistryPath -ErrorAction SilentlyContinue))
      {
         exit 1
      }

      if (-not ((Get-ItemPropertyValue -LiteralPath $RegistryPath -Name 'AllowAUOnServerOS' -ErrorAction SilentlyContinue) -eq 1))
      {
         exit 1
      }
   }
   catch
   {
      rexit 1
   }

   exit 0
}

function Set-AllowAllNET5Updates
{
   <#
         .SYNOPSIS
         Remediation Allow .NET 5.0 Updates

         .DESCRIPTION
         Remediation Allow .NET 5.0 Updates

         .EXAMPLE
         PS C:\> Set-AllowAllNET5Updates

         .LINK
         https://devblogs.microsoft.com/dotnet/server-operating-systems-auto-updates/
   #>
   [CmdletBinding(ConfirmImpact = 'None')]
   param ()

   $RegistryPath = 'HKLM:\SOFTWARE\Microsoft.NET\5.0'

   if ((Test-Path -LiteralPath $RegistryPath -ErrorAction SilentlyContinue) -ne $true)
   {
      $paramNewItem = @{
         Path        = $RegistryPath
         Force       = $true
         Confirm     = $false
         ErrorAction = 'SilentlyContinue'
      }
      $null = (New-Item @paramNewItem)
   }

   $paramNewItemProperty = @{
      LiteralPath  = $RegistryPath
      Name         = 'AllowAUOnServerOS'
      Value        = 1
      PropertyType = 'DWord'
      Force        = $true
      Confirm      = $false
      ErrorAction  = 'SilentlyContinue'
   }
   $null = (New-ItemProperty @paramNewItemProperty)
}
#endregion AllowAllNET5Updates

#region AllowAllNET5Updates
function Get-AllowAllNET31Updates
{
   <#
         .SYNOPSIS
         Check Allow .NET 3.1 Updates

         .DESCRIPTION
         Check Allow .NET 3.1 Updates

         .EXAMPLE
         PS C:\> Get-AllowAllNET31Updates

         .LINK
         https://devblogs.microsoft.com/dotnet/server-operating-systems-auto-updates/
   #>
   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([bool])]
   param ()

   $RegistryPath = 'HKLM:\SOFTWARE\Microsoft.NET\3.1'

   try
   {
      if (-not (Test-Path -LiteralPath $RegistryPath -ErrorAction SilentlyContinue))
      {
         exit 1
      }

      if (-not ((Get-ItemPropertyValue -LiteralPath $RegistryPath -Name 'AllowAUOnServerOS' -ErrorAction SilentlyContinue) -eq 1))
      {
         exit 1
      }
   }
   catch
   {
      exit 1
   }

   exit 0
}

function Set-AllowAllNET31Updates
{
   <#
         .SYNOPSIS
         Remediation Allow .NET 3.1 Updates

         .DESCRIPTION
         Remediation Allow .NET 3.1 Updates

         .EXAMPLE
         PS C:\> Set-AllowAllNET31Updates

         .LINK
         https://devblogs.microsoft.com/dotnet/server-operating-systems-auto-updates/
   #>
   [CmdletBinding(ConfirmImpact = 'None')]
   param ()

   $RegistryPath = 'HKLM:\SOFTWARE\Microsoft.NET\3.1'

   if ((Test-Path -LiteralPath $RegistryPath -ErrorAction SilentlyContinue) -ne $true)
   {
      $paramNewItem = @{
         Path        = $RegistryPath
         Force       = $true
         Confirm     = $false
         ErrorAction = 'SilentlyContinue'
      }
      $null = (New-Item @paramNewItem)
   }

   $paramNewItemProperty = @{
      LiteralPath  = $RegistryPath
      Name         = 'AllowAUOnServerOS'
      Value        = 1
      PropertyType = 'DWord'
      Force        = $true
      Confirm      = $false
      ErrorAction  = 'SilentlyContinue'
   }
   $null = (New-ItemProperty @paramNewItemProperty)
}
#endregion AllowAllNET31Updates

