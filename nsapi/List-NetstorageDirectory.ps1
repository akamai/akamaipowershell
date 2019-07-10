function List-NetstorageDirectory {
    Param(
        [Parameter(Mandatory=$true)] [string] $Path,
        [Parameter(Mandatory=$false)] [string] $AuthFile = "~/.akamai-cli/.netstorage/auth",
        [Parameter(Mandatory=$false)] [string] $Section = "default"
    )
    
    $Action = "list"

    $AdditionalOptions = @{
        'format' = 'sql'
    }

    try {
        $Result = Invoke-AkamaiNSAPIRequest -Path $Path -Action $Action -AdditionalOptions $AdditionalOptions -AuthFile $Authfile -Section $Section
        return $Result.list.file
    }
    catch {
        throw $_
    }
    
}