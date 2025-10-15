
# get the Windows version information.
$currentVersionKey = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion')
$text = @"
$($currentVersionKey.ProductName) (Build $($currentVersionKey.CurrentBuildNumber))
Installed on $((Get-Date).ToString('yyyy-MM-dd'))
"@

# create the lock screen image.
$null = (Add-Type -AssemblyName System.Drawing)

$defaultLockScreenImagePath = "$env:WINDIR\Web\Screen\img100.jpg"
$localLockScreenImagePath = "$env:WINDIR\Web\Screen\local-lock-screen.jpg"
$image = [Drawing.Image]::FromFile($defaultLockScreenImagePath)
$graphics = [Drawing.Graphics]::FromImage($image)
$font = (New-Object -TypeName System.Drawing.Font -ArgumentList ('Arial', 42, [Drawing.FontStyle]::Bold))
$brush = [Drawing.Brushes]::WhiteSmoke
$outlineBrush = [Drawing.Brushes]::Gray
$padding = [float]($image.Width * 0.01)
$maxWidth = [float]($image.Width - (2 * $padding))
$maxHeight = [float]($image.Height - (2 * $padding))
$textRect = (New-Object -TypeName System.Drawing.RectangleF -ArgumentList ($padding, $padding, $maxWidth, $maxHeight))
$format = (New-Object -TypeName System.Drawing.StringFormat)
$format.Alignment = [Drawing.StringAlignment]::Center
$format.LineAlignment = [Drawing.StringAlignment]::Near
$offset = 2

for ($x = - $offset; $x -le $offset; $x++)
{
   for ($y = - $offset; $y -le $offset; $y++)
   {
      if ($x -ne 0 -or $y -ne 0)
      {
         $shadowRect = (New-Object -TypeName System.Drawing.RectangleF -ArgumentList (
               ($textRect.X + $x), 
               ($textRect.Y + $y), 
               $textRect.Width, 
               $textRect.Height
         ))
         $graphics.DrawString($text, $font, $outlineBrush, $shadowRect, $format)
      }
   }
}

$graphics.DrawString($text, $font, $brush, $textRect, $format)
$image.Save($localLockScreenImagePath, [Drawing.Imaging.ImageFormat]::Jpeg)
