function Set-DesktopBackGroundColor
{
   <#
         .SYNOPSIS
         Set the desktop background to a given RGB color.

         .DESCRIPTION
         Set the desktop background to a given RGB color,
         the changes will take effect immediately.

         .PARAMETER Red
         Red Value, e.g., 0

         .PARAMETER Green
         Green Value, e.g., 0

         .PARAMETER Blue
         Blue Value, e.g., 0

         .EXAMPLE
         PS C:\> Set-DesktopBackGroundColor

         .EXAMPLE
         Set-DesktopBackGroundColor -Red 0 -Green 0 -Blue 0

         Set the background color to black

         .EXAMPLE
         Set-DesktopBackGroundColor -R 0 -G 0 -B 0

         Set the background color to black, using parameter aliases!

         .LINK
         https://www.powershellgallery.com/packages/Set-DesktopBackGround/1.0.0.0

         .NOTES
         I changed the C# Code a bit (mostly refactoring), and also changed the parameter names.
         Parameter aliases are added to keep it compatible with Jeffrey Snover's version.

         The core of this code was produced by http://stackoverflow.com/users/3281719/wheatfairies who published
         it here http://stackoverflow.com/questions/25774494/powershell-make-desktop-background-changes-take-effect-immediately
   #>
   [CmdletBinding(ConfirmImpact = 'Low',
   SupportsShouldProcess)]
   param
   (
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 0)]
      [ValidateNotNullOrEmpty()]
      [Alias('R')]
      [int]
      $Red = 81,
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 1)]
      [ValidateNotNullOrEmpty()]
      [Alias('G')]
      [int]
      $Green = 92,
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 2)]
      [ValidateNotNullOrEmpty()]
      [Alias('B')]
      [int]
      $Blue = 107
   )
   
   begin
   {
      #region RemoveBackgroundImage
      # Set the wallpaper PATH to NULL (could be set to '' as well)
      $RegistryKey = 'HKCU:\Control Panel\Desktop'
      
      $null = (Set-ItemProperty -Path $RegistryKey -Name 'WallPaper' -Value $null -Force -Confirm:$false -ErrorAction SilentlyContinue -WarningAction SilentlyContinue)
      #endregion RemoveBackgroundImage
      
      #region CsharpCode
      #  Changes c# code 
      $code = @'
using System.Runtime.InteropServices;
using Microsoft.Win32;

namespace CurrentUser
{
    public class Desktop
    {
        private const int UpdateIniFile = 0x01;
        private const int SendWinIniChange = 0x02;
        private const int SetDesktopBackground = 0x0014;
        private const int ColorDesktop = 1;
        public int[] First = { ColorDesktop };

        [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
        private static extern int SystemParametersInfo(
            int uAction,
            int uParm,
            string lpvParam,
            int fuWinIni
        );

        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        private static extern int SetSysColors(int cElements, int[] lpaElements, int[] lpRgbValues);

        private static void RemoveWallPaper()
        {
            SystemParametersInfo(SetDesktopBackground, 0, "", SendWinIniChange | UpdateIniFile);
            RegistryKey regkey = Registry.CurrentUser.OpenSubKey("Control Panel\\Desktop", true);
            if (regkey == null)
                return;
            regkey.SetValue(@"WallPaper", 0);
            regkey.Close();
        }

        public static void SetBackground(byte r, byte g, byte b)
        {
            int[] elements = { ColorDesktop };
            RemoveWallPaper();
            System.Drawing.Color color = System.Drawing.Color.FromArgb(r, g, b);
            int[] colors = { System.Drawing.ColorTranslator.ToWin32(color) };
            SetSysColors(elements.Length, elements, colors);
            RegistryKey key = Registry.CurrentUser.OpenSubKey("Control Panel\\Colors", true);
            if (key == null)
                return;
            key.SetValue(@"Background", string.Format("{0} {1} {2}", color.R, color.G, color.B));
            key.Close();
        }
    }
}
'@
      #endregion CsharpCode
   }
   
   process
   {
      if ($pscmdlet.ShouldProcess('Background Color', ('Set it to {0} {1} {2}' -f $Red, $Green, $Blue)))
      {
         try
         {
            # Load the C# Code, with a reference to System.Drawing.dll
            $null = (Add-Type -TypeDefinition $code -Language CSharp -ReferencedAssemblies System.Drawing.dll -IgnoreWarnings -ErrorAction Stop -WarningAction SilentlyContinue)
         }
         catch
         {
            Write-Verbose -Message 'Seems that this was loaded before, but we try it anyway!'
         }
         finally
         {
            # Execute it anyway, no matter what!
            [CurrentUser.Desktop]::SetBackground($Red, $Green, $Blue)
         }
      }
   }

   end
   {
      $code = $null
   }
}
