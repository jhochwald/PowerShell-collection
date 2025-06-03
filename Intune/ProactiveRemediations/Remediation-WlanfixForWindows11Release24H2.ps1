#requires -Version 1.0

# Remediation-WlanfixForWindows11Release24H2

# Change Dependency
try
{
   $paramNewItemProperty = @{
      Path         = 'HKLM:\SYSTEM\CurrentControlSet\Services\Wcmsvc'
      Name         = 'Start'
      Value        = 3
      PropertyType = 'MultiString'
      Force        = $true
      Confirm      = $false
      ErrorAction  = 'Stop'
   }
   $null = (New-ItemProperty @paramNewItemProperty)
}
catch
{
   $paramSetItemProperty = @{
      Path        = 'HKLM:\SYSTEM\CurrentControlSet\Services\Wcmsvc'
      Name        = 'DependOnService'
      Value       = @('RpcSs', 'NSI')
      Force       = $true
      Confirm     = $false
      ErrorAction = 'SilentlyContinue'
   }
   $null = (Set-ItemProperty @paramSetItemProperty)
}

# Set Service WinHttpAutoProxySvc to Manual
try
{
   $paramNewItemProperty = @{
      Path         = 'HKLM:\SYSTEM\CurrentControlSet\Services\WinHttpAutoProxySvc'
      Name         = 'Start'
      Value        = 3
      PropertyType = 'DWORD'
      Force        = $true
      Confirm      = $false
      ErrorAction  = 'Stop'
   }
   $null = (New-ItemProperty @paramNewItemProperty)
}
catch
{
   $paramSetItemProperty = @{
      LiteralPath = 'HKLM:\SYSTEM\CurrentControlSet\Services\WinHttpAutoProxySvc'
      Name        = 'Start'
      Value       = 3
      Force       = $true
      Confirm     = $false
      ErrorAction = 'SilentlyContinue'
   }
   $null = (Set-ItemProperty @paramSetItemProperty)
}

# Restart services
$paramRestartService = @{
   Force       = $true
   Confirm     = $false
   ErrorAction = 'SilentlyContinue'
}
$null = (Get-Service -Name WlanSvc -ErrorAction SilentlyContinue | Restart-Service @paramRestartService)
$null = (Get-Service -Name WcmSvc -ErrorAction SilentlyContinue | Restart-Service @paramRestartService)
