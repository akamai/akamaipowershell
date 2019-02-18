function Create-CloudletPolicyVersion
{
    Param(
        [Parameter(Mandatory=$true) ] [string] $PolicyID,
        [Parameter(Mandatory=$false)] [string] $Description,
        [Parameter(Mandatory=$false)] [object[]] $MatchRules,
        [Parameter(Mandatory=$false)] [string] $CloneVersion,
        [Parameter(Mandatory=$false)] [switch] $IncludeRules,
        [Parameter(Mandatory=$false)] [string] $MatchRuleFormat = '1.0',
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

    ## Remove unneeded member

    $MatchRules | foreach {
        $_.PsObject.Members.Remove('matchURL')
        $_.PsObject.Members.Remove('location')
    }
    
    $Post = @{ description = $Description; matchRuleFormat = $MatchRuleFormat; matchRules = $MatchRules }
    $PostJson = ConvertTo-Json $Post -Depth 10

    $Result = Invoke-AkamaiOPEN -Method POST -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL -Body $PostJson
    return $Result
}

