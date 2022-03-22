function Remove-NetstorageDirectory {
    Param(
        [Parameter(Mandatory=$true)] [string] $Path,
        [Parameter(Mandatory=$false)] [switch] $DirectoryIsEmpty,
        [Parameter(Mandatory=$false)] [switch] $ImReallyReallySure,
        [Parameter(Mandatory=$false)] [string] $AuthFile = "~/.akamai-cli/.netstorage/auth",
        [Parameter(Mandatory=$false)] [string] $Section = "default"
    )

    if($DirectoryIsEmpty){
        $Action = 'rmdir'
        $Body = ''
        $AdditionalOptions = @{}
    }

    else{
        if(!$ImReallyReallySure){
            $Sure = Read-Host "This operation will delete the directory $Path with no further confirmation. Are you really, really sure?[y/n]"
            if($Sure.ToLower() -ne "y"){
                Write-Host -ForegroundColor "Red" "Delete cancelled"
                return
            }
        }
    
        $Action = 'quick-delete'
        $Body = ''
        $AdditionalOptions = @{
            'quick-delete' = 'imreallyreallysure'
        }
    }   

    try {
        $Result = Invoke-AkamaiNSAPIRequest -Path $Path -Action $Action -Body $Body -AdditionalOptions $AdditionalOptions -AuthFile $Authfile -Section $Section
        return $Result
    }
    catch {
        throw $_
    }
    
}