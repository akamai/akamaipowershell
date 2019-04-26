function Test-OpenAPI
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $Path,
        [Parameter(Mandatory=$false)] [string] $Method = 'GET',
        [Parameter(Mandatory=$false)] [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'papi',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )


    # Check creds
    $Credentials = Get-AKCredentialsFromRC -EdgeRCFile $EdgeRCFile -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + $Path
    if($AccountSwitchKey)
    {
        if($ReqURL.Contains("?"))
        {
            $ReqURL += "&accountSwitchKey=$AccountSwitchKey"
        }
        else {
            $ReqURL += "?accountSwitchKey=$AccountSwitchKey"
        }
    }

    try {
        if($Body) {
            $Result = Invoke-AkamaiOPEN -Method $Method -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL -Body $Body
        }
        else {
            $Result = Invoke-AkamaiOPEN -Method $Method -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
        }
    }
    catch {
        throw $_
    }

    return $Result
}