function Get-CPCodeDetail
{
    Param(
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey,
        [Parameter(Mandatory=$true)]  [string] $CPCode,
        [Parameter(Mandatory=$false)] [switch] $JSON
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/cprg/v1/cpcodes/$CPCode"
    if($AccountSwitchKey)
    {
        $ReqURL += "?accountSwitchKey=$AccountSwitchKey"
    }

    try {
        $Result = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
        if($JSON)
        {
            return $Result | ConvertTo-Json -Depth 10
        }
        else
        {
            return $Result
        }
    }
    catch {
        return $_
    }
}