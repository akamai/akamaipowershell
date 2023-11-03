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
    $Auth = New-Object -TypeName PSCustomObject
    $SectionFound = $false
    for($i = 0; $i -lt $EdgeRCContent.length; $i++){
        $line = $EdgeRCContent[$i]
        $SanitizedLine = $line.Replace(" ","")

        if($SanitizedLine.contains("[") -and $SanitizedLine.contains("]")){
            $SectionHeader = $SanitizedLine.Substring($SanitizedLine.indexOf('[')+1)
            $SectionHeader = $SectionHeader.SubString(0,$SectionHeader.IndexOf(']'))
            if($SectionHeader -eq $Section){
                $SectionFound = $true
            }
        }

        # Skip other sections
        if($SectionHeader -ne $Section){ continue }

        if($SanitizedLine.ToLower().StartsWith("client_token")) { $ClientToken = $SanitizedLine.SubString($SanitizedLine.IndexOf("=") + 1) }
        if($SanitizedLine.ToLower().StartsWith("access_token")) { $ClientAccessToken = $SanitizedLine.SubString($SanitizedLine.IndexOf("=") + 1) }
        if($SanitizedLine.ToLower().StartsWith("host"))         { $EdgeRCHost = $SanitizedLine.SubString($SanitizedLine.IndexOf("=") + 1) }
        if($SanitizedLine.ToLower().StartsWith("client_secret")){ $ClientSecret = $SanitizedLine.SubString($SanitizedLine.IndexOf("=") + 1) }
        if($SanitizedLine.ToLower().StartsWith("account_key")){ $AccountKey = $SanitizedLine.SubString($SanitizedLine.IndexOf("=") + 1) }
    }

    # Validate auth contents
    if($SectionFound){
        $Auth | Add-Member -MemberType NoteProperty -Name 'ClientToken' -Value $ClientToken
        $Auth | Add-Member -MemberType NoteProperty -Name 'ClientAccessToken' -Value $ClientAccessToken
        $Auth | Add-Member -MemberType NoteProperty -Name 'Host' -Value $EdgeRCHost
        $Auth | Add-Member -MemberType NoteProperty -Name 'ClientSecret' -Value $ClientSecret
        $Auth | Add-Member -MemberType NoteProperty -Name 'AccountKey' -Value $AccountKey
    }
    else{
        throw "Error: Config section [$Section] not found in $EdgeRCFile"
    }

    if($null -eq $Auth.ClientToken -or $null -eq $Auth.ClientAccessToken -or $null -eq $Auth.ClientSecret -or $null -eq $Auth.Host){
        throw "Error: Some necessary auth elements missing from section  Please check your EdgeRC file"
    }

    # Check actual edgerc entries if debug mode
    $EdgeRCMatch = "^akab-[a-z0-9]{16}-[a-z0-9]{16}"
    if($Auth.Host -notmatch $EdgeRCMatch){
        Write-Debug "The 'host' attribute in the '$Section' section of your .edgerc file appears to be invalid"
    }
    if($Auth.ClientToken -notmatch $EdgeRCMatch){
        Write-Debug "The 'client_token' attribute in the '$Section' section of your .edgerc file appears to be invalid"
    }
    if($Auth.ClientAccessToken -notmatch $EdgeRCMatch){
        Write-Debug "The 'access_token' attribute in the '$Section' section of your .edgerc file appears to be invalid"
    }

    Write-Debug "Obtained credentials from section '$Section' of EdgeRC file $EdgeRCFile"

    return $Auth
}
