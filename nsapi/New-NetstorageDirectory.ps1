function New-NetstorageDirectory {
    Param(
        [Parameter(Mandatory=$true)] [string] $Path,
        [Parameter(Mandatory=$false)] [string] $AuthFile,
        [Parameter(Mandatory=$false)] [string] $Section
    )

    $Action = "mkdir"

    try {
        $Result = Invoke-AkamaiNSAPIRequest -Path $Path -Action $Action -AuthFile $Authfile -Section $Section
        return $Result
    }
    catch {
        throw $_
    }
    
}
