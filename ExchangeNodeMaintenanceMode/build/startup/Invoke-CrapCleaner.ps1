function Invoke-CrapCleaner 
	{
		<#
				.SYNOPSIS
				Describe purpose of "Invoke-CrapCleaner" in 1-2 sentences.

				.DESCRIPTION
				Add a more complete description of what the function does.
		#>

		BEGIN
		{
			$Dummy = 'Uncritical Problem'
			$filter2 = '00000000-0000-0000-0000-000000000000 '
			$Filter1 = ' 00000000-0000-0000-0000-000000000000'
			$SC = 'SilentlyContinue'
		}

		PROCESS {
			$ModTempPath = "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\ExchangeNodeMaintenanceMode"
			$filter = $Filter1

			$paramGetChildItem = @{
				Recurse       = $true
				Path          = $ModTempPath
				ErrorAction   = $SC
				WarningAction = $SC
			}
			$foo = $null
			$foo = (Get-ChildItem @paramGetChildItem | Where-Object -FilterScript {
					$_.Name -match $filter
			})

			if ($foo)
			{
				foreach ($Renamer in $foo) 
				{
					$paramRenameItem = @{
						Path    = $Renamer.FullName
						NewName = $Renamer.FullName -replace "$filter" -replace ''
						Force   = $true
						Confirm = $false
					}
					try 
					{
						Rename-Item @paramRenameItem
					}
					catch 
					{
						Write-Verbose -Message $Dummy
					}
				}
			}

			$filter = $filter2

			$paramGetChildItem = @{
				Recurse       = $true
				Path          = $ModTempPath
				ErrorAction   = $SC
				WarningAction = $SC
			}
			$foo = $null
			$foo = (Get-ChildItem @paramGetChildItem | Where-Object -FilterScript {
					$_.Name -match $filter
			})

			if ($foo)
			{
				foreach ($Renamer in $foo) 
				{
					$paramRenameItem = @{
						Path    = $Renamer.FullName
						NewName = $Renamer.FullName -replace "$filter" -replace ''
						Force   = $true
						Confirm = $false
					}
					try 
					{
						Rename-Item @paramRenameItem
					}
					catch 
					{
						Write-Verbose -Message $Dummy
					}
				}
			}

			$BuildTempPath = "$env:USERPROFILE\Documents\ExchangeNodeMaintenanceMode\"
			$filter = $Filter1

			$paramGetChildItem = @{
				Recurse       = $true
				Path          = $BuildTempPath
				ErrorAction   = $SC
				WarningAction = $SC
			}
			$foo = $null
			$foo = Get-ChildItem @paramGetChildItem | Where-Object -FilterScript {
				$_.Name -match $filter
			}

			if ($foo) 
			{
				foreach ($Renamer in $foo) 
				{
					$paramRenameItem = @{
						Path    = $Renamer.FullName
						NewName = $Renamer.FullName -replace "$filter" -replace ''
						Force   = $true
						Confirm = $false
					}
					try 
					{
						Rename-Item @paramRenameItem
					}
					catch 
					{
						Write-Verbose -Message $Dummy
					}
				}
			}

			$filter = $filter2

			$paramGetChildItem = @{
				Recurse       = $true
				Path          = $BuildTempPath
				ErrorAction   = $SC
				WarningAction = $SC
			}
			$foo = $null
			$foo = Get-ChildItem @paramGetChildItem | Where-Object -FilterScript {
				$_.Name -match $filter
			}

			if ($foo) 
			{
				foreach ($Renamer in $foo) 
				{
					$paramRenameItem = @{
						Path    = $Renamer.FullName
						NewName = $Renamer.FullName -replace "$filter" -replace ''
						Force   = $true
						Confirm = $false
					}
					try 
					{
						Rename-Item @paramRenameItem
					}
					catch 
					{
						Write-Verbose -Message $Dummy
					}
				}
			}
		}
	}

Invoke-CrapCleaner