function Get-PapiGroups
{
    Param(
        [Parameter(Mandatory=$false)] [switch] $Detail,
        [Parameter(Mandatory=$false)] [string] $Section = 'papi',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/papi/v1/groups"
    if($AccountSwitchKey)
    {
        $ReqURL += "?accountSwitchKey=$AccountSwitchKey"
    }

    $groups = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
    $returnGroup = $groups.groups.items
    
    if($Detail)
    {
        $returnGroup = $groups
    }
    
    return $returnGroup          
}

