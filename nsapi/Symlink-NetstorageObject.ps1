function Symlink-NetstorageObject {
    Param(
        [Parameter(Mandatory=$true)] [string] $Path,
        [Parameter(Mandatory=$true)] [string] $TargetPath,
        [Parameter(Mandatory=$false)] [string] $AuthFile,
        [Parameter(Mandatory=$false)] [string] $Section
    )

    $Action = 'symlink'
    $Body = ''
    $EncodedTargetPath = [System.Web.HttpUtility]::UrlEncode($TargetPath)
    $AdditionalOptions = @{
        'target' = $EncodedTargetPath
    }

    try {
        $Result = Invoke-AkamaiNSAPIRequest -Path $Path -Action $Action -AdditionalOptions $AdditionalOptions -Body $Body -AuthFile $Authfile -Section $Section
        return $Result
    }
    catch {
        throw $_
    }
    
}
