function Parse-NSAuthFile{
    Param(
        [Parameter(Mandatory=$true)] [string] $Section,
        [Parameter(Mandatory=$true)] [string] $AuthFile
    )

    # Get credentials from EdgeRC
    if(!(Test-Path $AuthFile)){
        throw "Error: Auth file $AuthFile not found"
    }
    
    $AuthFileContent = Get-Content $AuthFile
    $Auth = @{}
    for($i = 0; $i -lt $AuthFileContent.length; $i++){
        $line = $AuthFileContent[$i]
        $SanitisedLine = $line.Replace(" ","")

        if($line.contains("[") -and $line.contains("]")){
            $SectionHeader = $SanitisedLine.Substring($Line.indexOf('[')+1)
            $SectionHeader = $SectionHeader.SubString(0,$SectionHeader.IndexOf(']'))
            $Auth[$SectionHeader] = @{}
            $CurrentSection = $SectionHeader
        }

        if($SanitisedLine.ToLower().StartsWith('key'))      { $Auth[$CurrentSection]['key'] = $SanitisedLine.SubString($SanitisedLine.IndexOf("=") + 1) }
        if($SanitisedLine.ToLower().StartsWith('id'))       { $Auth[$CurrentSection]['id'] = $SanitisedLine.SubString($SanitisedLine.IndexOf("=") + 1) }
        if($SanitisedLine.ToLower().StartsWith('group'))    { $Auth[$CurrentSection]['group'] = $SanitisedLine.SubString($SanitisedLine.IndexOf("=") + 1) }
        if($SanitisedLine.ToLower().StartsWith('host'))     { $Auth[$CurrentSection]['host'] = $SanitisedLine.SubString($SanitisedLine.IndexOf("=") + 1) }
        if($SanitisedLine.ToLower().StartsWith('cpcode'))   { $Auth[$CurrentSection]['cpcode'] = $SanitisedLine.SubString($SanitisedLine.IndexOf("=") + 1) }
    }

    # Validate auth contents
    if($null -eq $Auth.$Section){
        throw "Error: Config section [$Section] not found in $AuthFile"
    }
    if($null -eq $Auth.$Section.key -or $null -eq $Auth.$Section.id -or $null -eq $Auth.$Section.group -or $null -eq $Auth.$Section.host -or $null -eq $Auth.$Section.cpcode){
        throw "Error: Some necessary auth elements missing from section $Section. Please check your auth file"
    }

    Write-Debug "Obtained credentials from section '$Section' of EdgeRC file $AuthFile"

    return $Auth
}


