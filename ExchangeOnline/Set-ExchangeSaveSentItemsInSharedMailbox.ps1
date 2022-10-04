#requires -Version 3.0

<#
.SYNOPSIS
Save Sent Items in Shared Mailbox Sent Items folder

.DESCRIPTION
Save Sent Items in Shared Mailbox Sent Items folder
This works in on Premises, Hybrid, and Exchange Online (Native) setups

.EXAMPLE
PS C:\> .\Set-ExchangeSaveSentItemsInSharedMailbox.ps1

.NOTES
This works in on Premises, Hybrid, and Exchange Online (Native) setups
#>
[CmdletBinding(ConfirmImpact = 'Low',
               SupportsShouldProcess)]
[OutputType([string])]
param ()

process
{
   if (Get-Command -Name Get-Mailbox -ErrorAction SilentlyContinue)
   {
      if ($pscmdlet.ShouldProcess('All Shared Mailboxes', 'Set MessageCopyForSendOnBehalfEnabled to TRUE'))
      {
         Get-Mailbox -ResultSize unlimited -ErrorAction SilentlyContinue -Filter {
            (RecipientTypeDetails -eq 'SharedMailbox')
         } | Set-Mailbox -MessageCopyForSendOnBehalfEnabled $True -ErrorAction Continue
      }
      if ($pscmdlet.ShouldProcess('All Shared Mailboxes', 'Set MessageCopyForSentAsEnabled to TRUE'))
      {
         Get-Mailbox -ResultSize unlimited -ErrorAction SilentlyContinue -Filter {
            (RecipientTypeDetails -eq 'SharedMailbox')
         } | Set-Mailbox -MessageCopyForSentAsEnabled $True -ErrorAction Continue
      }
   }
   else
   {
      Write-Error -Exception 'Not executed within an Exchange Management Shell' -Message 'Please execute with an Exchange Management Shell or connect to Exchange Online' -Category ResourceUnavailable -ErrorAction Stop

      Exit 1
   }
}  