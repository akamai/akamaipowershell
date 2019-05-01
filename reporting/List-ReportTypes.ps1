function List-ReportTypes
{
    Param(
        [Parameter(Mandatory=$false)] [switch] $ShowDeprecated,
        [Parameter(Mandatory=$false)] [switch] $ShowUnavailable,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -EdgeRCFile $EdgeRCFile -Section $Section
    if(!$Credentials){ return $null }

    # Nullify false switches
    $ShowDeprecatedString = $ShowDeprecated.IsPresent.ToString()
    if(!$ShowDeprecated){ $ShowDeprecatedString = '' }
    $ShowUnavailableString = $ShowUnavailable.IsPresent.ToString()
    if(!$ShowUnavailable){ $ShowUnavailableString = '' }

    $ReqURL = "https://" + $Credentials.host + "/reporting-api/v1/reports?showDeprecated=$ShowDeprecatedString&showUnavailable=$ShowUnavailableString&accountSwitchKey=$AccountSwitchKey"
    
    try {
        $Result = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
        return $Result
    }
    catch {
        throw $_.Exception
    }
}