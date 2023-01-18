function Rename-NetstorageFile {
    Param(
        [Parameter(Mandatory=$true)] [string] $Path,
        [Parameter(Mandatory=$true)] [string] $NewFilename,
        [Parameter(Mandatory=$false)] [string] $AuthFile = "~/.akamai-cli/.netstorage/auth",
        [Parameter(Mandatory=$false)] [string] $Section = "default"
    )

    $Action = 'rename'
    $Body = ''
    $OldFilename = $Path.Substring($Path.LastIndexOf("/")+1)
    $NewPath = $Path.Replace($OldFilename, $NewFilename)
    $EncodedNewPath = [System.Web.HttpUtility]::UrlEncode($NewPath)
    $AdditionalOptions = @{
        'destination' = $EncodedNewPath
    }

    try {
        $Result = Invoke-AkamaiNSAPIRequest -Path $Path -Action $Action -AdditionalOptions $AdditionalOptions -Body $Body -AuthFile $Authfile -Section $Section
        return $Result
    }
    catch {
        throw $_
    }
    
}
