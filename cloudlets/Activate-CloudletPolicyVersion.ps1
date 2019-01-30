function Activate-CloudletPolicyVersion
{
    Param(
        [Parameter(Mandatory=$true)]   [string] $PolicyID,
        [Parameter(Mandatory=$true)]   [string] $Version,
        [Parameter(Mandatory=$false)]  [string] $Network = 'production',
        [Parameter(Mandatory=$false)]  [string] $Section = 'cloudlets'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/cloudlets/api/v2/policies/$PolicyID/versions/$Version/activations"
    $Body = @{ network = $Network }
    $JsonBody = $Body | ConvertTo-Json -Depth 100
    $Result = Invoke-AkamaiOPEN -Method POST -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL -Body $JsonBody
    return $Result
}

