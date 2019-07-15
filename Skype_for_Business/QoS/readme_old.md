# Skype for Business QoS Settings
Setup Quality of Services (QoS) on Skype for Business Servers and Clients.

## You Network
You must configure your network equipment to match the marks that are configured on the client/server part.

Some people get this QoS wrong: This configuration enables your Clients and Servers to mark the traffic! Not more, not less. Your network equipment must do the dirty work and prioritize and/or reserve bandwidth that match your requirements.

If you just load the stuff here, nothing will change. Your Skype Clients and servers will mark the packets and that's about it!

## What it does
It configures the Skype for Business Servers to use a small range of ports for each function (e.g. Voice or Video). This range should match the Skype for Business Online (SfBO) configuration.
All Skype for Business Clients should use these configuration after a restart/re-login. Even non-Windows clients will be using the configuration, because it is configured on the server.

For Skype for Business Servers and Windows Based Clients, a dedicated Group Policy will be established. You should apply these to all OU's where the Clients and/or Servers are located.
The Client Policy also contains configuration/settings for VDI instances, and even for Citrix HDX setup's.

There is also the matching Edge configuration, these boxes should never be domain joined. Therefore, we use local registry settings!

To make the end-to-end setup, there is also a dedicated Group Policy for Exchange Servers. This Policy should be applied at minimum to all Exchange Servers that hosts the Unified Messaging Role. I apply these to all Exchange Servers.

## Please review everything
Before using the scripts to configure and/or load anything, you should review them! Do not just execute them. These scripts will change a lot and it will reconfigure a lot on your Skype for Business servers!!!
Don't blame me if something doesn't work as you might expect it.

## Detailed configuration
The source is the documentation! I know, that sounds typical for a geek... But if you take a closer look at the scripts, you will see a lot of comments and documentation snippets. They should make the settings and a lot of the logic clear.

Microsoft (MSFT) and the community provide a lot of very good and detailed documentation about Skype and QoS.

## Content
Here is a quick overview of the content

### `Client_GPO.ps1`
Create the Skype for Busines related Quality of Services Client Group Policy

### `Edge_REG.ps1`
Setup the Skype for Business 2015 Edge Server for Quality of Services
Edge Servers are not domain joined, we have to modify the registry instead of using a Group Policy
		
### `ExchangeUM_GPO.ps1`
Create the Skype for Busines related Exchange Unified Messaging Quality of Services Group Policy

### `Server_GPO.ps1`
Create the Skype for Busines related Quality of Services Server Group Policy

### `Skype_Server_Config.ps1`
Setup the Skype for Business 2015 Server for Quality of Services

## Signed
There is a signed version of the scripts within the 'signed' directory. The scripts are the same, they are signed with a valid certificate.

## Support
Are you kidding me? This is free software. Take it, or leave it!

## Final remarks
You Network Equipment must support QoS End-to-End!

Teams is not supported (yet).

Some of the new ports for Skype for Business Online (SfBO) are still missing. I might provide an updated version for them soon.

Hybrid with Skype for Business Online (SfBO) will work! But if you want to use QoS End-To-End, Fast Track might be required. Ask Microsoft!
