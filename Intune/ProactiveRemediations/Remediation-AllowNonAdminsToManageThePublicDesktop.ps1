#requires -Version 1.0

# Remediation-AllowNonAdminsToManageThePublicDesktop

try
{
   # Folder to modify
   $PublicDesktopPath = 'C:\Users\Public\Desktop'

   # Get the existing ACL
   $PublicDesktopAcl = (Get-Acl -Path $PublicDesktopPath -ErrorAction Stop)

   # Add 'S-1-5-11' a/k/a 'NT AUTHORITY\Authenticated Users' | https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-dtyp/81d92bba-d22b-4a8c-908a-554ab29148ab
   $SecurityIdentifier = (New-Object -TypeName System.Security.Principal.SecurityIdentifier -ArgumentList ('S-1-5-11'))

   # Rights to apply
   $FileSystemAccessRule = (New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList ($SecurityIdentifier, 'Modify', 'ContainerInherit,ObjectInherit', 'None', 'Allow'))

   # Modify the ACL object
   $PublicDesktopAcl.SetAccessRule($FileSystemAccessRule)

   # Apply the new ACL
   $null = (Set-Acl -Path $PublicDesktopPath -AclObject $PublicDesktopAcl -ErrorAction Stop)

   Exit 0
}
catch
{
   Exit 1
}
