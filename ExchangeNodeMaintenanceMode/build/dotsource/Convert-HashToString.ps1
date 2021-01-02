function Script:Convert-HashToString
{
    [cmdletbinding()]
    
    Param  (
        [Parameter(Mandatory=$true,Position=0)]
        [Hashtable]$Hashtable,
        
        [Parameter(Mandatory=$False)]
        [switch]$Flatten
    )

    Begin{
        If($Flatten -or $Hashtable.Keys.Count -eq 0)
        {
            $Mode = 'Append'
            $Indenting = ''
            $RecursiveIndenting = ''
        }
        Else{
            $Mode = 'Appendline'
            $Indenting = '    '
            $RecursiveIndenting = '    ' * (Get-PSCallStack).Where({$_.Command -match 'Convert-ArrayToString|Convert-HashToSTring' -and $_.InvocationInfo.CommandOrigin -eq 'Internal' -and $_.InvocationInfo.Line -notmatch '\$This'}).Count
        }
    }
    
    Process{
        $StringBuilder = [System.Text.StringBuilder]::new()
        
        If($Hashtable.Keys.Count -ge 1)
        {
            [void]$StringBuilder.$Mode("@{")
        }
        Else
        {
            [void]$StringBuilder.Append("@{")    
        }
        
        Foreach($Key in $Hashtable.Keys)
        {
            $Value = $Hashtable[$Key]
            
            If($Key -match '\s')
            {
                $Key = "'$Key'"
            }
            
            If($Value -is [String])
            {
                [void]$StringBuilder.$Mode($Indenting + $RecursiveIndenting + "$Key = '$Value'")
            }
            ElseIf($Value -is [int] -or $Value -is [double])
            {
                [void]$StringBuilder.$Mode($Indenting + $RecursiveIndenting + "$Key = $($Value.ToString())")
            }
            ElseIf($Value -is [bool])
            {
                [void]$StringBuilder.$Mode($Indenting + $RecursiveIndenting + "$Key = `$$Value")
            }
            ElseIf($Value -is [array])
            {
                $Value = Convert-ArrayToString -Array $Value -Flatten:$Flatten
                
                [void]$StringBuilder.$Mode($Indenting + $RecursiveIndenting + "$Key = $Value")
            }
            ElseIf($Value -is [hashtable])
            {
                $Value = Convert-HashToSTring -Hashtable $Value -Flatten:$Flatten
                [void]$StringBuilder.$Mode($Indenting + $RecursiveIndenting + "$Key = $Value")
            }
            Else
            {
                Throw "Key value is not of known type."    
            }
            
            If($Flatten){[void]$StringBuilder.Append("; ")}
        }
        
        [void]$StringBuilder.Append($RecursiveIndenting + "}")
        
        $StringBuilder.ToString().Replace("; }",'}')
    }
    
    End{}
}

#Remove-TypeData -TypeName System.Collections.HashTable -ErrorAction SilentlyContinue
#Update-TypeData -TypeName System.Collections.HashTable -MemberType ScriptMethod -MemberName ToString -Value {Convert-HashToString $This}