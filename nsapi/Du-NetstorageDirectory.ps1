function Du-NetstorageDirectory {
    Param(
        [Parameter(Mandatory=$true)] [string] $Path,
        [Parameter(Mandatory=$false)] [string] $AuthFile,
        [Parameter(Mandatory=$false)] [string] $Section
    )

    $Action = "du"

    $AdditionalOptions = @{
        'format' = 'sql'
    }

    try {
        $Result = Invoke-AkamaiNSAPIRequest -Path $Path -Action $Action -AdditionalOptions $AdditionalOptions -AuthFile $Authfile -Section $Section
        return $Result.du.'du-info'
    }
    catch {
        throw $_
    }
    
}
