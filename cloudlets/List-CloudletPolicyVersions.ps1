function List-CloudletPolicyVersions
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $PolicyID,
        [Parameter(Mandatory=$false)] [string] $CloneVersion,
        [Parameter(Mandatory=$false)] [switch] $IncludeRules,
        [Parameter(Mandatory=$false)] [string] $MatchRuleFormat,
        [Parameter(Mandatory=$false)] [int]    $Offset,
        [Parameter(Mandatory=$false)] [int]    $Pagesize,
        [Parameter(Mandatory=$false)] [string] $Section = 'cloudlets',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/cloudlets/api/v2/policies/$PolicyID/versions?&cloneVersion=$CloneVersion&includeRules=true&matchRuleFormat=$MatchRuleFormat&accountSwitchKey=$AccountSwitchKey"

    if($Offset){ $ReqURL += "&offset=$Offset"}
    if($Pagesize){ $ReqURL += "&pageSize=$PageSize"}

    try {
        $Result = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
        return $Result
    }
    catch {
        return $_
    }
}