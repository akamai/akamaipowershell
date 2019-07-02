function Get-NetstorageList {
    Param(
        [Parameter(Mandatory=$true)] [string] $Path,
        [Parameter(Mandatory=$false)] [string] $AuthFile = "~/.akamai-cli/.netstorage/auth",
        [Parameter(Mandatory=$false)] [string] $Section = "default"
    )

    $AdditionalOptions = @{
        'format' = 'sql'
    }

    try {
        $Result = Invoke-AkamaiNSAPIRequest -Path $Path -Action "list" -AdditionalOptions $AdditionalOptions -AuthFile $Authfile -Section $Section
        return $Result.list.file
    }
    catch {
        throw $_
    }
    
}