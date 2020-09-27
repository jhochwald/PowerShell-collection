#requires -Version 3.0 -Modules BitsTransfer, CimCmdlets -RunAsAdministrator
<#
      .SYNOPSIS
      Automate the driver update process

      .DESCRIPTION
      Automate the driver update process for Dell, HP and Lenovo devices

      .NOTES
      This script will determine the model of the computer,
      manufacturer and operating system used then download,
      extract & install the latest driver package from the manufacturer.

      At present Dell, HP and Lenovo devices are supported.

      Based on Invoke-MSIntuneDriverUpdate.ps1 1.0.2 by Maurice Daly (@MoDaly_IT)
#>
[CmdletBinding(ConfirmImpact = 'None')]
param ()

begin
{
   #region
   $SCT = 'SilentlyContinue'
   $STP = 'Stop'
   #endregion

   #region
   $paramJoinPath = @{
      Path		   = $env:SystemDrive
      ChildPath   = 'Install\SCConfigMgr'
      ErrorAction = $STP
   }
   $TempLocation = (Join-Path @paramJoinPath)
	
   # Set Temp & Log Location
   $paramJoinPath = @{
      Path		   = $TempLocation
      ChildPath   = '\Install'
      ErrorAction = $STP
   }
   [string]$TempDirectory = (Join-Path @paramJoinPath)
	
   $paramJoinPath = @{
      Path		   = $env:SystemDrive
      ChildPath   = '\Temp\SCConfigMgr'
      ErrorAction = $STP
   }
   [string]$LogDirectory = (Join-Path @paramJoinPath)

   # Create Temp Folder 
   $paramTestPath = @{
      Path = $TempDirectory
      ErrorAction = $SCT
   }
   if (-not (Test-Path @paramTestPath))
   {
      $paramNewItem = @{
         Path		   = $TempDirectory
         ItemType	   = 'Dir'
         Force		   = $true
         Confirm	   = $false
         ErrorAction = $STP
      }
      $null = (New-Item @paramNewItem)
   }
	
   $paramPushLocation = @{
      Path		   = $TempLocation
      ErrorAction = $SCT
   }
   $null = (Push-Location @paramPushLocation)
	
   # Create Logs Folder 
   if (-not (Test-Path -Path $LogDirectory))
   {
      $paramNewItem = @{
         Path		   = $LogDirectory
         ItemType	   = 'Dir'
         Force		   = $true
         Confirm	   = $false
         ErrorAction = $STP
      }
      $null = (New-Item @paramNewItem)
   }
   #endregion

   # Logging Function
   function Write-CMLogEntry
   {
      <#
            .SYNOPSIS
            Describe purpose of "Write-CMLogEntry" in 1-2 sentences.

            .DESCRIPTION
            Add a more complete description of what the function does.

            .PARAMETER Value
            Describe parameter -Value.

            .PARAMETER Severity
            Describe parameter -Severity.

            .PARAMETER FileName
            Describe parameter -FileName.

            .EXAMPLE
            Write-CMLogEntry -Value Value -Severity Value -FileName Value
            Describe what this call does

            .NOTES
            Place additional notes here.

            .LINK
            URLs to related sites
            The first link is opened by Get-Help -Online Write-CMLogEntry

            .INPUTS
            List of input types that are accepted by this function.

            .OUTPUTS
            List of output types produced by this function.
      #>


      [CmdletBinding(ConfirmImpact = 'None')]
      param (
         [parameter(Mandatory, HelpMessage = 'Value added to the log file.')]
         [ValidateNotNullOrEmpty()]
         [string]
         $Value,
         [parameter(Mandatory, HelpMessage = 'Severity for the log entry. 1 for Informational, 2 for Warning and 3 for Error.')]
         [ValidateNotNullOrEmpty()]
         [ValidateSet('1', '2', '3')]
         [string]
         $Severity,
         [ValidateNotNullOrEmpty()]
         [string]
         $FileName = 'Invoke-MSIntuneDriverUpdate.log'
      )
		
      begin
      {
         # Determine log file location
         $STP = 'Stop'
         $paramJoinPath = @{
            Path		   = $LogDirectory
            ChildPath   = $FileName
            ErrorAction = $STP
         }
         $LogFilePath = (Join-Path @paramJoinPath)
			
         # Construct time stamp for log entry
         $Time = -join @((Get-Date -Format 'HH:mm:ss.fff'), '+', (Get-WmiObject -Class Win32_TimeZone | Select-Object -ExpandProperty Bias))
			
         # Construct date for log entry
         $Date = (Get-Date -Format 'MM-dd-yyyy')
			
         # Construct context for log entry
         $Context = ([Security.Principal.WindowsIdentity]::GetCurrent().Name)
			
         # Construct final log entry
         $LogText = ('<![LOG[{0}]LOG]!><time=""{1}"" date=""{2}"" component=""DriverAutomationScript"" context=""{3}"" type=""{4}"" thread=""{5}"" file="""">' -f ($Value), ($Time), ($Date), ($Context), ($Severity), ($PID))
      }
		
      process
      {
         # Add value to log file
         try
         {
            $paramAddContent = @{
               Value		   = $LogText
               LiteralPath = $LogFilePath
               Force		   = $true
               ErrorAction = $STP
            }
            $null = (Add-Content @paramAddContent)
         }
         catch
         {
            Write-Warning -Message ('Unable to append log entry to Invoke-DriverUpdate.log file. Error message: {0}' -f $_.Exception.Message)
         }
      }
   }
	
   # Define Dell Download Sources
   $DellDownloadList = 'http://downloads.dell.com/published/Pages/index.html'
   $DellDownloadBase = 'http://downloads.dell.com'
   $DellDriverListURL = 'http://en.community.dell.com/techcenter/enterprise-client/w/wiki/2065.dell-command-deploy-driver-packs-for-enterprise-client-os-deployment'
   $DellBaseURL = 'http://en.community.dell.com'
	
   # Define Dell Download Sources
   $DellXMLCabinetSource = 'http://downloads.dell.com/catalog/DriverPackCatalog.cab'
   $DellCatalogSource = 'http://downloads.dell.com/catalog/CatalogPC.cab'
	
   # Define Dell Cabinet/XL Names and Paths
   $DellCabFile = [string]($DellXMLCabinetSource | Split-Path -Leaf)
   $DellCatalogFile = [string]($DellCatalogSource | Split-Path -Leaf)
   $DellXMLFile = $DellCabFile.Trim('.cab')
   $DellXMLFile = $DellXMLFile + '.xml'
   $DellCatalogXMLFile = $DellCatalogFile.Trim('.cab') + '.xml'
	
   # Define Dell Global Variables
   $DellCatalogXML = $null
   $DellModelXML = $null
   $DellModelCabFiles = $null
	
   # Define HP Download Sources
   $HPXMLCabinetSource = 'http://ftp.hp.com/pub/caps-softpaq/cmit/HPClientDriverPackCatalog.cab'
   $HPSoftPaqSource = 'http://ftp.hp.com/pub/softpaq/'
   $HPPlatFormList = 'http://ftp.hp.com/pub/caps-softpaq/cmit/imagepal/ref/platformList.cab'
	
   # Define HP Cabinet/XL Names and Paths
   $HPCabFile = [string]($HPXMLCabinetSource | Split-Path -Leaf)
   $HPXMLFile = $HPCabFile.Trim('.cab')
   $HPXMLFile = $HPXMLFile + '.xml'
   $HPPlatformCabFile = [string]($HPPlatFormList | Split-Path -Leaf)
   $HPPlatformXMLFile = $HPPlatformCabFile.Trim('.cab')
   $HPPlatformXMLFile = $HPPlatformXMLFile + '.xml'
	
   # Define HP Global Variables
   $HPModelSoftPaqs = $null
   $HPModelXML = $null
   $HPPlatformXML = $null
	
   # Define Lenovo Download Sources
   $script:LenovoXMLSource = 'https://download.lenovo.com/cdrt/td/catalog.xml'
	
   # Define Lenovo Cabinet/XL Names and Paths
   $script:LenovoXMLFile = [string]($global:LenovoXMLSource | Split-Path -Leaf)
	
   # Define Lenovo Global Variables
   $LenovoModelDrivers = $null
   $LenovoModelXML = $null
   $LenovoModelType = $null
   $LenovoSystemSKU = $null
	
   # Determine manufacturer
   $ComputerManufacturer = ((Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty Manufacturer).Trim())
	
   Write-CMLogEntry -Value ('Manufacturer determined as: ' + $ComputerManufacturer) -Severity 1
	
   # Determine manufacturer name and hardware information
   switch -Wildcard ($ComputerManufacturer)
   {
      '*HP*' 
      {
         $ComputerManufacturer = 'Hewlett-Packard'
         $ComputerModel = (Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty Model)
         $SystemSKU = ((Get-CimInstance -ClassName MS_SystemInformation -NameSpace root\WMI).BaseBoardProduct)
      }
      '*Hewlett-Packard*' 
      {
         $ComputerManufacturer = 'Hewlett-Packard'
         $ComputerModel = (Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty Model)
         $SystemSKU = ((Get-CimInstance -ClassName MS_SystemInformation -NameSpace root\WMI).BaseBoardProduct)
      }
      '*Dell*' 
      {
         $ComputerManufacturer = 'Dell'
         $ComputerModel = (Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty Model)
         $SystemSKU = ((Get-CimInstance -ClassName MS_SystemInformation -NameSpace root\WMI).SystemSku)
      }
      '*Lenovo*' 
      {
         $ComputerManufacturer = 'Lenovo'
         $ComputerModel = (Get-WmiObject -Class Win32_ComputerSystemProduct | Select-Object -ExpandProperty Version)
         $SystemSKU = (((Get-CimInstance -ClassName MS_SystemInformation -NameSpace root\WMI | Select-Object -ExpandProperty BIOSVersion).SubString(0, 4)).Trim())
      }
   }
	
   Write-CMLogEntry -Value ('Computer model determined as: ' + $ComputerModel) -Severity 1
	
   if (-not [string]::IsNullOrEmpty($SystemSKU))
   {
      Write-CMLogEntry -Value ('Computer SKU determined as: ' + $SystemSKU) -Severity 1
   }
	
   # Get operating system name from version
   switch -wildcard (Get-WmiObject -Class Win32_OperatingSystem | Select-Object -ExpandProperty Version)
   {
      '10.0*' 
      {
         $OSName = 'Windows 10'
      }
      '6.3*' 
      {
         $OSName = 'Windows 8.1'
      }
      '6.1*' 
      {
         $OSName = 'Windows 7'
      }
   }
	
   Write-CMLogEntry -Value ('Operating system determined as: ' + $OSName) -Severity 1
	
   # Get operating system architecture
   switch -wildcard ((Get-CimInstance -ClassName Win32_operatingsystem).OSArchitecture)
   {
      '64-*' 
      {
         $OSArchitecture = '64-Bit'
      }
      '32-*' 
      {
         $OSArchitecture = '32-Bit'
      }
   }
	
   Write-CMLogEntry -Value ('Architecture determined as: ' + $OSArchitecture) -Severity 1
	
   $WindowsVersion = ($OSName).Split(' ')[1]
	
   function DownloadDriverList
   {
      <#
            .SYNOPSIS
            Describe purpose of "DownloadDriverList" in 1-2 sentences.

            .DESCRIPTION
            Add a more complete description of what the function does.

            .EXAMPLE
            DownloadDriverList
            Describe what this call does

            .NOTES
            Place additional notes here.

            .LINK
            URLs to related sites
            The first link is opened by Get-Help -Online DownloadDriverList

            .INPUTS
            List of input types that are accepted by this function.

            .OUTPUTS
            List of output types produced by this function.
      #>


      [CmdletBinding(ConfirmImpact = 'None')]
      param ()
		
      begin
      {
         Write-CMLogEntry -Value '======== Download Model Link Information ========' -Severity 1
      }
		
      process
      {
         if ($ComputerManufacturer -eq 'Hewlett-Packard')
         {
            $paramTestPath = @{
               Path		   = ($TempDirectory + '\' + $HPCabFile)
               ErrorAction = 'SilentlyContinue'
            }
            if ((Test-Path @paramTestPath ) -eq $false)
            {
               Write-CMLogEntry -Value '======== Downloading HP Product List ========' -Severity 1
               Write-CMLogEntry -Value ('Info: Downloading HP driver pack cabinet file from {0}' -f $HPXMLCabinetSource) -Severity 1
					
               try
               {
                  $paramStartBitsTransfer = @{
                     Source		   = $HPXMLCabinetSource
                     Destination	   = $TempDirectory
                     Priority		   = 'High'
                     TransferPolicy = 'Always'
                     Confirm		   = $false
                  }
                  $null = (Start-BitsTransfer @paramStartBitsTransfer)
						
                  Write-CMLogEntry -Value ('Info: Expanding HP driver pack cabinet file: {0}' -f $HPXMLFile) -Severity 1
						
                  $null = (& "$env:windir\system32\expand.exe" ($TempDirectory + '\' + $HPCabFile + ' -F:* ' + $TempDirectory + '\' + $HPXMLFile))
               }
               catch
               {
                  Write-CMLogEntry -Value ('Error: {0}' -f $_.Exception.Message) -Severity 3
               }
            }
            # Read XML File
            if (-not ($HPModelSoftPaqs))
            {
               Write-CMLogEntry -Value ('Info: Reading driver pack XML file - ' + $TempDirectory + '\' + $HPXMLFile) -Severity 1
					
               $paramGetContent = @{
                  Path		   = ($TempDirectory + '\' + $HPXMLFile)
                  Force		   = $true
                  Encoding	   = 'UTF8'
                  ErrorAction = 'Continue'
               }
               [xml]$script:HPModelXML = (Get-Content @paramGetContent)
               # Set XML Object
               $null = ($HPModelXML.GetType().FullName)
               $script:HPModelSoftPaqs = $HPModelXML.NewDataSet.HPClientDriverPackCatalog.ProductOSDriverPackList.ProductOSDriverPack
            }
         }
			
         if ($ComputerManufacturer -eq 'Dell')
         {
            $paramTestPath = @{
               Path		   = ($TempDirectory + '\' + $DellCabFile)
               ErrorAction = 'SilentlyContinue'
            }
            if (-not (Test-Path @paramTestPath))
            {
               Write-CMLogEntry -Value 'Info: Downloading Dell product list' -Severity 1
               Write-CMLogEntry -Value ('Info: Downloading Dell driver pack cabinet file from {0}' -f $DellXMLCabinetSource) -Severity 1
					
               # Download Dell Model Cabinet File
               try
               {
                  $paramStartBitsTransfer = @{
                     Source		   = $DellXMLCabinetSource
                     Destination	   = $TempDirectory
                     Confirm		   = $false
                     TransferPolicy = 'Always'
                     Priority		   = 'High'
                     ErrorAction	   = 'Stop'
                  }
                  $null = (Start-BitsTransfer @paramStartBitsTransfer)
						
                  # Expand Cabinet File
                  Write-CMLogEntry -Value ('Info: Expanding Dell driver pack cabinet file: {0}' -f $DellXMLFile) -Severity 1
						
                  $null = (& "$env:windir\system32\expand.exe" ($TempDirectory + '\' + $DellCabFile + ' -F:* ' + $TempDirectory + '\' + $DellXMLFile))
               }
               catch
               {
                  Write-CMLogEntry -Value ('Error: {0}' -f $_.Exception.Message) -Severity 3
               }
            }
				
            if (-not ($DellModelXML))
            {
               # Read XML File
               Write-CMLogEntry -Value ('Info: Reading driver pack XML file - ' + $TempDirectory + '\' + $DellXMLFile) -Severity 1
					
               $paramGetContent = @{
                  Path		   = ($TempDirectory + '\' + $DellXMLFile)
                  Force		   = $true
                  Encoding	   = 'UTF8'
                  ErrorAction = 'Continue'
               }
               [xml]$DellModelXML = (Get-Content @paramGetContent)
               # Set XML Object
               $null = ($DellModelXML.GetType().FullName)
            }
            $DellModelCabFiles = $DellModelXML.driverpackmanifest.driverpackage
         }
			
         if ($ComputerManufacturer -eq 'Lenovo')
         {
            if (-not ($LenovoModelDrivers))
            {
               try
               {
                  $paramInvokeWebRequest = @{
                     Uri		   = $LenovoXMLSource
                     ErrorAction = 'Stop'
                  }
                  [xml]$script:LenovoModelXML = (Invoke-WebRequest @paramInvokeWebRequest)
               }
               catch
               {
                  Write-CMLogEntry -Value ('Error: {0}' -f $_.Exception.Message) -Severity 3
               }
					
               # Read Web Site
               Write-CMLogEntry -Value ('Info: Reading driver pack URL - {0}' -f $LenovoXMLSource) -Severity 1
					
               # Set XML Object 
               $null = ($LenovoModelXML.GetType().FullName)
               $script:LenovoModelDrivers = $global:LenovoModelXML.Products
            }
         }
      }
   }
	
   function FindLenovoDriver
   {
      <#
            .SYNOPSIS
            Describe purpose of "FindLenovoDriver" in 1-2 sentences.

            .DESCRIPTION
            Add a more complete description of what the function does.

            .PARAMETER URI
            Describe parameter -URI.

            .PARAMETER OS
            Describe parameter -OS.

            .PARAMETER Architecture
            Describe parameter -Architecture.

            .EXAMPLE
            FindLenovoDriver -URI Value -OS Value -Architecture Value
            Describe what this call does

            .NOTES
            # This powershell file will extract the link for the specified driver pack or application
            # param $URI The string version of the URL
            # param $64bit A boolean to determine what version to pick if there are multiple
            # param $os A string containing 7, 8, or 10 depending on the os we are deploying 
            #           i.e. 7, Win7, Windows 7 etc are all valid os strings
      #>
      [CmdletBinding(ConfirmImpact = 'None')]
      param (
         [parameter(Mandatory, HelpMessage = 'Provide the URL to parse.')]
         [ValidateNotNullOrEmpty()]
         [string]
         $URI,
         [parameter(Mandatory, HelpMessage = 'Specify the operating system.')]
         [ValidateNotNullOrEmpty()]
         [string]
         $OS,
         [string]
         $Architecture
      )
		
      begin
      {
         # Case for direct link to a zip file
         if ($URI.EndsWith('.zip'))
         {
            return $URI
         }
			
         $err = @()
      }
		
      process
      {
         # Get the content of the website
         try
         {
            $paramInvokeWebRequest = @{
               Uri		   = $URI
               ErrorAction = 'Stop'
            }
            $html = (Invoke-WebRequest @paramInvokeWebRequest)
         }
         catch
         {
            Write-CMLogEntry -Value ('Error: {0}' -f $_.Exception.Message) -Severity 3
         }
			
         # Create an array to hold all the links to exe files
         $Links = @()
         $Links.Clear()
			
         # Determine if the URL resolves to the old download location
         if ($URI -like '*olddownloads*')
         {
            #Quickly grab the links that end with exe
            $Links = (($html.Links | Where-Object -FilterScript {
                     $_.href -like '*exe'
            }) | Where-Object -Property class -EQ -Value 'downloadBtn').href
         }
			
         $Links = ((Select-String -Pattern '(http[s]?)(:\/\/)([^\s,]+.exe)(?=")' -InputObject ($html).Rawcontent -AllMatches).Matches.Value)
			
         if ($Links.Count -eq 0)
         {
            return $null
         }
			
         # Switch OS architecture
         switch -wildcard ($Architecture)
         {
            '*64*' 
            {
               $Architecture = '64'
            }
            '*86*' 
            {
               $Architecture = '32'
            }
         }
			
         # if there are multiple links then narrow down to the proper arc and os (if needed)
         if ($Links.Count -gt 0)
         {
            # Second array of links to hold only the ones we want to target
            $MatchingLink = @()
            $MatchingLink.clear()
				
            foreach ($Link in $Links)
            {
               if ($Link -like ('*w{0}{1}_*' -f ($OS), ($Architecture)) -or $Link -like ('*w{0}_{1}*' -f ($OS), ($Architecture)))
               {
                  $MatchingLink += $Link
               }
            }
         }
			
         if ($MatchingLink -ne $null)
         {
            return $MatchingLink
         }
         else
         {
            return 'badLink'
         }
      }
   }
	
   function Get-RedirectedUrl
   {
      <#
            .SYNOPSIS
            Describe purpose of "Get-RedirectedUrl" in 1-2 sentences.

            .DESCRIPTION
            Add a more complete description of what the function does.

            .PARAMETER URL
            Describe parameter -URL.

            .EXAMPLE
            Get-RedirectedUrl -URL Value
            Describe what this call does

            .NOTES
            Place additional notes here.

            .LINK
            URLs to related sites
            The first link is opened by Get-Help -Online Get-RedirectedUrl

            .INPUTS
            List of input types that are accepted by this function.

            .OUTPUTS
            List of output types produced by this function.
      #>


      [CmdletBinding(ConfirmImpact = 'None')]
      param (
         [Parameter(Mandatory,HelpMessage = 'Add help message for user')]
         [String]
         $URL
      )
		
      begin
      {
         $Request = [Net.WebRequest]::Create($URL)
         $Request.AllowAutoRedirect = $false
         $Request.Timeout = 3000
         $Response = $Request.GetResponse()
      }
		
      process
      {
         if ($Response.ResponseUri)
         {
            $Response.GetResponseHeader('Location')
         }
         $Response.Close()
      }
   }
	
   function LenovoModelTypeFinder
   {
      <#
            .SYNOPSIS
            Describe purpose of "LenovoModelTypeFinder" in 1-2 sentences.

            .DESCRIPTION
            Add a more complete description of what the function does.

            .PARAMETER ComputerModel
            Describe parameter -ComputerModel.

            .PARAMETER OS
            Describe parameter -OS.

            .PARAMETER ComputerModelType
            Describe parameter -ComputerModelType.

            .EXAMPLE
            LenovoModelTypeFinder -ComputerModel Value -OS Value -ComputerModelType Value
            Describe what this call does

            .NOTES
            Place additional notes here.

            .LINK
            URLs to related sites
            The first link is opened by Get-Help -Online LenovoModelTypeFinder

            .INPUTS
            List of input types that are accepted by this function.

            .OUTPUTS
            List of output types produced by this function.
      #>


      [CmdletBinding(ConfirmImpact = 'None')]
      param (
         [string]
         $ComputerModel,
         [string]
         $OS,
         [string]
         $ComputerModelType
      )
		
      process
      {
         try
         {
            if (-not ($LenovoModelDrivers))
            {
               $paramInvokeWebRequest = @{
                  Uri		   = $LenovoXMLSource
                  ErrorAction = 'Stop'
               }
               [xml]$script:LenovoModelXML = (Invoke-WebRequest @paramInvokeWebRequest)
					
               # Read Web Site
               Write-CMLogEntry -Value ('Info: Reading driver pack URL - {0}' -f $LenovoXMLSource) -Severity 1
					
               # Set XML Object
               $null = ($LenovoModelXML.GetType().FullName)
               $script:LenovoModelDrivers = $LenovoModelXML.Products
            }
         }
         catch
         {
            Write-CMLogEntry -Value ('Error: {0}' -f $_.Exception.Message) -Severity 3
         }
			
         if ($ComputerModel.Length -gt 0)
         {
            $script:LenovoModelType = ($LenovoModelDrivers.Product | Where-Object -FilterScript {
                  $_.Queries.Version -match $ComputerModel
            }).Queries.Types | Select-Object -ExpandProperty Type | Select-Object -First 1
            $script:LenovoSystemSKU = ($LenovoModelDrivers.Product | Where-Object -FilterScript {
                  $_.Queries.Version -match $ComputerModel
            }).Queries.Types | Select-Object -ExpandProperty Type | Get-Unique
         }
			
         if ($ComputerModelType.Length -gt 0)
         {
            $script:LenovoModelType = (($LenovoModelDrivers.Product.Queries) | Where-Object -FilterScript {
                  ($_.Types | Select-Object -ExpandProperty Type) -match $ComputerModelType
            }).Version | Select-Object -First 1
         }
      }
		
      end
      {
         return $LenovoModelType
      }
   }
	
   function InitiateDownloads
   {
      <#
            .SYNOPSIS
            Describe purpose of "InitiateDownloads" in 1-2 sentences.

            .DESCRIPTION
            Add a more complete description of what the function does.

            .EXAMPLE
            InitiateDownloads
            Describe what this call does

            .NOTES
            Place additional notes here.

            .LINK
            URLs to related sites
            The first link is opened by Get-Help -Online InitiateDownloads

            .INPUTS
            List of input types that are accepted by this function.

            .OUTPUTS
            List of output types produced by this function.
      #>


      [CmdletBinding(ConfirmImpact = 'None')]
      param ()
		
      $SCT = 'SilentlyContinue'
      $Product = 'Intune Driver Automation'
		
      # Driver Download ScriptBlock
      $DriverDownloadJob = {
         [CmdletBinding()]
         param ([string]
            $TempDirectory,
            [string]
            $ComputerModel,
            [string]
            $DriverCab,
            [string]
            $DriverDownloadURL
         )
			
         process
         {
            try
            {
               # Start Driver Download	
               $paramStartBitsTransfer = @{
                  DisplayName	   = ('{0}-DriverDownload' -f $ComputerModel)
                  Source		   = $DriverDownloadURL
                  Destination	   = ($TempDirectory + '\Driver Cab\' + $DriverCab)
                  Priority		   = 'High'
                  TransferPolicy = 'Always'
                  Confirm		   = $false
                  ErrorAction	   = 'Stop'
               }
               $null = (Start-BitsTransfer @paramStartBitsTransfer)
            }
            catch
            {
               Write-CMLogEntry -Value ('Error: {0}' -f $_.Exception.Message) -Severity 3
            }
         }
      }
		
      Write-CMLogEntry -Value '======== Starting Download Processes ========' -Severity 1
      Write-CMLogEntry -Value ('Info: Operating System specified: Windows {0}' -f ($WindowsVersion)) -Severity 1
      Write-CMLogEntry -Value ('Info: Operating System architecture specified: {0}' -f ($OSArchitecture)) -Severity 1
		
      # Operating System Version
      $OperatingSystem = ('Windows ' + $WindowsVersion)
		
      # Vendor Make
      $ComputerModel = $ComputerModel.Trim()
		
      # Get Windows Version Number
      switch -Wildcard ((Get-WmiObject -Class Win32_OperatingSystem).Version)
      {
         '*10.0.16*' 
         {
            $OSBuild = '1709'
         }
         '*10.0.15*' 
         {
            $OSBuild = '1703'
         }
         '*10.0.14*' 
         {
            $OSBuild = '1607'
         }
      }
		
      Write-CMLogEntry -Value ('Info: Windows 10 build {0} identified for driver match' -f $OSBuild) -Severity 1
      Write-CMLogEntry -Value ('Info: Starting Download,Extract And Import Processes For {0} Model: {1}' -f $ComputerManufacturer, ($ComputerModel)) -Severity 1
		
      if ($ComputerManufacturer -eq 'Dell')
      {
         Write-CMLogEntry -Value 'Info: Setting Dell variables' -Severity 1
			
         if (-not ($DellModelCabFiles))
         {
            $paramGetContent = @{
               Path		   = ($TempDirectory + '\' + $DellXMLFile)
               Force		   = $true
               Encoding	   = 'UTF8'
               ErrorAction = 'Continue'
            }
            [xml]$DellModelXML = (Get-Content @paramGetContent)
            # Set XML Object
            $null = ($DellModelXML.GetType().FullName)
            $DellModelCabFiles = $DellModelXML.driverpackmanifest.driverpackage
         }
			
         if ($SystemSKU -ne $null)
         {
            Write-CMLogEntry -Value ('Info: SystemSKU value is present, attempting match based on SKU - {0})' -f $SystemSKU) -Severity 1
				
            $ComputerModelURL = $DellDownloadBase + '/' + ($DellModelCabFiles | Where-Object -FilterScript {
                  ((($_.SupportedOperatingSystems).OperatingSystem).osCode -like ('*' + $WindowsVersion + '*')) -and ($_.SupportedSystems.Brand.Model.SystemID -eq $SystemSKU)
            }).delta
            $ComputerModelURL = $ComputerModelURL.Replace('\', '/')
            $DriverDownload = $DellDownloadBase + '/' + ($DellModelCabFiles | Where-Object -FilterScript {
                  ((($_.SupportedOperatingSystems).OperatingSystem).osCode -like ('*' + $WindowsVersion + '*')) -and ($_.SupportedSystems.Brand.Model.SystemID -eq $SystemSKU)
            }).path
            $DriverCab = (($DellModelCabFiles | Where-Object -FilterScript {
                     ((($_.SupportedOperatingSystems).OperatingSystem).osCode -like ('*' + $WindowsVersion + '*')) -and ($_.SupportedSystems.Brand.Model.SystemID -eq $SystemSKU)
            }).path).Split('/') | Select-Object -Last 1
         }
         elseif ((-not ($SystemSKU)) -or (-not ($DriverCab)))
         {
            Write-CMLogEntry -Value 'Info: Falling back to matching based on model name' -Severity 1
				
            $ComputerModelURL = $DellDownloadBase + '/' + ($DellModelCabFiles | Where-Object -FilterScript {
                  ((($_.SupportedOperatingSystems).OperatingSystem).osCode -like ('*' + $WindowsVersion + '*')) -and ($_.SupportedSystems.Brand.Model.Name -like ('*' + $ComputerModel + '*'))
            }).delta
            $ComputerModelURL = $ComputerModelURL.Replace('\', '/')
            $DriverDownload = $DellDownloadBase + '/' + ($DellModelCabFiles | Where-Object -FilterScript {
                  ((($_.SupportedOperatingSystems).OperatingSystem).osCode -like ('*' + $WindowsVersion + '*')) -and ($_.SupportedSystems.Brand.Model.Name -like ('*' + $ComputerModel + '*'))
            }).path
            $DriverCab = (($DellModelCabFiles | Where-Object -FilterScript {
                     ((($_.SupportedOperatingSystems).OperatingSystem).osCode -like ('*' + $WindowsVersion + '*')) -and ($_.SupportedSystems.Brand.Model.Name -like ('*' + $ComputerModel + '*'))
            }).path).Split('/') | Select-Object -Last 1
         }
			
         $DriverRevision = (($DriverCab).Split('-')[2]).Trim('.cab')
         $DellSystemSKU = ($DellModelCabFiles.supportedsystems.brand.model | Where-Object -FilterScript {
               $_.Name -match ('^' + $ComputerModel + '$')
         } | Get-Unique).systemID
			
         if ($DellSystemSKU.count -gt 1)
         {
            $DellSystemSKU = [string]($DellSystemSKU -join ';')
         }
			
         Write-CMLogEntry -Value ('Info: Dell System Model ID is : {0}' -f $DellSystemSKU) -Severity 1
      }
		
      if ($ComputerManufacturer -eq 'Hewlett-Packard')
      {
         Write-CMLogEntry -Value 'Info: Setting HP variables' -Severity 1
			
         if (-not ($HPModelSoftPaqs))
         {
            $paramGetContent = @{
               Path		   = ($TempDirectory + '\' + $HPXMLFile)
               Force		   = $true
               Encoding	   = 'UTF8'
               ErrorAction = 'Continue'
            }
            [xml]$script:HPModelXML = (Get-Content @paramGetContent)
            # Set XML Object
            $null = ($HPModelXML.GetType().FullName)
            $script:HPModelSoftPaqs = $HPModelXML.NewDataSet.HPClientDriverPackCatalog.ProductOSDriverPackList.ProductOSDriverPack
         }
			
         if ($SystemSKU)
         {
            $HPSoftPaqSummary = $HPModelSoftPaqs | Where-Object -FilterScript {
               ($_.SystemID -match $SystemSKU) -and ($_.OSName -like ($OSName + '*' + $OSArchitecture + '*' + $OSBuild + '*'))
            } | Sort-Object -Descending | Select-Object -First 1
         }
         else
         {
            $HPSoftPaqSummary = $HPModelSoftPaqs | Where-Object -FilterScript {
               ($_.SystemName -match $ComputerModel) -and ($_.OSName -like ('{0}*{1}*{2}*' -f $OSName, $OSArchitecture, $OSBuild))
            } | Sort-Object -Descending | Select-Object -First 1
         }
			
         if ($HPSoftPaqSummary)
         {
            $HPSoftPaq = $HPSoftPaqSummary.SoftPaqID
            $HPSoftPaqDetails = $HPModelXML.newdataset.hpclientdriverpackcatalog.softpaqlist.softpaq | Where-Object -FilterScript {
               $_.ID -eq $HPSoftPaq
            }
            $ComputerModelURL = (($HPSoftPaqDetails).URL)
            $DriverDownload = ((($HPSoftPaqDetails).URL).TrimStart('ftp:'))
            $DriverCab = $ComputerModelURL | Split-Path -Leaf
            $DriverRevision = (($HPSoftPaqDetails).Version)
         }
         else
         {
            Write-CMLogEntry -Value 'Unsupported model / operating system combination found. Exiting.' -Severity 3
            exit 1
         }
      }
		
      if ($ComputerManufacturer -eq 'Lenovo')
      {
         Write-CMLogEntry -Value 'Info: Setting Lenovo variables' -Severity 1
			
         $script:LenovoModelType = (LenovoModelTypeFinder -ComputerModel $ComputerModel -OS $WindowsVersion)
			
         Write-CMLogEntry -Value ('Info: {0} {1} matching model type: {2}' -f $ComputerManufacturer, $ComputerModel, $LenovoModelType) -Severity 1
			
         if ($LenovoModelDrivers)
         {
            [xml]$script:LenovoModelXML = (New-Object -TypeName System.Net.WebClient).DownloadString($LenovoXMLSource)
            # Set XML Object
            $null = ($LenovoModelXML.GetType().FullName)
            $script:LenovoModelDrivers = $LenovoModelXML.Products
				
            if ($SystemSKU)
            {
               $ComputerModelURL = (($LenovoModelDrivers.Product | Where-Object -FilterScript {
                        ($_.Queries.smbios -match $SystemSKU -and $_.OS -match $WindowsVersion)
                  }).driverPack | Where-Object -FilterScript {
                     $_.id -eq 'SCCM'
               }).'#text'
            }
            else
            {
               $ComputerModelURL = (($LenovoModelDrivers.Product | Where-Object -FilterScript {
                        ($_.Queries.Version -match ('^' + $ComputerModel + '$') -and $_.OS -match $WindowsVersion)
                  }).driverPack | Where-Object -FilterScript {
                     $_.id -eq 'SCCM'
               }).'#text'
            }
				
            Write-CMLogEntry -Value ('Info: Model URL determined as {0}' -f $ComputerModelURL) -Severity 1
				
            $DriverDownload = (FindLenovoDriver -URI $ComputerModelURL -os $WindowsVersion -Architecture $OSArchitecture)
				
            if ($DriverDownload)
            {
               $DriverCab = $DriverDownload | Split-Path -Leaf
               $DriverRevision = ($DriverCab.Split('_') | Select-Object -Last 1).Trim('.exe')
					
               Write-CMLogEntry -Value ('Info: Driver cabinet download determined as {0}' -f $DriverDownload) -Severity 1
            }
            else
            {
               Write-CMLogEntry -Value ('Error: Unable to find driver for {0} {1}' -f $ComputerManufacturer, $ComputerModel) -Severity 1
            }
         }
      }
		
      # Driver location variables
      $DriverSourceCab = ($TempDirectory + '\Driver Cab\' + $DriverCab)
      $DriverExtractDest = ($TempDirectory + '\Driver Files')
		
      Write-CMLogEntry -Value ('Info: Driver extract location set - {0}' -f $DriverExtractDest) -Severity 1
      Write-CMLogEntry -Value ('======== {0} - {1} {2} DRIVER PROCESSING STARTED ========' -f $Product, $ComputerManufacturer, $ComputerModel) -Severity 1
      Write-CMLogEntry -Value ('{0}: Retrieving ConfigMgr driver pack site For {1} {2}' -f ($Product), $ComputerManufacturer, $ComputerModel) -Severity 1
      Write-CMLogEntry -Value ('{0}: URL found: {1}' -f ($Product), $ComputerModelURL) -Severity 1
		
      if (($ComputerModelURL) -and ($DriverDownload -ne 'badLink'))
      {
         # Cater for HP / Model Issue
         $ComputerModel = $ComputerModel -replace '/', '-'
         $ComputerModel = $ComputerModel.Trim()
         Set-Location -Path $TempDirectory
			
         # Check for destination directory, create if required and download the driver cab
         $paramTestPath = @{
            Path		   = ($TempDirectory + '\Driver Cab\' + $DriverCab)
            ErrorAction = 'SilentlyContinue'
         }
         if (-not (Test-Path @paramTestPath))
         {
            $paramTestPath = @{
               Path		   = ($TempDirectory + '\Driver Cab')
               ErrorAction = 'SilentlyContinue'
            }
            if (-not (Test-Path @paramTestPath))
            {
               $paramNewItem = @{
                  ItemType	   = 'Directory'
                  Path		   = $
                  Value		   = ($TempDirectory + '\Driver Cab')
                  Force		   = $true
                  Confirm	   = $false
                  ErrorAction = 'Stop'
               }
               $null = (New-Item @paramNewItem)
            }
				
            Write-CMLogEntry -Value ('{0}: Downloading {1} driver cab file' -f ($Product), $DriverCab) -Severity 1
            Write-CMLogEntry -Value ('{0}: Downloading from URL: {1}' -f ($Product), $DriverDownload) -Severity 1
				
            $paramStartJob = @{
               Name		    = ('{0}-DriverDownload' -f $ComputerModel)
               ScriptBlock  = $DriverDownloadJob
               ArgumentList = ($TempDirectory, $ComputerModel, $DriverCab, $DriverDownload)
            }
            $null = (Start-Job @paramStartJob)
				
            Start-Sleep -Seconds 5
				
            $BitsJob = (Get-BitsTransfer | Where-Object -FilterScript {
                  $_.DisplayName -match ($ComputerModel + '-DriverDownload')
            })
            while (($BitsJob).JobState -eq 'Connecting')
            {
               Write-CMLogEntry -Value ('{0}: Establishing connection to {1}' -f ($Product), $DriverDownload) -Severity 1
					
               Start-Sleep -Seconds 30
            }
            while (($BitsJob).JobState -eq 'Transferring')
            {
               if ($BitsJob.BytesTotal)
               {
                  $PercentComplete = [int](($BitsJob.BytesTransferred * 100)/$BitsJob.BytesTotal)

                  Write-CMLogEntry -Value ('{0}: Downloaded {1} MB of {2} MB ({3}%). Next update in 30 seconds.' -f ($Product), ([int]((($BitsJob).BytesTransferred)/ 1MB)), ([int]((($BitsJob).BytesTotal)/ 1MB)), $PercentComplete) -Severity 1
						
                  Start-Sleep -Seconds 30
               }
               else
               {
                  Write-CMLogEntry -Value ('{0}: Download issues detected. Cancelling download process' -f ($Product)) -Severity 2
						
                  $null = (Get-BitsTransfer | Where-Object -FilterScript {
                        $_.DisplayName -eq ($ComputerModel + '-DriverDownload')
                  } | Remove-BitsTransfer)
               }
            }
				
            $null = (Get-BitsTransfer | Where-Object -FilterScript {
                  $_.DisplayName -eq ($ComputerModel + '-DriverDownload')
            } | Complete-BitsTransfer)
				
            Write-CMLogEntry -Value ('{0}: Driver revision: {1}' -f ($Product), $DriverRevision) -Severity 1
         }
         else
         {
            Write-CMLogEntry -Value ('{0}: Skipping {1}. Driver pack already downloaded.' -f ($Product), $DriverCab) -Severity 1
         }
			
         # Cater for HP / Model Issue
         $ComputerModel = $ComputerModel -replace '/', '-'
			
         $paramTestPath = @{
            Path		   = ($TempDirectory + '\Driver Cab\' + $DriverCab)
            ErrorAction = 'SilentlyContinue'
         }
         if ((Test-Path @paramTestPath ) -and ($DriverCab))
         {
            Write-CMLogEntry -Value ('{0}: {1} File exists - Starting driver update process' -f ($Product), $DriverCab) -Severity 1
				
            $paramTestPath = @{
               Path		   = $DriverExtractDest
               ErrorAction = $SCT
            }
				
            if (-not (Test-Path @paramTestPath))
            {
               $paramNewItem = @{
                  ItemType	   = 'Directory'
                  Path		   = $DriverExtractDest
                  Force		   = $true
                  ErrorAction = 'Stop'
               }
					
               $null = (New-Item @paramNewItem)
            }
				
            $paramGetChildItem = @{
               Path		   = $DriverExtractDest
               Recurse	   = $true
               Filter	   = '*.inf'
               File		   = $true
               ErrorAction = $SCT
            }
            if ((Get-ChildItem @paramGetChildItem).Count -eq 0)
            {
               Write-CMLogEntry -Value ('==================== {0} DRIVER EXTRACT ====================' -f $Product) -Severity 1
               Write-CMLogEntry -Value ('{0}: Expanding driver CAB source file: {1}' -f ($Product), $DriverCab) -Severity 1
               Write-CMLogEntry -Value ('{0}: Driver CAB destination directory: {1}' -f ($Product), $DriverExtractDest) -Severity 1
					
               # TODO: Switch instead of all the IF
               if ($ComputerManufacturer -eq 'Dell')
               {
                  Write-CMLogEntry -Value ('{0}: Extracting {1} drivers to {2}' -f ($Product), $ComputerManufacturer, $DriverExtractDest) -Severity 1
						
                  $null = (& "$env:windir\system32\expand.exe" ($DriverSourceCab + ' -F:* ' + $DriverExtractDest))
               }
               if ($ComputerManufacturer -eq 'Hewlett-Packard')
               {
                  Write-CMLogEntry -Value ('{0}: Extracting {1} drivers to {2}' -f ($Product), $ComputerManufacturer, $DriverExtractDest) -Severity 1
						
                  # Driver Silent Extract Switches
                  $HPSilentSwitches = ('/s /e /f "' + $DriverExtractDest + '"')
						
                  Write-CMLogEntry -Value ('{0}: Using {1} silent switches: {2}' -f ($Product), $ComputerManufacturer, $HPSilentSwitches) -Severity 1
						
                  $paramStartProcess = @{
                     FilePath	    = ($TempDirectory + '\Driver Cab\' + $DriverCab)
                     ArgumentList = $HPSilentSwitches
                     Verb		    = 'RunAs'
                  }
                  $null = (Start-Process @paramStartProcess)
                  $DriverProcess = ($DriverCab).Substring(0, $DriverCab.length - 4)
						
                  # Wait for HP SoftPaq Process To Finish
                  while ((Get-Process).name -contains $DriverProcess)
                  {
                     Write-CMLogEntry -Value ('{0}: Waiting for extract process (Process: {1}) to complete..  Next check in 30 seconds' -f ($Product), $DriverProcess) -Severity 1
							
                     Start-Sleep -Seconds 30
                  }
               }
               if ($ComputerManufacturer -eq 'Lenovo')
               {
                  # Driver Silent Extract Switches
                  $script:LenovoSilentSwitches = ('/VERYSILENT /DIR=' + '"' + $DriverExtractDest + '"' + ' /Extract="Yes"')
						
                  Write-CMLogEntry -Value ('{0}: Using {1} silent switches: {2}' -f ($Product), $ComputerManufacturer, $LenovoSilentSwitches) -Severity 1
                  Write-CMLogEntry -Value ('{0}: Extracting {1} drivers to {2}' -f ($Product), $ComputerManufacturer, $DriverExtractDest) -Severity 1
						
                  $paramUnblockFile = @{
                     Path		   = ($TempDirectory + '\Driver Cab\' + $DriverCab)
                     Confirm	   = $false
                     ErrorAction = 'SilentlyContinue'
                  }
                  $null = (Unblock-File @paramUnblockFile)
                  $paramStartProcess = @{
                     FilePath	    = ($TempDirectory + '\Driver Cab\' + $DriverCab)
                     ArgumentList = $LenovoSilentSwitches
                     Verb		    = 'RunAs'
                  }
                  $null = (Start-Process @paramStartProcess)
						
                  $DriverProcess = ($DriverCab).Substring(0, $DriverCab.length - 4)
						
                  # Wait for Lenovo Driver Process To Finish
                  while ((Get-Process).name -contains $DriverProcess)
                  {
                     Write-CMLogEntry -Value ('{0}: Waiting for extract process (Process: {1}) to complete..  Next check in 30 seconds' -f ($Product), $DriverProcess) -Severity 1
							
                     Start-Sleep -Seconds 30
                  }
               }
            }
            else
            {
               Write-CMLogEntry -Value 'Skipping. Drivers already extracted.' -Severity 1
            }
         }
         else
         {
            Write-CMLogEntry -Value ('{0}: {1} file download failed' -f ($Product), $DriverCab) -Severity 3
         }
      }
      elseif ($DriverDownload -eq 'badLink')
      {
         Write-CMLogEntry -Value ('{0}: Operating system driver package download path not found.. Skipping {1}' -f ($Product), $ComputerModel) -Severity 3
      }
      else
      {
         Write-CMLogEntry -Value ('{0}: Driver package not found for {1} running Windows {2} {3}. Skipping {4}' -f ($Product), $ComputerModel, $WindowsVersion, $OSArchitecture) -Severity 2
      }
		
      Write-CMLogEntry -Value ('======== {0} - {1} {2} DRIVER PROCESSING FINISHED ========' -f $Product, $ComputerManufacturer, $ComputerModel) -Severity 1
   }
	
   function Update-Drivers
   {
      <#
            .SYNOPSIS
            Describe purpose of "Update-Drivers" in 1-2 sentences.

            .DESCRIPTION
            Add a more complete description of what the function does.

            .EXAMPLE
            Update-Drivers
            Describe what this call does

            .NOTES
            Place additional notes here.

            .LINK
            URLs to related sites
            The first link is opened by Get-Help -Online Update-Drivers

            .INPUTS
            List of input types that are accepted by this function.

            .OUTPUTS
            List of output types produced by this function.
      #>


      [CmdletBinding(ConfirmImpact = 'None')]
      param ()
		
      $paramJoinPath = @{
         Path	    = $TempDirectory
         ChildPath = 'Driver Files'
      }
      $DriverPackagePath = (Join-Path @paramJoinPath)
		
      Write-CMLogEntry -Value ('Driver package location is {0}' -f $DriverPackagePath) -Severity 1
      Write-CMLogEntry -Value 'Starting driver installation process' -Severity 1
      Write-CMLogEntry -Value ('Reading drivers from {0}' -f $DriverPackagePath) -Severity 1
		
      # Apply driver maintenance package
      try
      {
         $paramGetChildItem = @{
            Path		   = $DriverPackagePath
            Filter	   = '*.inf'
            Recurse	   = $true
            ErrorAction = 'SilentlyContinue'
         }
         if (((Get-ChildItem @paramGetChildItem ).count -gt 0))
         {
            try
            {
               $paramStartProcess = @{
                  FilePath		     = ($PSHome + '\powershell.exe')
                  WorkingDirectory = $DriverPackagePath
                  ArgumentList	  = ("pnputil /add-driver *.inf /subdirs /install | Out-File -FilePath (Join-Path -Path {0} -ChildPath '\Install-Drivers.txt') -Append" -f $LogDirectory)
                  NoNewWindow	     = $true
                  Wait				  = $true
               }
               $null = (Start-Process @paramStartProcess)
					
               Write-CMLogEntry -Value 'Driver installation complete. Restart required' -Severity 1
            }
            catch
            {
               Write-CMLogEntry -Value ('An error occurred while attempting to apply the driver maintenance package. Error message: {0}' -f $_.Exception.Message) -Severity 3
					
               exit 1
            }
         }
         else
         {
            Write-CMLogEntry -Value ('No driver inf files found in {0}.' -f $DriverPackagePath) -Severity 3
				
            exit 1
         }
      }
      catch
      {
         Write-CMLogEntry -Value ('An error occurred while attempting to apply the driver maintenance package. Error message: {0}' -f $_.Exception.Message) -Severity 3
			
         exit 1
      }
		
      Write-CMLogEntry -Value 'Finished driver maintenance.' -Severity 1
		
      return $LastExitCode
   }
}

process
{
   if ($OSName -eq 'Windows 10')
   {
      # Download manufacturer lists for driver matching
      $null = (DownloadDriverList -ErrorAction $STP)

      # Initiate matched downloads
      $null = (InitiateDownloads -ErrorAction $STP)

      # Update driver repository and install drivers
      (Update-Drivers -ErrorAction $STP)
   }
   else
   {
      Write-CMLogEntry -Value 'An upsupported OS was detected. This script only supports Windows 10.' -Severity 3
      exit 1
   }
}

end
{
   $null = (Pop-Location -ErrorAction $SCT)
}
	