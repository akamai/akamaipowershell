function Activate-CloudletPolicyVersion
{
    Param(
        [Parameter(Mandatory=$true)]   [string] $PolicyID,
        [Parameter(Mandatory=$true)]   [string] $Version,
        [Parameter(Mandatory=$false)]  [string] $Network = 'production',
        [Parameter(Mandatory=$false)]  [string] $Section = 'cloudlets',
        [Parameter(Mandatory=$false)]  [string] $AccountSwitchKey
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/cloudlets/api/v2/policies/$PolicyID/versions/$Version/activations?accountSwitchKey=$AccountSwitchKey"

    $Body = @{ network = $Network }
    $JsonBody = $Body | ConvertTo-Json -Depth 100

    try {
        $Result = Invoke-AkamaiOPEN -Method POST -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL -Body $JsonBody
        return $Result
    }
    catch {
        throw $_.Exception
    }
}