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
    $Auth = New-Object -TypeName PSCustomObject
    $SectionFound = $false
    for($i = 0; $i -lt $AuthFileContent.length; $i++){
        $line = $AuthFileContent[$i]
        $SanitisedLine = $line.Replace(" ","")

        if($line.contains("[") -and $line.contains("]")){
            $SectionHeader = $SanitisedLine.Substring($Line.indexOf('[')+1)
            $SectionHeader = $SectionHeader.SubString(0,$SectionHeader.IndexOf(']'))
            if($SectionHeader -eq $Section){
                $SectionFound = $true
            }
        }

        if($SanitisedLine.ToLower().StartsWith('key'))      { $Key = $SanitisedLine.SubString($SanitisedLine.IndexOf("=") + 1) }
        if($SanitisedLine.ToLower().StartsWith('id'))       { $ID = $SanitisedLine.SubString($SanitisedLine.IndexOf("=") + 1) }
        if($SanitisedLine.ToLower().StartsWith('group'))    { $Group = $SanitisedLine.SubString($SanitisedLine.IndexOf("=") + 1) }
        if($SanitisedLine.ToLower().StartsWith('host'))     { $AuthHost = $SanitisedLine.SubString($SanitisedLine.IndexOf("=") + 1) }
        if($SanitisedLine.ToLower().StartsWith('cpcode'))   { $CPCode = $SanitisedLine.SubString($SanitisedLine.IndexOf("=") + 1) }
    }

    # Validate auth contents
    if($SectionFound){
        $Auth | Add-Member -MemberType NoteProperty -Name 'Key' -Value $Key
        $Auth | Add-Member -MemberType NoteProperty -Name 'ID' -Value $ID
        $Auth | Add-Member -MemberType NoteProperty -Name 'Group' -Value $Group
        $Auth | Add-Member -MemberType NoteProperty -Name 'Host' -Value $AuthHost
        $Auth | Add-Member -MemberType NoteProperty -Name 'CPCode' -Value $CPCode
    }
    else{
        throw "Error: Config section [$Section] not found in $AuthFile"
    }

    if($null -eq $Auth.Key -or $null -eq $Auth.ID -or $null -eq $Auth.Group -or $null -eq $Auth.Host -or $null -eq $Auth.CPCOde){
        throw "Error: Some necessary auth elements missing from section $Section. Please check your auth file"
    }

    Write-Debug "Obtained credentials from section '$Section' of auth file $AuthFile"

    return $Auth
}
