function Find-Property
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $PropertyName,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'papi',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/papi/v1/search/find-by-value?accountSwitchKey=$AccountSwitchKey"
    $Body = @{propertyName = $PropertyName}
    $JsonBody = $Body | ConvertTo-Json -Depth 10 

    try {
        $Result = Invoke-AkamaiOPEN -Method POST -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL -Body $JsonBody
        return $Result
    }
    catch {
        throw $_.Exception
    }
}

