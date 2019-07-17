function Upload-NetstorageFile {
    Param(
        [Parameter(Mandatory=$true)] [string] $LocalPath,
        [Parameter(Mandatory=$true)] [string] $RemotePath,
        [Parameter(Mandatory=$false)] [string] $AuthFile = "~/.akamai-cli/.netstorage/auth",
        [Parameter(Mandatory=$false)] [string] $Section = "default"
    )

    $Action = 'upload'
    # Assume if path ends with / we are uploading to a folder and append the filename
    if($RemotePath.EndsWith("/")){
        $File = Get-Item $LocalPath
        $RemotePath += $($File.Name)
    }

    try {
        $Result = Invoke-AkamaiNSAPIRequest -Path $RemotePath -Action $Action -InputFile $LocalPath -AuthFile $Authfile -Section $Section
        return $Result
    }
    catch {
        throw $_
    }
}