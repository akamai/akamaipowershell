function List-AppSecConfigurationVersions
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $ConfigID,
        [Parameter(Mandatory=$false)] [switch] $Detail,
        [Parameter(Mandatory=$false)] [int]    $Page = 1,
        [Parameter(Mandatory=$false)] [int]    $PageSize = 25,
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/appsec/v1/configs/$ConfigID/versions?detail=$Detail&page=$Page&pagSize=$PageSize&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
        return $Result
    }
    catch {
        throw $_.Exception 
    }
}