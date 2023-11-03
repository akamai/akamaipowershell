function Remove-NetstorageFile {
    Param(
        [Parameter(Mandatory=$true)] [string] $Path,
        [Parameter(Mandatory=$false)] [string] $AuthFile,
        [Parameter(Mandatory=$false)] [string] $Section
    )

    $Action = "delete"
    $Body = ''

    try {
        $Result = Invoke-AkamaiNSAPIRequest -Path $Path -Action $Action -Body $Body -AuthFile $Authfile -Section $Section
        return $Result
    }
    catch {
        throw $_
    }
    
}
