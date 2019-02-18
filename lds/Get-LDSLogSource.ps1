function Get-LDSLogSource
{
    Param(
        [Parameter(Mandatory=$false)] [string] $logSourceType = "cpcode-products",
        [Parameter(Mandatory=$true)]  [string] $logSourceId,
        [Parameter(Mandatory=$false)] [string] $Section = 'default'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/lds-api/v3/log-sources/$logSourceType/$logSourceId"
    $Result = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
    return $Result
}

