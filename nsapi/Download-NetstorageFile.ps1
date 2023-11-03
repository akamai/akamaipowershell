function Download-NetstorageFile {
    Param(
        [Parameter(Mandatory=$true)] [string] $RemotePath,
        [Parameter(Mandatory=$false)] [string] $LocalPath,
        [Parameter(Mandatory=$false)] [string] $AuthFile,
        [Parameter(Mandatory=$false)] [string] $Section
    )

    $Action = "download"

    if(!$LocalPath){
        $FileName = $RemotePath.Substring($RemotePath.LastIndexOf("/") + 1)
        $LocalPath = ".\$FileName"
    }

    try {
        $Result = Invoke-AkamaiNSAPIRequest -Path $RemotePath -Action $Action -Outputfile $LocalPath -AuthFile $Authfile -Section $Section
        #return $Result
    }
    catch {
        throw $_
    }
    
}
