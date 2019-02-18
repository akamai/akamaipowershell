function List-CloudletPolicyVersions
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $PolicyID,
        [Parameter(Mandatory=$false)] [string] $CloneVersion,
        [Parameter(Mandatory=$false)] [switch] $IncludeRules,
        [Parameter(Mandatory=$false)] [string] $MatchRuleFormat,
        [Parameter(Mandatory=$false)] [string] $Section = 'cloudlets'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/cloudlets/api/v2/policies/$PolicyID/versions"

    if($psboundparameters.Count -gt 2) { $ReqURL += "?" }
    if($CloneVersion)                  { $ReqURL += "&cloneVersion=$CloneVersion" }
    if($IncludeRules)                  { $ReqURL += "&includeRules=true" }
    if($MatchRuleFormat)               { $ReqURL += "&matchRuleFormat=$MatchRuleFormat" }

    $Result = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
    return $Result
}

