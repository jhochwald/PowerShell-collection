# ﻿Enable Administrator Protection
# Detection-EnableAdministratorProtection

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

try
{
   if (!(Test-Path -LiteralPath $RegPath -ErrorAction SilentlyContinue))
   {
      exit 1
   }

   # Define some defaults
   $paramGetItemPropertyValue = @{
      LiteralPath   = $RegPath
      WarningAction = 'SilentlyContinue'
      ErrorAction   = 'SilentlyContinue'
   }

   # Enable Admin Approval Mode for the built-in administrator
   if (!((Get-ItemPropertyValue -Name 'FilterAdministratorToken' @paramGetItemPropertyValue) -eq 1))
   {
      exit 1
   }

   # All administrators in Admin Approval Mode
   if (!((Get-ItemPropertyValue -Name 'EnableLUA' @paramGetItemPropertyValue) -eq 1))
   {
      exit 1
   }

   # Enable Secure Desktop for elevation prompts
   if (!((Get-ItemPropertyValue -Name 'PromptOnSecureDesktop' @paramGetItemPropertyValue) -eq 1))
   {
      exit 1
   }
}
catch
{
   exit 1
}

$paramGetItemPropertyValue = $null

# Ensure a clean exit!
exit 0
