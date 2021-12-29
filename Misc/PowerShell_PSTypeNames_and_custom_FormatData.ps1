<#
   .SYNOPSIS
   Set the Default Property Display in PowerShell on Custom Objects

   .DESCRIPTION
   Set the Default Property Display in PowerShell on Custom Objects
   Sample code for a blog post

   .EXAMPLE
   PS C:\> .\PowerShell_PSTypeNames_and_custom_FormatData.ps1

   .LINK
   https://hochwald.net

   .LINK
   https://github.com/jhochwald/PowerShell-collection/blob/master/ExchangeOnline/Search-MailboxItemDeletion.ps1

   .NOTES
   Sample code for a blog post
   The functions are just to describe a use case, they make no real sense!

   A real world use case is linked above
#>

function Get-MyProcessOne
{
   <#
      .SYNOPSIS
      Get a subset of values from Get-Process

      .DESCRIPTION
      Get a subset of values from Get-Process,
      to get less values you might want to filter them!

      This can get noisy and complicated, especially if you do not know
      all the values or if more come (e.g., for API's ?)

      .EXAMPLE
      PS C:\> Get-MyProcessOne

      Get a subset of values from Get-Process

      .EXAMPLE
      PS C:\> Get-MyProcessOne | Select-Object -Property Name, Id, CPU

      Get a subset of values from Get-Process and filter it

      .EXAMPLE
      PS C:\> Get-MyProcessOne | Get-Member

      Viewing Object Structure (Get-Member)

      .NOTES
      This is a very simple thing, right?
      The TypeName is Selected.System.Diagnostics.Process

      .LINK
      https://devblogs.microsoft.com/powershell/psstandardmembers-the-stealth-property/

      .LINK
      Get-Process
   #>

   # Cleanup
   $ProcessList = $null

   # Gather the Info
   $ProcessList = (Get-Process | Select-Object -Property Name, Id, PriorityClass, FileVersion, Path, Company, CPU, ProductVersion, Description, Product, ProcessName)

   # Dump the Report
   $ProcessList

   # Free-up the memory
   $ProcessList = $null

   #region GarbageCollection
   [GC]::Collect()
   [GC]::WaitForPendingFinalizers()
   #endregion GarbageCollection
}
Get-MyProcessOne
Get-MyProcessOne | Select-Object -Property Name, Id, CPU
Get-MyProcessOne | Get-Member

function Get-MyProcessTwo
{
   <#
      .SYNOPSIS
      Get a subset of values from Get-Process as PSCustomObject

      .DESCRIPTION
      Get a subset of values from Get-Process as PSCustomObject,
      to get less values you might want to filter them!

      This can get noisy and complicated, especially if you do not know
      all the values or if more come (e.g., for API's ?)

      .EXAMPLE
      PS C:\> Get-MyProcessTwo

      Get a subset of values from Get-Process as PSCustomObject

      .EXAMPLE
      PS C:\> Get-MyProcessTwo | Select-Object -Property Name, Id, CPU

      Get a subset of values from Get-Process as PSCustomObject

      .EXAMPLE
      PS C:\> Get-MyProcessTwo | Get-Member

      Viewing Object Structure (Get-Member)

      .NOTES
      Very similar to Get-MyProcessOne, but we use a PSCustomObject

      .LINK
      https://devblogs.microsoft.com/powershell/psstandardmembers-the-stealth-property/
   #>
   [OutputType([pscustomobject])]
   [CmdletBinding()]
   param ()

   # Cleanup
   $ProcessList = $null

   # Gather the Info
   $ProcessList = Get-Process | ForEach-Object -Process {
      [PSCustomObject]@{
         Name           = $_.Name
         Id             = $_.Id
         PriorityClass  = $_.PriorityClass
         FileVersion    = $_.FileVersion
         Path           = $_.Path
         Company        = $_.Company
         CPU            = $_.CPU
         ProductVersion = $_.ProductVersion
         Description    = $_.Description
         Product        = $_.Product
         ProcessName    = $_.ProcessName
      }
   }

   # Dump the Report
   $ProcessList

   # Free-up the memory
   $ProcessList = $null

   #region GarbageCollection
   [GC]::Collect()
   [GC]::WaitForPendingFinalizers()
   #endregion GarbageCollection
}
Get-MyProcessTwo
Get-MyProcessTwo | Select-Object -Property Name, Id, CPU
Get-MyProcessTwo | Get-Member

function Get-MyProcessThree
{
   <#
      .SYNOPSIS
      Use TypeData to display a subset of values

      .DESCRIPTION
      Use TypeData to display a subset of values,
      but you can use select to get more values from the return

      .EXAMPLE
      PS C:\> Get-MyProcessThree

      Use TypeData to display a subset of values

      .EXAMPLE
      PS C:\> Get-MyProcessThree | Select-Object -Property *

      Use TypeData to display a subset of values, in this case all values we know

      .EXAMPLE
      PS C:\> Get-MyProcessThree | Get-Member

      Viewing Object Structure (Get-Member)

      .NOTES
      Place additional notes here.

      .LINK
      https://devblogs.microsoft.com/powershell/psstandardmembers-the-stealth-property/

      .LINK
      https://powershell.one/powershell-internals/functions/using-propertysets

      .LINK
      https://learn-powershell.net/2013/08/03/quick-hits-set-the-default-property-display-in-powershell-on-custom-objects/

      .LINK
      http://stackoverflow.com/questions/1369542/can-you-set-an-objects-defaultdisplaypropertyset-in-a-powershell-v2-script/1891215#1891215
   #>
   [OutputType([pscustomobject])]
   [CmdletBinding()]
   param ()

   # Cleanup
   $ProcessList = $null

   # Gather the Info
   $ProcessList = Get-Process | ForEach-Object -Process {
      [PSCustomObject]@{
         PSTypeName     = 'MyProcessList'
         Name           = $_.Name
         Id             = $_.Id
         PriorityClass  = $_.PriorityClass
         FileVersion    = $_.FileVersion
         Path           = $_.Path
         Company        = $_.Company
         CPU            = $_.CPU
         ProductVersion = $_.ProductVersion
         Description    = $_.Description
         Product        = $_.Product
         ProcessName    = $_.ProcessName
      }
   }

   # Remove the existing TypeName
   Remove-TypeData -TypeName MyProcessList -ErrorAction SilentlyContinue

   # Configure a default display set for the TypeName
   Update-TypeData -TypeName MyProcessList -DefaultDisplayPropertySet 'Name', 'Id', 'CPU'

   # Dump the Report
   $ProcessList

   # Free-up the memory
   $ProcessList = $null

   #region GarbageCollection
   [GC]::Collect()
   [GC]::WaitForPendingFinalizers()
   #endregion GarbageCollection
}
Get-MyProcessThree
Get-MyProcessThree | Select-Object -Property *
Get-MyProcessThree | Get-Member

function Get-MyProcessFour
{
   <#
      .SYNOPSIS
      Use PSStandardMembers to display a subset of values

      .DESCRIPTION
      Use PSStandardMembers to display a subset of values,
      but you can use select to get more values from the return

      .EXAMPLE
      PS C:\> Get-MyProcessFour

      Use PSStandardMembers to display a subset of values

      .EXAMPLE
      PS C:\> Get-MyProcessFour | Select-Object -Property *

      Use PSStandardMembers to display a subset of values, in this case all values we know

      .EXAMPLE
      PS C:\> Get-MyProcessFour | Get-Member

      Viewing Object Structure (Get-Member)

      .NOTES
      This is what I used most in the past e.g., for Search-MailboxItemDeletion

      .LINK
      https://devblogs.microsoft.com/powershell/psstandardmembers-the-stealth-property/

      .LINK
      https://github.com/jhochwald/PowerShell-collection/blob/master/ExchangeOnline/Search-MailboxItemDeletion.ps1

      .LINK
      https://powershell.one/powershell-internals/functions/using-propertysets

      .LINK
      https://learn-powershell.net/2013/08/03/quick-hits-set-the-default-property-display-in-powershell-on-custom-objects/

      .LINK
      http://stackoverflow.com/questions/1369542/can-you-set-an-objects-defaultdisplaypropertyset-in-a-powershell-v2-script/1891215#1891215
   #>
   [OutputType([pscustomobject])]
   [CmdletBinding()]
   param ()

   # Configure a default display set
   $defaultDisplaySet = 'Name', 'Id', 'CPU'

   # Configure a default display set
   $defaultDisplayPropertySet = (New-Object -TypeName System.Management.Automation.PSPropertySet -ArgumentList ('DefaultDisplayPropertySet', [string[]]$defaultDisplaySet))
   $PSStandardMembers = [Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)

   $ProcessList = $null

   # Gather the Info
   $ProcessList = Get-Process | ForEach-Object -Process {
      [PSCustomObject]@{
         PSTypeName     = 'MyProcessList'
         Name           = $_.Name
         Id             = $_.Id
         PriorityClass  = $_.PriorityClass
         FileVersion    = $_.FileVersion
         Path           = $_.Path
         Company        = $_.Company
         CPU            = $_.CPU
         ProductVersion = $_.ProductVersion
         Description    = $_.Description
         Product        = $_.Product
         ProcessName    = $_.ProcessName
      }
   }

   # Give the object a unique TypeName
   $ProcessList.PSObject.TypeNames.Insert(0, 'MyProcessList.Information')
   $ProcessList | Add-Member -NotePropertyName MemberSet -NotePropertyValue PSStandardMembers -InputObject $PSStandardMembers

   # Dump the Report
   $ProcessList

   # Free-up the memory
   $ProcessList = $null

   #region GarbageCollection
   [GC]::Collect()
   [GC]::WaitForPendingFinalizers()
   #endregion GarbageCollection
}
Get-MyProcessFour
Get-MyProcessFour | Select-Object -Property *
Get-MyProcessFour | Get-Member

function Get-MyProcessFive
{
   <#
      .SYNOPSIS
      Change the display of objects or to define default displays for new object we created

      .DESCRIPTION
      Change the display of objects or to define default displays for new object we created in Windows PowerShell
      It uses a simple Format.ps1xml file to do so!

      Beginning in PowerShell 6, the default views are defined in PowerShell source code.
      The Format.ps1xml files from Windows PowerShell 5.1 and earlier versions don't exist in PowerShell Core 6 and later versions.

      .EXAMPLE
      PS C:\> Get-MyProcessFive

      Change the display of objects or to define default displays for new object we created

      .EXAMPLE
      PS C:\> Get-MyProcessFive | Select-Object -Property *

      Change the display of objects or to define default displays for new object we created,
      in this case all values we know

      .EXAMPLE
      PS C:\> Get-MyProcessFive | Get-Member

      Viewing Object Structure (Get-Member)

      .NOTES
      To be honest: This example is nonsense!

      You would never do that, using Format.ps1xml is nice for Windows PowerShell modules,
      creating the file on the fly (like in the example) is something I would never so,
      and you should avoid that as well!

      Please keep that in mind!

      And again: This is for Windows PowerShell only!
      with PowerShell Core 6, the default views for objects are defined in PowerShell source code.

      You can also create Table views, please see the links below!

      .LINK
      https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_format.ps1xml

      .LINK
      https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/update-formatdata

      .LINK
      https://powershell.one/powershell-internals/functions/using-propertysets
   #>

   #region ps1xmlDemo
   <#
      Formats (.ps1xml files) are typically used within PowerShell modules, this is just a sample and makes it way more complex

      Normally you would the all your Formats (.ps1xml files) in a dedicated subfolder within you PowerShell module folder,
      and include them via the module manifest.

      I personally recommend to use the subfolder named "Formats" in your module folder.
      In this case the sample below would be included in the manifest like this:

      FormatsToProcess = @("Formats/MyProcessListView.format.ps1xml")

      Please note: the .format. part in the name is not required, it is some of my personal preferences.
   #>
   #region ps1xmlCleanup
   # Format File name and Path
   $FormatFile = 'MyProcessListView.format.ps1xml'

   if (Test-Path -Path $FormatFile -ErrorAction SilentlyContinue)
   {
      $null = (Remove-Item -Path $FormatFile -Force -Confirm:$false)
   }
   #endregion ps1xmlCleanup

   #region ps1xmlHandler
   # Create the ps1xml content in memory
   $FormatData = @'
<?xml version="1.0" encoding="utf-8" ?>
<Configuration>
   <ViewDefinitions>
      <View>
         <Name>MyProcessListViewTable</Name>
         <ViewSelectedBy>
            <TypeName>MyProcessListView</TypeName>
         </ViewSelectedBy>
         <ListControl>
            <ListEntries>
                  <ListEntry>
                     <ListItems>
                        <ListItem>
                              <PropertyName>Name</PropertyName>
                        </ListItem>
                        <ListItem>
                              <PropertyName>Id</PropertyName>
                        </ListItem>
                        <ListItem>
                              <PropertyName>CPU</PropertyName>
                        </ListItem>
                     </ListItems>
                  </ListEntry>
            </ListEntries>
         </ListControl>
      </View>
   </ViewDefinitions>
</Configuration>
'@
   # Write the ps1xml file
   $FormatData | Set-Content -Path $FormatFile -Force

   # Free-up the memory
   $FormatData = $null

   # Use the ps1xml format file
   Update-FormatData -AppendPath $FormatFile
   #endregion ps1xmlHandler
   #endregion ps1xmlDemo

   # Cleanup
   $ProcessList = $null

   # Gather the Info
   $ProcessList = Get-Process | ForEach-Object -Process {
      [PSCustomObject]@{
         PSTypeName     = 'MyProcessListView'
         Name           = $_.Name
         Id             = $_.Id
         PriorityClass  = $_.PriorityClass
         FileVersion    = $_.FileVersion
         Path           = $_.Path
         Company        = $_.Company
         CPU            = $_.CPU
         ProductVersion = $_.ProductVersion
         Description    = $_.Description
         Product        = $_.Product
         ProcessName    = $_.ProcessName
      }
   }

   # Dump the Report
   $ProcessList

   #region ps1xmlCleanup
   if (Test-Path -Path $FormatFile -ErrorAction SilentlyContinue)
   {
      Remove-Item -Path $FormatFile -Force -Confirm:$false
   }

   # Free-up the memory
   $FormatFile = $null
   #endregion ps1xmlCleanup

   # Free-up the memory
   $ProcessList = $null

   #region GarbageCollection
   [GC]::Collect()
   [GC]::WaitForPendingFinalizers()
   #endregion GarbageCollection
}
Get-MyProcessFive
Get-MyProcessFive | Select-Object -Property *
Get-MyProcessFive | Get-Member
