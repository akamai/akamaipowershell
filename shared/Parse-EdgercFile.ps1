function Parse-EdgeRCFile{
    Param(
        [Parameter(Mandatory=$true)] [string] $Section,
        [Parameter(Mandatory=$true)] [string] $EdgeRCFile
    )

    # Get credentials from EdgeRC
    if(!(Test-Path $EdgeRCFile)){
        throw "Error: EdgeRCFile $EdgeRCFile not found"
    }
    
    $EdgeRCContent = Get-Content $EdgeRCFile
    $Auth = @{}
    for($i = 0; $i -lt $EdgeRCContent.length; $i++){
        $line = $EdgeRCContent[$i]
        if($line.contains("[") -and $line.contains("]")){
            $SectionHeader = $Line.Substring($Line.indexOf('[')+1)
            $SectionHeader = $SectionHeader.SubString(0,$SectionHeader.IndexOf(']'))
            $Auth[$SectionHeader] = @{}
            $CurrentSection = $SectionHeader
        }

        if($line.ToLower().StartsWith("client_token")) { $Auth[$CurrentSection]['ClientToken'] = $line.Replace(" ","").SubString($line.IndexOf("=")) }
        if($line.ToLower().StartsWith("access_token")) { $Auth[$CurrentSection]['ClientAccessToken'] = $line.Replace(" ","").SubString($line.IndexOf("=")) }
        if($line.ToLower().StartsWith("host"))         { $Auth[$CurrentSection]['Host'] = $line.Replace(" ","").SubString($line.IndexOf("=")) }
        if($line.ToLower().StartsWith("client_secret")){ $Auth[$CurrentSection]['ClientSecret'] = $line.Replace(" ","").SubString($line.IndexOf("=")) }
    }

    # Validate auth contents
    if($null -eq $Auth.$Section){
        throw "Error: Config section [$Section] not found in $EdgeRCFile"
    }
    if($null -eq $Auth.$Section.ClientToken -or $null -eq $Auth.$Section.ClientAccessToken -or $null -eq $Auth.$Section.ClientSecret -or $null -eq $Auth.$Section.Host){
        throw "Error: Some necessary auth elements missing from section $Section. Please check your EdgeRC file"
    }

    # Check actual edgerc entries if debug mode
    $EdgeRCMatch = "^akab-[a-z0-9]{16}-[a-z0-9]{16}"
    if($Auth.$Section.Host -notmatch $EdgeRCMatch){
        Write-Debug "The 'host' attribute in the '$Section' section of your .edgerc file appears to be invalid"
    }
    if($Auth.$Section.ClientToken -notmatch $EdgeRCMatch){
        Write-Debug "The 'client_token' attribute in the '$Section' section of your .edgerc file appears to be invalid"
    }
    if($Auth.$Section.ClientAccessToken -notmatch $EdgeRCMatch){
        Write-Debug "The 'access_token' attribute in the '$Section' section of your .edgerc file appears to be invalid"
    }

    Write-Debug "Obtained credentials from section '$Section' of EdgeRC file $EdgeRCFile"

    return $Auth
}

