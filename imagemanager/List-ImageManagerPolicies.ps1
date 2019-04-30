function List-ImageManagerPolicies
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $PolicySetAPIKey,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'imagemanager',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    if($AccountSwitchKey)
    {
        Write-Host -ForegroundColor Yellow "Image Manager API currently does not support Account Switching. Sorry"
        return
        #?accountSwitchKey=$AccountSwitchKey
    }

    $ReqURL = "https://" + $Credentials.host + "/imaging/v2/policies"
    $AdditionalHeaders = @{ 'Luna-Token' = $PolicySetAPIKey }

    try {
        $Result = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL -AdditionalHeaders $AdditionalHeaders
        return $Result.items
    }
    catch {
        throw $_.Exception
    }
}

