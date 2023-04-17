function Set-NetstorageFileMTime {
    Param(
        [Parameter(Mandatory=$true)] [string] $Path,
        [Parameter(Mandatory=$true)] [string] $mtime,
        [Parameter(Mandatory=$false)] [string] $AuthFile,
        [Parameter(Mandatory=$false)] [string] $Section
    )

    $Action = "mtime"
    $Body = ''
    $AdditionalOptions = @{
        'mtime' = $mtime
    }

    try {
        $Result = Invoke-AkamaiNSAPIRequest -Path $Path -Action $Action -AdditionalOptions $AdditionalOptions -Body $Body -AuthFile $Authfile -Section $Section
        return $Result
    }
    catch {
        throw $_
    }
    
}
