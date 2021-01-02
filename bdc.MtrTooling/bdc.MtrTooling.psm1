function New-MtrConfigrationFile
{
   <#
         .SYNOPSIS
         Generate a  Microsoft Teams Room (MTR) System configuration file

         .DESCRIPTION
         Generate a  Microsoft Teams Room (MTR) System configuration file

         .PARAMETER AutoScreenShare
         If true, auto screen share is enabled.

         .PARAMETER HideMeetingName
         If true, meeting names are hidden.

         .PARAMETER UserAccount
         Container for credentials parameters. The sign in address, Exchange address, or email address are usually the same, such as RanierConf@contoso.com.

         .PARAMETER IsTeamsDefaultClient
         Is Microsoft Teams the Default for new Meetings

         .PARAMETER BluetoothAdvertisementEnabled
         Support local Bluetooth beakoning

         .PARAMETER SkypeMeetingsEnabled
         Support Skype for Business Meetings

         .PARAMETER TeamsMeetingsEnabled
         Support Microsoft Terams Meetings

         .PARAMETER DualScreenMode
         If true, dual screen mode is enabled. Otherwise the device uses single screen mode.

         .PARAMETER SendLogs
         Configure the "Give Feedback" and "Report Issue"

         .PARAMETER Devices
         The connected audio device names in the child elements are the same values listed in the Device Manager app.
         The configuration can contain a device that does not presently exist on the system, such as an A/V device not currently connected to the console.
         The configuration would be retained for the respective device.

         .PARAMETER ThemeName
         Used to identify the theme on the client. The Theme Name options are Default, one of the provided preset themes, or Custom.
         Custom theme names always use the name Custom.
         The client UI can be set at the console to the Default or one of the presets, but use of a custom theme must be set remotely by an Administrator.

         Preset themes include:
         Default
         Blue Wave
         Digital Forest
         Dreamcatcher
         Limeade
         Pixel Perfect
         Roadmap
         Sunset

         To disable the current theme, use "No Theme" for the ThemeName.

         .PARAMETER SkypeSignInAddress
         The sign in name for the Skype for Business or Teams device account.

         .PARAMETER ExchangeAddress
         The sign in name for the Exchange device account.

         .PARAMETER ExchangeAddress
         The domain and user name of the device, for example Seattle\RanierConf.

         .PARAMETER Password
         The password parameter is the same password used for the Skype for Business device account sign-in.

         .PARAMETER ConfigureDomain
         You can list several domains, separated by commas.
         Use one long string here!!!

         .PARAMETER EmailAddressForLogsAndFeedback
         Sets an optional email address that logs can be sent to when the "Give Feedback" window appears.

         .PARAMETER SendLogsAndFeedback
         If true, logs are sent to the admin. If false, only feedback is sent to the admin (and not logs).

         .PARAMETER MicrophoneForCommunication
         Sets the microphone used as the recording device in a conference.

         .PARAMETER SpeakerForCommunication
         Device to be used as speaker for the conference. This setting is used to set the speaker device used in a call.

         .PARAMETER DefaultSpeaker
         Device to be used to play the audio from an HDMI ingest source.

         .PARAMETER ContentCameraId
         Define the instance path for the camera configured in room to share analog whiteboard content in a meeting.
         See https://docs.microsoft.com/en-us/MicrosoftTeams/room-systems/xml-config-file#locate-the-content-camera-usb-instance-path

         Please note: We replace "&" with "&amp;" for you!
         Just use the String you copied from the Device Manager/Imaging devices/Properties/Details/Device instance path

         .PARAMETER ContentCameraInverted
         Specify if the content camera is physically installed upside down. For content cameras that support automatic rotation, specify false.

         .PARAMETER ContentCameraEnhancement
         When set to true (the default), the content camera image is digitally enhanced: the whiteboard edge is detected and an appropriate zoom is selected, ink lines are enhanced, and the person writing on the whiteboard is made transparent.

         Set to false if you intend to send a raw video feed to meeting participants for spaces where a whiteboard is not drawn on with a pen and instead the camera is used to show sticky notes, posters, or other media.

         .PARAMETER CustomThemeImageUrl
         Required for a custom theme, use file name only.

         .PARAMETER RedComponent
         Represents the red color component.

         .PARAMETER GreenComponent
         Represents the green color component.

         .PARAMETER BlueComponent
         Represents the blue color component.

         .EXAMPLE
         PS C:\> New-MtrConfigrationFile -ThemeName Custom -CustomThemeImageUrl 'wallpaper.jpg' -RedComponent 100 -BlueComponent 100 -GreenComponent 100

         Generate a  Microsoft Teams Room (MTR) System configuration file with a custom wallpaper and color settings

         .EXAMPLE
         PS C:\> New-MtrConfigrationFile -Devices -MicrophoneForCommunication 'Microsoft LifeChat LX-6000' -SpeakerForCommunication 'Realtek High Definition Audio' -DefaultSpeaker 'Polycom CX5100' -ContentCameraId 'USB\VID_046D&PID_0843&amp;MI_00\7&17446CF2&0&0000' -ContentCameraInverted $false -ContentCameraEnhancement $true

         Generate a  Microsoft Teams Room (MTR) System configuration file with custom devices

         .EXAMPLE
         PS C:\> New-MtrConfigrationFile -UserAccount -SkypeSignInAddress 'RanierConf@contoso.com' -ExchangeAddress 'RanierConf@contoso.com' -DomainUsername 'Seattle\RanierConf' -Password 'password' -ConfigureDomain 'domain1, domain2'

         Generate a  Microsoft Teams Room (MTR) System configuration file with configured user information (Accounts)

         .LINK
         http://hochwald.net
	
         .NOTES
         Initial MTR function
         The dynmic parameters still need some tweaks!
   #>
	[CmdletBinding(DefaultParameterSetName = 'Devices',
						ConfirmImpact = 'None',
						SupportsShouldProcess)]
	param
	(
		[Parameter(ValueFromPipeline,
					  ValueFromPipelineByPropertyName)]
		[Alias('MTRAutoScreenShare')]
		[string]
		$AutoScreenShare = $null,
		[Parameter(ValueFromPipeline,
					  ValueFromPipelineByPropertyName)]
		[Alias('MtrHideMeetingName')]
		[string]
		$HideMeetingName = $null,
		[Parameter(ParameterSetName = 'UserAccount',
					  ValueFromPipeline,
					  ValueFromPipelineByPropertyName)]
		[switch]
		$UserAccount,
		[Parameter(ValueFromPipeline,
					  ValueFromPipelineByPropertyName)]
		[Alias('MtrIsTeamsDefaultClient')]
		[string]
		$IsTeamsDefaultClient = $null,
		[Parameter(ValueFromPipeline,
					  ValueFromPipelineByPropertyName)]
		[Alias('MtrBluetoothAdvertisementEnabled')]
		[string]
		$BluetoothAdvertisementEnabled = $null,
		[Parameter(ValueFromPipeline,
					  ValueFromPipelineByPropertyName)]
		[Alias('MtrSkypeMeetingsEnabled')]
		[string]
		$SkypeMeetingsEnabled = $null,
		[Parameter(ValueFromPipeline,
					  ValueFromPipelineByPropertyName)]
		[Alias('MtrTeamsMeetingsEnabled')]
		[string]
		$TeamsMeetingsEnabled = $null,
		[Parameter(ValueFromPipeline,
					  ValueFromPipelineByPropertyName)]
		[Alias('MtrDualScreenMode')]
		[string]
		$DualScreenMode = $null,
		[Parameter(ParameterSetName = 'SendLogs',
					  ValueFromPipeline,
					  ValueFromPipelineByPropertyName)]
		[Alias('MtrSendLogs')]
		[switch]
		$SendLogs,
		[Parameter(ParameterSetName = 'Devices',
					  ValueFromPipeline,
					  ValueFromPipelineByPropertyName)]
		[Alias('MtrDevices')]
		[switch]
		$Devices,
		[Parameter(ParameterSetName = 'ThemeName',
					  ValueFromPipeline,
					  ValueFromPipelineByPropertyName)]
		[ValidateSet('Default ', 'Blue Wave ', 'Digital Forest ', 'Dreamcatcher ', 'Limeade ', 'Pixel Perfect ', 'Roadmap ', 'Sunset', 'No Theme', 'Custom', IgnoreCase = $true)]
		[Alias('MtrThemeName')]
		[string]
		$ThemeName,
		[Parameter(ValueFromPipeline,
					  ValueFromPipelineByPropertyName)]
		[Alias('MtrPath')]
		[string]
		$Path = '.'
	)
	
	dynamicparam
	{
		# Initial
		$RuntimeParameterDictionary = (New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary)
		
		#region UserAccount
		if ($PsCmdLet.ParameterSetName -eq 'UserAccount')
		{
			#region SkypeSignInAddress
			$ParamName_SkypeSignInAddress = 'SkypeSignInAddress'
			$AttributeCollection = (New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute])
			$ParameterAttribute = (New-Object -TypeName System.Management.Automation.ParameterAttribute)
			$ParameterAttribute.Mandatory = $true
			$ParameterAttribute.HelpMessage = 'The sign in name for the Skype for Business or Teams device account.'
			$ParameterAttribute.ParameterSetName = 'UserAccount'
			$AttributeCollection.Add($ParameterAttribute)
			$RuntimeParameter = (New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter -ArgumentList ($ParamName_SkypeSignInAddress, [string], $AttributeCollection))
			$RuntimeParameterDictionary.Add($ParamName_SkypeSignInAddress, $RuntimeParameter)
			#endregion SkypeSignInAddress
			
			#region ExchangeAddress
			$ParamName_ExchangeAddress = 'ExchangeAddress'
			$AttributeCollection = (New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute])
			$ParameterAttribute = (New-Object -TypeName System.Management.Automation.ParameterAttribute)
			$ParameterAttribute.Mandatory = $true
			$ParameterAttribute.HelpMessage = 'The sign in name for the Exchange device account.'
			$ParameterAttribute.ParameterSetName = 'UserAccount'
			$AttributeCollection.Add($ParameterAttribute)
			$RuntimeParameter = (New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter -ArgumentList ($ParamName_ExchangeAddress, [string], $AttributeCollection))
			$RuntimeParameterDictionary.Add($ParamName_ExchangeAddress, $RuntimeParameter)
			#endregion ExchangeAddress
			
			#region DomainUsername
			$ParamName_DomainUsername = 'DomainUsername'
			$AttributeCollection = (New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute])
			$ParameterAttribute = (New-Object -TypeName System.Management.Automation.ParameterAttribute)
			$ParameterAttribute.Mandatory = $true
			$ParameterAttribute.HelpMessage = 'The sign in name for the Exchange device account.'
			$ParameterAttribute.ParameterSetName = 'UserAccount'
			$AttributeCollection.Add($ParameterAttribute)
			$RuntimeParameter = (New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter -ArgumentList ($ParamName_DomainUsername, [string], $AttributeCollection))
			$RuntimeParameterDictionary.Add($ParamName_DomainUsername, $RuntimeParameter)
			#endregion DomainUsername
			
			#region Password
			$ParamName_Password = 'Password'
			$AttributeCollection = (New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute])
			$ParameterAttribute = (New-Object -TypeName System.Management.Automation.ParameterAttribute)
			$ParameterAttribute.Mandatory = $true
			$ParameterAttribute.HelpMessage = 'The password parameter is the same password used for the Skype for Business device account sign-in.'
			$ParameterAttribute.ParameterSetName = 'UserAccount'
			$AttributeCollection.Add($ParameterAttribute)
			$RuntimeParameter = (New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter -ArgumentList ($ParamName_Password, [string], $AttributeCollection))
			$RuntimeParameterDictionary.Add($ParamName_Password, $RuntimeParameter)
			#endregion Password
			
			#region ConfigureDomain
			$ParamName_ConfigureDomain = 'ConfigureDomain'
			$AttributeCollection = (New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute])
			$ParameterAttribute = (New-Object -TypeName System.Management.Automation.ParameterAttribute)
			$ParameterAttribute.ParameterSetName = 'UserAccount'
			$AttributeCollection.Add($ParameterAttribute)
			$RuntimeParameter = (New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter -ArgumentList ($ParamName_ConfigureDomain, [string], $AttributeCollection))
			$RuntimeParameterDictionary.Add($ParamName_ConfigureDomain, $RuntimeParameter)
			#endregion ConfigureDomain
		}
		#endregion UserAccount
		
		#region SendLogs
		if ($PsCmdLet.ParameterSetName -eq 'SendLogs')
		{
			#region EmailAddressForLogsAndFeedback
			$ParamName_EmailAddressForLogsAndFeedback = 'EmailAddressForLogsAndFeedback'
			$AttributeCollection = (New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute])
			$ParameterAttribute = (New-Object -TypeName System.Management.Automation.ParameterAttribute)
			$ParameterAttribute.ParameterSetName = 'SendLogs'
			$AttributeCollection.Add($ParameterAttribute)
			$RuntimeParameter = (New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter -ArgumentList ($ParamName_EmailAddressForLogsAndFeedback, [string], $AttributeCollection))
			$RuntimeParameterDictionary.Add($ParamName_EmailAddressForLogsAndFeedback, $RuntimeParameter)
			#endregion EmailAddressForLogsAndFeedback
			
			#region SendLogsAndFeedback
			$ParamName_SendLogsAndFeedback = 'SendLogsAndFeedback'
			$AttributeCollection = (New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute])
			$ParameterAttribute = (New-Object -TypeName System.Management.Automation.ParameterAttribute)
			$ParameterAttribute.ParameterSetName = 'SendLogs'
			$AttributeCollection.Add($ParameterAttribute)
			$RuntimeParameter = (New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter -ArgumentList ($ParamName_SendLogsAndFeedback, [string], $AttributeCollection))
			$RuntimeParameterDictionary.Add($ParamName_SendLogsAndFeedback, $RuntimeParameter)
			#endregion SendLogsAndFeedback
		}
		#endregion SendLogs
		
		#region Devices
		if ($PsCmdLet.ParameterSetName -eq 'Devices')
		{
			#region MicrophoneForCommunication
			$ParamName_MicrophoneForCommunication = 'MicrophoneForCommunication'
			$AttributeCollection = (New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute])
			$ParameterAttribute = (New-Object -TypeName System.Management.Automation.ParameterAttribute)
			$ParameterAttribute.ParameterSetName = 'Devices'
			$AttributeCollection.Add($ParameterAttribute)
			$RuntimeParameter = (New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter -ArgumentList ($ParamName_MicrophoneForCommunication, [string], $AttributeCollection))
			$RuntimeParameterDictionary.Add($ParamName_MicrophoneForCommunication, $RuntimeParameter)
			#endregion MicrophoneForCommunication
			
			#region SpeakerForCommunication
			$ParamName_SpeakerForCommunication = 'SpeakerForCommunication'
			$AttributeCollection = (New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute])
			$ParameterAttribute = (New-Object -TypeName System.Management.Automation.ParameterAttribute)
			$AttributeCollection.Add($ParameterAttribute)
			$RuntimeParameter = (New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter -ArgumentList ($ParamName_SpeakerForCommunication, [string], $AttributeCollection))
			$RuntimeParameterDictionary.Add($ParamName_SpeakerForCommunication, $RuntimeParameter)
			#endregion SpeakerForCommunication
			
			#region DefaultSpeaker
			$ParamName_DefaultSpeaker = 'DefaultSpeaker'
			$AttributeCollection = (New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute])
			$ParameterAttribute = (New-Object -TypeName System.Management.Automation.ParameterAttribute)
			$AttributeCollection.Add($ParameterAttribute)
			$RuntimeParameter = (New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter -ArgumentList ($ParamName_DefaultSpeaker, [string], $AttributeCollection))
			$RuntimeParameterDictionary.Add($ParamName_DefaultSpeaker, $RuntimeParameter)
			#endregion DefaultSpeaker
			
			#region ContentCameraId
			$ParamName_ContentCameraId = 'ContentCameraId'
			$AttributeCollection = (New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute])
			$ParameterAttribute = (New-Object -TypeName System.Management.Automation.ParameterAttribute)
			$AttributeCollection.Add($ParameterAttribute)
			$RuntimeParameter = (New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter -ArgumentList ($ParamName_ContentCameraId, [string], $AttributeCollection))
			$RuntimeParameterDictionary.Add($ParamName_ContentCameraId, $RuntimeParameter)
			#endregion ContentCameraId
			
			#region ContentCameraInverted
			$ParamName_ContentCameraInverted = 'ContentCameraInverted'
			$AttributeCollection = (New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute])
			$ParameterAttribute = (New-Object -TypeName System.Management.Automation.ParameterAttribute)
			$AttributeCollection.Add($ParameterAttribute)
			$RuntimeParameter = (New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter -ArgumentList ($ParamName_ContentCameraInverted, [string], $AttributeCollection))
			$RuntimeParameterDictionary.Add($ParamName_ContentCameraInverted, $RuntimeParameter)
			#endregion ContentCameraInverted
			
			#region ContentCameraEnhancement
			$ParamName_ContentCameraEnhancement = 'ContentCameraEnhancement'
			$AttributeCollection = (New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute])
			$ParameterAttribute = (New-Object -TypeName System.Management.Automation.ParameterAttribute)
			$AttributeCollection.Add($ParameterAttribute)
			$RuntimeParameter = (New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter -ArgumentList ($ParamName_ContentCameraEnhancement, [string], $AttributeCollection))
			$RuntimeParameterDictionary.Add($ParamName_ContentCameraEnhancement, $RuntimeParameter)
			#endregion ContentCameraEnhancement
		}
		#endregion Devices
		
		#region ThemeNameCustom
		if (($PsCmdLet.ParameterSetName -eq 'ThemeName') -and ($ThemeName -eq 'Custom'))
		{
			#region CustomThemeImageUrl
			$ParamName_CustomThemeImageUrl = 'CustomThemeImageUrl'
			$AttributeCollection = (New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute])
			$ParameterAttribute = (New-Object -TypeName System.Management.Automation.ParameterAttribute)
			$ParameterAttribute.Mandatory = $true
			$ParameterAttribute.HelpMessage = 'Required for a custom theme, use file name only.'
			$ParameterAttribute.ParameterSetName = 'ThemeName'
			$AttributeCollection.Add($ParameterAttribute)
			$RuntimeParameter = (New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter -ArgumentList ($ParamName_CustomThemeImageUrl, [string], $AttributeCollection))
			$RuntimeParameterDictionary.Add($ParamName_CustomThemeImageUrl, $RuntimeParameter)
			#endregion CustomThemeImageUrl
			
			#region RedComponent
			$ParamName_RedComponent = 'RedComponent'
			$AttributeCollection = (New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute])
			$ParameterAttribute = (New-Object -TypeName System.Management.Automation.ParameterAttribute)
			$ParameterAttribute.ParameterSetName = 'ThemeName'
			$AttributeCollection.Add($ParameterAttribute)
			$RuntimeParameter = (New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter -ArgumentList ($ParamName_RedComponent, [int], $AttributeCollection))
			$RuntimeParameterDictionary.Add($ParamName_RedComponent, $RuntimeParameter)
			#endregion RedComponent
			
			#region GreenComponent
			$ParamName_GreenComponent = 'GreenComponent'
			$AttributeCollection = (New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute])
			$ParameterAttribute = (New-Object -TypeName System.Management.Automation.ParameterAttribute)
			$ParameterAttribute.ParameterSetName = 'ThemeName'
			$AttributeCollection.Add($ParameterAttribute)
			$RuntimeParameter = (New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter -ArgumentList ($ParamName_GreenComponent, [int], $AttributeCollection))
			$RuntimeParameterDictionary.Add($ParamName_GreenComponent, $RuntimeParameter)
			#endregion GreenComponent
			
			#region BlueComponent
			$ParamName_BlueComponent = 'BlueComponent'
			$AttributeCollection = (New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute])
			$ParameterAttribute = (New-Object -TypeName System.Management.Automation.ParameterAttribute)
			$ParameterAttribute.ParameterSetName = 'ThemeName'
			$AttributeCollection.Add($ParameterAttribute)
			$RuntimeParameter = (New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter -ArgumentList ($ParamName_BlueComponent, [int], $AttributeCollection))
			$RuntimeParameterDictionary.Add($ParamName_BlueComponent, $RuntimeParameter)
			#endregion BlueComponent
		}
		#endregion ThemeNameCustom
		
		# Dump all the dynamic parameters
		return $RuntimeParameterDictionary
	}
	
	begin
	{
		#region SaveTheDynmicValues
		#region SkypeSignInAddress
		try
		{
			if ($PsBoundParameters[$ParamName_SkypeSignInAddress])
			{
				[string]$SkypeSignInAddress = $PsBoundParameters[$ParamName_SkypeSignInAddress]
			}
		}
		catch
		{
			$SkypeSignInAddress = $null
		}
		#endregion SkypeSignInAddress
		
		#region ExchangeAddress
		try
		{
			if ($PsBoundParameters[$ParamName_ExchangeAddress])
			{
				[string]$ExchangeAddress = $PsBoundParameters[$ParamName_ExchangeAddress]
			}
		}
		catch
		{
			$ExchangeAddress = $null
		}
		#endregion ExchangeAddress
		
		#region DomainUsername
		try
		{
			if ($PsBoundParameters[$ParamName_DomainUsername])
			{
				[string]$DomainUsername = $PsBoundParameters[$ParamName_DomainUsername]
			}
		}
		catch
		{
			$DomainUsername = $null
		}
		#endregion DomainUsername
		
		#region Password
		try
		{
			if ($PsBoundParameters[$ParamName_Password])
			{
				[string]$Password = $PsBoundParameters[$ParamName_Password]
			}
		}
		catch
		{
			$Password = $null
		}
		#endregion Password
		
		#region ConfigureDomain
		try
		{
			if ($PsBoundParameters[$ParamName_ConfigureDomain])
			{
				[string]$ConfigureDomain = $PsBoundParameters[$ParamName_ConfigureDomain]
			}
		}
		catch
		{
			$ConfigureDomain = $null
		}
		#endregion ConfigureDomain
		
		#region EmailAddressForLogsAndFeedback
		try
		{
			if ($PsBoundParameters[$ParamName_EmailAddressForLogsAndFeedback])
			{
				[string]$EmailAddressForLogsAndFeedback = $PsBoundParameters[$ParamName_EmailAddressForLogsAndFeedback]
			}
		}
		catch
		{
			$EmailAddressForLogsAndFeedback = $null
		}
		#endregion EmailAddressForLogsAndFeedback
		
		#region SendLogsAndFeedback
		try
		{
			if ($PsBoundParameters[$ParamName_SendLogsAndFeedback])
			{
				[bool]$SendLogsAndFeedback = $PsBoundParameters[$ParamName_SendLogsAndFeedback]
			}
		}
		catch
		{
			$SendLogsAndFeedback = $null
		}
		#endregion SendLogsAndFeedback
		
		#region MicrophoneForCommunication
		try
		{
			if ($PsBoundParameters[$ParamName_MicrophoneForCommunication])
			{
				[string]$MicrophoneForCommunication = $PsBoundParameters[$ParamName_MicrophoneForCommunication]
			}
		}
		catch
		{
			$MicrophoneForCommunication = $null
		}
		#endregion MicrophoneForCommunication
		
		#region SpeakerForCommunication
		try
		{
			if ($PsBoundParameters[$ParamName_SpeakerForCommunication])
			{
				[string]$SpeakerForCommunication = $PsBoundParameters[$ParamName_SpeakerForCommunication]
			}
		}
		catch
		{
			$SpeakerForCommunication = $null
		}
		#endregion SpeakerForCommunication
		
		#region DefaultSpeaker
		try
		{
			if ($PsBoundParameters[$ParamName_DefaultSpeaker])
			{
				[string]$DefaultSpeaker = $PsBoundParameters[$ParamName_DefaultSpeaker]
			}
		}
		catch
		{
			$DefaultSpeaker = $null
		}
		#endregion DefaultSpeaker
		
		#region ContentCameraId
		try
		{
			if ($PsBoundParameters[$ParamName_ContentCameraId])
			{
				[string]$ContentCameraId = $PsBoundParameters[$ParamName_ContentCameraId]
				
				# Replace the ampersand (&) with &amp;
				[string]$ContentCameraId = [string]$ContentCameraId.Replace('&', '&amp;')
			}
		}
		catch
		{
			$ContentCameraId = $null
		}
		#endregion ContentCameraId
		
		#region ContentCameraInverted
		try
		{
			if ($PsBoundParameters[$ParamName_ContentCameraInverted])
			{
				[bool]$ContentCameraInverted = $PsBoundParameters[$ParamName_ContentCameraInverted]
			}
		}
		catch
		{
			$ContentCameraInverted = $null
		}
		#endregion ContentCameraInverted
		
		#region ContentCameraEnhancement
		try
		{
			if ($PsBoundParameters[$ParamName_ContentCameraEnhancement])
			{
				[bool]$ContentCameraEnhancement = $PsBoundParameters[$ParamName_ContentCameraEnhancement]
			}
		}
		catch
		{
			$ContentCameraEnhancement = $null
		}
		#endregion ContentCameraEnhancement
		
		#region CustomThemeImageUrl
		try
		{
			if ($PsBoundParameters[$ParamName_CustomThemeImageUrl])
			{
				[string]$CustomThemeImageUrl = $PsBoundParameters[$ParamName_CustomThemeImageUrl]
			}
		}
		catch
		{
			$CustomThemeImageUrl = $null
		}
		#endregion CustomThemeImageUrl
		
		#region RedComponent
		try
		{
			if ($PsBoundParameters[$ParamName_RedComponent])
			{
				[int]$RedComponent = $PsBoundParameters[$ParamName_RedComponent]
				
				# Check the values
				if (($RedComponent -lt 0) -or ($RedComponent -gt 255))
				{
					Write-Error -Message ('The Value RedComponent is {0} - Valis is 0-255' -f $RedComponent) -Category InvalidArgument -TargetObject $RedComponent -ErrorAction Stop
					
					# Just in case
					exit 1
				}
			}
		}
		catch
		{
			$RedComponent = $null
		}
		#endregion RedComponent
		
		#region GreenComponent
		try
		{
			if ($PsBoundParameters[$ParamName_GreenComponent])
			{
				[int]$GreenComponent = $PsBoundParameters[$ParamName_GreenComponent]
				
				# Check the values
				if (($GreenComponent -lt 0) -or ($GreenComponent -gt 255))
				{
					Write-Error -Message ('The Value GreenComponent is {0} - Valis is 0-255' -f $GreenComponent) -Category InvalidArgument -TargetObject $GreenComponent -ErrorAction Stop
					
					# Just in case
					exit 1
				}
			}
		}
		catch
		{
			$GreenComponent = $null
		}
		#endregion GreenComponent
		
		#region BlueComponent
		try
		{
			if ($PsBoundParameters[$ParamName_BlueComponent])
			{
				[int]$BlueComponent = $PsBoundParameters[$ParamName_BlueComponent]
				
				# Check the values
				if (($BlueComponent -lt 0) -or ($BlueComponent -gt 255))
				{
					Write-Error -Message ('The Value BlueComponent is {0} - Valis is 0-255' -f $BlueComponent) -Category InvalidArgument -TargetObject $BlueComponent -ErrorAction Stop
					
					# Just in case
					exit 1
				}
			}
		}
		catch
		{
			$BlueComponent = $null
		}
		#endregion BlueComponent
		#endregion SaveTheDynmicValues
	}
	
	process
	{
		if (($AutoScreenShare) -or ($HideMeetingName) -or ($UserAccount) -or ($IsTeamsDefaultClient) -or ($BluetoothAdvertisementEnabled) -or ($SkypeMeetingsEnabled) -or ($TeamsMeetingsEnabled) -or ($DualScreenMode) -or ($SendLogs) -or ($Devices) -or ($ThemeName))
		{
			#region SomeCheck
			if (($SkypeMeetingsEnabled) -and ($TeamsMeetingsEnabled))
			{
				if (($SkypeMeetingsEnabled -eq [bool]$false) -and ($TeamsMeetingsEnabled -eq [bool]$false))
				{
					Write-Error -Message 'The XML file is considered badly formed if both <SkypeMeetingsEnabled> and<TeamsMeetingsEnabled> are disabled, but it is acceptable to have both settings enabled at the same time.' -Category InvalidData -ErrorAction Stop
				}
			}
			#endregion SomeCheck
			
			try
			{
				# Create the Settings name
				[string]$SkypeSettingsName = 'SkypeSettings.xml'
				
				# Create the XML configuration file
				$paramNewObject = @{
					TypeName	    = 'System.XMl.XmlTextWriter'
					ArgumentList = (($Path + '\' + $SkypeSettingsName), $null)
				}
				$xmlWriter = (New-Object @paramNewObject)
				
				# Set the defaults for the XML configuration file
				$xmlWriter.Formatting = 'Indented'
				$xmlWriter.Indentation = 1
				$xmlWriter.IndentChar = "`t"
				
				# Create the document
				$xmlWriter.WriteStartDocument()
				
				# Create <SkypeSettings>
				$xmlWriter.WriteStartElement('SkypeSettings')
				
				if ($AutoScreenShare)
				{
					$xmlWriter.WriteElementString('AutoScreenShare', $AutoScreenShare)
				}
				
				if ($HideMeetingName)
				{
					$xmlWriter.WriteElementString('HideMeetingName', $HideMeetingName)
				}
				
				if ($UserAccount)
				{
					# Create <UserAccount>
					$xmlWriter.WriteStartElement('UserAccount')
					
					if ($SkypeSignInAddress)
					{
						$xmlWriter.WriteElementString('SkypeSignInAddress', $SkypeSignInAddress)
					}
					
					if ($ExchangeAddress)
					{
						$xmlWriter.WriteElementString('ExchangeAddress', $ExchangeAddress)
					}
					
					if ($DomainUsername)
					{
						$xmlWriter.WriteElementString('DomainUsername', $DomainUsername)
					}
					
					if ($Password)
					{
						$xmlWriter.WriteElementString('Password', $Password)
					}
					
					if ($ConfigureDomain)
					{
						$xmlWriter.WriteElementString('ConfigureDomain', $ConfigureDomain)
					}
					
					# Close </UserAccount>
					$xmlWriter.WriteEndElement()
				}
				
				if ($IsTeamsDefaultClient)
				{
					$xmlWriter.WriteElementString('IsTeamsDefaultClient', $IsTeamsDefaultClient)
				}
				
				if ($BluetoothAdvertisementEnabled)
				{
					$xmlWriter.WriteElementString('BluetoothAdvertisementEnabled', $BluetoothAdvertisementEnabled)
				}
				
				if ($SkypeMeetingsEnabled)
				{
					$xmlWriter.WriteElementString('SkypeMeetingsEnabled', $SkypeMeetingsEnabled)
				}
				
				if ($TeamsMeetingsEnabled)
				{
					$xmlWriter.WriteElementString('TeamsMeetingsEnabled', $TeamsMeetingsEnabled)
				}
				
				if ($DualScreenMode)
				{
					$xmlWriter.WriteElementString('DualScreenMode', $DualScreenMode)
				}
				
				if ($SendLogs)
				{
					# Create <SendLogs>
					$xmlWriter.WriteStartElement('SendLogs')
					
					if ($EmailAddressForLogsAndFeedback)
					{
						$xmlWriter.WriteElementString('EmailAddressForLogsAndFeedback', $EmailAddressForLogsAndFeedback)
					}
					
					if ($SendLogsAndFeedback)
					{
						$xmlWriter.WriteElementString('SendLogsAndFeedback', $SendLogsAndFeedback)
					}
					
					# Close </SendLogs>
					$xmlWriter.WriteEndElement()
				}
				
				if ($Devices)
				{
					# Create <Devices>
					$xmlWriter.WriteStartElement('Devices')
					
					if ($MicrophoneForCommunication)
					{
						$xmlWriter.WriteElementString('MicrophoneForCommunication', $MicrophoneForCommunication)
					}
					
					if ($SpeakerForCommunication)
					{
						$xmlWriter.WriteElementString('SpeakerForCommunication', $SpeakerForCommunication)
					}
					
					if ($DefaultSpeaker)
					{
						$xmlWriter.WriteElementString('DefaultSpeaker', $DefaultSpeaker)
					}
					
					if ($ContentCameraId)
					{
						$xmlWriter.WriteElementString('ContentCameraId', $ContentCameraId)
					}
					
					if ($ContentCameraInverted)
					{
						$xmlWriter.WriteElementString('ContentCameraInverted', $ContentCameraInverted)
					}
					
					if ($ContentCameraEnhancement)
					{
						$xmlWriter.WriteElementString('ContentCameraEnhancement', $ContentCameraEnhancement)
					}
					
					# Close </Devices>
					$xmlWriter.WriteEndElement()
				}
				
				if ($ThemeName)
				{
					# Create <Theming>
					$xmlWriter.WriteStartElement('Theming')
					
					if ($ThemeName)
					{
						$xmlWriter.WriteElementString('ThemeName', $ThemeName)
					}
					
					if ($CustomThemeImageUrl)
					{
						$xmlWriter.WriteElementString('CustomThemeImageUrl', $CustomThemeImageUrl)
					}
					
					if (($RedComponent) -or ($GreenComponent) -or ($BlueComponent))
					{
						# Create <CustomThemeColor>
						$xmlWriter.WriteStartElement('CustomThemeColor')
						
						if ($RedComponent)
						{
							$xmlWriter.WriteElementString('RedComponent', $RedComponent)
						}
						
						if ($GreenComponent)
						{
							$xmlWriter.WriteElementString('GreenComponent', $GreenComponent)
						}
						
						if ($BlueComponent)
						{
							$xmlWriter.WriteElementString('BlueComponent', $BlueComponent)
						}
						
						# Close </CustomThemeColor>
						$xmlWriter.WriteEndElement()
					}
					
					# Close </Theming>
					$xmlWriter.WriteEndElement()
				}
				
				# Close </SkypeSettings>
				$xmlWriter.WriteEndElement()
				
				# Save the XML
				$xmlWriter.WriteEndDocument()
				$xmlWriter.Flush()
				$xmlWriter.Close()
			}
			catch
			{
				#region ErrorHandler
				# get error record
				[Management.Automation.ErrorRecord]$e = $_
				
				# retrieve information about runtime error
				$info = [PSCustomObject]@{
					Exception = $e.Exception.Message
					Reason	 = $e.CategoryInfo.Reason
					Target	 = $e.CategoryInfo.TargetName
					Script	 = $e.InvocationInfo.ScriptName
					Line	    = $e.InvocationInfo.ScriptLineNumber
					Column	 = $e.InvocationInfo.OffsetInLine
				}
				
				$info | Out-String | Write-Verbose
				
				Write-Error -Message ($info.Exception) -Exception ($e.Exception) -ErrorAction Stop -WarningAction Continue
				#endregion ErrorHandler
			}
		}
		else
		{
			Write-Verbose -Message 'Nothing to do!!!'
		}
	}
}

function New-MtrWallpaper
{
   <#
         .SYNOPSIS
         Configure a new wallpaper for Microsoft Teams Room (MTR) System

         .DESCRIPTION
         Configure a new wallpaper for Microsoft Teams Room (MTR) System.

         This is done by randomly choosing a supported image file from a folder.

         Wallpaper is then copied to the proper folder, and a corresponding XML file is also written.

         When the system reboots as part of its normal scheduled nightly maintenance,
         the new wallpaper is set for the 'Custom' them in MTR.

         .PARAMETER Path
         Local MTR User root path, as for now this is the same on every MTR device!
         Can be a Share (\\<MTRHostname>\\C$\Users\Skype\AppData\Local\Packages\Microsoft.SkypeRoomSystem_8wekyb3d8bbwe\LocalState),
         if you have more then one MTR or want to do it remotely!

         .PARAMETER Check
         Check if a given Wallpaperfile has the correct resolution

         .PARAMETER RedComponent
         RedComponent for the template
         Default is 100

         .PARAMETER GreenComponent
         GreenComponent for the template
         Default is 100

         .PARAMETER BlueComponent
         BlueComponent for the template
         Default is 100

         .EXAMPLE
         PS C:\> New-MtrWallpaper

         Picks a random image, copies to the root folder, and writes XML file

         .NOTES
         In the code you will find some exaples for more customization. Not scope of this script, but possible.
         Please see: https://docs.microsoft.com/en-us/MicrosoftTeams/room-systems/xml-config-file

         All Images must be exactly 3840×1080, for Single or dual screen!

         If you copy the wallpaper image (wallpaper.jpg), with or without the settings XML,
         to different MTR systems the change will not be activated!
         The MTR doesn't do a reload or check if a file is changed.
         The MTR will reboot every day at 2:30 (AM), then the changes will be activated.

         The MTR support .jpg, .jpeg, .png, and .bmp for wallpapers!

         My version of the script has no enhancements, at least not yet!
         It's just a minor changed version based on the great work of Pat Richard.

         .LINK
         https://www.ucunleashed.com/4323

         .LINK
         https://github.com/patrichard/New-MtrWallpaper

         .LINK
         https://docs.microsoft.com/en-us/MicrosoftTeams/downloads/ThemingTemplateMicrosoftTeamsRooms_v2.1.psd

         .LINK
         https://docs.microsoft.com/en-us/MicrosoftTeams/room-systems/xml-config-file

         .LINK
         https://www.ucit.blog/post/configuring-custom-themes-for-microsoft-teams-skype-room-systems

         .LINK
         https://www.bing.com/images/search?q=wallpaper+3840x1080&qpvt=wallpaper+3840x1080&form=IGRE&first=1&cw=1680&ch=939
   #>
	
	[CmdletBinding(ConfirmImpact = 'None',
						SupportsShouldProcess)]
	param
	(
		[Parameter(ValueFromPipeline,
					  ValueFromPipelineByPropertyName)]
		[ValidateNotNullOrEmpty()]
		[Alias('ThisRoot')]
		[string]
		$Path = "$env:HOMEDRIVE\Users\Skype\AppData\Local\Packages\Microsoft.SkypeRoomSystem_8wekyb3d8bbwe\LocalState",
		[Parameter(ValueFromPipeline,
					  ValueFromPipelineByPropertyName)]
		[switch]
		$Check,
		[Parameter(ValueFromPipeline,
					  ValueFromPipelineByPropertyName)]
		[ValidateRange(0, 255)]
		[Alias('Red')]
		[int]
		$RedComponent = 100,
		[Parameter(ValueFromPipeline,
					  ValueFromPipelineByPropertyName)]
		[ValidateRange(0, 255)]
		[Alias('Green')]
		[int]
		$GreenComponent = 100,
		[Parameter(ValueFromPipeline,
					  ValueFromPipelineByPropertyName)]
		[ValidateRange(0, 255)]
		[Alias('Blue')]
		[int]
		$BlueComponent = 100
	)
	
	begin
	{
		#region Defaults
		$STP = 'Stop'
		$CNT = 'Continue'
		$SCT = 'SilentlyContinue'
		#endregion Defaults
		
		#region Helpers
		
		#endregion Helpers
		
		#region Check
		try
		{
			# Cleanup
			$AllWallpapers = $null
			
			# Get a list of all of the wallpapers to choose from. Wallpaper images MUST be exactly 3840x1080, regardless if the MTR is a single or dual screen system.
			$paramGetChildItem = @{
				Path		   = ($Path + '\Wallpapers')
				ErrorAction = $STP
			}
			$AllWallpapers = (Get-ChildItem @paramGetChildItem | Where-Object -FilterScript {
					$_.Extension -in '.jpg', '.jpeg', '.png', '.bmp'
				} | Select-Object -Property Name, Extension)
			
			# Prevent any futher action if there are no files (wallpapers)
			if (-not ($AllWallpapers))
			{
				# Just in case
				throw
			}
		}
		catch
		{
			# Create the String, just for the error message
			[string]$NewWallpaperPath = ($Path + '\Wallpapers')
			
			Write-Error -Message ('No wallpapers where found in {0}' -f $NewWallpaperPath) -Exception 'No wallpapers where found' -Category ObjectNotFound -RecommendedAction 'Check given path' -ErrorAction $STP
			
			# Just in case
			exit 1
		}
		#endregion Check
	}
	
	process
	{
		# Files to remove
		$FileToCleanup = @(
			'wallpaper.jpg'
			'wallpaper.jpeg'
			'wallpaper.png'
			'wallpaper.bmp'
			'SkypeSettings.xml'
		)
		
		# Default parameters
		$paramRemoveItem = @{
			Force		     = $true
			Confirm		  = $false
			ErrorAction   = $SCT
			WarningAction = $SCT
		}
		
		#region CleanupLoop
		foreach ($item in $FileToCleanup)
		{
			# Build the String
			$CleanupPath = ($Path + '\' + $item)
			
			# Check if the file exists
			if (Get-Item -Path $CleanupPath -ErrorAction $SCT)
			{
				# Add the parameter
				$paramRemoveItem.Path = $CleanupPath
				
				# Remove the File
				$null = (Remove-Item @paramRemoveItem)
			}
			
			# Cleanup
			$paramRemoveItem.Path = $null
			$CleanupPath = $null
		}
		#endregion CleanupLoop
		
      <#
            Pick a random wallpaper
            Keep in mind that the fewer images to choose from,
            the higher the potential to choose the same image that was used last time.
      #>
		$NewWallpaper = (Get-Random -InputObject $AllWallpapers)
		
		#region NewWallpaper
		if ($NewWallpaper)
		{
			# New Variables to support all extensions
			$NewWallpaperName = $NewWallpaper.Name
			$NewWallpaperFilename = ('wallpaper' + $NewWallpaper.Extension)
			
			if ($Check)
			{
				if (Get-Command -Name 'Test-MtrWallpaper')
				{
					if (-not (Test-MtrWallpaper -Path ($Path + '\Wallpapers\' + $NewWallpaperName)))
					{
						Write-Error -Message ('Sorry, but {0} is not in the required resultion!' -f $NewWallpaperName) -Exception 'Wrong resulution' -Category InvalidData -RecommendedAction 'Check resulution' -ErrorAction $STP
						
						# Just in case
						exit 1
					}
				}
				else
				{
					Write-Warning -Message 'Check parameter is given, but the Test-MtrWallpaper is not availible' -ErrorAction Stop -WarningAction Stop
					
					# Just in case
					exit 1
				}
			}
			
			Write-Verbose -Message ('Chosen wallpaper is ' + $Path + '\Wallpapers\' + $NewWallpaperName)
			
			# Copy the chosen wallpaper to the right folder. We rename it to a generic name as a safeguard against improper characters or file names that are too long.
			$paramCopyItem = @{
				Path			  = ($Path + '\Wallpapers\' + $NewWallpaperName)
				Destination   = ($Path + '\' + $NewWallpaperFilename)
				Force		     = $true
				Confirm		  = $false
				ErrorAction   = $CNT
				WarningAction = $CNT
			}
			$null = (Copy-Item @paramCopyItem)
			
			$paramNewObject = @{
				TypeName	    = 'System.XMl.XmlTextWriter'
				ArgumentList = (($Path + '\SkypeSettings.xml'), $null)
			}
			$xmlWriter = (New-Object @paramNewObject)
			
			$xmlWriter.Formatting = 'Indented'
			$xmlWriter.Indentation = 1
			$xmlWriter.IndentChar = "`t"
			
			$xmlWriter.WriteStartDocument()
			$xmlWriter.WriteStartElement('SkypeSettings')
			
			# Theming starts here
			$xmlWriter.WriteStartElement('Theming')
			$xmlWriter.WriteElementString('ThemeName', 'Custom')
			$xmlWriter.WriteElementString('CustomThemeImageUrl', ($Path + '\' + $NewWallpaperFilename))
			$xmlWriter.WriteStartElement('CustomThemeColor')
			
			# Review the Color Settings!
			$xmlWriter.WriteElementString('RedComponent', $RedComponent)
			$xmlWriter.WriteElementString('GreenComponent', $GreenComponent)
			$xmlWriter.WriteElementString('BlueComponent', $BlueComponent)
			
			# Close CustomThemeColor
			$xmlWriter.WriteEndElement()
			
			# Close Theming
			$xmlWriter.WriteEndElement()
			
			# Close SkypeSettings
			$xmlWriter.WriteEndElement()
			
			# Save the XML
			$xmlWriter.WriteEndDocument()
			$xmlWriter.Flush()
			$xmlWriter.Close()
		}
		#endregion NewWallpaper
	}
	
	end
	{
		Write-Verbose -Message ('The new wallpaper is {0}' -f $NewWallpaper)
	}
}

function Test-MtrWallpaper
{
   <#
         .SYNOPSIS
         Check if a given Wallpaperfile has the correct resolution

         .DESCRIPTION
         Check if a given Wallpaperfile has the correct resolution.
         All Images must be exactly 3840×1080, for Single or dual screen!

         .PARAMETER Path
         Wallpaperfile to check (Full path)

         .INPUTS
         String

         .OUTPUTS
         Bool

         .EXAMPLE
         PS C:\> Test-MtrWallpaper -Path 'Z:\Desktop\wallpaper\TheBeachView.jpg'

         True

         .EXAMPLE
         PS C:\> Test-MtrWallpaper -Path 'Z:\Desktop\wallpaper\TheBeachView.jpg'

         False

         .NOTES
         All Images must be exactly 3840×1080, for Single or dual screen!
   #>
	[CmdletBinding(ConfirmImpact = 'None')]
	[OutputType([bool])]
	param
	(
		[Parameter(Mandatory, HelpMessage = 'Wallpaperfile to check (Full path)',
					  ValueFromPipeline,
					  ValueFromPipelineByPropertyName)]
		[ValidateNotNullOrEmpty()]
		[Alias('Wallpaper', 'MTRWallpaper', 'Image')]
		[string]
		$Path
	)
	
	begin
	{
		# Cleanup
		$Check = $null
		
		# Load the Assembly
		$null = (Add-Type -AssemblyName System.Drawing)
	}
	
	process
	{
		# Create the new variable with the Image (Assembly needed)
		$image = [Drawing.Image]::FromFile($Path)
		
		# Do the check
		if (($image.Width -eq '3840') -and ($image.Height -eq '1080'))
		{
			[bool]$Check = $true
		}
		else
		{
			[bool]$Check = $false
		}
	}
	
	end
	{
		return $Check
	}
}

function Get-MtrVideoDeviceInformation
{
   <#
         .SYNOPSIS
         Get information about all attached Video devices
	
         .DESCRIPTION
         Get information about all attached Video devices
	
         .PARAMETER Computer
         The Computer to get the information from, default is the localhost
	
         .PARAMETER DeviceID
         Get the DeviceID attribute of the Video devices.
         Might be useful if you need the ID for the content camera.
	
         .EXAMPLE
         PS C:\> Get-MtrVideoDeviceInformation
	
         .EXAMPLE
         PS C:\> Get-MtrVideoDeviceInformation -Computer 'RanierConf'
	
         .LINK
         https://docs.microsoft.com/en-us/MicrosoftTeams/rooms/rooms-operations
	
         .NOTES
         Initial Version
   #>
	
	[CmdletBinding(ConfirmImpact = 'None')]
	param
	(
		[Parameter(ValueFromPipeline,
					  ValueFromPipelineByPropertyName)]
		[ValidateNotNullOrEmpty()]
		[Alias('MtrDevice')]
		[string]
		$Computer = $env:COMPUTERNAME,
		[Parameter(ValueFromPipeline,
					  ValueFromPipelineByPropertyName)]
		[Alias('VideoDeviceID')]
		[switch]
		$DeviceID
	)
	
	begin
	{
		Write-Verbose -Message "Get VIDEO DEVICES on $env:COMPUTERNAME"
	}
	
	process
	{
		$deviceInfo = (Invoke-Command -ScriptBlock {
				Get-WmiObject -Class Win32_PnPEntity | Where-Object -FilterScript {
					$_.PNPClass -eq 'Image'
				} | Select-Object -Property Name, Status, DeviceID, Present
			} -ComputerName $Computer)
		
		if ($DeviceID)
		{
			$deviceInfo = $deviceInfo | Select-Object -Property Name, Status, DeviceID, Present
		}
		else
		{
			$deviceInfo = $deviceInfo | Select-Object -Property Name, Status, Present
		}
	}
	
	end
	{
		$deviceInfo
	}
}

function Get-MtrAudioDeviceInformation
{
   <#
         .SYNOPSIS
         Get information about all attached Audio devices
	
         .DESCRIPTION
         Get information about all attached Audio devices
	
         .PARAMETER Computer
         The Computer to get the information from, default is the localhost
	
         .EXAMPLE
         PS C:\> Get-MtrAudioDeviceInformation
	
         .EXAMPLE
         PS C:\> Get-MtrAudioDeviceInformation -Computer 'RanierConf'
	
         .LINK
         https://docs.microsoft.com/en-us/MicrosoftTeams/rooms/rooms-operations
	
         .NOTES
         Initial Version
   #>
	
	[CmdletBinding(ConfirmImpact = 'None')]
	param
	(
		[Parameter(ValueFromPipeline,
					  ValueFromPipelineByPropertyName)]
		[ValidateNotNullOrEmpty()]
		[Alias('MtrDevice')]
		[string]
		$Computer = $env:COMPUTERNAME
	)
	
	begin
	{
		Write-Verbose -Message "Get AUDIO DEVICES on $env:COMPUTERNAME"
	}
	
	process
	{
		$deviceInfo = (Invoke-Command -ScriptBlock {
				Get-WmiObject -Class Win32_PnPEntity | Where-Object -FilterScript {
					$_.PNPClass -eq 'Media'
				} | Select-Object -Property Name, Status, Present
			} -ComputerName $Computer)
	}
	
	end
	{
		$deviceInfo
	}
}

function Get-MtrDisplayDeviceInformation
{
   <#
         .SYNOPSIS
         Get information about all attached Display devices
	
         .DESCRIPTION
         Get information about all attached Display devices
	
         .PARAMETER Computer
         The Computer to get the information from, default is the localhost
	
         .EXAMPLE
         PS C:\> Get-MtrDisplayDeviceInformation
	
         .EXAMPLE
         PS C:\> Get-MtrDisplayDeviceInformation -Computer 'RanierConf'
	
         .LINK
         https://docs.microsoft.com/en-us/MicrosoftTeams/rooms/rooms-operations
	
         .NOTES
         Initial Version
   #>
	
	[CmdletBinding(ConfirmImpact = 'None')]
	param
	(
		[Parameter(ValueFromPipeline,
					  ValueFromPipelineByPropertyName)]
		[ValidateNotNullOrEmpty()]
		[Alias('MtrDevice')]
		[string]
		$Computer = $env:COMPUTERNAME
	)
	
	begin
	{
		Write-Verbose -Message "Get DISPLAY DEVICES on $env:COMPUTERNAME"
	}
	
	process
	{
		$deviceInfo = (Invoke-Command -ScriptBlock {
				Get-WmiObject -Class Win32_PnPEntity | Where-Object -FilterScript {
					$_.PNPClass -eq 'Monitor'
				} | Select-Object -Property Name, Status, Present
			} -ComputerName $Computer)
	}
	
	end
	{
		$deviceInfo
	}
}

function Get-MtrAppStatus
{
   <#
         .SYNOPSIS
         Get information about the Teams Room App Status
	
         .DESCRIPTION
         Get information about the Teams Room App Status
	
         .PARAMETER Computer
         The Computer to get the information from, default is the localhost
	
         .EXAMPLE
         PS C:\> Get-MtrAppStatus
	
         .EXAMPLE
         PS C:\> Get-MtrAppStatus -Computer 'RanierConf'
	
         .LINK
         https://docs.microsoft.com/en-us/MicrosoftTeams/rooms/rooms-operations
	
         .NOTES
         Initial Version
   #>
	
	[CmdletBinding(ConfirmImpact = 'None')]
	param
	(
		[Parameter(ValueFromPipeline,
					  ValueFromPipelineByPropertyName)]
		[ValidateNotNullOrEmpty()]
		[Alias('MtrDevice')]
		[string]
		$Computer = $env:COMPUTERNAME
	)
	
	begin
	{
		Write-Verbose -Message "Get Teams Room App Status on $env:COMPUTERNAME"
	}
	
	process
	{
		$deviceInfo = (Invoke-Command -ScriptBlock {
				# Just in case... Newer version might get a new name
				$MtrName = 'Microsoft.SkypeRoomSystem'
				
				$package = (Get-AppxPackage -User Skype -Name $MtrName -ErrorAction SilentlyContinue)
				
				if ($package -eq $null)
				{
					Write-Output -InputObject 'The Microsoft Teams Room Systems App is not installed.'
				}
				else
				{
					Write-Output -InputObject 'Microsoft Teams Room Systems App: ', $package.Version
				}
				
				$process = (Get-Process -Name $MtrName -ErrorAction SilentlyContinue)
				
				if ($process -eq $null)
				{
					Write-Output -InputObject 'Microsoft Teams Room Systems App is not running.'
				}
				else
				{
					$process | Select-Object -Property StartTime, Responding
				}
			} -ComputerName $Computer)
	}
	
	end
	{
		$deviceInfo
	}
}

function Get-MtrSystemInfo
{
   <#
         .SYNOPSIS
         Get System information about the the Microsoft Teams Room Device
	
         .DESCRIPTION
         Get System information about the the Microsoft Teams Room Device.
         Should work on any device.
	
         .PARAMETER Computer
         The Computer to get the information from, default is the localhost
	
         .EXAMPLE
         PS C:\> Get-MtrSystemInfo
	
         .EXAMPLE
         PS C:\> Get-MtrSystemInfo -Computer 'RanierConf'
	
         .LINK
         https://docs.microsoft.com/en-us/MicrosoftTeams/rooms/rooms-operations
	
         .NOTES
         Initial Version, need some care for the return (output)
   #>
	
	[CmdletBinding(ConfirmImpact = 'None')]
	param
	(
		[Parameter(ValueFromPipeline,
					  ValueFromPipelineByPropertyName)]
		[ValidateNotNullOrEmpty()]
		[Alias('MtrDevice')]
		[string]
		$Computer = $env:COMPUTERNAME
	)
	
	begin
	{
		Write-Verbose -Message "Get Teams Room System Info on $env:COMPUTERNAME"
	}
	
	process
	{
		$deviceInfo = (Invoke-Command -ScriptBlock {
				$deviceInfolocal = @()
				$deviceInfolocal += (Get-WmiObject -Class Win32_ComputerSystem | Select-Object -Property PartOfDomain, Domain, Workgroup, Manufacturer, Model)
				$deviceInfolocal += (Get-WmiObject -Class Win32_Bios | Select-Object -Property SerialNumber, SMBIOSBIOSVersion)
				$deviceInfolocal
			})
	}
	
	end
	{
		$deviceInfo
	}
}

function Confirm-MtrDirectoryStructure
{
   <#
         .SYNOPSIS
         Create the Wallpapers folder within the MTR local state directory
	
         .DESCRIPTION
         Create the Wallpapers folder within the MTR local state directory
	
         .EXAMPLE
         PS C:\> Confirm-MtrDirectoryStructure
	
         Create the Wallpapers folder within the MTR local state directory
	
         .NOTES
         Initial Version
   #>
	[CmdletBinding(ConfirmImpact = 'None')]
	param ()
	
	# Check if the local user exists. MTR still use the user SKYPE!
	if (Get-LocalUser -Name Skype -ErrorAction SilentlyContinue)
	{
		# Set the Directory Variable
		$TargetDirectory = "$env:HOMEDRIVE\Users\Skype\AppData\Local\Packages\Microsoft.SkypeRoomSystem_8wekyb3d8bbwe\LocalState\Wallpapers"
		
		# Does the directory exist?
		if (-not (Test-Path -Path $TargetDirectory -ErrorAction SilentlyContinue))
		{
			$null = (New-Item -ItemType Directory -Force -Path $TargetDirectory -Confirm:$false -ErrorAction Stop)
		}
		else
		{
			Write-Output -InputObject 'The Wallpapers folder exists in the MTR local state directory.'
		}
	}
	else
	{
		Write-Warning -Message 'The local user SKYPE does not exist! Is this an Microsoft Teams Room Device?' -WarningAction Stop
		
		# Just in case
		exit 1
	}
}

function Invoke-mtrDisableModernAuthentication
{
   <#
         .SYNOPSIS
         Disable Modern Authentication for a Microsoft Teams Room Device Account

         .DESCRIPTION
         Disable Modern Authentication for a Microsoft Teams Room Device Account
         It dsables it in Exchange Online and Skype for Business Online. It also configures the tenant to do so, if needed.

         .PARAMETER Identity
         The Microsoft Teams Rooms (MTR) Account Search String

         .EXAMPLE
         PS C:\> .\Invoke-mtrDisableModernAuthentication.ps1 -Identity 'MyTeamRoom'

         .EXAMPLE
         PS C:\> .\Invoke-mtrDisableModernAuthentication.ps1 -Identity 'TeamRoom@contoso.com'

         .NOTES
         Just a quick and dirty tool to do the job, nothing fancy and without a real error handling!
         -> Use at your own risk!

         You need to be a tenant admin to configure all the things
   #>
	[CmdletBinding(ConfirmImpact = 'Low')]
	param
	(
		[Parameter(Mandatory, HelpMessage = 'The Microsoft Teams Rooms (MTR) Account Search String',
					  ValueFromPipeline,
					  ValueFromPipelineByPropertyName,
					  Position = 0)]
		[ValidateNotNullOrEmpty()]
		[Alias('SearchString', 'mtrAccount')]
		[string]
		$Identity
	)
	
	begin
	{
		#region Defaults
		$STP = 'Stop'
		$SCT = 'SilentlyContinue'
		#endregion Defaults
		
		#region GeneralParameters
		$RemovePSSessionDefaultParams = @{
			Confirm	   = $false
			ErrorAction = $SCT
		}
		
		$RemoveModuleDefaultParams = @{
			Force		   = $true
			Confirm	   = $false
			ErrorAction = $SCT
		}
		#endregion GeneralParameters
		
		Write-Verbose -Message 'Message'
	}
	
	process
	{
		#region ConnectAzureAD
		$null = (Connect-AzureAD)
		#endregion ConnectAzureAD
		
		#region ConnectSkypeForBusinessOnline
		# We use a crappy workaround, because the Modern Auth window never shows up to querry the admin UPN, and I do NOT trust the command to querry it
		$SkypeForBusinessSession = (New-CsOnlineSession -UserName (Read-Host -Prompt 'Please enter the admin principal name (ex. admin@contoso.com)'))
		$paramImportPSSession = @{
			Session				  = $SkypeForBusinessSession
			DisableNameChecking = $true
			AllowClobber		  = $true
		}
		$null = (Import-PSSession @paramImportPSSession)
		#endregion ConnectSkypeForBusinessOnline
		
		#region ConnectExchangeOnline
		# We use the ExchangeOnlineShell Module from the Gallery
		if (-not (Get-Command -Name Get-Mailbox -ErrorAction $SCT))
		{
			$paramConnectExchangeOnlineShell = @{
				Confirm		  = $false
				WarningAction = $SCT
				ErrorAction   = $STP
			}
			$null = (Connect-ExchangeOnlineShell @paramConnectExchangeOnlineShell)
		}
		#endregion ConnectExchangeOnline
		
		#region CheckModernAuth
		# Do we have Modern Auth enabled Global?
		if ((Get-OrganizationConfig | Select-Object -ExpandProperty OAuth2ClientProfileEnabled) -eq $true)
		{
			# Disconnect Modern Authentication (For a single user) - In this case the MTR
			$paramRevokeAzureADUserAllRefreshToken = @{
				ObjectId = (Get-AzureADUser -SearchString $Identity | Select-Object -ExpandProperty objectId)
				ErrorAction = $SCT
			}
			$null = (Revoke-AzureADUserAllRefreshToken @paramRevokeAzureADUserAllRefreshToken)
			$null = (Revoke-AzureADUserAllRefreshToken @paramRevokeAzureADUserAllRefreshToken)
			
			# Allow non Modern Auth in Skype for Business
			if ((Get-CsOAuthConfiguration -ErrorAction $SCT | Select-Object -ExpandProperty ClientAdalAuthOverride) -ne 'Allowed')
			{
				$paramSetCsOAuthConfiguration = @{
					ClientAdalAuthOverride = 'Allowed'
					Confirm					  = $false
					ErrorAction            = $SCT
				}
				$null = (Set-CsOAuthConfiguration @paramSetCsOAuthConfiguration)
			}
		}
		else
		{
			# Shame on you!
			Write-Warning -Message 'Looks like Modern Auth is not enabled for this tenant!' -WarningAction $STP
		}
		#endregion CheckModernAuth
		
		#region DisconnectAzureAD
		$null = (Disconnect-AzureAD -Confirm:$false -ErrorAction $SCT)
		#endregion DisconnectAzureAD
		
		#region DisconnectSkypeForBusiness
		$paramRemoveModule = @{
			Name = (Get-Command -Name Set-CsOAuthConfiguration -ErrorAction $SCT | Select-Object -ExpandProperty Source)
			Force = $true
			ErrorAction = $SCT
		}
		
		$null = (Remove-Module @paramRemoveModule)
		$null = ($SkypeForBusinessSession.Id | Remove-PSSession @RemovePSSessionDefaultParams)
		#endregion DisconnectSkypeForBusiness
		
		#region DisconnectExchangeOnline
		$ExchangeSessionID = (Get-PSSession | Where-Object {
				$_.ComputerName -eq 'outlook.office365.com'
			} | Select-Object -ExpandProperty Id)
		
		if ($ExchangeSessionID)
		{
			$paramDisconnectExchangeOnlineShell = @{
				SessionID = $ExchangeSessionID
				Confirm   = $false
			}
			$null = (Disconnect-ExchangeOnlineShell @paramDisconnectExchangeOnlineShell)
		}
		
		# Will be removed soon (Disconnect-ExchangeOnlineShell will handle this for us!)
		$RemoveModuleName = (Get-Command -Name Get-OrganizationConfig -ErrorAction $SCT | Select-Object -ExpandProperty Source)
		
		if ($RemoveModuleName)
		{
			$paramRemoveModule = @{
				Name		   = $RemoveModuleName
				Force		   = $true
				ErrorAction = $SCT
			}
			$null = (Remove-Module @RemoveModuleDefaultParams)
		}
		#endregion DisconnectExchangeOnline
	}
	
	end
	{
		#region FinalCleanup
		# Just in case: We remove all sessions that might still be around
		$null = ((Get-PSSession -ErrorAction $SCT | Where-Object {
					$_.ComputerName -eq 'outlook.office365.com'
				}) | Remove-PSSession @RemovePSSessionDefaultParams)
		
		$null = ((Get-PSSession -ErrorAction $SCT | Where-Object {
					$_.ComputerName -like 'admin*.online.lync.com'
				}) | Remove-PSSession @RemovePSSessionDefaultParams)
		
		# Remove the Modules (Here just in case we missed something above)
		$null = (Remove-Module -Name (Get-Command -Name Connect-ExchangeOnlineShell -ErrorAction $SCT | Select-Object -ExpandProperty Source) @RemoveModuleDefaultParams)
		$null = (Remove-Module -Name (Get-Command -Name Disconnect-AzureAD -ErrorAction $SCT | Select-Object -ExpandProperty Source) @RemoveModuleDefaultParams)
		$null = (Remove-Module -Name (Get-Command -Name New-CsOnlineSession -ErrorAction $SCT | Select-Object -ExpandProperty Source) @RemoveModuleDefaultParams)
		#endregion FinalCleanup
	}
}
