function Get-OSSlashCharacter {
    if($PSVersionTable.PSVersion.Major -gt 5){
        switch($PSVersionTable.Platform){
            'Win32NT'   { $Char = '\'}
            'Unix'      { $Char = '/'}
        }
    }
    else{
        $Char = '\'
    }
    
    return $Char
}
