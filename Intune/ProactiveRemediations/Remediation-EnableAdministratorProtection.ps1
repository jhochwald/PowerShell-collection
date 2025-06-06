# Enable Administrator Protection
# Remediation-EnableAdministratorProtection

<#
      Please Activate Administrator Protection with Intune or Group Policy

      This is just to ensure that the Administrator Protection is setup

      Why you should rnable Administrator Protection:
      There are three (3) commonly used attack methods that can exploit existing UAC weaknesses:
      - UAC bypass
      Attacks that alter registry keys or environment variables within the user's context can deceive
      the UAC system into executing harmful processes when the user elevates privileges.
      These methods allow malware to piggyback on trusted processes to gain admin rights.

      - Token theft
      Traditional UAC models leave admin tokens available in memory, which attackers can steal to
      impersonate an administrator and move laterally within networks.

      - auto-elevation bypass
      This attack exploits the UAC feature that allows certain trusted system binaries to automatically
      elevate privileges without prompting the user. Attackers leverage this behavior by manipulating these
      auto-elevated binaries to execute malicious code with elevated privileges,
      effectively bypassing UAC prompts.

      Administrator Protection is designed to mitigate and prevent these attacks.
#>

$RegPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'

if ((Test-Path -LiteralPath $RegPath -ErrorAction SilentlyContinue) -ne $true)
{
   $paramNewItem = @{
      Path          = $RegPath
      Force         = $true
      Confirm       = $false
      WarningAction = 'SilentlyContinue'
      ErrorAction   = 'SilentlyContinue'
   }
   $null = (New-Item @paramNewItem)
   $paramNewItem = $null
}

# Define some defaults
$paramNewItemProperty = @{
   LiteralPath = $RegPath
   Force       = $true
   Confirm     = $false
   ErrorAction = 'SilentlyContinue'
}

# Enable Admin Approval Mode for the built-in administrator
$null = (New-ItemProperty -Name 'FilterAdministratorToken' -Value 1 -PropertyType DWord @paramNewItemProperty)

# All administrators in Admin Approval Mode
$null = (New-ItemProperty -Name 'EnableLUA' -Value 1 -PropertyType DWord @paramNewItemProperty)

# Enable Secure Desktop for elevation prompts
$null = (New-ItemProperty -Name 'PromptOnSecureDesktop' -Value 1 -PropertyType DWord @paramNewItemProperty)

$paramNewItemProperty = $null

# Ensure a clean exit!
exit 0
