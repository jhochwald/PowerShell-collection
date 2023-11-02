#requires -Version 1.0

<#
      .SYNOPSIS
      Shrink the Microsoft Entra Connect Synchronization Service SQL Express Database

      .DESCRIPTION
      Simple PowerShell Wrapper to automate the shrinking of the SQL Express Database,
      used by the Microsoft Entra Connect Synchronization Service

      .EXAMPLE
      PS C:\> .\Invoke-ShrinkADSyncSqlDatabase.ps1

      Shrink the Microsoft Entra Connect Synchronization Service SQL Express Database

      .LINK
      https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/tshoot-connect-recover-from-localdb-10gb-limit

      .NOTES
      Please read the comments in the code, the names might different in your setup!!!
      If you did that, and checked that everything is fine, you can change the $ReviewAndExecute to $true, or remove it from the code.

      SQL Express has a database limit of 10GB!
      If your Microsoft Entra Connect Synchronization Service SQL Express Database is nearing the limit of 10 GB,
      or has already reached it, shrinking the database might be a cool thing to do.

      Typical messages, when your system reached the limit:
      - "stopped-database-disk-full" when running the Microsoft Entra Connect Synchronization Service - And your "DISK" still has enough space left
      - Event ID 6323 (The server encountered an error because SQL Server is out of disk space.)

      With disk space, the messages mean the size of the SQL Express Database! It will not go beyond the 10 GB limit!

      Some final words:
      This is nothing that you should run daily!!! Under normal circumstances, you will never need this script anyway!
      The Microsoft Entra Connect Synchronization Service will delete the sync history 7 days (at least by default), and should never reach the 10GB limit.
      If you read the Microsoft pages, the message is Cristal clear:
      > DO NOT RUN THIS, IF YOU DON'T HAVE TO!
      With "THIS", they mean shrinking the database...

      And I agree here! Shrinking the database might cause issues, it can cause fragmentation of the database and this can decrease the performance a lot!

      Why do I have this script anyway? I had to fix an issue for a customer and I wasn't allowed to run it by myself.
      I had to provide a script to do the job and the operations team executed it (without me).
      I decided to publish it now, while I changed the naming from "Azure AD Connect" to "Microsoft Entra Connect Synchronization Service".
      Funny story, because the product itself is still called "Azure AD Connect" and all the basic rules contains AAD in the names.

      And why is my approach slightly different from the Microsoft docs page? Well, I use SQL pipes for stuff like this, that's why ;-)
#>
[CmdletBinding(ConfirmImpact = 'None')]
[OutputType([string])]
param ()

begin
{
   #region
   $ReviewAndExecute = $false

   # Let's check if you are a smart bear
   if ($ReviewAndExecute -eq $false)
   {
      # Shame on you, you did NOT read the comments above
      $paramWriteError = @{
         Exception         = 'unwilling to perform'
         Message           = 'Did you read the comment above? No you did not...'
         Category          = 'NotEnabled'
         TargetObject      = $ReviewAndExecute
         RecommendedAction = 'RTFM'
         ErrorAction       = 'Stop'
      }
      Write-Error @paramWriteError

      # Don't go any further - enforce that
      exit 1
   }
   #endregion

   # Where to store the command file
   $SqlCmdPath = ('{0}\ADSyncCleanup.sql' -f $env:TEMP)

   $paramRemoveItem = @{
      Path        = $SqlCmdPath
      Force       = $true
      Confirm     = $false
      ErrorAction = 'SilentlyContinue'
   }
   $null = (Remove-Item @paramRemoveItem)

   #region
   $paramOutFile = @{
      FilePath    = $SqlCmdPath
      Encoding    = 'utf8'
      Force       = $true
      Confirm     = $false
      ErrorAction = 'Stop'
   }

   # Check the Database name, but "ADSync" should work most of the time!
   $null = (@'
DBCC Shrinkdatabase(ADSync,1);
GO
'@ | Out-File @paramOutFile)
   $paramOutFile = $null
   #endregion
}

process
{
   <#
         Execute the SQL Statement
         And here is, where things are getting complicated for us...
         1. Check the Path of the SQLCMD.EXE below
         2. The Database (SH950A3B) is deferent most of the time
   #>
   & "$env:ProgramW6432\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\SQLCMD.EXE" @('-I', '-S', 'np:\\.\pipe\LOCALDB#SH950A3B\tsql\query', '-i', $SqlCmdPath)
}

end
{
   $null = (Remove-Item @paramRemoveItem)

   $paramRemoveItem = $null
   $SqlCmdPath = $null
}