function Stat-NetstorageObject {
    Param(
        [Parameter(Mandatory=$true)] [string] $Path,
        [Parameter(Mandatory=$false)] [string] $Encoding,
        [Parameter(Mandatory=$false)] [switch] $Implicit,
        [Parameter(Mandatory=$false)] [switch] $SlashBoth,
        [Parameter(Mandatory=$false)] [string] $AuthFile = "~/.akamai-cli/.netstorage/auth",
        [Parameter(Mandatory=$false)] [string] $Section = "default"
    )
    
    $Action = 'stat'

    $AdditionalOptions = @{
        'format' = 'sql'
        'encoding' = $Encoding
    }

    if($Implicit){
        $AdditionalOptions['implicit'] = 'yes'
    }
    if($SlashBoth){
        $AdditionalOptions['slash'] = 'both'
    }

    try {
        $Result = Invoke-AkamaiNSAPIRequest -Path $Path -Action $Action -AdditionalOptions $AdditionalOptions -AuthFile $Authfile -Section $Section
        return $Result.stat.file
    }
    catch {
        throw $_
    }
    
}
