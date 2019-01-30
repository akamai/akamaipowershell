function List-IDMAccountSwitchKeys
{
    Param(
        [Parameter(Mandatory=$false)] [string] $Section = 'papi',
        [Parameter(Mandatory=$true)] [string] $OpenIdentityID,
        [Parameter(Mandatory=$true)] [string] $SearchString
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $EncodedSearchString = [System.Web.HttpUtility]::UrlEncode($SearchString)
    $ReqURL = "https://" + $Credentials.host + "/identity-management/v1/open-identities/$OpenIdentityID/account-switch-keys?search=$EncodedSearchString"
    $Result = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
    
    return $Result
}

