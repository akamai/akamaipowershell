function Get-OSSlashCharacter {
    switch($PSVersionTable.Platform){
        'Win32NT'   { $Char = '\'}
        'Unix'      { $Char = '/'}
    }

    return $Char
}