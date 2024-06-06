# Detection: Prevent Windows Copilot/Copilot+ and Windows Recall from being installed from updates

try
{
   #region Copilot
   $CopilotRegPath = 'HKLM:\Software\Policies\Microsoft\Windows\WindowsCopilot'

   if (!(Test-Path -LiteralPath $CopilotRegPath -ErrorAction SilentlyContinue))
   {
      exit 1
   }

   if (!((Get-ItemPropertyValue -LiteralPath $CopilotRegPath -Name 'TurnOffWindowsCopilot' -ErrorAction SilentlyContinue) -eq 1))
   {
      exit 1
   }
   #endregion Copilot

   #region Recall
   $RecallRegPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI'

   if (!(Test-Path -LiteralPath $RecallRegPath -ErrorAction SilentlyContinue))
   {
      exit 1
   }

   if (!((Get-ItemPropertyValue -LiteralPath $RecallRegPath -Name 'DisableAIDataAnalysis' -ErrorAction SilentlyContinue) -eq 1))
   {
      exit 1
   }
   #endregion Recall
}
catch
{
   exit 1
}


exit 0