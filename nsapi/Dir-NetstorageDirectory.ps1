function Dir-NetstorageDirectory {
    Param(
        [Parameter(Mandatory=$true)] [string] $Path,
        [Parameter(Mandatory=$false)] [string] $Prefix,
        [Parameter(Mandatory=$false)] [string] $StartPath,
        [Parameter(Mandatory=$false)] [string] $EndPath,
        [Parameter(Mandatory=$false)] [int] $MaxEntries,
        [Parameter(Mandatory=$false)] [string] $Encoding,
        [Parameter(Mandatory=$false)] [switch] $SlashBoth,
        [Parameter(Mandatory=$false)] [string] $AuthFile = "~/.akamai-cli/.netstorage/auth",
        [Parameter(Mandatory=$false)] [string] $Section = "default"
    )
    
    $Action = 'dir'

    $AdditionalOptions = @{
        'format' = 'sql'
        'prefix' = $Prefix
        'start' = $StartPath
        'end' = $EndPath
        'max_entries' = $MaxEntries
        'encoding' = $Encoding
    }

    if($SlashBoth){
        $AdditionalOptions['slash'] = 'both'
    }

    try {
        $Result = Invoke-AkamaiNSAPIRequest -Path $Path -Action $Action -AdditionalOptions $AdditionalOptions -AuthFile $Authfile -Section $Section
        return $Result.list.file
    }
    catch {
        throw $_
    }
    
}