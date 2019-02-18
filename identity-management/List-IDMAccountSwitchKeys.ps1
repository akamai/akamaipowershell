function List-IDMAccountSwitchKeys
{
    Param(
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$true)] [string] $SearchString
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $Client = Get-IDMClientByAccessToken -Section $Section
    $OpenIdentityID = $Client.openIdentityId

    $EncodedSearchString = [System.Web.HttpUtility]::UrlEncode($SearchString)
    $ReqURL = "https://" + $Credentials.host + "/identity-management/v1/open-identities/$OpenIdentityID/account-switch-keys?search=$EncodedSearchString"
    $Result = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
    
    return $Result
}

