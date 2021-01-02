# Troubleshooting

Here are a few things I found during the Installation of CU's.

## Cannot start service WinMgmt on computer '.'.

Something I had a few times in the past:

```
Microsoft Exchange Server 2016 Cumulative Update 6 Unattended Setup

Copying Files...
File copy complete. Setup will now collect additional information needed for installation.

Languages
Management tools
Mailbox role: Transport service
Mailbox role: Client Access service
Mailbox role: Unified Messaging service
Mailbox role: Mailbox service
Mailbox role: Front End Transport service
Mailbox role: Client Access Front End service

Performing Microsoft Exchange Server Prerequisite Check

    Configuring Prerequisites	COMPLETED
    Prerequisite Analysis		COMPLETED

Configuring Microsoft Exchange Server

    Preparing Setup				COMPLETED
    Stopping Services			COMPLETED
    Language Files				COMPLETED
    Removing Exchange Files 	COMPLETED
FAILED
Cannot start service WinMgmt on computer '.'.

The Exchange Server setup operation didn't complete. More details can be found in ExchangeSetup.log located in the
<SystemDrive>:\ExchangeSetupLogs folder.
```

### What to do?

Take a look at the ExchangeSetup.log in <SystemDrive>:\ExchangeSetupLogs (e.g. c:\ExchangeSetupLogs).
In my case, the error messages where not very helpfull, but a friend told me that sometimes they are. He told me, that the WinMgmt service seems to run into a timeout, based on what he found in the logs.
But in his case it was on Windows Server 2012R2 and Exchange 2013 CU 14.
In my case it was running and the logs told me, that the system where not able to start the WinMgmt service. Strange, but a restart solved it.

Reboot the Server and try it again!

Keep calm! Not ideal, but not so bad as it sounds.

## Reboot pending

One thing I found strange! Something went wrong and the installer then think, the servers needs a reboot.

```
Microsoft Exchange Server 2016 Cumulative Update 6 Unattended Setup

Copying Files...
File copy complete. Setup will now collect additional information needed for installation.

Languages
Management tools
Mailbox role: Transport service
Mailbox role: Client Access service
Mailbox role: Unified Messaging service
Mailbox role: Mailbox service
Mailbox role: Front End Transport service
Mailbox role: Client Access Front End service

Performing Microsoft Exchange Server Prerequisite Check

    Configuring Prerequisites       COMPLETED
    Prerequisite Analysis           FAILED

A reboot from a previous installation is pending. Please restart the system and then rerun Setup.
For more information, visit: http://technet.microsoft.com/library(EXCHG.150)/ms.exch.setupreadiness.RebootPending.aspx


The Exchange Server setup operation didn't complete. More details can be found in ExchangeSetup.log located in the
<SystemDrive>:\ExchangeSetupLogs folder.
```

### What to do?

Reboot the Server and try it again! Honestly, I have no idea where this comes from, but after the reboot the installtion went well...

Crawling the logs indicated, that the system where not able to remove some files!

