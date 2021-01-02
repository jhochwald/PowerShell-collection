#requires -Version 3.0 -RunAsAdministrator

<#
   .SYNOPSIS

   The purpose of this script is to automate the driver update process when enrolling devices through
   Microsoft Intune.

   .DESCRIPTION

   This script will determine the model of the computer, manufacturer and operating system used then download,
   extract & install the latest driver package from the manufacturer. At present Dell, HP and Lenovo devices
   are supported.

   .NOTES

   FileName:    Invoke-MSIntuneDriverUpdate.ps1

   Author:      Maurice Daly
   Contact:     @MoDaly_IT
   Created:     2017-12-03
   Updated:     2017-12-05

   Version history:

   1.0.0 - (2017-12-03) Script created
   1.0.1 - (2017-12-05) Updated Lenovo matching SKU value and added regex matching for Computer Model values.
   1.0.2 - (2017-12-05) Updated to cater for language differences in OS architecture returned
#>
[CmdletBinding(ConfirmImpact = 'None')]
param ()

begin
{
   $SCT = 'SilentlyContinue'

   if (Get-Command -Name 'Set-MpPreference' -ErrorAction $SCT)
   {
      $null = (Set-MpPreference -EnableControlledFolderAccess Disabled -Force -ErrorAction $SCT)
   }

   # Set Temp & Log Location
   $paramJoinPath = @{
      Path        = 'c:\install'
      ChildPath   = '\SCConfigMgr'
      ErrorAction = 'Stop'
   }
   [string]$TempDirectory = (Join-Path @paramJoinPath)
   $paramJoinPath = @{
      Path        = 'c:\temp'
      ChildPath   = '\SCConfigMgr'
      ErrorAction = 'Stop'
   }
   [string]$LogDirectory = (Join-Path @paramJoinPath)

   # Create Temp Folder
   $paramTestPath = @{
      Path        = $TempDirectory
      ErrorAction = $SCT
   }
   if ((Test-Path @paramTestPath ) -eq $false)
   {
      $paramNewItem = @{
         Path        = $TempDirectory
         ItemType    = 'Dir'
         Force       = $true
         ErrorAction = $SCT
      }
      $null = (New-Item @paramNewItem)
   }

   # Create Logs Folder
   $paramTestPath = @{
      Path        = $LogDirectory
      ErrorAction = $SCT
   }
   if ((Test-Path @paramTestPath ) -eq $false)
   {
      $paramNewItem = @{
         Path        = $LogDirectory
         ItemType    = 'Dir'
         Force       = $true
         ErrorAction = $SCT
      }
      $null = (New-Item @paramNewItem)
   }

   $paramPushLocation = @{
      Path = 'c:\install'
   }
   $null = (Push-Location @paramPushLocation)

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
         $paramJoinPath = @{
            Path        = $LogDirectory
            ChildPath   = $FileName
            ErrorAction = 'Stop'
         }
         $LogFilePath = (Join-Path @paramJoinPath)

         # Construct time stamp for log entry
         $Time = -join @((Get-Date -Format 'HH:mm:ss.fff'), '+', (Get-WmiObject -Class Win32_TimeZone | Select-Object -ExpandProperty Bias))

         # Construct date for log entry
         $Date = (Get-Date -Format 'MM-dd-yyyy')

         # Construct context for log entry
         $Context = $([Security.Principal.WindowsIdentity]::GetCurrent().Name)

         # Construct final log entry
         $LogText = "<![LOG[$($Value)]LOG]!><time=""$($Time)"" date=""$($Date)"" component=""DriverAutomationScript"" context=""$($Context)"" type=""$($Severity)"" thread=""$($PID)"" file="""">"
      }

      process
      {
         # Add value to log file
         try
         {
            $paramAddContent = @{
               Value       = $LogText
               LiteralPath = $LogFilePath
               Force       = $true
               ErrorAction = 'Stop'
            }
            $null = (Add-Content @paramAddContent)
         }
         catch
         {
            Write-Warning -Message "Unable to append log entry to Invoke-DriverUpdate.log file. Error message: $($_.Exception.Message)"
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
   $DellCabFile = [string]($DellXMLCabinetSource | Split-Path -Leaf -ErrorAction $SCT)
   $DellCatalogFile = [string]($DellCatalogSource | Split-Path -Leaf -ErrorAction $SCT)
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
   $HPCabFile = [string]($HPXMLCabinetSource | Split-Path -Leaf -ErrorAction $SCT)
   $HPXMLFile = $HPCabFile.Trim('.cab')
   $HPXMLFile = $HPXMLFile + '.xml'
   $HPPlatformCabFile = [string]($HPPlatFormList | Split-Path -Leaf -ErrorAction $SCT)
   $HPPlatformXMLFile = $HPPlatformCabFile.Trim('.cab')
   $HPPlatformXMLFile = $HPPlatformXMLFile + '.xml'

   # Define HP Global Variables
   $HPModelSoftPaqs = $null
   $HPModelXML = $null
   $HPPlatformXML = $null

   # Define Lenovo Download Sources
   $script:LenovoXMLSource = 'https://download.lenovo.com/cdrt/td/catalog.xml'

   # Define Lenovo Cabinet/XL Names and Paths
   $script:LenovoXMLFile = [string]($LenovoXMLSource | Split-Path -Leaf -ErrorAction $SCT)

   # Define Lenovo Global Variables
   $LenovoModelDrivers = $null
   $LenovoModelXML = $null
   $LenovoModelType = $null
   $LenovoSystemSKU = $null

   # Determine manufacturer
   $ComputerManufacturer = ((Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty Manufacturer).Trim())

   Write-CMLogEntry -Value "Manufacturer determined as: $($ComputerManufacturer)" -Severity 1

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

   Write-CMLogEntry -Value "Computer model determined as: $($ComputerModel)" -Severity 1

   if (-not [string]::IsNullOrEmpty($SystemSKU))
   {
      Write-CMLogEntry -Value "Computer SKU determined as: $($SystemSKU)" -Severity 1
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

   Write-CMLogEntry -Value "Operating system determined as: $OSName" -Severity 1

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

   Write-CMLogEntry -Value "Architecture determined as: $OSArchitecture" -Severity 1

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
      #>
      [CmdletBinding(ConfirmImpact = 'None')]
      param ()

      Write-CMLogEntry -Value '======== Download Model Link Information ========' -Severity 1

      switch ($ComputerManufacturer)
      {
         'Hewlett-Packard'
         {
            if ((Test-Path -Path $TempDirectory\$HPCabFile) -eq $false)
            {
               Write-CMLogEntry -Value '======== Downloading HP Product List ========' -Severity 1
               Write-CMLogEntry -Value "Info: Downloading HP driver pack cabinet file from $HPXMLCabinetSource" -Severity 1

               try
               {
                  $paramStartBitsTransfer = @{
                     Source         = $HPXMLCabinetSource
                     Destination    = $TempDirectory
                     TransferPolicy = 'Always'
                     Priority       = 'Foreground'
                     ErrorAction    = 'Stop'
                  }
                  $null = (Start-BitsTransfer @paramStartBitsTransfer)

                  Write-CMLogEntry -Value "Info: Expanding HP driver pack cabinet file: $HPXMLFile" -Severity 1

                  $null = (& "$env:windir\system32\expand.exe" "$TempDirectory\$HPCabFile" -F:* "$TempDirectory\$HPXMLFile")
               }
               catch
               {
                  Write-CMLogEntry -Value "Error: $($_.Exception.Message)" -Severity 3
               }
            }
            # Read XML File
            if (-not ($HPModelSoftPaqs))
            {
               Write-CMLogEntry -Value "Info: Reading driver pack XML file - $TempDirectory\$HPXMLFile" -Severity 1

               $paramGetContent = @{
                  Path        = ($TempDirectory + '\' + $HPXMLFile)
                  ErrorAction = $SCT
               }
               [xml]$script:HPModelXML = (Get-Content @paramGetContent)

               # Set XML Object
               $null = ($HPModelXML.GetType().FullName)
               $script:HPModelSoftPaqs = $HPModelXML.NewDataSet.HPClientDriverPackCatalog.ProductOSDriverPackList.ProductOSDriverPack
            }
         }
         'Dell'
         {
            if (-not (Test-Path -Path $TempDirectory\$DellCabFile))
            {
               Write-CMLogEntry -Value 'Info: Downloading Dell product list' -Severity 1
               Write-CMLogEntry -Value "Info: Downloading Dell driver pack cabinet file from $DellXMLCabinetSource" -Severity 1

               # Download Dell Model Cabinet File
               try
               {
                  $paramStartBitsTransfer = @{
                     Source         = $DellXMLCabinetSource
                     Destination    = $TempDirectory
                     TransferPolicy = 'Always'
                     Priority       = 'High'
                     ErrorAction    = 'Stop'
                  }
                  $null = (Start-BitsTransfer @paramStartBitsTransfer)

                  # Expand Cabinet File
                  Write-CMLogEntry -Value "Info: Expanding Dell driver pack cabinet file: $DellXMLFile" -Severity 1

                  $null = (& "$env:windir\system32\expand.exe" "$TempDirectory\$DellCabFile" -F:* "$TempDirectory\$DellXMLFile")
               }
               catch
               {
                  Write-CMLogEntry -Value "Error: $($_.Exception.Message)" -Severity 3
               }
            }

            if (-not ($DellModelXML))
            {
               # Read XML File
               Write-CMLogEntry -Value "Info: Reading driver pack XML file - $TempDirectory\$DellXMLFile" -Severity 1

               $paramGetContent = @{
                  Path        = $TempDirectory
                  ReadCount   = '\'
                  TotalCount  = $DellXMLFile
                  ErrorAction = $SCT
               }
               [xml]$DellModelXML = (Get-Content @paramGetContent)

               # Set XML Object
               $null = ($DellModelXML.GetType().FullName)
            }

            $DellModelCabFiles = $DellModelXML.driverpackmanifest.driverpackage
         }
         'Lenovo'
         {
            if (-not ($LenovoModelDrivers))
            {
               try
               {
                  $paramInvokeWebRequest = @{
                     Uri         = $LenovoXMLSource
                     ErrorAction = 'Stop'
                  }
                  [xml]$script:LenovoModelXML = (Invoke-WebRequest @paramInvokeWebRequest)
               }
               catch
               {
                  Write-CMLogEntry -Value "Error: $($_.Exception.Message)" -Severity 3
               }

               # Read Web Site
               Write-CMLogEntry -Value "Info: Reading driver pack URL - $LenovoXMLSource" -Severity 1

               # Set XML Object
               $null = ($LenovoModelXML.GetType().FullName)
               $script:LenovoModelDrivers = $LenovoModelXML.Products
            }
         }
         Default
         {
            Write-CMLogEntry -Value 'Unknown or unsupported Computer Manufacturer or OEM' -Severity 2
         }
      }
   }

   function FindLenovoDriver
   {
      <#
         .SYNOPSIS
         extract the link for the specified driver pack or application

         .DESCRIPTION
         extract the link for the specified driver pack or application

         .PARAMETER URI
         The string version of the URL

         .PARAMETER OS
         Describe parameter -OS.

         .PARAMETER Architecture
         A string containing 7, 8, or 10 depending on the os we are deploying i.e. 7, Win7, Windows 7 etc are all valid os strings

         .EXAMPLE
         FindLenovoDriver -URI Value -OS Value -Architecture Value
         extract the link for the specified driver pack or application

         .NOTES
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
               Uri         = $URI
               ErrorAction = 'Stop'
            }
            $html = (Invoke-WebRequest @paramInvokeWebRequest)
         }
         catch
         {
            Write-CMLogEntry -Value "Error: $($_.Exception.Message)" -Severity 3
         }

         # Create an array to hold all the links to exe files
         $Links = @()
         $Links.Clear()

         # Determine if the URL resolves to the old download location
         if ($URI -like '*olddownloads*')
         {
            #Quickly grab the links that end with exe
            $Links = (($html.Links | Where-Object {
                     $_.href -like '*exe'
                  }) | Where-Object class -EQ -Value 'downloadBtn').href
         }

         $Links = ((Select-String -Pattern '(http[s]?)(:\/\/)([^\s,]+.exe)(?=")' -InputObject (($html).Rawcontent) -AllMatches ErrorAction $SCT).Matches.Value)

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
               if ($Link -like "*w$($OS)$($Architecture)_*" -or $Link -like "*w$($OS)_$($Architecture)*")
               {
                  $MatchingLink += $Link
               }
            }
         }
      }

      end
      {
         if ($MatchingLink)
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
      #>
      [CmdletBinding(ConfirmImpact = 'None')]
      param (
         [Parameter(Mandatory, HelpMessage = 'Add help message for user')]
         [String]
         $URL
      )

      process
      {
         $Request = [Net.WebRequest]::Create($URL)
         $Request.AllowAutoRedirect = $false
         $Request.Timeout = 3000
         $Response = $Request.GetResponse()

         if ($Response.ResponseUri)
         {
            $Response.GetResponseHeader('Location')
         }
      }

      end
      {
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
               [xml]$script:LenovoModelXML = (Invoke-WebRequest -Uri $LenovoXMLSource -ErrorAction Stop)

               # Read Web Site
               Write-CMLogEntry -Value "Info: Reading driver pack URL - $LenovoXMLSource" -Severity 1

               # Set XML Object
               $null = ($LenovoModelXML.GetType().FullName)
               $script:LenovoModelDrivers = $LenovoModelXML.Products
            }
         }
         catch
         {
            Write-CMLogEntry -Value "Error: $($_.Exception.Message)" -Severity 3
         }

         if ($ComputerModel.Length -gt 0)
         {
            $script:LenovoModelType = ($LenovoModelDrivers.Product | Where-Object {
                  $_.Queries.Version -match "$ComputerModel"
               }).Queries.Types | Select-Object -ExpandProperty Type | Select-Object -First 1
            $script:LenovoSystemSKU = ($LenovoModelDrivers.Product | Where-Object {
                  $_.Queries.Version -match "$ComputerModel"
               }).Queries.Types | Select-Object -ExpandProperty Type | Get-Unique
         }

         if ($ComputerModelType.Length -gt 0)
         {
            $script:LenovoModelType = (($LenovoModelDrivers.Product.Queries) | Where-Object {
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
      #>
      [CmdletBinding(ConfirmImpact = 'None')]
      param ()

      begin
      {
         $Product = 'Intune Driver Automation'
      }

      process
      {
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

            try
            {
               # Start Driver Download
               $null = (Start-BitsTransfer -DisplayName "$ComputerModel-DriverDownload" -Source $DriverDownloadURL -Destination "$($TempDirectory + '\Driver Cab\' + $DriverCab)" -ErrorAction Stop)
            }
            catch
            {
               Write-CMLogEntry -Value "Error: $($_.Exception.Message)" -Severity 3
            }
         }

         # Operating System Version
         $OperatingSystem = ('Windows ' + $($WindowsVersion))

         Write-CMLogEntry -Value '======== Starting Download Processes ========' -Severity 1
         Write-CMLogEntry -Value "Info: Operating System specified: Windows $OperatingSystem" -Severity 1
         Write-CMLogEntry -Value "Info: Operating System architecture specified: $($OSArchitecture)" -Severity 1

         # Vendor Make
         if ($ComputerModel)
         {
            $ComputerModel = $ComputerModel.Trim()
         }
         else
         {
            $ComputerModel = ''
         }

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

         Write-CMLogEntry -Value "Info: Windows 10 build $OSBuild identified for driver match" -Severity 1
         Write-CMLogEntry -Value "Info: Starting Download,Extract And Import Processes For $ComputerManufacturer Model: $($ComputerModel)" -Severity 1

         if ($ComputerManufacturer -eq 'Dell')
         {
            Write-CMLogEntry -Value 'Info: Setting Dell variables' -Severity 1

            if (-not ($DellModelCabFiles))
            {
               [xml]$DellModelXML = (Get-Content -Path $TempDirectory\$DellXMLFile)
               # Set XML Object
               $null = ($DellModelXML.GetType().FullName)
               $DellModelCabFiles = $DellModelXML.driverpackmanifest.driverpackage
            }

            if ($SystemSKU)
            {
               Write-CMLogEntry -Value "Info: SystemSKU value is present, attempting match based on SKU - $SystemSKU)" -Severity 1

               $ComputerModelURL = $DellDownloadBase + '/' + ($DellModelCabFiles | Where-Object {
                     ((($_.SupportedOperatingSystems).OperatingSystem).osCode -like "*$WindowsVersion*") -and ($_.SupportedSystems.Brand.Model.SystemID -eq $SystemSKU)
                  }).delta
               $ComputerModelURL = $ComputerModelURL.Replace('\', '/')
               $DriverDownload = $DellDownloadBase + '/' + ($DellModelCabFiles | Where-Object {
                     ((($_.SupportedOperatingSystems).OperatingSystem).osCode -like "*$WindowsVersion*") -and ($_.SupportedSystems.Brand.Model.SystemID -eq $SystemSKU)
                  }).path
               $DriverCab = (($DellModelCabFiles | Where-Object {
                        ((($_.SupportedOperatingSystems).OperatingSystem).osCode -like "*$WindowsVersion*") -and ($_.SupportedSystems.Brand.Model.SystemID -eq $SystemSKU)
                     }).path).Split('/') | Select-Object -Last 1
            }
            elseif ((-not ($SystemSKU)) -or (-not ($DriverCab)))
            {
               Write-CMLogEntry -Value 'Info: Falling back to matching based on model name' -Severity 1

               $ComputerModelURL = $DellDownloadBase + '/' + ($DellModelCabFiles | Where-Object {
                     ((($_.SupportedOperatingSystems).OperatingSystem).osCode -like "*$WindowsVersion*") -and ($_.SupportedSystems.Brand.Model.Name -like "*$ComputerModel*")
                  }).delta
               $ComputerModelURL = $ComputerModelURL.Replace('\', '/')
               $DriverDownload = $DellDownloadBase + '/' + ($DellModelCabFiles | Where-Object {
                     ((($_.SupportedOperatingSystems).OperatingSystem).osCode -like "*$WindowsVersion*") -and ($_.SupportedSystems.Brand.Model.Name -like "*$ComputerModel")
                  }).path
               $DriverCab = (($DellModelCabFiles | Where-Object {
                        ((($_.SupportedOperatingSystems).OperatingSystem).osCode -like "*$WindowsVersion*") -and ($_.SupportedSystems.Brand.Model.Name -like "*$ComputerModel")
                     }).path).Split('/') | Select-Object -Last 1
            }

            $DriverRevision = (($DriverCab).Split('-')[2]).Trim('.cab')
            $DellSystemSKU = ($DellModelCabFiles.supportedsystems.brand.model | Where-Object {
                  $_.Name -match ('^' + $ComputerModel + '$')
               } | Get-Unique).systemID

            if ($DellSystemSKU.count -gt 1)
            {
               $DellSystemSKU = [string]($DellSystemSKU -join ';')
            }

            Write-CMLogEntry -Value "Info: Dell System Model ID is : $DellSystemSKU" -Severity 1
         }

         if ($ComputerManufacturer -eq 'Hewlett-Packard')
         {
            Write-CMLogEntry -Value 'Info: Setting HP variables' -Severity 1

            if (-not ($HPModelSoftPaqs))
            {
               [xml]$script:HPModelXML = (Get-Content -Path $TempDirectory\$HPXMLFile)
               # Set XML Object
               $null = ($HPModelXML.GetType().FullName)
               $script:HPModelSoftPaqs = $HPModelXML.NewDataSet.HPClientDriverPackCatalog.ProductOSDriverPackList.ProductOSDriverPack
            }

            if ($SystemSKU)
            {
               $HPSoftPaqSummary = $HPModelSoftPaqs | Where-Object {
                  ($_.SystemID -match $SystemSKU) -and ($_.OSName -like "$OSName*$OSArchitecture*$OSBuild*")
               } | Sort-Object -Descending | Select-Object -First 1
            }
            else
            {
               $HPSoftPaqSummary = $HPModelSoftPaqs | Where-Object {
                  ($_.SystemName -match $ComputerModel) -and ($_.OSName -like "$OSName*$OSArchitecture*$OSBuild*")
               } | Sort-Object -Descending | Select-Object -First 1
            }

            if ($HPSoftPaqSummary)
            {
               $HPSoftPaq = $HPSoftPaqSummary.SoftPaqID
               $HPSoftPaqDetails = $HPModelXML.newdataset.hpclientdriverpackcatalog.softpaqlist.softpaq | Where-Object {
                  $_.ID -eq "$HPSoftPaq"
               }
               $ComputerModelURL = $HPSoftPaqDetails.URL
               $DriverDownload = ($HPSoftPaqDetails.URL).TrimStart('ftp:')
               $DriverCab = $ComputerModelURL | Split-Path -Leaf
               $DriverRevision = "$($HPSoftPaqDetails.Version)"
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

            Write-CMLogEntry -Value "Info: $ComputerManufacturer $ComputerModel matching model type: $LenovoModelType" -Severity 1

            if ($LenovoModelDrivers)
            {
               [xml]$script:LenovoModelXML = (New-Object -TypeName System.Net.WebClient).DownloadString("$LenovoXMLSource")
               # Set XML Object
               $null = ($LenovoModelXML.GetType().FullName)
               $script:LenovoModelDrivers = $LenovoModelXML.Products

               if ($SystemSKU)
               {
                  $ComputerModelURL = (($LenovoModelDrivers.Product | Where-Object {
                           ($_.Queries.smbios -match $SystemSKU -and $_.OS -match $WindowsVersion)
                        }).driverPack | Where-Object {
                        $_.id -eq 'SCCM'
                     }).'#text'
               }
               else
               {
                  $ComputerModelURL = (($LenovoModelDrivers.Product | Where-Object {
                           ($_.Queries.Version -match ('^' + $ComputerModel + '$') -and $_.OS -match $WindowsVersion)
                        }).driverPack | Where-Object {
                        $_.id -eq 'SCCM'
                     }).'#text'
               }

               Write-CMLogEntry -Value "Info: Model URL determined as $ComputerModelURL" -Severity 1

               $DriverDownload = (FindLenovoDriver -URI $ComputerModelURL -os $WindowsVersion -Architecture $OSArchitecture)

               if ($DriverDownload)
               {
                  $DriverCab = $DriverDownload | Split-Path -Leaf
                  $DriverRevision = ($DriverCab.Split('_') | Select-Object -Last 1).Trim('.exe')

                  Write-CMLogEntry -Value "Info: Driver cabinet download determined as $DriverDownload" -Severity 1
               }
               else
               {
                  Write-CMLogEntry -Value "Error: Unable to find driver for $ComputerManufacturer $ComputerModel" -Severity 1
               }
            }
         }

         # Driver location variables
         $DriverSourceCab = ($TempDirectory + '\Driver Cab\' + $DriverCab)
         $DriverExtractDest = ("$TempDirectory" + '\Driver Files')

         Write-CMLogEntry -Value "Info: Driver extract location set - $DriverExtractDest" -Severity 1
         Write-CMLogEntry -Value "======== $Product - $ComputerManufacturer $ComputerModel DRIVER PROCESSING STARTED ========" -Severity 1
         Write-CMLogEntry -Value "$($Product): Retrieving ConfigMgr driver pack site For $ComputerManufacturer $ComputerModel" -Severity 1
         Write-CMLogEntry -Value "$($Product): URL found: $ComputerModelURL" -Severity 1

         if (($ComputerModelURL) -and ($DriverDownload -ne 'badLink'))
         {
            # Cater for HP / Model Issue
            $ComputerModel = $ComputerModel -replace '/', '-'
            $ComputerModel = $ComputerModel.Trim()
            Set-Location -Path $TempDirectory

            # Check for destination directory, create if required and download the driver cab
            if (-not (Test-Path -Path $($TempDirectory + '\Driver Cab\' + $DriverCab)))
            {
               if (-not (Test-Path -Path $($TempDirectory + '\Driver Cab')))
               {
                  $null = (New-Item -ItemType Directory -Path $($TempDirectory + '\Driver Cab') -Force)
               }

               Write-CMLogEntry -Value "$($Product): Downloading $DriverCab driver cab file" -Severity 1
               Write-CMLogEntry -Value "$($Product): Downloading from URL: $DriverDownload" -Severity 1

               $null = (Start-Job -Name "$ComputerModel-DriverDownload" -ScriptBlock $DriverDownloadJob -ArgumentList ($TempDirectory, $ComputerModel, $DriverCab, $DriverDownload))
               Start-Sleep -Seconds 5

               $BitsJob = Get-BitsTransfer | Where-Object {
                  $_.DisplayName -match "$ComputerModel-DriverDownload"
               }
               while (($BitsJob).JobState -eq 'Connecting')
               {
                  Write-CMLogEntry -Value "$($Product): Establishing connection to $DriverDownload" -Severity 1

                  Start-Sleep -Seconds 30
               }
               while (($BitsJob).JobState -eq 'Transferring')
               {
                  if ($BitsJob.BytesTotal)
                  {
                     $PercentComplete = [int](($BitsJob.BytesTransferred * 100) / $BitsJob.BytesTotal)


                     Write-CMLogEntry -Value "$($Product): Downloaded $([int]((($BitsJob).BytesTransferred)/ 1MB)) MB of $([int]((($BitsJob).BytesTotal)/ 1MB)) MB ($PercentComplete%). Next update in 30 seconds." -Severity 1

                     Start-Sleep -Seconds 30
                  }
                  else
                  {
                     Write-CMLogEntry -Value "$($Product): Download issues detected. Cancelling download process" -Severity 2

                     $null = (Get-BitsTransfer | Where-Object {
                           $_.DisplayName -eq "$ComputerModel-DriverDownload"
                        } | Remove-BitsTransfer)
                  }
               }

               $null = (Get-BitsTransfer | Where-Object {
                     $_.DisplayName -eq "$ComputerModel-DriverDownload"
                  } | Complete-BitsTransfer)

               Write-CMLogEntry -Value "$($Product): Driver revision: $DriverRevision" -Severity 1
            }
            else
            {
               Write-CMLogEntry -Value "$($Product): Skipping $DriverCab. Driver pack already downloaded." -Severity 1
            }

            # Cater for HP / Model Issue
            $ComputerModel = $ComputerModel -replace '/', '-'

            if (((Test-Path -Path "$($TempDirectory + '\Driver Cab\' + $DriverCab)") -eq $true) -and ($DriverCab))
            {
               Write-CMLogEntry -Value "$($Product): $DriverCab File exists - Starting driver update process" -Severity 1

               if ((Test-Path -Path "$DriverExtractDest" -ErrorAction SilentlyContinue) -eq $false)
               {
                  $null = (New-Item -ItemType Directory -Path "$($DriverExtractDest)" -Force)
               }

               if ((Get-ChildItem -Path "$DriverExtractDest" -Recurse -Filter *.inf -File -ErrorAction SilentlyContinue).Count -eq 0)
               {
                  Write-CMLogEntry -Value "==================== $Product DRIVER EXTRACT ====================" -Severity 1
                  Write-CMLogEntry -Value "$($Product): Expanding driver CAB source file: $DriverCab" -Severity 1
                  Write-CMLogEntry -Value "$($Product): Driver CAB destination directory: $DriverExtractDest" -Severity 1

                  if ($ComputerManufacturer -eq 'Dell')
                  {
                     Write-CMLogEntry -Value "$($Product): Extracting $ComputerManufacturer drivers to $DriverExtractDest" -Severity 1

                     $null = (& "$env:windir\system32\expand.exe" "$DriverSourceCab" -F:* "$DriverExtractDest")
                  }
                  if ($ComputerManufacturer -eq 'Hewlett-Packard')
                  {
                     Write-CMLogEntry -Value "$($Product): Extracting $ComputerManufacturer drivers to $DriverExtractDest" -Severity 1

                     # Driver Silent Extract Switches
                     $HPSilentSwitches = ('/s /e /f "' + $DriverExtractDest + '"')

                     Write-CMLogEntry -Value "$($Product): Using $ComputerManufacturer silent switches: $HPSilentSwitches" -Severity 1

                     $null = (Start-Process -FilePath "$($TempDirectory + '\Driver Cab\' + $DriverCab)" -ArgumentList $HPSilentSwitches -Verb RunAs)
                     $DriverProcess = ($DriverCab).Substring(0, $DriverCab.length - 4)

                     # Wait for HP SoftPaq Process To Finish
                     while ((Get-Process).name -contains $DriverProcess)
                     {
                        Write-CMLogEntry -Value "$($Product): Waiting for extract process (Process: $DriverProcess) to complete..  Next check in 30 seconds" -Severity 1

                        Start-Sleep -Seconds 30
                     }
                  }
                  if ($ComputerManufacturer -eq 'Lenovo')
                  {
                     # Driver Silent Extract Switches
                     $script:LenovoSilentSwitches = ('/VERYSILENT /DIR=' + '"' + $DriverExtractDest + '"' + ' /Extract="Yes"')

                     Write-CMLogEntry -Value "$($Product): Using $ComputerManufacturer silent switches: $LenovoSilentSwitches" -Severity 1
                     Write-CMLogEntry -Value "$($Product): Extracting $ComputerManufacturer drivers to $DriverExtractDest" -Severity 1

                     $null = (Unblock-File -Path $($TempDirectory + '\Driver Cab\' + $DriverCab))
                     $null = (Start-Process -FilePath "$($TempDirectory + '\Driver Cab\' + $DriverCab)" -ArgumentList $LenovoSilentSwitches -Verb RunAs)

                     $DriverProcess = ($DriverCab).Substring(0, $DriverCab.length - 4)

                     # Wait for Lenovo Driver Process To Finish
                     while ((Get-Process).name -contains $DriverProcess)
                     {
                        Write-CMLogEntry -Value "$($Product): Waiting for extract process (Process: $DriverProcess) to complete..  Next check in 30 seconds" -Severity 1

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
               Write-CMLogEntry -Value "$($Product): $DriverCab file download failed" -Severity 3
            }
         }
         elseif ($DriverDownload -eq 'badLink')
         {
            Write-CMLogEntry -Value "$($Product): Operating system driver package download path not found.. Skipping $ComputerModel" -Severity 3
         }
         else
         {
            Write-CMLogEntry -Value "$($Product): Driver package not found for $ComputerModel running Windows $WindowsVersion $OSArchitecture. Skipping $ComputerModel" -Severity 2
         }

         Write-CMLogEntry -Value "======== $Product - $ComputerManufacturer $ComputerModel DRIVER PROCESSING FINISHED ========" -Severity 1
      }
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
      #>
      [CmdletBinding(ConfirmImpact = 'None')]
      param ()

      begin
      {
         $DriverPackagePath = (Join-Path -Path $TempDirectory -ChildPath 'Driver Files')

         Write-CMLogEntry -Value "Driver package location is $DriverPackagePath" -Severity 1
         Write-CMLogEntry -Value 'Starting driver installation process' -Severity 1
         Write-CMLogEntry -Value "Reading drivers from $DriverPackagePath" -Severity 1
      }

      process
      {
         # Apply driver maintenance package
         try
         {
            if ((Get-ChildItem -Path $DriverPackagePath -Filter *.inf -Recurse).count -gt 0)
            {
               try
               {
                  $null = (Start-Process -FilePath 'powershell.exe' -WorkingDirectory $DriverPackagePath -ArgumentList "pnputil /add-driver *.inf /subdirs /install | Out-File -FilePath (Join-Path $LogDirectory '\Install-Drivers.txt') -Append" -NoNewWindow -Wait)

                  Write-CMLogEntry -Value 'Driver installation complete. Restart required' -Severity 1
               }
               catch
               {
                  Write-CMLogEntry -Value "An error occurred while attempting to apply the driver maintenance package. Error message: $($_.Exception.Message)" -Severity 3

                  exit 1
               }
            }
            else
            {
               Write-CMLogEntry -Value "No driver inf files found in $DriverPackagePath." -Severity 3

               exit 1
            }
         }
         catch
         {
            Write-CMLogEntry -Value "An error occurred while attempting to apply the driver maintenance package. Error message: $($_.Exception.Message)" -Severity 3

            exit 1
         }

         Write-CMLogEntry -Value 'Finished driver maintenance.' -Severity 1
      }

      end
      {
         return $LastExitCode
      }
   }
}

process
{
   if ($OSName -eq 'Windows 10')
   {
      # Download manufacturer lists for driver matching
      $null = (DownloadDriverList)

      # Initiate matched downloads
      $null = (InitiateDownloads)

      # Update driver repository and install drivers
      (Update-Drivers -ErrorAction Stop)
   }
   else
   {
      Write-CMLogEntry -Value 'An upsupported OS was detected. This script only supports Windows 10.' -Severity 3

      exit 1
   }
}

end
{
   $null = (Pop-Location)

   if (Get-Command -Name 'Set-MpPreference' -ErrorAction $SCT)
   {
      $null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction $SCT)
   }
}
