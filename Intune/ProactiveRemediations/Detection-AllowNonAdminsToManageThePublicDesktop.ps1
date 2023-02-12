#requires -Version 1.0

# Detection-AllowNonAdminsToManageThePublicDesktop

try
{
   # 'S-1-5-11' is 'NT AUTHORITY\Authenticated Users' | https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-dtyp/81d92bba-d22b-4a8c-908a-554ab29148ab
   $AuthenticatedUsersSID = (New-Object -TypeName System.Security.Principal.SecurityIdentifier -ArgumentList ('S-1-5-11'))

   # Get the name for the given SID
   $AuthenticatedUsersObject = $AuthenticatedUsersSID.Translate( [Security.Principal.NTAccount])

   # Save the name for the SID
   $AuthenticatedUsers = $AuthenticatedUsersObject.Value

   # Folder to check
   $PublicDesktopPath = 'C:\Users\Public\Desktop'

   # Get existing ACL
   $PublicDesktopAcl = (Get-Acl -Path $PublicDesktopPath -ErrorAction Stop)

   # Compare
   if ($PublicDesktopAcl.Access | Where-Object -FilterScript {
         (($_.IdentityReference -eq $AuthenticatedUsers) -and ($_.AccessControlType -eq 'Allow') -and ($_.FileSystemRights -match 'Modify') -and ($_.FileSystemRights -match 'Synchronize'))
   })
   {
      # Match
      Exit 0
   }
   else
   {
      # No match
      Exit 1
   }
}
catch
{
   Exit 1
}

# Just in case
Exit 0