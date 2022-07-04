function Get-DeviceAutoPilotInfo
{
   <#
         .SYNOPSIS
         Get the devices AutoPilot Info

         .DESCRIPTION
         Get the devices AutoPilot Info

         .EXAMPLE
         Get-DeviceAutoPilotInfo
         Get the devices AutoPilot Info

         .LINK
         Get-WindowsAutoPilotInfo

         .LINK
         https://www.powershellgallery.com/packages/Get-WindowsAutoPilotInfo

         .NOTES
         Based on the idea of Get-WindowsAutoPilotInfo from Michael Niehaus

         This functions exists, to get rid of the dependency,
         in other cases we still use the Get-WindowsAutoPilotInfo

         We removed a lot off overhead to keep it simple (just do what we want)
   #>

   begin
   {
      #region Clean-up
      $DeviceAutoPilotInfo = $null
      $DeviceName = $null
      $DeviceHash = $null
      $DeviceSerial = $null
      $DeviceManufacturer = $null
      $DeviceModel = $null
      $DeviceDetail = $null
      $ComputerSystemInfo = $null
      #endregion Clean-up

      # Defaults
      $SCT = 'SilentlyContinue'
   }

   process
   {
      $DeviceName = $env:COMPUTERNAME

      # Get the full serial
      $paramGetCimInstance = @{
         ClassName   = 'Win32_BIOS'
         ErrorAction = $SCT
      }
      $DeviceSerial = (Get-CimInstance @paramGetCimInstance).SerialNumber
      $paramGetCimInstance = $null

      # Get the hash (Hint: Do NOT compare the hash, it will change every time you create it! e.g., it uses Uses DateTime)
      $paramGetCimInstance = @{
         Namespace   = 'root/cimv2/mdm/dmmap'
         ClassName   = 'MDM_DevDetail_Ext01'
         Filter      = "InstanceID='Ext' AND ParentID='./DevDetail'"
         ErrorAction = $SCT
      }
      $DeviceDetail = (Get-CimInstance @paramGetCimInstance)
      $paramGetCimInstance = $null

      # Save the info
      $paramGetCimInstance = @{
         ClassName   = 'Win32_ComputerSystem'
         ErrorAction = $SCT
      }
      $ComputerSystemInfo = (Get-CimInstance @paramGetCimInstance)
      $paramGetCimInstance = $null

      if ($ComputerSystemInfo)
      {
         $DeviceManufacturer = $ComputerSystemInfo.Manufacturer.Trim()
         $DeviceModel = $ComputerSystemInfo.Model.Trim()
         $ComputerSystemInfo = $null
      }
      else
      {
         $DeviceManufacturer = $null
         $DeviceModel = $null
      }

      # Save the hash
      if ($DeviceDetail)
      {
         $DeviceHash = $DeviceDetail.DeviceHardwareData
      }
      else
      {
         $DeviceHash = $null
      }
   }

   end
   {
      # Create our own object
      $DeviceAutoPilotInfo = [PSCustomObject][ordered]@{
         Name         = $DeviceName
         Hash         = $DeviceHash
         Serial       = $DeviceSerial
         Manufacturer = $DeviceManufacturer
         Model        = $DeviceModel
      }

      # Dump it to the terminal (perfect for pipeline usage)
      $DeviceAutoPilotInfo

      #region Clean-up
      $DeviceAutoPilotInfo = $null
      $DeviceName = $null
      $DeviceHash = $null
      $DeviceSerial = $null
      $DeviceManufacturer = $null
      $DeviceModel = $null
      $DeviceDetail = $null
      $ComputerSystemInfo = $null
      #endregion Clean-up
   }
}

