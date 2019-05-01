function Delete-CacheByCPCode
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $CPCode,
        [Parameter(Mandatory=$false)] [string] $Network = 'production',
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'ccu',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -EdgeRCFile $EdgeRCFile -Section $Section
    if(!$Credentials){ return $null }

    $PostBody = @{ objects = @("$CPCode") }
    $PostJson = $PostBody | ConvertTo-Json -Depth 100
    $ReqURL = "https://" + $Credentials.host + "/ccu/v3/delete/cpcode/$Network`?accountSwitchKey=$AccountSwitchKey"

    try
    {
        $Result = Invoke-AkamaiOPEN -Method POST -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL -Body $PostJson
        return $Result
    }
    catch
    {
        throw $_.Exception
    }   
}