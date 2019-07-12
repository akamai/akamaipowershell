function Dir-NetstorageDirectory {
    Param(
        [Parameter(Mandatory=$true)] [string] $Path,
        [Parameter(Mandatory=$true)] [string] $SubPath,
        [Parameter(Mandatory=$false)] [string] $AuthFile = "~/.akamai-cli/.netstorage/auth",
        [Parameter(Mandatory=$false)] [string] $Section = "default"
    )
    
    $Action = 'dir'

    $AdditionalOptions = @{
        'format' = 'sql'
        'path' = $SubPath
    }

    try {
        $Result = Invoke-AkamaiNSAPIRequest -Path $Path -Action $Action -AdditionalOptions $AdditionalOptions -AuthFile $Authfile -Section $Section
        return $Result.list.file
    }
    catch {
        throw $_
    }
    
}