function Get-PapiAccountID
{
    Param(
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

    $ReqURL = "https://" + $Credentials.host + "/papi/v1/groups"
    $groups = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
    $AccID = $Groups.accountId.Replace("act_","")
    
    return $AccID          
}

