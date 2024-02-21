# Remediation-UptimeToLong

# Dont't display the progress bar
$ProgressPreference = 'SilentlyContinue'

#region InternalFunctions
function Invoke-DisplayToastNotification()
{
   <#
         .SYNOPSIS
         Very simple Display Toast Notification function

         .DESCRIPTION
         Very simple Display Toast Notification function

         .EXAMPLE
         Invoke-DisplayToastNotification
         Very simple Display Toast Notification function,
         all the data must exist in the matching variables

         .NOTES
         Simple function, all parameters are parsed as they are
   #>

   process
   {
      try
      {
         $null = (Add-Type -AssemblyName Windows.Data -ErrorAction SilentlyContinue)
      }
      catch
      {
         Write-Verbose -Message 'Whoopsie'
      }
      try
      {
         $null = (Add-Type -AssemblyName Windows.UI -ErrorAction SilentlyContinue)
      }
      catch
      {
         Write-Verbose -Message 'Whoopsie'
      }

      $null = [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]
      $null = [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime]

      # Load the notification into the required format
      $ToastXML = (New-Object -TypeName Windows.Data.Xml.Dom.XmlDocument)
      $ToastXML.LoadXml($Toast.OuterXml)

      # Display the toast notification
      try
      {
         [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($App).Show($ToastXML)
      }
      catch
      {
         Write-Warning -Message 'Something went wrong when displaying the toast notification'
         Write-Warning -Message 'Make sure the script is running as the logged on user'
      }
   }
}
#endregion InternalFunctions

# Setting image variables
$HeroImageUri = 'https://cdn.enatec.net/assets/img/enablingTechnology.png'
$HeroImage = "$env:TEMP\ToastHeroImage.png"
$Uptime = (Get-ComputerInfo | Select-Object -ExpandProperty OSUptime -ErrorAction SilentlyContinue)

# Fetching image from URI
$null = (Invoke-WebRequest -Uri $HeroImageUri -OutFile $HeroImage -ErrorAction SilentlyContinue)

# Defining the Toast notification settings
# ToastNotification Settings
$Scenario = 'reminder' # <!-- Possible values are: reminder | short | long -->

# Load Toast Notification text
$AttributionText = "`nenabling Technology"
$HeaderText = 'Computer Restart is needed!'
$TitleText = ('Your device has not performed a reboot the last {0} days' -f $Uptime.Days)
$BodyText1 = 'For performance and stability reasons we suggest a reboot at least once a week.'
$BodyText2 = 'Please save your work and restart your device today. Thank you in advance.'

# Check for required entries in registry for when using PowerShell as application for the toast
# Register the AppID in the registry for use with the Action Center, if required
$RegPath = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings'
$App = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'

# Creating registry entries if they don't exists
if (!(Test-Path -Path ('{0}\{1}' -f $RegPath, $App) -ErrorAction SilentlyContinue))
{
   $null = (New-Item -Path ('{0}\{1}' -f $RegPath, $App) -Force -Confirm:$false -ErrorAction SilentlyContinue)
   $null = (New-ItemProperty -Path ('{0}\{1}' -f $RegPath, $App) -Name 'ShowInActionCenter' -Value 1 -PropertyType 'DWORD' -Force -Confirm:$false -ErrorAction SilentlyContinue)
}

# Make sure the app used with the action center is enabled
if ((Get-ItemProperty -Path ('{0}\{1}' -f $RegPath, $App) -Name 'ShowInActionCenter' -ErrorAction SilentlyContinue).ShowInActionCenter -ne '1')
{
   $null = (New-ItemProperty -Path ('{0}\{1}' -f $RegPath, $App) -Name 'ShowInActionCenter' -Value 1 -PropertyType 'DWORD' -Force -Confirm:$false -ErrorAction SilentlyContinue)
}

# No function, just close it
$DismissButtonContent = $null

# Formatting the toast notification XML
[xml]$Toast = (@'
<toast scenario="{0}">
    <visual>
    <binding template="ToastGeneric">
        <image placement="hero" src="{1}"/>

        <text placement="attribution">{2}</text>
        <text>{3}</text>
        <group>
            <subgroup>
                <text hint-style="title" hint-wrap="true" >{4}</text>
            </subgroup>
        </group>
        <group>
            <subgroup>
                <text hint-style="body" hint-wrap="true" >{5}</text>
            </subgroup>
        </group>
        <group>
            <subgroup>
                <text hint-style="body" hint-wrap="true" >{6}</text>
            </subgroup>
        </group>
    </binding>
    </visual>
    <actions>
        <action activationType="system" arguments="dismiss" content="{7}"/>
    </actions>
</toast>
'@ -f $Scenario, $HeroImage, $AttributionText, $HeaderText, $TitleText, $BodyText1, $BodyText2, $DismissButtonContent)

# Send the notification
Invoke-DisplayToastNotification

# wait until the message unfolds
Start-Sleep -Seconds 1

# remove the downloaded file
$null = (Remove-Item -Path $HeroImage -Force -Confirm:$false -ErrorAction SilentlyContinue)

# Let us go away
Exit 0