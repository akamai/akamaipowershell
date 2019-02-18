function Get-SiteShieldMapByID
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $SiteShieldID,
        [Parameter(Mandatory=$false)] [string] $Section = 'site-shield',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/siteshield/v1/maps/" + $SiteShieldID
    if($AccountSwitchKey)
    {
        $ReqURL += "?accountSwitchKey=$AccountSwitchKey"
    }

    $Result = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
    return $Result
}

