function List-ReportTypes
{
    Param(
        [Parameter(Mandatory=$false)] [switch] $ShowDeprecated,
        [Parameter(Mandatory=$false)] [switch] $ShowUnavailable,
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/reporting-api/v1/reports?showDeprecated=$ShowDeprecated&showUnavailable=$ShowUnavailable&accountSwitchKey=$AccountSwitchKey"
    
    try {
        $Result = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
        return $Result
    }
    catch {
        return $_
    }
}