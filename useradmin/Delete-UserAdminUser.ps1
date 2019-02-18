function Delete-UserAdminUser
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $ContactID,
        [Parameter(Mandatory=$false)] [string] $Section = 'papi'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/user-admin/v1/users/$ContactID"

    $Result = Invoke-AkamaiOPEN -Method DELETE -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
    return $Result
}

### Cache Control Utility

